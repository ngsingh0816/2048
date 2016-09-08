/*
 * Original Windows comment:
 * "This code was created by Jeff Molofee 2000
 * A HUGE thanks to Fredric Echols for cleaning up
 * and optimizing the base code, making it more flexible!
 * If you've found this code useful, please let me know.
 * Visit my site at nehe.gamedev.net"
 * 
 * Cocoa port by Bryan Blackburn 2002; www.withay.com
 */

/* GLView.m */

#import "GLView.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "GLString.h"
#import "Tween.h"
#include <vector>
#include "game.h"

#define ANIMATION_TIME	15.0

NSSize resolution = NSMakeSize(500, 500);

int animatingFrames = 0;

int animation = 0;
#define ANIM_ADD		(1 << 0)

// Animations
int newX = -1, newY = -1, newVal = 0;
game* currentGame;

float blockColors[] = {
	0, 0, 0,
	0.933333, 0.894118, 0.858824,	// 2
	0.929412, 0.878431, 0.788235,	// 4
	0.941177, 0.694118, 0.490196,	// 8
	0.952941, 0.584314, 0.407843,	// 16
	0.956863, 0.486275, 0.388235,	// 32
	0.952941, 0.376471, 0.262745,	// 64
	0.925490, 0.807843, 0.470588,	// 128
	0.925490, 0.796079, 0.411765,	// 256
	0.925490, 0.780392, 0.352941,	// 512
	0.925490, 0.768628, 0.298039,	// 1024
	0.925490, 0.756863, 0.250980,	// 2048
};

float textColors[] = {
	0, 0, 0,
	0.466667, 0.431373, 0.392157,	// 2
	0.466667, 0.431373, 0.392157,	// 4
	0.976471, 0.964706, 0.949020,	// 8
	0.976471, 0.964706, 0.949020,	// 16
	0.976471, 0.964706, 0.949020,	// 32
	0.976471, 0.964706, 0.949020,	// 64
	0.976471, 0.964706, 0.949020,	// 128
	0.976471, 0.964706, 0.949020,	// 256
	0.976471, 0.964706, 0.949020,	// 512
	0.976471, 0.964706, 0.949020,	// 1024
	0.976471, 0.964706, 0.949020,	// 2048
};

@interface GLView (InternalMethods)
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame;
- (BOOL) initGL;
@end

@implementation GLView

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
		   depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen
{
	NSOpenGLPixelFormat *pixelFormat;
	
	colorBits = numColorBits;
	depthBits = numDepthBits;
	pixelFormat = [ self createPixelFormat:frame ];
	if( pixelFormat != nil )
	{
		self = [ super initWithFrame:frame pixelFormat:pixelFormat ];
		[ pixelFormat release ];
		if( self )
		{
			[ [ self openGLContext ] makeCurrentContext ];
			[ self reshape ];
			if( ![ self initGL ] )
			{
				[ self clearGLContext ];
				self = nil;
			}
			
			secondTimer = [ [ NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateFPS) userInfo:nil repeats:YES ] retain ];
			
			currentGame = make_game(4, 4);
			[ self addBlock ];
		}
	}
	else
		self = nil;
	
	return self;
}


/*
 * Create a pixel format and possible switch to full screen mode
 */
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame
{
	NSOpenGLPixelFormatAttribute pixelAttribs[ 16 ];
	int pixNum = 0;
	NSOpenGLPixelFormat *pixelFormat;
	
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADoubleBuffer;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAAccelerated;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAColorSize;
	pixelAttribs[ pixNum++ ] = colorBits;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADepthSize;
	pixelAttribs[ pixNum++ ] = depthBits;
	
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAMultisample;
	pixelAttribs[ pixNum++ ] = 1;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFASampleBuffers;
	pixelAttribs[ pixNum++ ] = 1;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFASamples;
	pixelAttribs[ pixNum++ ] = 128;
	
	pixelAttribs[ pixNum ] = 0;
	pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
                   initWithAttributes:pixelAttribs ];
	
	return pixelFormat;
}

/*
 * Initial OpenGL setup
 */
- (BOOL) initGL
{ 
	glShadeModel( GL_SMOOTH );                // Enable smooth shading
	glClearColor( 0.0f, 0.0f, 0.0f, 0.5f );   // Black background
	glClearDepth( 1.0f );                     // Depth buffer setup
	glEnable( GL_DEPTH_TEST );                // Enable depth testing
	glDepthFunc( GL_LEQUAL );                 // Type of depth test to do
	// Really nice perspective calculations
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	return TRUE;
}


/*
 * Resize ourself
 */
- (void) reshape
{ 
	NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	sceneBounds = [ self bounds ];
	resolution = sceneBounds.size;
	// Reset current viewport
	glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height );
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
	// Calculate the aspect ratio of the view
	gluOrtho2D(0, resolution.width , resolution.height, 0);
	//gluPerspective( 45.0f, sceneBounds.size.width / sceneBounds.size.height,
	//             0.1f, 100.0f );
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
}

- (void) addBlock
{
	BOOL empty = FALSE;
	for (int x = 0; x < 4; x++)
	{
		for (int y = 0; y < 4; y++)
		{
			if (*get_cell(currentGame, y, x) == -1)
			{
				empty = TRUE;
				break;
			}
		}
	}
	if (!empty)
	{
		// Game Over
		return;
	}
	
	for (;;)
	{
		int x1 = arc4random() % 4;
		int y1 = arc4random() % 4;
		
		if (*get_cell(currentGame, y1, x1) != -1)
			continue;
		
		*get_cell(currentGame, y1, x1) = ((arc4random() % 100) > 90) ? 4 : 2;
		newX = x1, newY = y1, newVal = *get_cell(currentGame, y1, x1);
		animation |= ANIM_ADD;
		break;
	}
}

- (void) keyDown:(NSEvent *)theEvent
{
	if (animatingFrames != 0)
		return;
	animatingFrames = ANIMATION_TIME;
	combineCoords.clear();
	
	unsigned short key = [ [ theEvent characters ] characterAtIndex:0 ];
	
	if (key == NSUpArrowFunctionKey)
	{
		if (move_w(currentGame))
		{
			[ self addBlock ];
			if (!legal_move_check(currentGame))
			{
				NSAlert* alert = [ [ NSAlert alloc ] init ];
				alert.informativeText = @"You Lose.";
				[ alert addButtonWithTitle:@"Ok" ];
				[ alert runModal ];
			}
		}
		else
			animatingFrames = 0;
	}
	else if (key == NSDownArrowFunctionKey)
	{
		if (move_s(currentGame))
		{
			[ self addBlock ];
			if (!legal_move_check(currentGame))
			{
				NSAlert* alert = [ [ NSAlert alloc ] init ];
				alert.informativeText = @"You Lose.";
				[ alert addButtonWithTitle:@"Ok" ];
				[ alert runModal ];
			}
		}
		else
			animatingFrames = 0;
	}
	else if (key == NSLeftArrowFunctionKey)
	{
		if (move_a(currentGame))
		{
			[ self addBlock ];
			if (!legal_move_check(currentGame))
			{
				NSAlert* alert = [ [ NSAlert alloc ] init ];
				alert.informativeText = @"You Lose.";
				[ alert addButtonWithTitle:@"Ok" ];
				[ alert runModal ];
			}
		}
		else
			animatingFrames = 0;
	}
	else if (key == NSRightArrowFunctionKey)
	{
		if (move_d(currentGame))
		{
			[ self addBlock ];
			if (!legal_move_check(currentGame))
			{
				NSAlert* alert = [ [ NSAlert alloc ] init ];
				alert.informativeText = @"You Lose.";
				[ alert addButtonWithTitle:@"Ok" ];
				[ alert runModal ];
			}
		}
		else
			animatingFrames = 0;
	}
}

- (void) drawRoundedSquare
{
	glBegin(GL_TRIANGLE_FAN);
	
	glVertex2d(0, 0);
	
	float radius = 0.05;
	int slices = 36;
	float centerX = (-0.21 / 2 + radius) * resolution.width;
	float centerY = (-0.21 / 2 + radius) * resolution.height;
	
	for (int z = 0; z <= slices; z++)
	{
		float angle = M_PI * (1 + z / 2.0 / slices);
		glVertex2d(centerX + radius * cos(angle) * resolution.width, centerY + radius * sin(angle) * resolution.height);
	}
	
	centerX = (0.21 / 2 - radius) * resolution.width;
	for (int z = 0; z <= slices; z++)
	{
		float angle = M_PI * (1.5 + z / 2.0 / slices);
		glVertex2d(centerX + radius * cos(angle) * resolution.width, centerY + radius * sin(angle) * resolution.height);
	}
	
	centerY = (0.21 / 2 - radius) * resolution.height;
	for (int z = 0; z <= slices; z++)
	{
		float angle = M_PI * (z / 2.0 / slices);
		glVertex2d(centerX + radius * cos(angle) * resolution.width, centerY + radius * sin(angle) * resolution.height);
	}
	
	centerX = (-0.21 / 2 + radius) * resolution.width;
	for (int z = 0; z <= slices; z++)
	{
		float angle = M_PI * (0.5 + z / 2.0 / slices);
		glVertex2d(centerX + radius * cos(angle) * resolution.width, centerY + radius * sin(angle) * resolution.height);
	}
	
	centerY = (-0.21 / 2 + radius) * resolution.height;
	glVertex2d(centerX - radius * resolution.width, centerY);
	
	glEnd();
}

/*
 * Called when the system thinks we need to draw.
 */
- (void) drawRect:(NSRect)rect
{
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
	// Draw background
	glLoadIdentity();
	glBegin(GL_QUADS);
	{
		glColor4d(0.733333, 0.678431, 0.631373, 1);
		glVertex2d(0, 0);
		glVertex2d(resolution.width, 0);
		glVertex2d(resolution.width, resolution.height);
		glVertex2d(0, resolution.height);
	}
	glEnd();
	
	// Draw 4x4 grid
	glTranslated(resolution.width / 200, resolution.height / 200, 0);
	for (int y = 0; y < 4; y++)
	{
		for (int x = 0; x < 4; x++)
		{
			NSPoint point = NSMakePoint(resolution.width / 100 * 3 * (x + 1) + 0.21 * resolution.width * x + 0.21 * resolution.width / 2, resolution.height / 100 * 3 * (y + 1) + 0.21 * resolution.height * y + 0.21 * resolution.height / 2);
			
			glTranslated(point.x, point.y, 0);
			
			BOOL foundCoord = FALSE;
			if (animation | ANIM_ADD && animatingFrames != 0 && x == newX && y == newY)
			{
				glColor4d(0.803922, 0.756863, 0.709804, 1);
				[ self drawRoundedSquare ];
				glPushMatrix();
				float val = MDTweenEaseOutQuadratic((ANIMATION_TIME - animatingFrames) / ANIMATION_TIME);
				glScaled(val, val, 1);
			}
			else if (animatingFrames != 0 && combineCoords.size() != 0)
			{
				for (int z = 0; z < combineCoords.size(); z++)
				{
					if (combineCoords[z].x == x && combineCoords[z].y == y)
					{
						foundCoord = TRUE;
						break;
					}
				}
				if (foundCoord)
				{
					glColor4d(0.803922, 0.756863, 0.709804, 1);
					[ self drawRoundedSquare ];
					glPushMatrix();
					float val = MDTweenEaseOutElastic((ANIMATION_TIME - animatingFrames) / ANIMATION_TIME);
					glScaled(val, val, 1);
				}
			}

			
			if (*get_cell(currentGame, y, x) == -1)
				glColor4d(0.803922, 0.756863, 0.709804, 1);
			else
			{
				int val = round(log2(*get_cell(currentGame, y, x)));
				glColor4d(blockColors[val * 3], blockColors[val * 3 + 1], blockColors[val * 3 + 2], 1);
			}
			
			[ self drawRoundedSquare ];
			
			if (animation | ANIM_ADD && animatingFrames && x == newX && y == newY)
				glPopMatrix();
			else if (foundCoord)
				glPopMatrix();
			
			glTranslated(-point.x, -point.y, 0);
			
			if (*get_cell(currentGame, y, x) != -1)
			{
				int val = *get_cell(currentGame, y, x);
				unsigned int realValue = val;
				val = round(log2(val));
				
				[ self writeString:[ NSString stringWithFormat:@"%i", realValue ] textColor:[ NSColor colorWithCalibratedRed:textColors[val * 3] green:textColors[val * 3 + 1] blue:textColors[val * 3 + 2] alpha:1 ] boxColor:[ NSColor clearColor ] borderColor:[ NSColor clearColor ] atLocation:point withSize:45 withFontName:@"Helvetica" rotation:0 center:YES ];
			}
		}
	}
	glTranslated(-resolution.width / 200, -resolution.height / 200, 0);
	
	
	[ self writeString:[ NSString stringWithFormat:@"%i", FPS ] textColor:[ NSColor yellowColor ] boxColor:[ NSColor clearColor ] borderColor:[ NSColor clearColor ] atLocation:NSMakePoint(0, 0) withSize:12 withFontName:@"Helvetica" rotation:0 center:NO ];
	
	[ [ self openGLContext ] flushBuffer ];
	
	counterFPS++;
	
	if (animatingFrames != 0)
	{
		animatingFrames--;
		if (animatingFrames == 0)
			animation = 0;
	}
}

- (void) updateFPS
{
	FPS = counterFPS;
	counterFPS = 0;
}

- (void) writeString: (NSString*) str textColor: (NSColor*) text
			boxColor: (NSColor*) box borderColor: (NSColor*) border
		  atLocation: (NSPoint) location withSize: (double) dsize
		withFontName: (NSString*) fontName rotation:(float) rot center:(BOOL)align
{
	// Init string and font
	NSFont* font = [ NSFont fontWithName:fontName size:dsize ];
	if (font == nil)
		return;
	
	GLString* string = [ [ GLString alloc ] initWithString:str withAttributes:[ NSDictionary
	   dictionaryWithObjectsAndKeys:text, NSForegroundColorAttributeName, font,
	   NSFontAttributeName, nil ] withTextColor: text withBoxColor: box withBorderColor: border ];
	
	// Get ready to draw
	int s = 0;
	glGetIntegerv (GL_MATRIX_MODE, &s);
	glMatrixMode (GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity ();
	glMatrixMode (GL_MODELVIEW);
	glPushMatrix();
	
	// Draw
	NSSize internalRes = [ self bounds ].size;
	glLoadIdentity();    // Reset the current modelview matrix
	glScaled(2.0 / internalRes.width, -2.0 / internalRes.height, 1.0);
	glTranslated(-internalRes.width / 2.0, -internalRes.height / 2.0, 0.0);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);	// Make right color
	
	NSSize frameSize = [ string frameSize ];
	glTranslated(location.x + (frameSize.width / 2),
				 location.y + (frameSize.height / 2), 0);
	glRotated(rot, 0, 0, 1);
	glTranslated(-(location.x + (frameSize.width / 2)),
				 -(location.y + (frameSize.height / 2)), 0);
	if (align)
		glTranslated(-frameSize.width / 2, -frameSize.height / 2, 0);
	
	[ string drawAtPoint:location ];
	
	// Reset things
	glPopMatrix(); // GL_MODELVIEW
	glMatrixMode (GL_PROJECTION);
    glPopMatrix();
    glMatrixMode (s);
	
	// Cleanup
	[ string release ];
}

/*
 * Cleanup
 */
- (void) dealloc
{
	if (currentGame)
	{
		destroy_game(currentGame);
		currentGame = NULL;
	}
	if (secondTimer)
		[ secondTimer invalidate ];
	[ super dealloc ];
}

@end
