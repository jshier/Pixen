//
//  PXMoveTool.m
//  Pixen-XCode
//

// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


//  Created by Andy Matuschak on Fri Feb 27 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXMoveTool.h"
#import "PXCanvasController.h"
#import "PXCanvas.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"
#import "PXImage.h"

@implementation PXMoveTool

- (NSString *)name
{
	return NSLocalizedString(@"MOVE_NAME", @"Move Tool");
}

-(NSString *) actionName
{
	return NSLocalizedString(@"MOVE_ACTION", @"Moving");
}

- (void)startMovingSelectionFromPoint:(NSPoint)aPoint
	  fromCanvasController:(PXCanvasController *)controller
{
	isMovingSelection = YES;
	id canvas = [controller canvas];
	selectedRect = [canvas selectedRect]; // O(N)
	lastSelectedRect = selectedRect;
	selectionOrigin = selectedRect.origin;
	moveLayer = [[PXLayer alloc] initWithName:NSLocalizedString(@"Temp Layer", @"Temp Layer") size:selectedRect.size];
	[moveLayer setCanvas:canvas];
	[moveLayer setOpacity:[[canvas activeLayer] opacity]];
	// we clear the selected area in the active layer and copy the selected pixels
	// into a pximage of our own to be drawn each frame. whoo.
	// this is O(N), incidentally. but just over selected pixels, not the whole canvas.
	int i, j;
	NSColor *clear = [canvas eraseColor];
	for (i = NSMinX(selectedRect); i < NSMaxX(selectedRect); i++)
	{
		for (j = NSMinY(selectedRect); j < NSMaxY(selectedRect); j++)
		{
			NSPoint point = NSMakePoint(i, j);
			if (![canvas pointIsSelected:point])
				continue;
			
			[canvas setColor:[canvas colorAtPoint:point] 
               atPoint:NSMakePoint(i - selectedRect.origin.x, j - selectedRect.origin.y)
               onLayer:moveLayer];
			[canvas setColor:clear atPoint:point];
		}
	}
	[moveLayer moveToPoint:selectedRect.origin]; // move to initial point
	[canvas insertLayer:moveLayer atIndex:[[canvas layers] indexOfObject:realLayer]+1];
}

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *) controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	origin = aPoint;
	PXCanvas *canvas = [controller canvas];
	[canvas beginUndoGrouping];
	if ([canvas hasSelection])
	{
		[canvas replaceLayer:[canvas activeLayer] withLayer:[[[canvas activeLayer] copy] autorelease] actionName:[self actionName]];
		realLayer = [canvas activeLayer];
		[self startMovingSelectionFromPoint:aPoint fromCanvasController:controller];
	}
	else
	{
		selectionOrigin = NSZeroPoint;
		moveLayer = [canvas activeLayer];
		realLayer = moveLayer;
		[self updateCopyLayerForCanvas:canvas];
	}
}

- (void)updateCopyLayerForCanvas:(PXCanvas *)canvas
{
	if(isCopying)
	{
		if(moveLayer != nil)
		{
			if(copyLayer == nil)
			{
				copyLayer = [moveLayer copy];
				[copyLayer moveToPoint:selectionOrigin];
			}
			if(![[canvas layers] containsObject:copyLayer])
			{
				[canvas insertLayer:copyLayer atIndex:[canvas indexOfLayer:moveLayer]];
				[canvas activateLayer:moveLayer];
			}
		}		
	}
	else
	{
		if(copyLayer != nil && moveLayer != nil && [[canvas layers] containsObject:copyLayer])
		{
			[canvas removeLayer:copyLayer];
		}	
	}	
}

- (void)drawFromPoint:(NSPoint)initialPoint
			  toPoint:(NSPoint)finalPoint
			 inCanvas:(PXCanvas *) canvas
{
	float dx = (finalPoint.x - initialPoint.x), dy = (finalPoint.y - initialPoint.y);
	[self updateCopyLayerForCanvas:canvas];
	if (isMovingSelection)
	{
		selectedRect.origin = NSMakePoint(selectionOrigin.x + dx, selectionOrigin.y + dy);
		[moveLayer moveToPoint:selectedRect.origin];
		[canvas setSelectionOrigin:NSMakePoint(dx, dy)];
		[canvas changedInRect:NSInsetRect(NSUnionRect(selectedRect, lastSelectedRect), -1, -1)];
		lastSelectedRect = selectedRect;
	}
	else
	{
		[[canvas activeLayer] moveToPoint:NSMakePoint(dx, dy)];
		[canvas changedInRect:NSMakeRect(0,0,[canvas size].width,[canvas size].height)];
	}
}

- (BOOL)supportsAdditionalLocking
{
	return YES;
}

- (void)finalDrawFromPoint:(NSPoint)initialPoint
				   toPoint:(NSPoint)finalPoint
				  inCanvas:(PXCanvas *) canvas
{
	if (isMovingSelection)
	{
		isMovingSelection = NO;
		[moveLayer setSize:[canvas size]];
		[moveLayer finalizeMotion];
		if(isCopying && copyLayer != nil)
		{
			[copyLayer setSize:[canvas size]];
			[copyLayer finalizeMotion];
		}
		selectedRect = lastSelectedRect;
		NSUInteger index = [[canvas layers] indexOfObject:moveLayer];
		[canvas mergeDownLayer:moveLayer];
		[moveLayer release];
		if(isCopying && copyLayer != nil)
		{
			[copyLayer release];
			copyLayer = [[canvas layers] objectAtIndex:index-1];
			[canvas mergeDownLayer:copyLayer];
		}
		[canvas finalizeSelectionMotion];
		[canvas changed];
		[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName
															object:canvas];
	}
	else
	{
		[canvas moveLayer:moveLayer byX:[moveLayer origin].x y:[moveLayer origin].y];
		moveLayer = [canvas activeLayer];
		[moveLayer moveToPoint:NSZeroPoint];
		if(isCopying && copyLayer != nil)
		{
			[canvas mergeDownLayer:moveLayer];
			[copyLayer release];
		}
	}
	moveLayer = nil;
	copyLayer = nil;
	realLayer = nil;
	[canvas endUndoGrouping:[self actionName]];
}

- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc
{
	NSPoint nudgeDest = NSZeroPoint;
	int nudgeAmount = 1;
	if(([event modifierFlags] & NSShiftKeyMask) == NSShiftKeyMask)
	{
		nudgeAmount = 10;
	}
	if([[event characters] characterAtIndex:0] == NSUpArrowFunctionKey)
	{
		nudgeDest.y = nudgeAmount;
	}
	else if([[event characters] characterAtIndex:0] == NSRightArrowFunctionKey)
	{
		nudgeDest.x = nudgeAmount;
	}
	else if([[event characters] characterAtIndex:0] == NSDownArrowFunctionKey)
	{
		nudgeDest.y = -nudgeAmount;
	}
	else if([[event characters] characterAtIndex:0] == NSLeftArrowFunctionKey)
	{
		nudgeDest.x = -nudgeAmount;
	}
	if(!NSEqualPoints(nudgeDest, NSZeroPoint))
	{
		[self mouseDownAt:NSZeroPoint fromCanvasController:cc];
		[self mouseDraggedFrom:NSZeroPoint to:nudgeDest fromCanvasController:cc];
		[self mouseUpAt:nudgeDest fromCanvasController:cc];
	}
}


- (BOOL)optionKeyDown
{
	isCopying = YES;
	if(moveLayer == nil || realLayer == nil)
	{
		return YES;
	}
	[self fakeMouseDraggedIfNecessary];
	return YES;
}

- (BOOL)optionKeyUp
{
	isCopying = NO;
	if(moveLayer == nil || realLayer == nil)
	{
		return YES;
	}
	[self fakeMouseDraggedIfNecessary];
	return YES;
}

@end
