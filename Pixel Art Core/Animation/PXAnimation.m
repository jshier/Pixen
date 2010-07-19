//
//  PXAnimation.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXAnimation.h"
#import "PXCel.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "NSMutableArray+ReorderingAdditions.h"

#import "gif_lib.h"

@implementation PXAnimation

- init
{
	[super init];
	cels = [[NSMutableArray alloc] initWithCapacity:100];
	[cels addObject:[[[PXCel alloc] init] autorelease]];
	return self;
}

- (void)dealloc
{
	[cels release];
	[super dealloc];
}

- copyWithZone:(NSZone *)zone
{
	PXAnimation *newAnimation = [[PXAnimation alloc] init];
	[newAnimation setValue:[cels deepMutableCopy] forKey:@"cels"];
	[newAnimation setUndoManager:undoManager];
	return newAnimation;
}

- (PXCel *)objectInCelsAtIndex:(NSUInteger)index 
{
	return [cels objectAtIndex:index];
}

- (NSUInteger)indexOfObjectInCels:(PXCel *)cel
{
	return [cels indexOfObject:cel];
}

- (NSUInteger)countOfCels
{
	return [cels count];
}

- (NSArray *)canvases
{
  return [cels valueForKey:@"canvas"];
}

- (NSSize)size
{
	return [[cels lastObject] size];
}

- (void)setSizeNoUndo:(NSSize)aSize
{
	for (id current in cels)
	{
		[current setSize:aSize];
	}
}

- (void)setSize:(NSSize)aSize
{
	[self setSize:aSize withOrigin:NSZeroPoint backgroundColor:[[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]];
}

- (void)_willChangeSize:(BOOL)undo
{
	[self willChangeValueForKey:@"size"];
	if(undo)
	{
		[[undoManager prepareWithInvocationTarget:self] _willChangeSize:undo];
	}
}

- (void)_didChangeSize:(BOOL)undo
{
	[self didChangeValueForKey:@"size"];
	if(undo)
	{
		[[undoManager prepareWithInvocationTarget:self] _didChangeSize:undo];
	}
}

- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor
{
	[self setSize:aSize withOrigin:origin backgroundColor:bgcolor undo:YES];
}

- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor undo:(BOOL)undo
{
	if(undo)
	{
		[undoManager beginUndoGrouping];
	}
	[self _willChangeSize:undo];
	for (id current in cels)
	{
		[current setSize:aSize withOrigin:origin backgroundColor:bgcolor];
	}
	[self _didChangeSize:undo];
	if(undo)
	{
		[undoManager endUndoGrouping];
	}
}

- (NSUndoManager *)undoManager
{
	return undoManager;
}

- (void)setUndoManager:man
{
	undoManager = man;
	[undoManager setGroupsByEvent:NO];
	[cels setValue:man forKey:@"undoManager"];
}

- (void)insertObject:(PXCel *)cel inCelsAtIndex:(NSUInteger)index
{
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	[[undoManager prepareWithInvocationTarget:self] removeCel:cel];
	[cel setUndoManager:undoManager];
  NSSize oldSize = [self size];
	[cels insertObject:cel atIndex:index];
  if(!NSEqualSizes([cel size], oldSize))
  {
    NSSize resultSize = oldSize;
    if([cel size].width > resultSize.width) 
    {
      resultSize.width = [cel size].width;
    }
    if([cel size].height > resultSize.height) 
    {
      resultSize.height = [cel size].height;
    }
    [self setSize:resultSize];
  }
	[undoManager setActionName:NSLocalizedString(@"Add Cel", @"Add Cel")];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)addCel:(PXCel *)cel
{
	[self insertObject:cel inCelsAtIndex:[self countOfCels]];
}

- (void)insertNewCelAtIndex:(NSUInteger)index
{
	PXCel *newCel = [[[PXCel alloc] init] autorelease];
	[newCel setSize:[self size]];
	if(index <= [cels count] && index > 0)
	{
		[[newCel canvas] setGrid:[[[cels objectAtIndex:index - 1] canvas] grid]];
	}
	[self insertObject:newCel inCelsAtIndex:index];	
}

- (void)addNewCel
{
	[self insertNewCelAtIndex:0];
}

- (void)moveCelFromIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2
{
	if(index1 == index2) { return; }
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	id cel = [cels objectAtIndex:index1];
	[cels insertObject:cel atIndex:index2];
	NSUInteger removeIndex = index1;
	if(index1 > index2)
	{
		removeIndex++;
	}
	[cels removeObjectAtIndex:removeIndex];
	[[undoManager prepareWithInvocationTarget:self] moveCelFromIndex:[cels indexOfObject:cel] toIndex:removeIndex];
	[undoManager setActionName:NSLocalizedString(@"Move Cel", @"Move Cel")];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)copyCelFromIndex:(NSUInteger)originalIndex toIndex:(NSUInteger)insertionIndex
{
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	PXCel *cel = [[[self objectInCelsAtIndex:originalIndex] copy] autorelease];
	[cel setUndoManager:undoManager];
	[[undoManager prepareWithInvocationTarget:self] removeCel:cel];
	[cels insertObject:cel atIndex:insertionIndex];
	[undoManager setActionName:NSLocalizedString(@"Copy Cel", @"Copy Cel")];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)removeObjectFromCelsAtIndex:(NSUInteger)index
{
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	[[undoManager prepareWithInvocationTarget:self] insertObject:[self objectInCelsAtIndex:index] inCelsAtIndex:index];
	[cels removeObjectAtIndex:index];
	[undoManager setActionName:NSLocalizedString(@"Delete Cel", @"Delete Cel")];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)removeCel:(PXCel *)cel
{
	[self removeObjectFromCelsAtIndex:[cels indexOfObject:cel]];
}

- (NSImage *)spriteSheetWithCelMargin:(NSUInteger)margin
{
	int fullWidth = [self countOfCels]*[self size].width + ([self countOfCels] - 1)*margin;
  int width = fullWidth; //could change this if multirow sheets were desirable.  they're not.
	int cellsHigh = (int)(ceilf((float)fullWidth/(float)width));
	NSSize imageSize = NSMakeSize(MIN(fullWidth, width), cellsHigh*[self size].height + (cellsHigh - 1)*margin);
	NSImage *spriteSheet = [[[NSImage alloc] initWithSize:imageSize] autorelease];
	NSPoint compositePoint = NSMakePoint(0, imageSize.height - [self size].height);
	int i;
	[spriteSheet lockFocus];
	for (i=0; i<[self countOfCels]; i++) {
    PXCel *cel = [self objectInCelsAtIndex:i];
		[[cel displayImage] compositeToPoint:compositePoint operation:NSCompositeSourceOver];
		compositePoint.x += [cel size].width + margin;
		if (compositePoint.x + [cel size].width > imageSize.width) {
			compositePoint.x = 0;
			compositePoint.y += [cel size].height + margin;
		}
	}
	[spriteSheet unlockFocus];
	return spriteSheet;
}

- (void)reduceColorsTo:(NSUInteger)colors withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor
{
	[PXCanvas reduceColorsInCanvases:[cels valueForKey:@"canvas"] 
						toColorCount:colors
					withTransparency:transparency 
						  matteColor:matteColor];
}

@end
