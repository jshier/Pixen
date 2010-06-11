//
//  PXCanvasController.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvasController.h"
#import "PXDocumentController.h"
#import "PXImageSizePrompter.h"
#import "PXBackgroundController.h"
#import "PXPreviewController.h"
#import "PXToolPaletteController.h"
#import "PXInfoPanelController.h"
#import "PXCanvas.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "SBCenteringClipView.h"
#import "PXCanvasView.h"
#import "PXTool.h"
#import "PXCanvasDocument.h"
#import "PXPattern.h"
#import "PXGridSettingsPrompter.h"
#import "PXGrid.h"
#import "PXToolSwitcher.h"
#import "TabletEvents.h"

@implementation PXCanvasController

- view
{
	return view;
}

- (void)awakeFromNib
{
	[self setLastDrawnPoint:NSMakePoint(-1, -1)];
	prompter = [[PXImageSizePrompter alloc] init];
	backgroundController = [[PXBackgroundController alloc] init];
	[backgroundController setDelegate:self];
	previewController = [PXPreviewController sharedPreviewController];
	//this exists to fix a bug relating to autosave frames and scrollers appearing
	[view setFrame:NSMakeRect(1, 1, 1, 1)];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(canvasSizeDidChange:) 
												 name:PXCanvasSizeChangedNotificationName 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(toolSwitched:) 
												 name:PXToolDidChangeNotificationName
											   object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[canvas deselect];
	[backgroundController close];
	[backgroundController release];

	if([[prompter window] isVisible]) 
	{
		[prompter close]; 
	}
	[prompter release];
	[super dealloc];
}

- (void)layerSelectionDidChange:(NSNotification *) aNotification
{
	[canvas activateLayer:[[aNotification userInfo] objectForKey:PXLayerKey]];
}

- (void)setLayerController:contro
{
	layerController = contro;
	[layerController setCanvas:canvas];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self 
		   selector:@selector(layerSelectionDidChange:) 
			   name:PXLayerSelectionDidChangeName 
			 object:layerController];
	
	if ([[canvas layers] count] > 1)
		[layerController toggle:self];
	[nc postNotificationName:PXCanvasLayersChangedNotificationName
					  object:canvas];
}

- (void)prepare
{
	[view setDelegate:self];
	
	// Programmatically create our scrollview and canvas view
	id clip = [[[SBCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]] autorelease];
	[clip setBackgroundColor:[NSColor lightGrayColor]];
	[clip setCopiesOnScroll:NO];
	
	[(NSScrollView *)scrollView setContentView:clip];
	[scrollView setDocumentView:view];
	[view setCanvas:canvas];
	[layerController setCanvas:canvas];
}

- (void)gridSettingsPrompter:aPrompter 
			 updatedWithSize:(NSSize)aSize
					   color:color
				  shouldDraw:(BOOL)shouldDraw
{
	PXGrid *grid = [canvas grid];
	[grid setUnitSize:aSize];
	[grid setColor:color];
	[grid setShouldDraw:shouldDraw];
	[canvas changed];
}

- (void)toolSwitched:(NSNotification *)notification
{
	if (![[NSDocumentController sharedDocumentController] showsToolPreview]) { return; }
	NSPoint currentPoint = [view convertFromViewToCanvasPoint:[view convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil]];
	[[[notification userInfo] objectForKey:PXNewToolKey] mouseMovedTo:currentPoint fromCanvasController:self];
	[view setNeedsDisplayInRect:[view visibleRect]];
}

- (void)canvasSizeDidChange:(NSNotification *) aNotification
{
	[[PXInfoPanelController sharedInfoPanelController] setCanvasSize:[canvas size]];
	[view sizeToCanvas];
	[self updatePreview];
}

- (PXCanvas *) canvas
{
	return canvas;
}

- (void)setColor:(NSColor *) aColor
{
	[[PXToolPaletteController sharedToolPaletteController] setColor:aColor];
}

- (void)promptForImageSize
{
	[prompter setDelegate:self];
	[prompter promptInWindow:[self window]];
}

- (void)prompterDidCancel:aPrompter
{
	[[[[[self document] windowControllers] lastObject] window] performClose:self];
}

- (void)prompter:aPrompter didFinishWithSize:(NSSize)aSize backgroundColor:(NSColor *)bg
{
	[delegate canvasController:self setSize:aSize backgroundColor:bg];
	[self updateCanvasSize];
}

- (void)setCanvas:(PXCanvas *)canv
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
				  name:PXCanvasChangedNotificationName 
				object:canvas];
	
	canvas = canv;
	if(canvas)
	{
		if(NSEqualSizes([canvas size], NSZeroSize))
		{
			[self promptForImageSize];
		}
		[canvas setWraps:wraps];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
			   selector:@selector(canvasDidChange:)
				   name:PXCanvasChangedNotificationName 
				 object:canvas];
	}
	[view setCanvas:canvas];
	[layerController setCanvas:canvas];
	if(canvas)
	{
		[[PXInfoPanelController sharedInfoPanelController] setCanvasSize:[canvas size]];
		[canvas changed];	
		[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasLayersChangedNotificationName 
															object:canvas];
	}
}

- (void)canvasDidChange:(NSNotification *) aNotification
{
	NSRect rect= [[[aNotification userInfo] objectForKey:PXChangedRectKey] rectValue];
	if(![[aNotification userInfo] objectForKey:PXChangedRectKey])
	{
		[view setNeedsDisplay:YES];
	}
	else
	{
		[view setNeedsDisplayInCanvasRect:rect];
	}
}

- (void)activate
{
	PXTool *currentTool = [[PXToolPaletteController sharedToolPaletteController] currentTool];
	if (!currentTool) { currentTool = [[PXToolPaletteController sharedToolPaletteController] leftTool]; }
	if (![[currentTool path] isEmpty])
		[view setNeedsDisplayInCanvasRect:[[currentTool path] bounds]];
	[self mouseMoved:nil];
	
	// we turn off all the other documents' acceptance of first mouse; we can't do
	// this on windowDidResignMain because that'd cause problems with panels
//FIXME: refactor to nix dependency on PXCanvasDocument
	for (PXCanvasDocument *doc in [[NSDocumentController sharedDocumentController] documents])
	{
		if ([doc canvasController] == self)
			// if we don't have a slight delay, the click that activates the window goes through. a bit of a hack.
			[[self view] performSelector:@selector(setAcceptsFirstMouse:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.01];
		else
			[[[doc canvasController] view] setAcceptsFirstMouse:NO];
	}	
}

- (void)deactivate
{
	PXTool *currentTool = [[PXToolPaletteController sharedToolPaletteController] currentTool];
	if (!currentTool) { currentTool = [[PXToolPaletteController sharedToolPaletteController] leftTool]; }
	if (![[currentTool path] isEmpty])
		[view setNeedsDisplayInCanvasRect:[[currentTool path] bounds]];
	if ([[view crosshair] shouldDraw])
		[view setNeedsDisplayInRect:[view visibleRect]];
}

- (void)updatePreview
{
	[canvas updatePreviewSize];
	[previewController setCanvas:canvas];
	[previewController window];
}

- mainBackground
{
	return [canvas mainBackground];
}

- alternateBackground
{
	return [canvas alternateBackground];
}

- (void)setMainBackground:(id) aBackground
{
	[canvas setMainBackground:aBackground];
	[view resetCursorRects];
	[view setNeedsDisplayInRect:[view visibleRect]];
}

- (void)setAlternateBackground:(id) aBackground
{
	[canvas setAlternateBackground:aBackground];
	[view setNeedsDisplayInRect:[view visibleRect]];
	[view resetCursorRects];
}

- (PXBackground *)defaultMainBackground
{
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:PXCanvasDefaultMainBackgroundKey];
	return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

- (void)setDefaultMainBackground:(PXBackground *)bg
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:bg] forKey:PXCanvasDefaultMainBackgroundKey];
}

- (PXBackground *)defaultAlternateBackground
{
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:PXCanvasDefaultAlternateBackgroundKey];
	return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

- (void)setDefaultAlternateBackground:(PXBackground *)bg
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:bg] forKey:PXCanvasDefaultAlternateBackgroundKey];
}

- (void)toggleShouldTile
{
	BOOL newWraps = ![canvas wraps];
	[canvas setWraps:newWraps];
	if (newWraps)
		[view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	else
		[view setAutoresizingMask:NSViewNotSizable];		
	[view setZoomPercentage:[view zoomPercentage]]; // resizes the view accordingly
	[view setNeedsDisplay:YES];	
	wraps = newWraps;
}

- scrollView
{
	return scrollView;
}

- (void)setPatternToSelection
{
	if (![canvas hasSelection]) { return; }
	PXTool *currentTool = [[PXToolPaletteController sharedToolPaletteController] currentTool];
	if (![currentTool supportsPatterns]) { return; }
	NSRect selectedRect = [canvas selectedRect];
	NSRect patternRect = NSZeroRect;
	int i, j;
	// on the first pass, figure out how big the pattern's going to be.
	// we have to do this instead of just using selectedRect.size because
	// if the outer pixels of the selection are < .5 opacity, they wouldn't
	// be included in the pattern, and so it would be too big.
	for (i = NSMinX(selectedRect); i < NSMaxX(selectedRect); i++)
	{
		for (j = NSMinY(selectedRect); j < NSMaxY(selectedRect); j++)
		{
			NSPoint point = NSMakePoint(i, j);
			if ([canvas pointIsSelected:point] && [[canvas colorAtPoint:point] alphaComponent] >= 0.5)
			{
				NSRect newRect = NSMakeRect(i - NSMinX(selectedRect), j - NSMinY(selectedRect), 1, 1);
				patternRect = NSUnionRect(patternRect, newRect);
			}
		}
	}
//FIXME: undo goes here?
	PXPattern *pattern = [[[PXPattern alloc] init] autorelease];
	[pattern setSize:patternRect.size];
	// now we loop through again and actually set the points
	for (i = NSMinX(selectedRect); i < NSMaxX(selectedRect); i++)
	{
		for (j = NSMinY(selectedRect); j < NSMaxY(selectedRect); j++)
		{
			NSPoint point = NSMakePoint(i, j);
			if ([canvas pointIsSelected:point] && [[canvas colorAtPoint:point] alphaComponent] >= 0.5)
			{
				[pattern addPoint:NSMakePoint(i - NSMinX(selectedRect) - NSMinX(patternRect), j - NSMinY(selectedRect) - NSMinY(patternRect))];
			}
		}
	}
	[canvas deselect];
	[currentTool setPattern:pattern];
	[canvas changedInRect:NSInsetRect([canvas selectedRect], -2, -2)];	
}

- (void)backgroundChanged:(id)changed
{
	[self canvasDidChange:nil]; 
}

- (void)showBackgroundInfo
{
	[backgroundController reloadData];
	[[backgroundController window] setTitle:[NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Backgrounds", @"Backgrounds"), [[self document] displayName]]];
	[backgroundController setPreviewImage:[canvas displayImage]];
	[backgroundController showWindow:self];	
}

- (void)showGridSettings
{
	if (gridSettingsPrompter) 
		[gridSettingsPrompter release];
	
	gridSettingsPrompter = [[PXGridSettingsPrompter alloc] initWithSize:[[view grid] unitSize] 
																  color:[[view grid] color] 
															 shouldDraw:[[view grid] shouldDraw] ? YES : NO];
	[[gridSettingsPrompter window] setTitle:[NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Grid", @"Grid"), [[self document] displayName]]];
	
	[gridSettingsPrompter setDelegate:self];
	[(PXGridSettingsPrompter *)gridSettingsPrompter prompt];	
}

- (void)updateCanvasSizeZoomingToFit:(BOOL)zooming
{
	[[PXInfoPanelController sharedInfoPanelController] setCanvasSize:[canvas size]];
	
	[view sizeToCanvas];
	[self updatePreview];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL zoomToFit = [defaults boolForKey:PXZoomNewDocumentsToFitKey];	
	if (zooming && zoomToFit)
		[delegate zoomToFitCanvasController:self];
}

- (void)updateCanvasSize
{
	[self updateCanvasSizeZoomingToFit:YES];
}

- document
{
	return document;
}

- (void)setDocument:doc
{
	document = doc;
}

- window
{
	return window;
}

- (void)setWindow:win
{
	window = win;
}

- layerController
{
	return layerController;
}

- (void)zoomInOnCanvasPoint:(NSPoint)point
{
	[delegate canvasController:self zoomInOnCanvasPoint:point];
	[view centerOn:[view convertFromCanvasToViewPoint:point]];
}

- (void)zoomOutOnCanvasPoint:(NSPoint)point
{
	[delegate canvasController:self zoomOutOnCanvasPoint:point];
	[view centerOn:[view convertFromCanvasToViewPoint:point]];
}

- delegate
{
	return delegate;
}

- (void)setDelegate:del
{
	delegate = del;
}

- (void)mouseDown:event forTool:aTool
{
	if(downEventOccurred) 
		return; 
	// avoid the case where the right mouse can be pressed while the left is
	///dragging, and vice-versa. there should really be separate booleans for
	//left-mouse-is-being-used and right-mouse-is-being-used, since right now
	//if the right mouse is pressed and unpressed while the left mouse is pressed, 
	//the result will be that the left, too, becomes unpressed. fortunately, 
	//there are seemingly no unfortunate side effects from this situation, only
	//the more obvious bug.
	downEventOccurred = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:PXLockToolSwitcherNotificationName 
														object:aTool];
	
	if(! [aTool respondsToSelector:@selector(mouseDownAt:fromCanvasController:)]) 
		return; 
	[oldColor autorelease];
	oldColor = [[aTool colorForCanvas:canvas] retain];
	if([event isTabletPointerEvent] && [self caresAboutPressure])
	{
		id color = [oldColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		float pressure = [event scaledTabletPressure];
		[aTool setColor:[NSColor colorWithDeviceRed:[color redComponent] green:[color greenComponent] blue:[color blueComponent] alpha:pressure * [color alphaComponent]]];
	}
	initialPoint = [event locationInWindow];
	[aTool mouseDownAt:[view convertFromWindowToCanvasPoint:initialPoint] fromCanvasController:self];	
}

- (void)mouseDragged:(NSEvent *)event forTool:aTool
{
	if(!downEventOccurred)  
		return; 
	
	if(![aTool respondsToSelector:@selector(mouseDraggedFrom:to:fromCanvasController:)]) 
		return; 
	if([event isTabletPointerEvent] && [self caresAboutPressure])
	{
		id color = [oldColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		float pressure = [event scaledTabletPressure];
		[aTool setColor:[NSColor colorWithDeviceRed:[color redComponent] green:[color greenComponent] blue:[color blueComponent] alpha:pressure * [color alphaComponent]]];
	}	
	NSPoint endPoint = [event locationInWindow];
	[aTool mouseDraggedFrom:[view convertFromWindowToCanvasPoint:initialPoint] 
						 to:[view convertFromWindowToCanvasPoint:endPoint] 
	   fromCanvasController:self];
	
	initialPoint = endPoint;
}

- (void)mouseUpAt:(NSPoint)loc forTool:aTool
{
	if(!downEventOccurred) 
		return; 
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	downEventOccurred = NO;
	[nc postNotificationName:PXUnlockToolSwitcherNotificationName 
					  object:aTool];
	
	if(![aTool respondsToSelector:@selector(mouseUpAt:fromCanvasController:)]) 
		return; 
	
	[aTool mouseUpAt:loc fromCanvasController:self];
	[aTool setColor:oldColor];
}

- (void)mouseMovedTo:(NSPoint)point forTool:aTool
{
	if(![aTool respondsToSelector:@selector(mouseMovedTo:fromCanvasController:)]) 
		return; 
	if (![[NSDocumentController sharedDocumentController] showsToolPreview])
		return;
	
	[aTool mouseMovedTo:point fromCanvasController:self];
}

- (void)updateMousePosition:(NSPoint)newLocation
{
	[[PXToolPaletteController sharedToolPaletteController] flagsChanged:[NSApp currentEvent]];
	if (!downEventOccurred) {
		NSPoint canvasPoint = [view convertFromWindowToCanvasPoint:newLocation];
		[view updateMousePosition:newLocation dragging:NO];
		[[PXToolPaletteController sharedToolPaletteController] flagsChanged:[NSApp currentEvent]];
		[self mouseMovedTo:canvasPoint forTool:[[PXToolPaletteController sharedToolPaletteController] leftTool]];
		[self mouseMovedTo:canvasPoint forTool:[[PXToolPaletteController sharedToolPaletteController] rightTool]];
	}
}

- (void)mouseDown:(NSEvent *)event
{
	if (usingSpaceKey) { return; }
	[self mouseDown:event forTool:[[PXToolPaletteController sharedToolPaletteController] currentTool]];
}

//Joe's fault.  He's sorry.

- (void)eraserDown:(NSEvent *)event
{
	if (usingSpaceKey) { return; }
	id eraser = [[[PXToolPaletteController sharedToolPaletteController] leftSwitcher] toolWithTag:PXEraserToolTag];
	[self mouseDown:event forTool:eraser];
}

- (void)eraserDragged:(NSEvent *)event
{
	if (usingSpaceKey)
	{
		[self panViewWithEvent:event];
		return;
	}
	id eraser = [[[PXToolPaletteController sharedToolPaletteController] leftSwitcher] toolWithTag:PXEraserToolTag];
	[self mouseDragged:event forTool:eraser];
}

- (void)eraserUp:(NSEvent *)event
{
	id eraser = [[[PXToolPaletteController sharedToolPaletteController] leftSwitcher] toolWithTag:PXEraserToolTag];
	[self mouseUpAt:[view convertFromWindowToCanvasPoint:[event locationInWindow]] forTool:eraser];
}

- (void)eraserMoved:(NSEvent *)event
{
	id eraser = [[[PXToolPaletteController sharedToolPaletteController] leftSwitcher] toolWithTag:PXEraserToolTag];
	[self mouseMovedTo:[view convertFromWindowToCanvasPoint:[[self window] mouseLocationOutsideOfEventStream]] forTool:eraser];
	[self mouseMoved:event];
}

- (void)mouseDragged:(NSEvent *) event
{
	if (usingSpaceKey)
	{
		[self panViewWithEvent:event];
		return;
	}
	[self mouseDragged:event forTool:[[PXToolPaletteController sharedToolPaletteController] currentTool]];
}


- (void)mouseMoved:(NSEvent *) event
{
	[self updateMousePosition:[[self window] mouseLocationOutsideOfEventStream]];
}


- (void)mouseUp:(NSEvent *) event
{
	[self mouseUpAt:[view convertFromWindowToCanvasPoint:[event locationInWindow]] forTool:[[PXToolPaletteController sharedToolPaletteController] currentTool]];
}

- (void)rightMouseDown:(NSEvent *) event
{
	[[PXToolPaletteController sharedToolPaletteController] rightMouseDown];
	[self mouseDown:event];
}

- (void)rightMouseDragged:(NSEvent *) event
{
	[self mouseDragged:event];
}

- (void)rightMouseUp:(NSEvent *) event
{
	[self mouseUp:event];
	[[PXToolPaletteController sharedToolPaletteController] rightMouseUp];
}

- (void)scrollWheelZoom:(NSEvent *)event roundedDelta:(int)rd
{
	if ([event deltaY] > 0)
	{
		if (rd != 0)
		{
			[self zoomInOnCanvasPoint:[view convertFromWindowToCanvasPoint:[event locationInWindow]]];
		}
	}
	else
	{
		if (rd != 0)
		{
			[self zoomOutOnCanvasPoint:[view convertFromWindowToCanvasPoint:[event locationInWindow]]];
		}
	}	
}

- (void)scrollWheel:(NSEvent *)event
{
	static float absolute = 0;
	static float lastScroll = 0;
	absolute += [event deltaY];
	//this hardly seems right.  absolute never gets reset! beh?
	//i guess it would decrease with scroll wheel negative, but... beh?!
	int roundedDelta = ([event deltaY] > 0) ? floorf((absolute - lastScroll)) : ceilf((absolute - lastScroll));
	if([event modifierFlags] & NSAlternateKeyMask)
	{
		[self scrollWheelZoom:event roundedDelta:roundedDelta];
	}
	else
	{
		//i <3 nsscrollview
		[[self scrollView] scrollWheel:event];
	}
	lastScroll = absolute;
}

- (void)otherMouseDragged:(NSEvent *)event
{
	[self panViewWithEvent:event];
}

- (void)keyUp:(NSEvent *)event
{
	if([[event characters] characterAtIndex:0] == ' ')
	{
		usingSpaceKey = NO;
	}	
}

- (void)keyDown:(NSEvent *)event
{
	// [FIXME] Should we scroll the view or move the active layer here?  Hmm...
	if (downEventOccurred) { return; }
	if([[event characters] characterAtIndex:0] == NSDeleteFunctionKey)
	{
		[[self document] delete:self];
	}
	else
	{
		[[PXToolPaletteController sharedToolPaletteController] keyDown:event fromCanvasController:self];
	}
}

- (void)flagsChanged:(NSEvent *) event
{
	[[PXToolPaletteController sharedToolPaletteController] flagsChanged:event];
	[self updateMousePosition:[[self window] mouseLocationOutsideOfEventStream]];
}


- (void)panViewWithEvent:(NSEvent *)event
{
	NSPoint delta = [view convertFromViewToPartialCanvasPoint:NSMakePoint([event deltaX] * 3, [event deltaY] * 3)];
	delta.x += panLeftovers.x;
	delta.y += panLeftovers.y;
	NSPoint integerDelta = NSMakePoint(floorf(delta.x), floorf(delta.y));
	panLeftovers.x = delta.x - integerDelta.x;
	panLeftovers.y = delta.y - integerDelta.y;
	if (integerDelta.x != 0 || integerDelta.y != 0) {
		[view panByX:integerDelta.x y:integerDelta.y];
	}
}

- (BOOL)caresAboutPressure
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:PXCaresAboutPressureKey];
}


- (void)setLastDrawnPoint:(NSPoint)point
{
	lastDrawnPoint = point;
}

- (NSPoint)lastDrawnPoint
{
	return lastDrawnPoint;
}

@end
