//
//  PXAnimation.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PXCel;
@interface PXAnimation : NSObject <NSCopying> {
	NSMutableArray *cels;
	NSUndoManager *undoManager;
}
- init;
- (NSArray *)canvases;
- (PXCel *)objectInCelsAtIndex:(unsigned int)index;
- (unsigned)indexOfObjectInCels:(PXCel *)cel;
- (unsigned)countOfCels;
- (NSSize)size;
- (void)setSize:(NSSize)aSize;
- (void)setSizeNoUndo:(NSSize)aSize;
- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor;
- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor undo:(BOOL)undo;
- (NSUndoManager *)undoManager;
- (void)setUndoManager:man;
- (void)insertObject:(PXCel *)cel inCelsAtIndex:(unsigned int)index;
- (void)addNewCel;
- (void)insertNewCelAtIndex:(unsigned int)index;
- (void)addCel:(PXCel *)cel;
- (void)removeObjectFromCelsAtIndex:(unsigned)index;
- (void)removeCel:(PXCel *)cel;
- (void)moveCelFromIndex:(int)index1 toIndex:(int)index2;
- (void)copyCelFromIndex:(int)originalIndex toIndex:(int)insertionIndex;
- (NSImage *)spriteSheetWithCelMargin:(int)margin;
- (void)reduceColorsTo:(int)colors withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor;
@end
