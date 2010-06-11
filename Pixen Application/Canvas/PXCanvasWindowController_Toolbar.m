//
//  PXCanvasWindowController_Toolbar.m
//  Pixen-XCode
//
//  Created by Joe Osborn on 2005.05.09.

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

#import "PXCanvasWindowController_Toolbar.h"
#import "PXPanelManager.h"

@implementation PXCanvasWindowController(Toolbar)

//identifiers
NSString *PXBackgroundConfigurator = @"PXBackgroundConfigurator";
NSString *PXLayerDrawer = @"PXLayerDrawer";
NSString *PXPreview = @"PXPreview";
NSString *PXToolProperties = @"PXToolProperties";
NSString *PXGridConfigurator = @"PXGridConfigurator";
NSString *PXZoomFit = @"PXZoomFit";
NSString *PXZoom100 = @"PXZoom100";
NSString *PXScale = @"PXScale";
NSString *PXResize = @"PXResize";
NSString *PXFeedback = @"PXFeedback";
NSString *PXZoom = @"PXZoom";
  //NSString *PXDocumentPalette = @"PXDocumentPalette";

- (void)prepareToolbar
{
	toolbar = [[NSToolbar alloc] initWithIdentifier:PXCanvasDocumentToolbarIdentifier];
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	[[self window] setToolbar:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
	 itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
	if ([itemIdentifier isEqualToString:PXBackgroundConfigurator])
	{
		[item setLabel:NSLocalizedString(@"BACKGROUND_LABEL", @"Background Label")];
		[item setToolTip:NSLocalizedString(@"BACKGROUND_TOOLTIP", @"Background Tooltip")];
		[item setAction:@selector(showBackgroundInfo:)];
		[item setImage:[NSImage imageNamed:@"bgconf"]];
	}
	else if ([itemIdentifier isEqualToString:PXLayerDrawer])
	{
		[item setLabel:NSLocalizedString(@"LAYERS_LABEL", @"Layers Label")];
		[item setToolTip:NSLocalizedString(@"LAYERS_TOOLTIP", @"Layers Tooltip")];
		[item setAction:@selector(toggleLayersDrawer:)];
		[item setImage:[NSImage imageNamed:@"layerdrawer"]];
	}
	else if ([itemIdentifier isEqualToString:PXPreview])
	{
		[item setLabel:NSLocalizedString(@"PREVIEW_LABEL", @"Preview Label")];
		[item setToolTip:NSLocalizedString(@"PREVIEW_TOOLTIP", @"Preview Tooltip")];
		[item setAction:@selector(togglePreviewWindow:)];
		[item setImage:[NSImage imageNamed:@"preview"]];
	}
	else if ([itemIdentifier isEqualToString:PXToolProperties])
	{
		[item setLabel:NSLocalizedString(@"TOOL_PROPERTIES_LABEL", @"Tool Properties Label")];
		[item setToolTip:NSLocalizedString(@"TOOL_PROPERTIES_TOOLTIP", @"Tool Properties Tooltip")];
		[item setTarget:[PXPanelManager sharedManager]];
		[item setAction:@selector(toggleLeftToolProperties:)];
		[item setImage:[NSImage imageNamed:@"toolproperties"]];
	}
	else if ([itemIdentifier isEqualToString:PXGridConfigurator])
	{
		[item setLabel:NSLocalizedString(@"GRID_LABEL", @"Grid Label")];
		[item setToolTip:NSLocalizedString(@"GRID_TOOLTIP", @"Grid Tooltip")];
		[item setAction:@selector(showGridSettingsPrompter:)];
		[item setImage:[NSImage imageNamed:@"grid"]];
	}
	else if ([itemIdentifier isEqualToString:PXZoomFit])
	{		
		[item setLabel:NSLocalizedString(@"ZOOM_FIT_LABEL", @"Zoom Fit Label")];
		[item setToolTip:NSLocalizedString(@"ZOOM_FIT_TOOLTIP", @"Zoom Fit Tooltip")];
		[item setAction:@selector(zoomToFit:)];
		[item setImage:[NSImage imageNamed:@"zoomfit"]];
	}
	else if ([itemIdentifier isEqualToString:PXZoom100])
	{
		[item setLabel:NSLocalizedString(@"ZOOM_ACTUAL_LABEL", @"Zoom Actual Label")];
		[item setToolTip:NSLocalizedString(@"ZOOM_ACTUAL_TOOLTIP", @"Zoom Actual Tooltip")];
		[item setAction:@selector(zoomStandard:)];
		[item setImage:[NSImage imageNamed:@"zoom100"]];
	}
	else if ([itemIdentifier isEqualToString:PXScale])
	{
		[item setLabel:NSLocalizedString(@"SCALE_LABEL", @"Scale Label")];
		[item setToolTip:NSLocalizedString(@"SCALE_TOOLTIP", @"Scale Tooltip")];
		[item setAction:@selector(scaleCanvas:)];
		[item setImage:[NSImage imageNamed:@"scale"]];
	}
	else if ([itemIdentifier isEqualToString:PXResize])
	{
		[item setLabel:NSLocalizedString(@"RESIZE_LABEL", @"Resize Label")];
		[item setToolTip:NSLocalizedString(@"RESIZE_TOOLTIP", @"Resize Tooltip")];
		[item setAction:@selector(resizeCanvas:)];
		[item setImage:[NSImage imageNamed:@"resize"]];
	}
//	else if ([itemIdentifier isEqualToString:PXDocumentPalette])
//	{
//		[item setLabel:NSLocalizedString(@"DOCUMENT_PALETTE_LABEL", @"Document Palette Label")];
//		[item setToolTip:NSLocalizedString(@"DOCUMENT_PALETTE_TOOLTIP", @"Document Palette Tooltip")];
//		[item setAction:@selector(popDocumentPalette:)];
//		[item setImage:[NSImage imageNamed:@"colorpalette"]];
//	}
	else if ([itemIdentifier isEqualToString:PXFeedback])
	{
		[item setLabel:NSLocalizedString(@"FEEDBACK_LABEL", @"Feedback Label")];
		[item setToolTip:NSLocalizedString(@"FEEDBACK_TOOLTIP", @"Feedback Tooltip")];
		[item setTarget:[PXPanelManager sharedManager]];
		[item setAction:@selector(showFeedback:)];
		[item setImage:[NSImage imageNamed:@"feedback"]];
	}
	else if ([itemIdentifier isEqualToString:PXZoom])
	{
		[item setLabel:NSLocalizedString(@"ZOOM_LABEL", @"Zoom Label")];
		[item setToolTip:NSLocalizedString(@"ZOOM_TOOLTIP", @"Zoom Tooltip")];
		[item setView:zoomView];
		[item setMinSize:NSMakeSize(124,NSHeight([zoomView frame]))];
		[item setMaxSize:NSMakeSize(124,NSHeight([zoomView frame]))];
	}
	[item setPaletteLabel:[item label]];
	if(![item target])
	{
		[item setTarget:self];
	}
	return item;
}

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:PXBackgroundConfigurator, PXLayerDrawer,
		PXPreview, PXZoom, 
		PXZoomFit, PXZoom100,
		PXResize, PXScale,
		PXFeedback, PXGridConfigurator,
          //		PXDocumentPalette,
		NSToolbarCustomizeToolbarItemIdentifier, 
		NSToolbarSpaceItemIdentifier,
		NSToolbarSeparatorItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier, 
		nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:PXBackgroundConfigurator, PXGridConfigurator, 
		NSToolbarSeparatorItemIdentifier, PXLayerDrawer, PXPreview, /*PXDocumentPalette,*/
		NSToolbarFlexibleSpaceItemIdentifier, PXFeedback,
		PXZoom,
		nil];
}
@end
