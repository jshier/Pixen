//
//  PXCanvasWindowController_IBActions.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvasWindowController_IBActions.h"
#import "PXCanvas_Layers.h"
#import "PXToolPaletteController.h"
#import "PXCanvasResizePrompter.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_CopyPaste.h"
#import "PXCanvasDocument.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Selection.h"
#import "PXCanvasController.h"
#import "PXScaleController.h"
#import "PXTool.h"
#import "PXPaletteExporter.h"
#import "PXPalettePanel.h"

#import "PXAnimationDocument.h"
#import "PXAnimation.h"
#import "PXCel.h"

@implementation PXCanvasWindowController(IBActions)

- (IBAction)createAnimationFromImage:sender
{
	PXAnimationDocument *animationDocument = [[PXAnimationDocument alloc] init];
	NSImage *cocoaImage = [[[self canvas] exportImage] retain];
	[cocoaImage lockFocus];
	NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:(NSRect){NSZeroPoint,[cocoaImage size]}] autorelease];
	[cocoaImage unlockFocus];
	[cocoaImage removeRepresentation:[[cocoaImage representations] objectAtIndex:0]];
	[cocoaImage addRepresentation:bitmapRep];
	[[[[animationDocument animation] objectInCelsAtIndex:0] canvas] replaceActiveLayerWithImage:cocoaImage];
	[animationDocument makeWindowControllers];
	[animationDocument showWindows];
  [animationDocument updateChangeCount:NSChangeReadOtherContents];
}

- (void)rotateLayerCounterclockwise:sender
{
	[canvas rotateLayer:[canvas activeLayer] byDegrees:90];
}

- (void)rotateLayerClockwise:sender
{
	[canvas rotateLayer:[canvas activeLayer] byDegrees:270];
}

- (void)rotateLayer180:sender
{
	[canvas rotateLayer:[canvas activeLayer] byDegrees:180];
}

- (IBAction)rotateCounterclockwise:sender
{
	[canvas rotateByDegrees:90];
}

- (IBAction)rotateClockwise:sender
{
	[canvas rotateByDegrees:270];
}

- (IBAction)rotate180:sender
{
	[canvas rotateByDegrees:180];
}

- (IBAction)resizeCanvas:(id) sender
{
	[resizePrompter loadWindow];
	[resizePrompter setDelegate:self];
//FIXME: this stuff should use the canvas's mainbackground to draw the resize area stuffies.  otherwise the matte color won't show up very well
	[resizePrompter setBackgroundColor:
	 [NSKeyedUnarchiver unarchiveObjectWithData:
	  [[NSUserDefaults standardUserDefaults] objectForKey:PXDefaultNewDocumentBackgroundColor]]];
	[resizePrompter setCurrentSize:[canvas size]];
	[resizePrompter setCachedImage:[canvas displayImage]];
	[resizePrompter promptInWindow:[self window]];
}

- (IBAction)scaleCanvas:(id) sender
{
	[scaleController scaleCanvasFromController:self modalForWindow:[self window]];
}

- (IBAction)increaseOpacity:(id)sender
{
	id switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	[switcher setColor:[[switcher color] colorWithAlphaComponent:[[switcher color] alphaComponent] + 0.1f]];
}

- (IBAction)decreaseOpacity:(id) sender
{
	id switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	[switcher setColor:[[switcher color] colorWithAlphaComponent:[[switcher color] alphaComponent] - 0.1f]];
}

- (IBAction)duplicateDocument:(id)sender
{
	PXCanvasDocument *newDocument = [[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:PixenImageFileType];
	id newCanvas = [[canvas copy] autorelease];
	[newDocument setCanvas:newCanvas];
	[newDocument makeWindowControllers];
	[[NSDocumentController sharedDocumentController] addDocument:newDocument];
}

- (IBAction)exportDocumentPalette:sender
{
	id exporter = [[PXPaletteExporter alloc] init];
	PXPalette *p = [canvas createFrequencyPalette];
	[exporter runWithPalette:p inWindow:[self window]];
	PXPalette_release(p);
}

- (IBAction)mergeDown:(id) sender
{
	[canvas mergeDownLayer:[canvas activeLayer]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	if ([anItem action] == @selector(crop:))
		return [[self canvas] hasSelection];
	else if ([anItem action] == @selector(mergeDown:))
		return [[[self canvas] layers] count] > 1 &&
			[[[self canvas] layers] objectAtIndex:0] != [[self canvas] activeLayer];
	else if ([anItem action] == @selector(promoteSelection:))
		return [[self canvas] hasSelection];
	else if ([anItem action] == @selector(deleteLayer:))
		return [[[self canvas] layers] count] > 1;
	else if ([anItem action] == @selector(previousLayer:))
		return [[[self canvas] layers] count] > 1 && [[[self canvas] layers] lastObject] != [[self canvas] activeLayer];
	else if ([anItem action] == @selector(nextLayer:))
		return [[[self canvas] layers] count] > 1 && [[[self canvas] layers] objectAtIndex:0] != [[self canvas] activeLayer];
	else if ([anItem action] == @selector(shouldTileToggled:))
	{
		[anItem setTitle:([canvas wraps]) ? NSLocalizedString(@"HIDE_TILED_VIEW", @"Hide Tiled View") :
			NSLocalizedString(@"SHOW_TILED_VIEW", @"Show Tiled View")];
		return YES;
	}
	else if ([anItem action] == @selector(cut:) || [anItem action] == @selector(copy:) ||
		[anItem action] == @selector(copyMerged:) || [anItem action] == @selector(selectNone:) ||
		[anItem action] == @selector(delete:)) {
		return [canvas hasSelection];
	}
	else if ([anItem action] == @selector(paste:) || [anItem action] == @selector(pasteIntoActiveLayer:))
	{
		NSPasteboard *board = [NSPasteboard generalPasteboard];
		
		NSEnumerator *enumerator = [[NSImage imagePasteboardTypes] objectEnumerator];
		id current;
		while ((current = [enumerator nextObject]))
		{
			if ([[board types] containsObject:current])
			{
				return YES;
			}
		}
		
		return NO;
	}
	else if ([anItem action] == @selector(cutLayer:))
	{
		return [[canvas layers] count] > 1;
	}
	else if ([anItem action] == @selector(pasteLayer:))
	{
		NSPasteboard *board = [NSPasteboard generalPasteboard];
		if ([[board types] containsObject:PXLayerPboardType])
			return YES;
		else
			return NO;
	}	
	else if ([anItem action] == @selector(setPatternToSelection:))
		return [[self canvas] hasSelection] && [[[PXToolPaletteController sharedToolPaletteController] currentTool] supportsPatterns];
	else if ([anItem action] == @selector(popDocumentPalette:))
		return NO;  // currently no document palette, so disable the menu item
	return YES;
}

- (IBAction)promoteSelection:(id) sender
{
	[canvas promoteSelection];
}

- (IBAction)newLayer:(id) sender
{
	[[canvasController layerController] addLayer:sender];
}

- (IBAction)deleteLayer:sender
{
	[canvas removeLayer:[canvas activeLayer]];
}

- (IBAction)crop:sender
{
	[canvas cropToSelection];
	[canvasController updateCanvasSizeZoomingToFit:NO];		
}

- (IBAction)flipHorizontally:(id)sender
{
	[canvas flipHorizontally];
}

- (IBAction)flipVertically:(id)sender
{
	[canvas flipVertically];
}

- (IBAction)flipLayerHorizontally:(id) sender
{		
	[canvas flipLayerHorizontally:[canvas activeLayer]];
}

- (IBAction)flipLayerVertically:(id) sender
{
	[canvas flipLayerVertically:[canvas activeLayer]];
}

- (IBAction)duplicateLayer:(id) sender
{
	[[canvasController layerController] duplicateLayer:sender];
}

- (IBAction)nextLayer:(id) sender
{
	[[canvasController layerController] nextLayer:sender];
}

- (IBAction)previousLayer:(id) sender
{
	[[canvasController layerController] previousLayer:sender];
}

- (IBAction) shouldTileToggled: (id) sender
{
	[canvasController toggleShouldTile];
}

- (IBAction)setPatternToSelection:sender
{
	[canvasController setPatternToSelection];
}

- (IBAction)showPreviewWindow:(NSEvent *) sender
{
	[previewController showWindow:self];
}

- (IBAction)togglePreviewWindow: (id) sender
{
	if ([[previewController window] isVisible])
	{
		[[previewController window] performClose:self];
	}
	else
	{
		[previewController showWindow:self];
	}
}

- (IBAction)showBackgroundInfo:(id) sender
{
	[canvasController showBackgroundInfo];
}

- (IBAction)showGridSettingsPrompter:(id) sender
{
	[canvasController showGridSettings];
}

- (IBAction)toggleLayersDrawer:(id) sender
{
	[[canvasController layerController] toggle:sender];
}

- (IBAction)redrawCanvas: (id) sender
{
	[canvas changed];
}

- (void)prompter:aPrompter
didFinishWithSize:(NSSize)aSize
		position:(NSPoint)position
 backgroundColor:(NSColor *)color
{
	[canvas setSize:aSize withOrigin:position backgroundColor:color];
	[canvasController updateCanvasSize];
}

- (IBAction)cut:sender
{
	[canvas cutSelection];
}

- (IBAction)cutLayer:sender
{
	[canvas cutActiveLayer];
}

- (IBAction)copyLayer:sender
{
	[canvas copyActiveLayer];
}

- (IBAction)pasteLayer:sender
{
	[canvas pasteLayer];
}

- (IBAction)copy:(id) sender
{
	[canvas copySelection];
}

- (IBAction)copyMerged: (id) sender
{
	[canvas copyMergedSelection];
}

- (IBAction) paste: (id) sender
{
	[canvas paste];
}

- (IBAction) pasteIntoActiveLayer: (id) sender
{
	[canvas pasteIntoLayer:[canvas activeLayer]];
}


- (IBAction)delete:(id) sender
{
	[canvas deleteSelection];
}

- (IBAction)selectAll: (id) sender
{
	[canvas selectAll];
}

- (IBAction)invertSelection: (id) sender
{
	[canvas invertSelection];
}

- (IBAction)selectNone: (id) sender
{
	[canvas deselect];
}

- (IBAction)popDocumentPalette:sender
{
	//FIXME: no palette, memory concerns, change this architecture some
	// note: if this is implemented in the future, need to remove code in validateMenuItem: that disables the menu item
	assert(0);
//	[PXPalettePanel popWithPalette:[canvas palette] fromWindow:[NSColorPanel sharedColorPanel]];
}

@end
