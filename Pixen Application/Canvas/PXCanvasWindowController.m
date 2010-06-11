//  PXCanvasWindowController.m
//  Pixen
//
// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  Created by Joe Osborn on Sat Sep 13 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXDocumentController.h"

#import "PXCanvasWindowController.h"
#import "PXCanvasWindowController_Toolbar.h"
#import "PXCanvasWindowController_Zooming.h"
#import "PXCanvasWindowController_IBActions.h"
#import "PXCanvasController.h"
#import "PXCanvas_Layers.h"
#import "PXLayerController.h"
#import "PXCanvasResizePrompter.h"
#import "PXScaleController.h"
#import "PXCanvasDocument.h"
#import "PXPreviewController.h"
#import "PXInfoPanelController.h"
#import "RBSplitView.h"
#import "PXPaletteController.h"

//Taken from a man calling himself "BROCK BRANDENBERG" 
//who is here to save the day.
#import "SBCenteringClipView.h"

@implementation PXCanvasWindowController

- (PXCanvasView *)view
{
	return [canvasController view];
}

- (id) initWithWindowNibName:name
{
	if (! ( self = [super initWithWindowNibName:name] ) ) 
		return nil;
	layerController = [[PXLayerController alloc] init];
	[layerController setNextResponder:self];
	paletteController = [[PXPaletteController alloc] init];
	resizePrompter = [[PXCanvasResizePrompter alloc] init];
	previewController = [PXPreviewController sharedPreviewController];
	scaleController = [[PXScaleController alloc] init];

	return self;
}

- (RBSplitSubview*)layerSplit;
{
	return layerSplit;
}

- (RBSplitSubview*)canvasSplit;
{
	return canvasSplit;
}

- (void)awakeFromNib
{
	id paletteView = [paletteController view];
	[paletteSplit addSubview:paletteView];
	[canvasController setLayerController:layerController];
	[layerController setSubview:layerSplit];
	[layerSplit addSubview:[layerController view]];
	[self updateFrameSizes];
	[self prepareToolbar];
	[[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)updateFrameSizes
{
	[[layerController view] setFrameSize:[layerSplit frame].size];
	[[layerController view] setFrameOrigin:NSZeroPoint];

	[[paletteController view] setFrameSize:[paletteSplit frame].size];
	[[paletteController view] setFrameOrigin:NSZeroPoint];
	[[canvasController scrollView] setFrameOrigin:NSZeroPoint];
	[[canvasController scrollView] setFrameSize:[[self canvasSplit] frame].size];
}

- (void)dealloc
{
	[canvasController deactivate];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[layerController release];
	[resizePrompter release];
	[scaleController release];
	[toolbar release];
	
	[super dealloc];
}

- (PXCanvas *) canvas
{
	return canvas;
}

- (void)windowWillClose:note
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self setCanvas:nil];
}

- (void)releaseCanvas
{
	canvas = nil;
	[canvasController setCanvas:nil];
}

- (void)setCanvas:(PXCanvas *) aCanvas
{
	canvas = aCanvas;
	[canvasController setCanvas:canvas];
	[self updatePreview];
}

- (void)updatePreview
{
	[canvasController updatePreview];
}

- (void)setDocument:(NSDocument *)doc
{
	[super setDocument:doc];
	[canvasController setDocument:doc];
	[layerController setDocument:doc];
	[paletteController setDocument:doc];
}

- (void)windowDidResignMain:note
{
	if ([note object] == [self window])
	{
		[canvasController deactivate];
	}
}

- (void)windowDidBecomeMain:(NSNotification *) aNotification
{
	if([aNotification object] == [self window])
	{
		[canvasController activate];
		[self updateFrameSizes];
		[[PXInfoPanelController sharedInfoPanelController] setCanvasSize:[canvas size]];
		[self updatePreview];
	}
}

- (void)prepare
{
	[self prepareZoom];
	[canvasController setDocument:[self document]];
	[canvasController setWindow:[self window]];
	[canvasController prepare];
	[self zoomToFit:self];
	[[self window] useOptimizedDrawing:YES];
	[[self window] makeKeyAndOrderFront:self];
}

- (void)updateCanvasSize
{
	[canvasController updateCanvasSize];
}

- canvasController
{
	return canvasController;
}

- (void)canvasController:(PXCanvasController *)controller setSize:(NSSize)size backgroundColor:(NSColor *)bg
{
	[canvas setSize:size withOrigin:NSZeroPoint backgroundColor:bg];
	[[[self document] undoManager] removeAllActions];
	[[self document] updateChangeCount:NSChangeCleared];
}

- (void)mouseMoved:event
{
	[[canvasController view] mouseMoved:event];
}

- (void)flagsChanged:event
{
	[canvasController flagsChanged:event];
}

- (void)rightMouseUp:event
{
	[canvasController rightMouseUp:event];
}

- (void)rightMouseDown:event
{
	if(NSPointInRect([event locationInWindow], [[canvasController view] convertRect:[[canvasController view] bounds] toView:nil])) {
		[[canvasController view] rightMouseDown:event];
	}
}

- (void)rightMouseDragged:event
{
	[[canvasController view] rightMouseDragged:event];
}

- (void)mouseUp:event
{
	[[canvasController view] mouseUp:event];
}

- (void)mouseDown:event
{
	if(NSPointInRect([event locationInWindow], [[canvasController view] convertRect:[[canvasController view] bounds] toView:nil])) {
		[[canvasController view] mouseDown:event];
	}
}

- (void)mouseDragged:event
{
	[[canvasController view] mouseDragged:event];
}

- (void)keyDown:event
{
	if([paletteController isPaletteIndexKey:event])
	{
		[paletteController keyDown:event];
	}
	[canvasController keyDown:event];
}

//- (void)undo:sender { [[[self document] windowController] undo]; }
//- (void)redo:sender { [[[self document] windowController] redo]; }
//- (void)performMiniaturize:sender { [[self window] performMiniaturize:sender]; }
//- (void)toggleToolbarShown:sender { [[self window] toggleToolbarShown:sender]; }
//- (void)runToolbarCustomizationPalette:sender { [[self window] runToolbarCustomizationPalette:sender]; }
//- (void)performClose:sender
//{
//	[window performClose:sender];
//}


- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	BOOL v = [[self window] validateMenuItem:anItem];
	NSUndoManager *manager = [[self document] undoManager];
	if ([anItem action] == @selector(undo:))
	{
		[anItem setTitleWithMnemonic:[manager undoMenuItemTitle]];
		return [manager canUndo];
	}
	if ([anItem action] == @selector(redo:))
	{
		[anItem setTitleWithMnemonic:[manager redoMenuItemTitle]];
		return [manager canRedo];
	}
	return v;
}


//this is to fix a bug in animation documents where expanding the
//split subview trashes the dimensions of the layer control view
- (void)splitView:(RBSplitView*)sender didExpand:(RBSplitSubview*)subview;
{
	[self updateFrameSizes];
}

@end
