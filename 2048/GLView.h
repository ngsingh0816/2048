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

/* GLView.h */

#import <Cocoa/Cocoa.h>

@interface GLView : NSOpenGLView
{
	int colorBits, depthBits;
	
	NSTimer* secondTimer;
	int counterFPS;
	int FPS;
}

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
		   depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen;
- (void) reshape;
- (void) drawRect:(NSRect)rect;
- (void) updateFPS;
- (void) writeString: (NSString*) str textColor: (NSColor*) text
			boxColor: (NSColor*) box borderColor: (NSColor*) border
		  atLocation: (NSPoint) location withSize: (double) dsize
		withFontName: (NSString*) fontName rotation:(float) rot center:(BOOL)align;
- (void) dealloc;

@end
