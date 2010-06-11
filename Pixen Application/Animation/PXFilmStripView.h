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
	int celRectsCount;
	NSBezierPath *spokeHolePath;
	
	NSRect updateRect;
	NSTimer *updateTimer;
	
	NSPoint dragOrigin;
	int targetDraggingIndex;
	
	NSPoint mouseLocation;
	
	NSTrackingRectTag *celTrackingTags;
	NSTrackingRectTag *closeButtonTrackingTags;
	
	int gonnaBeDeleted;
	
	NSMutableIndexSet *selectedIndices;
	BOOL allowsMultipleSelection;
	NSTextFieldCell *fieldCell;
	int activeCelForField;
}

- (void)setDataSource:dataSource;
- (void)setDelegate:delegate;
- (void)reloadData;
- (float)minimumHeight;

- (void)setNeedsDelayedDisplayInRect:(NSRect)rect;

- (unsigned int)selectedIndex;
- selectedCel;
- (NSIndexSet *)selectedIndices;
- (NSArray *)selectedCels;
- (void)selectCelAtIndex:(unsigned)index byExtendingSelection:(BOOL)extend;
- (NSRect)rectOfCelIndex:(unsigned int)index;

@end

@interface NSObject (PXFilmStripDataSource)
- (int)numberOfCels;
- celAtIndex:(int)index;
- (NSArray *)draggedTypesForFilmStripView:view;
- (void)deleteCelsAtIndices:(NSIndexSet *)indices;
- (void)writeCelsAtIndices:(NSIndexSet *)indices toPasteboard:(NSPasteboard *)pboard;
- (BOOL)insertCelIntoFilmStripView:view fromPasteboard:(NSPasteboard *)pboard atIndex:(int)targetDraggingIndex;
- (BOOL)moveCelInFilmStripView:view fromIndex:(int)index1 toIndex:(int)index2;
- (BOOL)copyCelInFilmStripView:view atIndex:(int)currentIndex toIndex:(int)anotherIndex;
@end

@interface NSObject (PXFilmStripDelegate)
- (void)filmStripSelectionDidChange:(NSNotification *)note;
@end

