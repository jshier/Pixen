//
//  PXPreviewController.h
//  Pixen-XCode

// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Andy Matuschak on Wed Jun 09 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.

#import "PXPreviewController.h"
#import "PXCanvas.h"
#import "PXCanvas_Backgrounds.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXBackgrounds.h"
#import "PXBackgroundController.h"
#import "PXDefaults.h"
#import "PXCanvasView.h"
#import "PXCanvasDocument.h"
#import "PXGrid.h"
#import "PXCrosshair.h"
#import "PXPreviewResizeSizeView.h"
#import "PXPreviewBezelView.h"
#import "PXPreviewResizePrompter.h"
#import "PXNotifications.h"

static PXPreviewController *instance = nil;

@interface NSWindow(TitleBarHeight)
- (float)titleBarHeight;
@end

@implementation NSWindow(TitleBarHeight)
- (float)titleBarHeight
{
	return NSHeight([self frame]) - NSHeight([[self contentView] frame]);
}
@end

@implementation PXPreviewController

- (BOOL)hasUsableCanvas
{
	return canvas && !NSEqualSizes([canvas size], NSZeroSize);
}

- (id) init
{
	if(instance) {
		return instance;
	}
	if ( ! ( self = [super initWithWindowNibName:@"PXPreview"] ) ) 
		return nil;
	
	[NSTimer scheduledTimerWithTimeInterval:0.1
									 target:self selector:@selector(shouldRedraw:) 
								   userInfo:nil 
									repeats:YES];
	updateRect = NSZeroRect;
	[[self window] setFrameAutosaveName:@"PXPreviewFrame"];
	resizeSizeWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 60, 27) 
												   styleMask:NSBorderlessWindowMask 
													 backing:NSBackingStoreBuffered 
													   defer:YES];
	
	[resizeSizeWindow setOpaque:NO];
	[resizeSizeWindow setHasShadow:YES];
	[resizeSizeWindow setContentView:[[[PXPreviewResizeSizeView alloc] 
				      initWithFrame:NSMakeRect(0, 0, 60, 27)]
		autorelease]];
	[resizeSizeWindow setLevel:NSPopUpMenuWindowLevel];
	
	NSRect contentFrame = [[[self window] contentView] frame];
	bezelView = [[PXPreviewBezelView alloc] initWithFrame:NSMakeRect(NSWidth(contentFrame) - 18, NSHeight(contentFrame) - 18, 18, 18)];
	[[[self window] contentView] addSubview:bezelView];
	[bezelView setAlphaValue:0.33];
	[bezelView setHidden:YES];
	[bezelView setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
	
	[[NSNotificationCenter defaultCenter]  addObserver:self 
											  selector:@selector(documentClosed:) 
												  name:PXDocumentWillCloseNotificationName
												object:nil];
	
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
	[bezelView setDelegate:self];
	
	backgroundController = [[PXBackgroundController alloc] init];
	[backgroundController setDelegate:self];
	return self;
}

+(id) sharedPreviewController
{	
	if(! instance )
		instance = [[self alloc] init]; 
	
	return instance;
}

- (void)windowWillClose:(NSNotification *) notification
{
	[[NSUserDefaults standardUserDefaults] setBool:NO
											forKey:PXPreviewWindowIsOpenKey];
}

- (void)documentClosed:(NSNotification *)notification
{
	if ([[notification object] canvas] == canvas) {
		[self setCanvas:nil];
	}
}

- (void)mouseEntered:(NSEvent *)event
{
	[bezelFadeTimer invalidate];
	[bezelFadeTimer release];
	bezelFadeTimer = [[NSTimer scheduledTimerWithTimeInterval:.01
													   target:self
													 selector:@selector(fadeBezel:) 
													 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSNumber numberWithFloat:.41], PXFadeOpacityKey,
														 [NSNumber numberWithBool:YES], PXFadeDirectionKey, nil]
													  repeats:NO] retain];
}

- (void)mouseExited:(NSEvent *)event
{
	[bezelFadeTimer invalidate];
	[bezelFadeTimer release];
	bezelFadeTimer = [[NSTimer scheduledTimerWithTimeInterval:.01
													   target:self
													 selector:@selector(fadeBezel:) 
													 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSNumber numberWithFloat:[bezelView alphaValue]-.04], PXFadeOpacityKey,
														 [NSNumber numberWithBool:NO], PXFadeDirectionKey, nil]
													  repeats:NO] retain];
	
}

- (void)dealloc
{
	[fadeOutTimer invalidate];
	[fadeOutTimer dealloc];
	
	[bezelFadeTimer invalidate];
	[bezelFadeTimer dealloc];
	
	[resizeSizeWindow release];
	[bezelView release];
	[[NSUserDefaults standardUserDefaults] setBool:[[self window] isVisible] forKey:PXPreviewWindowIsOpenKey];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

// the timer exists to limit the preview window to
// redrawing a maximum of 20 times a second.
- (void)shouldRedraw:timer
{
	if(NSIsEmptyRect(updateRect)) 
    {
		return; 
    }
	if([[self window] isVisible])
    {
		[view setNeedsDisplayInCanvasRect:updateRect];
		[bezelView setNeedsDisplay:YES];
		updateRect = NSZeroRect;
    }
}

- (void)updateTrackingRectAssumingInside:(BOOL)inside
{
	[self mouseExited:nil];
	NSRect trackingFrame = [[[self window] contentView] frame];
	if (trackingTag != -1) { [view removeTrackingRect:trackingTag]; }
	trackingTag = [[[self window] contentView] addTrackingRect:trackingFrame owner:self userData:nil assumeInside:inside];
}

- (void)windowDidLoad
{
	[[self window] setBackgroundColor:[NSColor lightGrayColor]];
	[view setCrosshair:nil];
	[view setShouldDrawSelectionMarquee:NO];
	[view setDelegate:bezelView]; // for mouse up
	[view setShouldDrawToolBeziers:NO];
	[view setShouldDrawGrid:NO];
	[view setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
}

- (void)updateViewPercentage
{
	if ([canvas size].height > 0 && [canvas size].width > 0) {
		float ratio = MIN(NSHeight([view frame]) / [canvas size].height,
						  NSWidth([view frame]) / [canvas size].width);
		if (ratio != 0) {
			[view setZoomPercentage:MIN(ratio, 100) * 100.0f];
		}
	}
}

- (NSSize)properWindowSizeForCanvasSize:(NSSize)size
{
	NSSize newSize = [[[self window] contentView] frame].size;
	if (size.width > 64)
    {
		newSize.width = size.width;
    }
	else
    {
		newSize.width = 64;
    }
	if (size.height > 64)
    {
		newSize.height = size.height;
    }
	else
    {
		newSize.height = 64;
    }
	return newSize;
}

- (void)liveResize
{
	if (![[self window] isVisible]) {
		return;
	}
	NSSize newSize;
	if (NSEqualSizes([canvas previewSize], NSZeroSize))
		newSize = NSMakeSize(64, 64);
	else
		newSize = [self properWindowSizeForCanvasSize:[canvas previewSize]];
	NSRect newFrame = [[self window] frame];
	newFrame.size = newSize;
	if(!NSEqualSizes(newFrame.size, [[[self window] contentView] frame].size))
	{
		liveResizing = YES;
		NSRect windowFrame = [[self window] frame];
		NSRect contentFrame = [[[self window] contentView] frame];
		newFrame.size.height += NSHeight(windowFrame) - NSHeight(contentFrame);
		[[self window] setFrame:newFrame display:YES animate:YES];
	}
	[view setFrameSize:canvas ? [canvas previewSize] : NSZeroSize];
	[self centerContent];
}

- (void)sizeToCanvas
{
	if(![self hasUsableCanvas]) { return; }
	[self setCanvasSize:[canvas previewSize]];
}

- (void)setCanvasSize:(NSSize)size
{
	if(![self hasUsableCanvas]) { return; }
	NSPoint topLeft = [[self window] frame].origin;
	topLeft.y += NSHeight([[self window] frame]);		
	[[self window] setFrameTopLeftPoint:topLeft];
	[view setFrameSize:size];
	[self updateViewPercentage];
	updateRect = NSMakeRect(0, 0, size.width, size.height);
	[[[self window] contentView] setNeedsDisplay:YES];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	sender = nil;
	if(![self hasUsableCanvas]) { return [[self window] frame].size; }
	
	float titleBarSize = [[self window] titleBarHeight]; 
	// We need to find the projection of the size delta vector on the aspect ratio's vector.
	// First construct a vector to represent the aspect ratio.
	float ratio = [canvas size].width / [canvas size].height;
	float aspectX = 1, aspectY = 1;
	if ([canvas size].width > [canvas size].height)
		aspectX = 1 * ratio;
	else
		aspectY = 1 * (1 / ratio);
	// Now construct the vector created by the difference of the window sizes.
	float deltaX = proposedFrameSize.width - NSWidth([[self window] frame]);
	float deltaY = proposedFrameSize.height - NSHeight([[self window] frame]);
	// Now we need the magnitude of the aspect vector
	float aspectMagnitude = sqrt(aspectX*aspectX + aspectY*aspectY);
	// The formula for the scalar projection is a (dot) b / |a| where a is the aspect vector,
	// b is the delta vector, (dot) is dot product, and |a| is the magnitude of a.
	float scalarProjection = ((aspectX * deltaX) + (aspectY * deltaY)) / aspectMagnitude;
	// Now that we have a scalar projection, we need to find the vector projection by
	// multiplying the scalar projection by the unit vector of the aspect vector.
	// The unit vector is a / |a|.
	float projectedX = scalarProjection * (aspectX / aspectMagnitude);
	float projectedY = scalarProjection * (aspectY / aspectMagnitude);
	// Take care of normal resizing
	if(!([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSShiftKeyMask))
    {
		// Add our newly-constructed projected vector onto the preview view's size and find the
		// appropriate window size to fit it.
		NSSize newSize = NSMakeSize(NSWidth([view frame]) + projectedX, NSHeight([view frame]) + projectedY);
		sizingFactor = NSMakeSize(newSize.width / NSWidth([view frame]), newSize.height / NSHeight([view frame]));
		newSize = [self properWindowSizeForCanvasSize:newSize];
		newSize.width = MAX(newSize.width, 64);
		newSize.height = MAX(newSize.height + titleBarSize, 64 + titleBarSize);
		
		// If the window sizes are the same, we're probably doing a fancy in-window resize, so call it anyway.
		if (NSEqualSizes(newSize, [[self window] frame].size))
			[self windowDidResize:nil];
		
		return newSize;
    }
	
	// Shift key must be down--do locking.
	
	// The projected vector's already locked to the aspect ratio, so just worry about x.	
	float aspectRatio = NSWidth([view frame]) / [canvas size].width;
	float lastRatio, nextRatio;
	
	// Floorf the ratio to get the nearest equal or smaller locked size (2.5 -> 2; 3 -> 3)
	if (aspectRatio >= 1)
	{
		lastRatio = floorf(aspectRatio);
		if (projectedX < 0)
			lastRatio--;
		nextRatio = lastRatio + 1;
		if (lastRatio == 0)
			lastRatio = 0.5;
	}
	else
	{
		// If the aspect ratio is < 1 (ie: doing fancy in-window sizing), we have to instead
		// lock the ratios to members of the harmonic series. These fancy repricocals take care of that.
		lastRatio = 1 / (floorf(1/aspectRatio) + ((projectedX > 0) ? 0 : 1));
		nextRatio = 1 / ((1 / lastRatio) - 1);
	}
	
	// Get widths based on this
	float lastWidth = [canvas size].width * lastRatio;
	float nextWidth = [canvas size].width * nextRatio;
	float widthDifference = nextWidth - lastWidth;
	
	// If we take the quotient of the projected component and the width difference, we get
	// a fraction saying how much of the distance has been covered by the mouse. Floorf
	// this and add to the last ratio to get the new ratio.
	projectedX *= 2;
	float newRatio;
	if (projectedX > 0)
		newRatio = floorf(projectedX / widthDifference) ? nextRatio : lastRatio;
	else
		newRatio = floorf((projectedX * -1) / widthDifference) ? lastRatio : nextRatio;
	sizingFactor = NSMakeSize(newRatio / aspectRatio, newRatio / aspectRatio);
	NSSize newSize = NSMakeSize([canvas size].width * newRatio, [canvas size].height * newRatio);
	newSize = [self properWindowSizeForCanvasSize:newSize];
	newSize.height += titleBarSize;
	// in-window resize, so call windowDidResize anyway.
	if (NSEqualSizes(newSize, [[self window] frame].size) && newRatio != aspectRatio)
		[self windowDidResize:nil];
	return newSize;	
}

- (void)updateResizeSizeViewScale
{
	if(![self hasUsableCanvas] || ![[self window] isVisible]) 
    {
		return;
    }
	
	if (![[resizeSizeWindow contentView] updateScale:[view zoomPercentage]/100]) {
		return;
	}
	
	[resizeSizeWindow setContentSize:[[resizeSizeWindow contentView] scaleStringSize]];
	
	NSPoint newOrigin = [[self window] frame].origin;
	newOrigin.x += NSWidth([[self window] frame]);
	newOrigin.y -= NSHeight([resizeSizeWindow frame]);
	[resizeSizeWindow setFrameOrigin:newOrigin];
	
	float initialAlpha = 0.75;
	[resizeSizeWindow setAlphaValue:initialAlpha];
	[resizeSizeWindow orderFront:self];
	
	[fadeOutTimer invalidate];
	[fadeOutTimer release];
	fadeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:1
													 target:self 
												   selector:@selector(fadeOutSize:)
												   userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:initialAlpha] forKey:PXFadeOpacityKey] repeats:NO] retain];
	
}

- (void)fadeBezel:(NSTimer *)timer
{
	NSDictionary *dict = [timer userInfo];
	float alphaValue = [[dict objectForKey:PXFadeOpacityKey] floatValue];
	[bezelView setAlphaValue:MAX(alphaValue, 0.33)];
	BOOL fadingIn = [[dict objectForKey:PXFadeDirectionKey] boolValue];
	[bezelFadeTimer invalidate];
	[bezelFadeTimer release];
	if (fadingIn)
	{
		if (alphaValue < 0.75)
		{
			bezelFadeTimer = [[NSTimer scheduledTimerWithTimeInterval:.01
															   target:self
															 selector:@selector(fadeBezel:) 
															 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																 [NSNumber numberWithFloat:alphaValue+.08], PXFadeOpacityKey,
																 [NSNumber numberWithBool:YES], PXFadeDirectionKey, nil]
															  repeats:NO] retain];
		}
		else
		{
			bezelFadeTimer = nil;
		}
	}
	else
	{
		if (alphaValue > 0.33)
		{
			bezelFadeTimer = [[NSTimer scheduledTimerWithTimeInterval:.01
															   target:self
															 selector:@selector(fadeBezel:) 
															 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																 [NSNumber numberWithFloat:alphaValue-.04], PXFadeOpacityKey,
																 [NSNumber numberWithBool:NO], PXFadeDirectionKey, nil]
															  repeats:NO] retain];			
		}
		else
		{
			bezelFadeTimer = nil;
		}
	}
	[bezelView setNeedsDisplay:YES];
}

- (void)fadeOutSize:(NSTimer *)timer
{
	NSDictionary *dict = [timer userInfo];
	float alphaValue = [[dict objectForKey:PXFadeOpacityKey] floatValue];
	[resizeSizeWindow setAlphaValue:alphaValue];
	[fadeOutTimer invalidate];
	[fadeOutTimer release];
	if (alphaValue > 0) 
    {
		fadeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:.01
														 target:self
													   selector:@selector(fadeOutSize:) 
													   userInfo:[NSDictionary dictionaryWithObject:
												  [NSNumber numberWithFloat:alphaValue-.01] forKey:PXFadeOpacityKey] repeats:NO] retain];
	} 
	else 
    {
		fadeOutTimer = nil;
    }
}

- (void)centerContent
{
	NSSize windowSize = [[[self window] contentView] frame].size;
	NSSize contentSize = [view frame].size;
	NSPoint newOrigin;
	newOrigin.x = (windowSize.width - contentSize.width) / 2;
	newOrigin.y = (windowSize.height - contentSize.height) / 2;
	[view setFrameOrigin:newOrigin];
	[[[self window] contentView] display];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	if([self hasUsableCanvas]) {
		if(liveResizing) {
			NSSize windowSize = [[[self window] contentView] frame].size;
			NSSize finalCanvasSize = [canvas previewSize];
			NSSize finalWindowSize = [self properWindowSizeForCanvasSize:finalCanvasSize];
			NSPoint canvasToWindowRatio = NSMakePoint(1,1);
			if (finalCanvasSize.width < 64) {
				canvasToWindowRatio.x = finalCanvasSize.width / finalWindowSize.width;
			}
			if (finalCanvasSize.height < 64) {
				canvasToWindowRatio.y = finalCanvasSize.height / finalWindowSize.height;
			}
			
			[self setCanvasSize:NSMakeSize(canvasToWindowRatio.x * windowSize.width, canvasToWindowRatio.y * windowSize.height)];
			if(NSEqualSizes([view frame].size, finalCanvasSize))
			{
				[view resetCursorRects];
				liveResizing = NO;
			}
		} else {
			NSSize newSize;
			float titleBarSize = [[self window] titleBarHeight];
			// If the view's frame is smaller than the window's frame in both dimensions, do
			// the fancy in-window resizing.
			if ((NSWidth([view frame]) <= NSWidth([[self window] frame])) && (NSHeight([view frame]) <= (NSHeight([[self window] frame]) - titleBarSize)))
			{
				newSize = [view frame].size;
				
				// These lines are crazy. Basically, they do a bunch of bounding. First, we determine
				// the minimum view size: take the canvas's size in that dimension, half it. Then
				// bound that size to [1, 64]. That's as small as the view's new size is allowed to get.
				newSize.width = MAX(newSize.width * sizingFactor.width, MAX(floorf(MIN([canvas size].width / 2, 64)), 1));
				newSize.height = MAX(newSize.height * sizingFactor.height, MAX(floorf(MIN([canvas size].height / 2, 64)), 1));
			}
			else
				newSize = [[[self window] contentView] frame].size;
			[canvas setPreviewSize:newSize];
			[self sizeToCanvas];
		}
		[self centerContent];
		[self updateResizeSizeViewScale];
		[self updateTrackingRectAssumingInside:NO];
	}
}

- (void)initializeWindow
{
	[view setCanvas:canvas];
	[view setDrawsWrappedCanvases:NO];
	[view setShouldDrawGrid:NO];
	[self updateTrackingRectAssumingInside:NO];
	[view resetCursorRects];
}

- (IBAction)showWindow:(id) sender
{
	[super showWindow:sender];
	[self initializeWindow];
	[self sizeToCanvas];
	[self centerContent];
	[self updateTrackingRectAssumingInside:NO];
	[view setNeedsDisplay:YES];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:PXPreviewWindowIsOpenKey];
}

- (void)setCanvas:(PXCanvas *) aCanvas
{
	//we have to do all this no matter what so there aren't inconsistency-bugs
	[view setCanvas:nil];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self 
				  name:PXCanvasChangedNotificationName 
				object:canvas];
	id oldCanvas = canvas;
	canvas = aCanvas;
	if (aCanvas == nil) 
    {
		[bezelView setHidden:YES];
    } 
	else 
    {
		[bezelView setHidden:NO];
		[nc addObserver:self 
			   selector:@selector(canvasDidChange:) 
				   name:PXCanvasChangedNotificationName 
				 object:canvas];
    }
	
	[self initializeWindow];
	[self liveResize];
	[self updateViewPercentage];
	if (canvas != oldCanvas) {
		[self updateResizeSizeViewScale];
	}
	[self updateTrackingRectAssumingInside:NO];
	[self centerContent];
	updateRect = NSMakeRect(0, 0, [canvas size].width, [canvas size].height);
}

- (void)canvasDidChange:(NSNotification *)aNotification
{
	if([[self window] isVisible])
    {
		updateRect = NSUnionRect(updateRect, [[[aNotification userInfo] objectForKey:PXChangedRectKey] rectValue]);
    }
}

- (void)sizeToActual:sender
{
	if(![self hasUsableCanvas]) { return; }
	NSSize canvasSize = [canvas size];
	if(canvasSize.width <= 0 || canvasSize.height <= 0)
	{
		return;
	}
	NSSize previewSize;
	if (canvasSize.width > 1024 || canvasSize.height > 1024)
	{
		if (canvasSize.width > canvasSize.height)
		{
			previewSize.width = 1024;
			previewSize.height = canvasSize.height * (1024 / canvasSize.width);
		}
		else
		{
			previewSize.height = 1024;
			previewSize.width = canvasSize.width * (1024 / canvasSize.height);
		}
	}
	else
	{	
		previewSize = canvasSize;
	}
	[canvas setPreviewSize:previewSize];
	[self setCanvasSize:previewSize];
	[self liveResize];
	[self updateResizeSizeViewScale];
}

- (void)sizeTo:sender
{
	if(![self hasUsableCanvas]) { return; }
	PXPreviewResizePrompter * prompter = [[PXPreviewResizePrompter alloc] init];
	[prompter promptInWindow:[self window]];
	[prompter setDelegate:self];
	[prompter setCanvasSize:[canvas size]];
	[prompter setZoomFactor:[view zoomPercentage] / 100];
}

- (void)prompter:(PXPreviewResizePrompter *)prompter didFinishWithZoomFactor:(float)factor
{
	NSSize previewSize = NSMakeSize([canvas size].width * factor, [canvas size].height * factor);
	[canvas setPreviewSize:previewSize];
	[self setCanvasSize:previewSize];
	[self liveResize];
	[self updateResizeSizeViewScale];
}

- (void)setBackground:sender
{
	[backgroundController setPreviewImage:[canvas displayImage]];
	[[backgroundController window] setTitle:NSLocalizedString(@"Backgrounds - Preview", @"Backgrounds - Preview")];
	[backgroundController showWindow:self];
	[backgroundController reloadData];
}

// backgrounds delegate stuff

- (void)backgroundChanged:(id)changed
{
	[view resetCursorRects];
	[[[self window] contentView] setNeedsDisplay:YES];
}

- (PXBackground *)mainBackground
{
	return [canvas mainPreviewBackground];
}

- (PXBackground *)alternateBackground
{
	return [canvas alternatePreviewBackground];
}

- (void)setMainBackground:(PXBackground *) aBackground
{
	[canvas setMainPreviewBackground:aBackground];
	[view resetCursorRects];
	[view display];
}

- (void)setAlternateBackground:(PXBackground *) aBackground
{
	[canvas setAlternatePreviewBackground:aBackground];
	[view resetCursorRects];
	[view display];
}

- (PXBackground *)defaultMainBackground
{
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:PXPreviewDefaultMainBackgroundKey];
	return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

- (void)setDefaultMainBackground:(PXBackground *)bg
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:bg] forKey:PXPreviewDefaultMainBackgroundKey];
}

- (PXBackground *)defaultAlternateBackground
{
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:PXPreviewDefaultAlternateBackgroundKey];
	return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

- (void)setDefaultAlternateBackground:(PXBackground *)bg
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:bg] forKey:PXPreviewDefaultAlternateBackgroundKey];
}

@end