//
//  PXFillTool.m
//  Pixen-XCode
//
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
//  Created by Joe Osborn on Tue Nov 18 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

// This code is based on some from Will Leshner. Thanks, man!

#import "PXFillTool.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasController.h"
#import "PXLayer.h"
#import "PXFillToolPropertiesView.h"
#import "NSColor+PXPaletteAdditions.h"

int CombineAxis(int Xaxis, int Yaxis, int width, int height)
{
	return ((height - Yaxis) * width) + Xaxis;
}	

@implementation PXFillTool

- (NSString *)name
{
	return NSLocalizedString(@"FILL_NAME", @"Fill Tool");
}

-(NSString *)actionName
{
	return NSLocalizedString(@"FILL_ACTION", @"Fill");
}

- init
{
	[super init];
	propertiesView = [[PXFillToolPropertiesView alloc] init];
	return self;
}

- (void)dealloc
{
	[propertiesView release];
	[super dealloc];
}

- (BOOL)commandKeyDown 
{
	[propertiesView willChangeValueForKey:@"contiguous"];
	[propertiesView setValue:[NSNumber numberWithBool:![(PXFillToolPropertiesView *)propertiesView contiguous]] forKey:@"contiguous"];
	[propertiesView didChangeValueForKey:@"contiguous"];
	return NO; 
}

- (BOOL)commandKeyUp 
{ 
	[propertiesView willChangeValueForKey:@"contiguous"];
	[propertiesView setValue:[NSNumber numberWithBool:![(PXFillToolPropertiesView *)propertiesView contiguous]] forKey:@"contiguous"];
	[propertiesView didChangeValueForKey:@"contiguous"];
	return NO; 
}

- (BOOL)shouldAbandonFillingAtPoint:(NSPoint)aPoint
			   fromCanvasController:(PXCanvasController *)controller
{
	if([[self colorForCanvas:[controller canvas]] isEqual:[[controller canvas] colorAtPoint:aPoint]])
		return YES;	
	return NO;
}

- (void)mouseDownAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController*)controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	if([self shouldAbandonFillingAtPoint:aPoint fromCanvasController:controller] || ([self checkSelectionOnCanvas:[controller canvas]] == YES && [[controller canvas] pointIsSelected:aPoint] == NO))
		return;
	
	[self fillPointsFromPoint:aPoint forCanvasController:controller];
	
}

- (void)fillPointsFromPoint:(NSPoint)aPoint forCanvasController:(PXCanvasController *)controller
{
	PXCanvas * canvas = [controller canvas];
	aPoint = [canvas correct:aPoint];
	NSColor * initialColor = [canvas colorAtPoint:aPoint];
	NSColor * fillColor = [self colorForCanvas:[controller canvas]];
	int canvasWidth = [canvas size].width;
	int canvasHeight = [canvas size].height;
	float tolerance = [(PXFillToolPropertiesView *)propertiesView tolerance] / 255.0f;
	BOOL * points = (BOOL *)malloc((canvasWidth + 1) * (canvasHeight + 1) * sizeof(BOOL));
	memset(points, NO, (canvasWidth + 1) * (canvasHeight + 1));
	NSMutableArray * consideredPoints = [[NSMutableArray alloc] initWithCapacity:(canvasWidth * canvasHeight)];
	NSMutableArray * pointsToFill = [[NSMutableArray alloc] initWithCapacity:(canvasWidth * canvasHeight)];
	int index = CombineAxis(aPoint.x, aPoint.y, canvasWidth, canvasHeight);
	points[index] = YES;
	BOOL hasSelection = NO;
	if([self checkSelectionOnCanvas:canvas] == YES)
	{
		hasSelection = YES;
		if([canvas pointIsSelected:aPoint] == NO)
		{
			return;
		}	
	}	
	[canvas clearUndoBuffers];
	[consideredPoints addObject:[NSNumber numberWithInt:CombineAxis(aPoint.x, aPoint.y, canvasWidth, canvasHeight)]];
	[pointsToFill addObject:[NSNumber numberWithInt:CombineAxis(aPoint.x, aPoint.y, canvasWidth, canvasHeight)]];
	int xPointAxis;
	int yPointAxis;
	int leftBound = aPoint.x;
	int rightBound = aPoint.x;
	int upperBound = aPoint.y;
	int lowerBound = aPoint.y;
	NSPoint checkingPoint;
	PXLayer * activeLayer = [canvas activeLayer];
	if ([(PXFillToolPropertiesView *)propertiesView contiguous])
	{
		while([consideredPoints count] != 0)
		{
			xPointAxis = [[consideredPoints lastObject] intValue] % canvasWidth;
			yPointAxis = ([[consideredPoints lastObject] intValue] - ([[consideredPoints lastObject] intValue] % canvasWidth)) / canvasWidth ;
			[consideredPoints removeLastObject];
			checkingPoint = [canvas correct:NSMakePoint(xPointAxis + 1, canvasHeight - yPointAxis)];
			if(points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)] == NO && (hasSelection == NO || [canvas pointIsSelected:checkingPoint] == YES))
			{
				if([[activeLayer colorAtPoint:checkingPoint] distanceTo:initialColor] <= tolerance  && [canvas containsPoint:checkingPoint] == YES)
				{
					NSNumber * pointIndex = [NSNumber numberWithInt:CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)];		
					points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  = YES;
					[consideredPoints addObject:pointIndex];
					[pointsToFill addObject:pointIndex];
					if(checkingPoint.x > rightBound)
					{
						rightBound = checkingPoint.x;
					}
					if(checkingPoint.x < leftBound)
					{
						leftBound = checkingPoint.x;
					}
				}
			}
			checkingPoint = [canvas correct:NSMakePoint(xPointAxis - 1, canvasHeight - yPointAxis)];
			if(points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  == NO && (hasSelection == NO || [canvas pointIsSelected:checkingPoint] == YES))
			{
				if([[activeLayer colorAtPoint:checkingPoint] distanceTo:initialColor] <= tolerance && [canvas containsPoint:checkingPoint] == YES)
				{
					NSNumber * pointIndex = [NSNumber numberWithInt:CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)];		
					points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  = YES;
					[consideredPoints addObject:pointIndex];
					[pointsToFill addObject:pointIndex];
					if(checkingPoint.x > rightBound)
					{
						rightBound = checkingPoint.x;
					}
					if(checkingPoint.x < leftBound)
					{
						leftBound = checkingPoint.x;
					}
				}
			}
			checkingPoint = [canvas correct:NSMakePoint(xPointAxis, canvasHeight - (yPointAxis + 1))];
			if(points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  == NO && (hasSelection == NO || [canvas pointIsSelected:checkingPoint] == YES))
			{
				if([[activeLayer colorAtPoint:checkingPoint] distanceTo:initialColor] <= tolerance  && [canvas containsPoint:checkingPoint] == YES)
				{
					NSNumber * pointIndex = [NSNumber numberWithInt:CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)];
					points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  = YES;
					[consideredPoints addObject:pointIndex];
					[pointsToFill addObject:pointIndex];
					if(checkingPoint.y > upperBound)
					{
						upperBound = checkingPoint.y;
					}
					if(checkingPoint.y < lowerBound)
					{
						lowerBound = checkingPoint.y;
					}
				}
			}
			checkingPoint = [canvas correct:NSMakePoint(xPointAxis, canvasHeight - (yPointAxis - 1))];
			if(points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  == NO && (hasSelection == NO || [canvas pointIsSelected:checkingPoint] == YES))
			{
				if([[activeLayer colorAtPoint:checkingPoint] distanceTo:initialColor] <= tolerance && [canvas containsPoint:checkingPoint] == YES)
				{
					NSNumber * pointIndex = [NSNumber numberWithInt:CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)];
					points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  = YES;
					[consideredPoints addObject:pointIndex];
					[pointsToFill addObject:pointIndex];
					if(checkingPoint.y > upperBound)
					{
						upperBound = checkingPoint.y;
					}
					if(checkingPoint.y < lowerBound)
					{
						lowerBound = checkingPoint.y;
					}
				}
			}
		}
	}
	else
	{
		[pointsToFill removeAllObjects];
		int i;
		leftBound = 0;
		lowerBound = 0;
		rightBound = canvasWidth - 1;
		upperBound = canvasHeight - 1;
		for (i = 0; i < canvasWidth * canvasHeight; i++)
		{
			if ([[activeLayer colorAtIndex:i] distanceTo:initialColor] <= tolerance && (hasSelection == NO || [canvas indexIsSelected:i] == YES))
			{
				[pointsToFill addObject:[NSNumber numberWithInt:i+canvasWidth]]; // not sure why this works...
			}
		}
	}
	NSRect bounds = NSMakeRect(leftBound, lowerBound, rightBound - leftBound + 1, upperBound - lowerBound + 1);
	[self fillPixelsInBOOLArray:pointsToFill withColor:fillColor withBoundsRect:bounds ofCanvas:canvas];
	[consideredPoints release];
	[canvas registerForUndo];
	return;
}



- (BOOL)checkSelectionOnCanvas:(PXCanvas *)canvas
{ 
	return [canvas hasSelection];
}	

- (void)fillPixelsInBOOLArray:(NSArray *)fillPoints withColor:(NSColor *)newColor withBoundsRect:(NSRect)bounds ofCanvas:(PXCanvas *)canvas
{
	int canvasWidth = [canvas size].width;
	id indices = [NSMutableArray arrayWithCapacity:[fillPoints count]];
	for (id current in fillPoints)
	{
		int val = [current intValue];
		int xLoc = val % canvasWidth;
		int yLoc = (val - (val % canvasWidth))/canvasWidth - 1;
		[indices addObject:[NSNumber numberWithInt:xLoc + (yLoc * canvasWidth)]];
	}
	[canvas setColor:newColor atIndices:indices updateIn:bounds];
	[canvas changedInRect:bounds];
}


@end
