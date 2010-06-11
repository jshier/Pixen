//
//  PXLassoTool.m
//  Pixen-XCode

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

//  Created by Joe Osborn on Sat Jun 12 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXLassoTool.h"
#import "PXCanvasController.h"
#import "PXCanvas.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXToolSwitcher.h"

@implementation PXLassoTool

- (NSString *)name
{
	return NSLocalizedString(@"LASSO_NAME", @"Lasso Tool");
}

-(id) init
{
	if (! ( self = [super init] ) ) 
		return nil;
	
	isClicking = NO;
	
	return self;
}

-(NSString *) actionName
{
	return NSLocalizedString(@"LASSO_ACTION", @"Selection");
}

- (NSString *) movingActionName
{
	return NSLocalizedString(@"SELECTION_MOVE_ACTION", @"Moving");
}

- (BOOL)shiftKeyDown
{
	if (!isClicking)
	{
		isAdding = YES;
		[switcher setIcon:[NSImage imageNamed:@"lassoadd"] forTool:self];
	}
	return YES;
}

- (BOOL)shiftKeyUp
{
	if (!isClicking)
	{
		isAdding = NO;
		[switcher setIcon:[NSImage imageNamed:@"lasso"] forTool:self];
	}
	return YES;
}

- (void)drawPixelAtPoint:(NSPoint)point inCanvas:(PXCanvas *) canvas
{
	leftMost = MIN(point.x, leftMost);
	rightMost = MAX(point.x, rightMost);
	bottomMost = MIN(point.y, bottomMost);
	topMost = MAX(point.y, topMost);
	[path appendBezierPathWithRect:NSMakeRect(point.x, point.y, 1, 1)];
	[linePath lineToPoint:point];
}

- (void)drawRectOnTop:(NSRect)rect inView:view
{
	if (!isClicking || isMoving) 
	{
		return; 
	}
	
	[[[NSColor blackColor] colorWithAlphaComponent:0.7f] set];
	
	[path fill];
	[((isSubtracting) ? [NSColor redColor] : [NSColor whiteColor]) set];
	[path setLineWidth:0.1];
	[path stroke];
}

- (BOOL)optionKeyDown
{
	if (!isClicking)
	{
		isSubtracting = YES;
		[switcher setIcon:[NSImage imageNamed:@"lassosubtract"] forTool:self];
	}
	
	return YES;
}

- (BOOL)optionKeyUp
{
	if (!isClicking)
	{
		isSubtracting = NO;
		[switcher setIcon:[NSImage imageNamed:@"lasso"] forTool:self];
	}
	
	return YES;
}

- (void)mouseDownAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController*)controller
{
	isClicking = YES;	
	origin = aPoint;
	leftMost = origin.x;
	rightMost = origin.x;
	bottomMost = origin.y;
	topMost = origin.y;
	
	//have to have an undo grouping here because we're doing multiple selects on the canvas, including the deselect.
	[[controller canvas] beginUndoGrouping];
	if ( ([[controller canvas] pointIsSelected:aPoint] )
		 && (!isAdding && !isSubtracting) )
	{
		[self startMovingCanvas:[controller canvas]];
	}
	else
	{
		if (!isAdding && !isSubtracting)
		{
			[[controller canvas] deselect];
		}
		[path release];
		path = [[NSBezierPath bezierPath] retain];
		[path appendBezierPathWithRect:NSMakeRect(aPoint.x, aPoint.y, 1, 1)];
		[linePath release];
		linePath = [[NSBezierPath bezierPath] retain];
		[linePath moveToPoint:origin];
	}
}

- (void)startMovingCanvas:(PXCanvas *)canvas
{
	isMoving = YES;
	selectedRect = [canvas selectedRect];
	lastSelectedRect = NSZeroRect;
}

- (void)stopMovingCanvas:canvas
{
	isMoving = NO;
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint 
					  to:(NSPoint)finalPoint 
	fromCanvasController:(PXCanvasController *) controller
{
	NSPoint differencePoint = NSMakePoint(finalPoint.x - initialPoint.x, finalPoint.y - initialPoint.y);
	
	NSPoint currentPoint = initialPoint;
	
	if (isMoving)
	{
		[[controller canvas] translateSelectionMaskByX:differencePoint.x y:differencePoint.y];
		selectedRect.origin.x += differencePoint.x;
		selectedRect.origin.y += differencePoint.y;
		[[controller canvas] changedInRect:NSInsetRect(NSUnionRect(selectedRect, lastSelectedRect), -1, -1)];
		lastSelectedRect = selectedRect;
	}
	else
	{
		while(!NSEqualPoints(finalPoint, currentPoint))
		{
			if(differencePoint.x == 0) 
			{
				currentPoint.y += ((differencePoint.y > 0) ? 1 : -1); 
			}
			else if (differencePoint.y == 0) 
			{ 
				currentPoint.x += ((differencePoint.x > 0) ? 1 : -1); 
			}
			else if(abs(differencePoint.x) < abs(differencePoint.y)) 
			{
				currentPoint.y += ((differencePoint.y > 0) ? 1 : -1);
				currentPoint.x = rintf((differencePoint.x/differencePoint.y)*(currentPoint.y-initialPoint.y) + initialPoint.x);
			} 
			else
			{
				currentPoint.x += ((differencePoint.x > 0) ? 1 : -1);
				currentPoint.y = rintf((differencePoint.y/differencePoint.x)*(currentPoint.x-initialPoint.x) + initialPoint.y);
			}
			
			if([[controller canvas] wraps] || NSPointInRect(currentPoint, NSMakeRect(0, 0, [[controller canvas] size].width, [[controller canvas] size].height)))
			{
				[self drawPixelAtPoint:currentPoint inCanvas:[controller canvas]];
			}
		}
		
		[[controller canvas] changedInRect:[path bounds]];
	}
}

- (void)mouseUpAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	PXCanvas *canvas = [controller canvas];
	isClicking = NO;
	if (!isMoving)
	{
		NSMutableArray *indices = [NSMutableArray arrayWithCapacity:1000];
		[linePath closePath];
		int i, j;
		//go from left to right
		for (i = leftMost; i <= rightMost; i++)
		{
			//go from bottom to top
			for (j = bottomMost; j <= topMost; j++)
			{
				NSPoint point = NSMakePoint(i, j);
				if([linePath containsPoint:point])
				{
					[indices addObject:[NSNumber numberWithInt:point.x + ([canvas size].height - point.y - 1) * [canvas size].width]];
				}
			}
		}
		[canvas setSelectionMaskBit:!isSubtracting atIndices:indices];		
		[canvas changedInRect:NSMakeRect(leftMost-8, bottomMost-8, rightMost-leftMost+16, topMost-bottomMost+16)];
	}
	else
	{
		[self stopMovingCanvas:canvas];
		if (NSEqualPoints(origin, aPoint))
		{
			[canvas deselect];
		}
		else
		{	
			[canvas finalizeSelectionMotion];
		}
	}
	[canvas endUndoGrouping:NSLocalizedString(@"Selection", @"Selection")];
	[canvas updateSelectionSwitch];
}

@end
