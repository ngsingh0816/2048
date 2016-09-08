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

/* Controller.m */

#import "Controller.h"

@interface Controller (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
- (void) createFailed;
@end

@implementation Controller

- (void) awakeFromNib
{  
	[ (NSApplication*)NSApp setDelegate:(id<NSApplicationDelegate>)self ];   // We want delegate notifications
	renderTimer = nil;
	[ glWindow makeFirstResponder:self ];
	glView = [ [ GLView alloc ] initWithFrame:[ glWindow frame ]
									colorBits:16 depthBits:16 fullscreen:FALSE ];
	if( glView != nil )
	{
		[ glWindow setContentView:glView ];
		[ glWindow makeKeyAndOrderFront:self ];
		[ glWindow makeFirstResponder:glView ];
		[ self setupRenderTimer ];
	}
	else
		[ self createFailed ];
}  


/*
 * Setup timer to update the OpenGL view.
 */
- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = 0.005;
	
	renderTimer = [ [ NSTimer scheduledTimerWithTimeInterval:timeInterval
													  target:self
													selector:@selector( updateGLView: )
													userInfo:nil repeats:YES ] retain ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSEventTrackingRunLoopMode ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSModalPanelRunLoopMode ];
}


/*
 * Called by the rendering timer.
 */
- (void) updateGLView:(NSTimer *)timer
{
	if( glView != nil )
		[ glView drawRect:[ glView frame ] ];
}  


/*
 * Handle key presses
 */
- (void) keyDown:(NSEvent *)theEvent
{
	unichar unicodeKey;
	
	unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
	switch( unicodeKey )
	{
			// Handle key presses here
	}
}


/*
 * Called if we fail to create a valid OpenGL view
 */
- (void) createFailed
{
	NSWindow *infoWindow;
	
	infoWindow = NSGetCriticalAlertPanel( @"Initialization failed",
                                         @"Failed to initialize OpenGL",
                                         @"OK", nil, nil );
	[ NSApp runModalForWindow:infoWindow ];
	[ infoWindow close ];
	[ NSApp terminate:self ];
}


/* 
 * Cleanup
 */
- (void) dealloc
{
	[ glWindow release ]; 
	[ glView release ];
	if( renderTimer != nil && [ renderTimer isValid ] )
		[ renderTimer invalidate ];
	[ super dealloc ];
}

@end
