//
//  PXFilmStripView.h
//  PXFilmstrip
//
//  Created by Andy Matuschak on 8/9/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXFilmStripView : NSView
{
	id dataSource;
	id delegate;
	
	NSImage *spokeHoleCache;
	
	NSRect *celRects;
	NSUInteger celRectsCount;
	NSBezierPath *spokeHolePath;
	
	NSRect updateRect;
	NSTimer *updateTimer;
	
	NSPoint dragOrigin;
	NSInteger targetDraggingIndex;
	
	NSPoint mouseLocation;
	
	NSTrackingRectTag *celTrackingTags;
	NSTrackingRectTag *closeButtonTrackingTags;
	
	NSInteger gonnaBeDeleted;
	
	NSMutableIndexSet *selectedIndices;
	BOOL allowsMultipleSelection;
	NSTextFieldCell *fieldCell;
	NSUInteger activeCelForField;
}

- (void)setDataSource:dataSource;
- (void)setDelegate:delegate;
- (void)reloadData;
- (CGFloat)minimumHeight;

- (void)setNeedsDelayedDisplayInRect:(NSRect)rect;

- (NSUInteger)selectedIndex;
- selectedCel;
- (NSIndexSet *)selectedIndices;
- (NSArray *)selectedCels;
- (void)selectCelAtIndex:(NSUInteger)index byExtendingSelection:(BOOL)extend;
- (NSRect)rectOfCelIndex:(NSUInteger)index;

@end

@interface NSObject (PXFilmStripDataSource)
- (NSUInteger)numberOfCels;
- celAtIndex:(NSUInteger)index;
- (NSArray *)draggedTypesForFilmStripView:view;
- (void)deleteCelsAtIndices:(NSIndexSet *)indices;
- (void)writeCelsAtIndices:(NSIndexSet *)indices toPasteboard:(NSPasteboard *)pboard;
- (BOOL)insertCelIntoFilmStripView:view fromPasteboard:(NSPasteboard *)pboard atIndex:(NSUInteger)targetDraggingIndex;
- (BOOL)moveCelInFilmStripView:view fromIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2;
- (BOOL)copyCelInFilmStripView:view atIndex:(NSUInteger)currentIndex toIndex:(NSUInteger)anotherIndex;
@end

@interface NSObject (PXFilmStripDelegate)
- (void)filmStripSelectionDidChange:(NSNotification *)note;
@end

