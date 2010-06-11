//
//  PXMagicWandTool.m
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


//  Created by Andy Matuschak on Sat Jun 12 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXMagicWandTool.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvasController.h"
#import "PXTool.h"
#import "PXLayer.h"
#import "PXImage.h"
#import "PXToolSwitcher.h"
#import "PXNotifications.h"

@implementation PXMagicWandTool

- (NSString *)name
{
	return NSLocalizedString(@"MAGICWAND_NAME", @"Magic Wand Tool");
}

- (BOOL)shiftKeyDown
{
	isAdding = YES;
	[switcher setIcon:[NSImage imageNamed:@"magicadd"] forTool:self];
	return YES;
}

- (BOOL)shiftKeyUp
{
	isAdding = NO;
	[switcher setIcon:[NSImage imageNamed:@"magic"] forTool:self];
	return YES;
}

- (BOOL)optionKeyDown
{
	isSubtracting = YES;
	[switcher setIcon:[NSImage imageNamed:@"magicsubtract"] forTool:self];
	return YES;
}

- (BOOL)optionKeyUp
{
	isSubtracting = NO;
	[switcher setIcon:[NSImage imageNamed:@"magic"] forTool:self];
	return YES;
}

-(NSString *) actionName
{
	return NSLocalizedString(@"MAGICWAND_ACTION", @"Selection");
}

- (void)startMovingCanvas:(PXCanvas *) canvas
{
	selectedRect = [canvas selectedRect];
	lastSelectedRect = NSZeroRect;
	isMoving = YES;
}

- (void)stopMovingCanvas:(PXCanvas *) canvas
{
	isMoving = NO;
	selectedRect = lastSelectedRect; 
	[[canvas activeLayer] finalizeMotion];
}

- (BOOL)shouldAbandonFillingAtPoint:(NSPoint)aPoint 
			   fromCanvasController:(PXCanvasController *) controller
{
	return NO;
}

- (void)mouseDownAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *) controller
{
	[[controller canvas] beginUndoGrouping];
	origin = aPoint;
	if([[controller canvas] pointIsSelected:aPoint] && !isSubtracting && !isAdding)
    {
		lastSelectedRect = [[controller canvas] selectedRect];
		[self startMovingCanvas:[controller canvas]];
    }	
	else
    {
		if (!isAdding && !isSubtracting)
		{
			selectedRect = NSZeroRect;
			[[controller canvas] deselect];
		}
		[super mouseDownAt:aPoint fromCanvasController:controller];
    }
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint 
					  to:(NSPoint)finalPoint 
    fromCanvasController:(PXCanvasController *) controller
{
	if(isMoving)
    {
		NSPoint differencePoint = NSMakePoint(finalPoint.x - initialPoint.x, finalPoint.y - initialPoint.y);
		[[controller canvas] translateSelectionMaskByX:differencePoint.x y:differencePoint.y];
		selectedRect.origin.x += differencePoint.x;
		selectedRect.origin.y += differencePoint.y;
		[[controller canvas] changedInRect:NSInsetRect(NSUnionRect(selectedRect, lastSelectedRect), -1, -1)];
		lastSelectedRect = selectedRect;
    }
}

- (void)mouseUpAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *)controller
{
	PXCanvas *canvas = [controller canvas];
	if(isMoving)
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
	else
	{
		[super mouseUpAt:aPoint fromCanvasController:controller];
	}
	[[controller canvas] endUndoGrouping:[self actionName]];
}

- (BOOL)checkSelectionOnCanvas:(PXCanvas *)canvas
{
	return NO;
}	

- (void)fillPixelsInBOOLArray:(NSArray *)fillPoints withColor:(NSColor *)newColor withBoundsRect:(NSRect)bounds ofCanvas:(PXCanvas *)canvas
{
	id indices = [NSMutableArray arrayWithCapacity:[fillPoints count]];
	for (id current in fillPoints)
	{
		[indices addObject:[NSNumber numberWithInt:[current intValue] - [canvas size].width]];
	}
	[canvas setSelectionMaskBit:!isSubtracting atIndices:indices];
	[canvas changedInRect:bounds]; 
}

@end
