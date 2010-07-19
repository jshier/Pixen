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
- (PXCel *)objectInCelsAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfObjectInCels:(PXCel *)cel;
- (NSUInteger)countOfCels;
- (NSSize)size;
- (void)setSize:(NSSize)aSize;
- (void)setSizeNoUndo:(NSSize)aSize;
- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor;
- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor undo:(BOOL)undo;
- (NSUndoManager *)undoManager;
- (void)setUndoManager:man;
- (void)insertObject:(PXCel *)cel inCelsAtIndex:(NSUInteger)index;
- (void)addNewCel;
- (void)insertNewCelAtIndex:(NSUInteger)index;
- (void)addCel:(PXCel *)cel;
- (void)removeObjectFromCelsAtIndex:(NSUInteger)index;
- (void)removeCel:(PXCel *)cel;
- (void)moveCelFromIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2;
- (void)copyCelFromIndex:(NSUInteger)originalIndex toIndex:(NSUInteger)insertionIndex;
- (NSImage *)spriteSheetWithCelMargin:(NSUInteger)margin;
- (void)reduceColorsTo:(NSUInteger)colors withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor;
@end
