//
//  PXCanvas_Selection.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(Selection)

- (NSArray *)boundedRectsFromRect:(NSRect)rect;
- (NSData *)selectionData;
- (BOOL)hasSelection;
- (void)setHasSelection:(BOOL)hasSelection;
- (void)promoteSelection;
- (void)deselect;
- (void)selectPixelAtPoint:(NSPoint)point;
- (void)deselectPixelAtPoint:(NSPoint)point;
- (void)selectPixelsInRect:(NSRect)rect;
- (void)deselectPixelsInRect:(NSRect)rect;
- (BOOL)indexIsSelected:(unsigned int)index;
- (BOOL)pointIsSelected:(NSPoint)point;
- (void)selectAll;
- (NSRect)selectedRect;
- (PXSelectionMask)selectionMask;
- (long)selectionMaskSize;
- (void)translateSelectionMaskByX:(int)x y:(int)y;
- (void)updateSelectionSwitch;
- (void)setMaskData:(NSData *)mask withOldMaskData:(NSData *)prevMask;
- (void)setMask:(PXSelectionMask)newMask;
- (void)setSelectionMaskBit:(BOOL)maskValue inRect:(NSRect)rect;
- selectionDataWithType:(NSBitmapImageFileType)storageType properties:(NSDictionary *)properties;
- (void)finalizeSelectionMotion;
- (NSPoint)selectionOrigin;
- (void)deleteSelection;
- (void)cropToSelection;
- (void)setSelectionMaskBit:(BOOL)bit atIndices:(NSArray *)indices;
- (void)reallocateSelection;
- (void)invertSelection;
- (void)setSelectionOrigin:(NSPoint)orig;

@end
