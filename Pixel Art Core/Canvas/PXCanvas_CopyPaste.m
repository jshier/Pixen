  //
  //  PXCanvas_CopyPaste.m
  //  Pixen
  //
  //  Created by Joe Osborn on 2005.07.31.
  //  Copyright 2005 Open Sword Group. All rights reserved.
  //

#import "PXCanvas_CopyPaste.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXLayer.h"

@implementation PXCanvas(CopyPaste)

- (NSInteger)runPasteTooBigAlert:(NSString *)pastedThing size:(NSSize)aSize
{
	return [[NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"The pasted %@ is too big!", @"The pasted %@ is too big!"), pastedThing]
                          defaultButton:NSLocalizedString(@"Resize Canvas to Fit", @"Resize Canvas to Fit")
                        alternateButton:NSLocalizedString(@"Cancel Paste", @"Cancel Paste")
                            otherButton:NSLocalizedString(@"Paste Anyway", @"Paste Anyway")
              informativeTextWithFormat:NSLocalizedString(@"The pasted %@ is %ldx%ld, while the canvas is only %ldx%ld.", @"The pasted %@ is %ldx%ld, while the canvas is only %ldx%ld."), pastedThing,
           (long)(aSize.width), (long)(aSize.height),
           (long)([self size].width), (long)([self size].height)] runModal];
}

- (BOOL)canContinuePasteOf:(NSString *)pastedThing size:(NSSize)aSize
{
	if (aSize.width > [self size].width || aSize.height > [self size].height)
	{
		switch ([self runPasteTooBigAlert:pastedThing size:aSize])
		{
			case NSAlertDefaultReturn:
				[self setSize:NSMakeSize(MAX([self size].width, aSize.width), MAX([self size].height, aSize.height))];
				[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasSizeChangedNotificationName object:nil];
				break;
			case NSAlertAlternateReturn:
				return NO;
			case NSAlertOtherReturn:
				break;
			default:
				break;
		}
	}
	return YES;
}

- (void)pasteLayer:(PXLayer *)layer
{
	[self beginUndoGrouping]; {
		[self deselect];
		[self addLayer:layer];
		[self activateLayer:layer];
	} [self endUndoGrouping];		
}

- (void)pasteLayerFromPasteboard:(NSPasteboard *)board type:type
{
	if (![type isEqualToString:PXLayerPboardType]) { return; }
	NSDictionary *layerDict = [NSKeyedUnarchiver unarchiveObjectWithData:[board dataForType:PXLayerPboardType]];
	NSImage *image = [layerDict objectForKey:PXLayerImageKey];
	if(![self canContinuePasteOf:NSLocalizedString(@"layer", @"layer") size:[image size]]) { return; }
	NSString *name = [layerDict objectForKey:PXLayerNameKey];
	PXLayer *layer = [PXLayer layerWithName:name image:image size:[self size]];
	[layer setOpacity:[[layerDict objectForKey:PXLayerOpacityKey] floatValue]];
	[self pasteLayer:layer];
	[self layersChanged];
}

- (PXLayer *)layerForPastingFromPasteboard:(NSPasteboard *)board type:type
{
  PXLayer *layer = nil;
	if([type isEqualToString:PXLayerPboardType]) {
		layer = [NSKeyedUnarchiver unarchiveObjectWithData:[board dataForType:type]];
		[layer setSize:[self size]];
	}
	else if([type isEqualToString:PXNSImagePboardType]) {
		id image = [[[NSImage alloc] initWithPasteboard:board] autorelease];
		if(![self canContinuePasteOf:NSLocalizedString(@"image", @"image") size:[image size]]) { return nil; }
		NSPoint origin;
		if (![board stringForType:PXSelectionOriginPboardType])
		{	
			origin = NSMakePoint(([self size].width - [image size].width) / 2, ([self size].height - [image size].height) / 2);
		}
		else
		{
			NSPoint pOrigin = NSPointFromString([board stringForType:PXSelectionOriginPboardType]);
			origin.x = MIN([self size].width - [image size].width, pOrigin.x);
			origin.y = MIN([self size].height - [image size].height, pOrigin.y);
		}
		layer = [PXLayer layerWithName:NSLocalizedString(@"Pasted Layer", @"Pasted Layer") image:image origin:origin size:[self size]];
 	}
  return layer;
}

  //really, this should keep around an invisible paste-layer until the selection is removed, or something...
  //this way, it will lead to data garbling when people move their selections around.  save it for the rewrite!

- (void)pasteFromPasteboard:(NSPasteboard *) board type:type intoLayer:(PXLayer *)layer
{
  PXLayer *newLayer = [self layerForPastingFromPasteboard:board type:type];
  NSUInteger idx = [layers indexOfObject:layer];
  [self beginUndoGrouping]; {
      //FIXME wasteful copy
		[self setLayers:[[layers deepMutableCopy] autorelease] fromLayers:layers];
		[self deselect];
    [[layers objectAtIndex:idx] compositeUnder:newLayer flattenOpacity:YES];
	} [self endUndoGrouping];		
}

- (void)pasteFromPasteboard:(NSPasteboard *) board type:type
{
	PXLayer *layer = [self layerForPastingFromPasteboard:board type:type];
	[self pasteLayer:layer];
	[self layersChanged];
}

- (void)copyLayer:(PXLayer *)layer toPasteboard:(NSPasteboard *)board
{
	[board declareTypes:[NSArray arrayWithObjects:PXLayerPboardType, NSTIFFPboardType, nil] owner:self];
	if (![[board types] containsObject:PXLayerPboardType])
	{
		[board addTypes:[NSArray arrayWithObject:PXLayerPboardType] owner:self];
	}
	if(! [[board types] containsObject:NSTIFFPboardType]) 
  { 
		[board addTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self]; 
  }	
	
	NSImage *layerImage = [layer exportImage];
	[layerImage lockFocus];
	NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, [layerImage size].width, [layerImage size].height)] autorelease];
	[layerImage unlockFocus];
	NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:layerImage, PXLayerImageKey,
                            [NSNumber numberWithFloat:[layer opacity]], PXLayerOpacityKey,
                            [layer name], PXLayerNameKey, nil];
	[board setData:[NSKeyedArchiver archivedDataWithRootObject:dataDict] forType:PXLayerPboardType];
	[board setData:[bitmapRep representationUsingType:NSTIFFFileType properties:nil] forType:NSTIFFPboardType];	
}

- (void)performCopyMergingLayers:(BOOL)merge
{
	id board = [NSPasteboard generalPasteboard];
	[board declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, PXSelectionOriginPboardType, nil] owner:self];	
	if(! [[board types] containsObject:NSTIFFPboardType]) 
  { 
		[board addTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self]; 
  }
	if (![[board types] containsObject:PXSelectionOriginPboardType])
		[board addTypes:[NSArray arrayWithObject:PXSelectionOriginPboardType] owner: self];
	
	[board setData:[self selectionDataWithType:NSTIFFFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:merge] forKey:PXMergeLayersKey]]
         forType:NSTIFFPboardType];
	[board setString:NSStringFromPoint([self selectedRect].origin) forType:PXSelectionOriginPboardType];
}

- (void)copySelection
{
	[self performCopyMergingLayers:NO];
}

- (void)copyMergedSelection
{
	[self performCopyMergingLayers:YES];
}

- (void)cutLayer:aLayer
{
	[self beginUndoGrouping]; {
		[self copyLayer:aLayer toPasteboard:[NSPasteboard generalPasteboard]];
		[self removeLayer:aLayer];
	} [self endUndoGrouping:NSLocalizedString(@"Cut Layer", @"Cut Layer")];
}

- (void)copyActiveLayer
{
	[self copyLayer:[self activeLayer] toPasteboard:[NSPasteboard generalPasteboard]];
}

- (void)cutActiveLayer
{
	[self cutLayer:activeLayer];
}

- (void)pasteLayer
{
	[self beginUndoGrouping]; {
		[self pasteLayerFromPasteboard:[NSPasteboard generalPasteboard] type:PXLayerPboardType];
	} [self endUndoGrouping:NSLocalizedString(@"Paste Layer", @"Paste Layer")];
}

- (void)cutSelection
{
	[self beginUndoGrouping]; {
		[self copySelection];
		[self deleteSelection];
	} [self endUndoGrouping:NSLocalizedString(@"Cut Selection", @"Cut Selection")];	
}

- (void)paste
{
	[self beginUndoGrouping]; {
		[self pasteFromPasteboard:[NSPasteboard generalPasteboard] type:PXNSImagePboardType];
	} [self endUndoGrouping:NSLocalizedString(@"Paste Selection", @"Paste Selection")];
}
- (void)pasteIntoLayer:(PXLayer *)layer
{
	[self beginUndoGrouping]; {
		[self pasteFromPasteboard:[NSPasteboard generalPasteboard] type:PXNSImagePboardType intoLayer:layer];
	} [self endUndoGrouping:NSLocalizedString(@"Paste Selection", @"Paste Selection")];
}

@end
