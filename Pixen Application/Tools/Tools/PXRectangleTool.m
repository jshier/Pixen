//
//  PXRectangleTool.m
//  Pixen-XCode

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
//  Created by Andy Matuschak on Wed Mar 10 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXRectangleTool.h"
#import "PXCanvasController.h"
#import "PXPalette.h"
#import "PXRectangleToolPropertiesView.h"
#import "PXCanvas_Modifying.h"

@implementation PXRectangleTool

- (NSString *)name
{
	return NSLocalizedString(@"RECTANGLE_NAME", @"Rectangle Tool");
}

-(NSString *) actionName
{
	return NSLocalizedString(@"RECTANGLE_ACTION", @"Drawing Rectangle");
}

-(id) init
{
	if (! (self = [super init]) )
		return nil;
	
	propertiesView = [[PXRectangleToolPropertiesView alloc] init];
	return self;
}


- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *) controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	lastRect = NSMakeRect(_origin.x, _origin.y, 0, 0);
}

- (void)drawRect:(NSRect)aRect inCanvas:(PXCanvas *) aCanvas
{
    int i, j;
    for (i = NSMinX(aRect); i < NSMaxX(aRect); i++)
	{
		for (j = NSMinY(aRect); j < NSMaxY(aRect); j++)
		{
			[self drawPixelAtPoint:NSMakePoint(i, j) inCanvas:aCanvas];
		}
    }
}

- (void)drawFromPoint:(NSPoint)origin
			  toPoint:(NSPoint)aPoint
			 inCanvas:(PXCanvas *)canvas
		   shouldFill:(BOOL)shouldFill
{
	int borderWidth = [(PXRectangleToolPropertiesView *)propertiesView borderWidth];
	float leftMost = (origin.x < aPoint.x) ? origin.x : aPoint.x;
	float rightMost = (origin.x < aPoint.x) ? aPoint.x: origin.x;
	float topMost = (origin.y < aPoint.y) ? aPoint.y: origin.y;
	float bottomMost = (origin.y < aPoint.y) ? origin.y : aPoint.y;
	rightMost++;
	topMost++;
	if (rightMost - borderWidth < leftMost) {
		borderWidth = rightMost - leftMost;
	}
	if (topMost - borderWidth < bottomMost) {
		borderWidth = topMost - bottomMost;
	}
	if (shouldFill)
    {
		// careful about backwards-drawn rectangles...
		NSColor * oldColor = [self colorForCanvas:canvas];
		if (![(PXRectangleToolPropertiesView *)propertiesView shouldUseMainColorForFill]) 
		{ 
			color = [(PXRectangleToolPropertiesView *)propertiesView fillColor];
		}
		[self drawRect:NSMakeRect(leftMost + borderWidth,
								  bottomMost + borderWidth,
								  rightMost - leftMost - 2*borderWidth,
								  topMost - bottomMost - 2*borderWidth)
			  inCanvas:canvas];
		color = oldColor;
    }
	[self drawRect:NSMakeRect(leftMost, bottomMost, rightMost - leftMost, borderWidth) inCanvas:canvas];
	[self drawRect:NSMakeRect(leftMost, topMost-borderWidth, rightMost - leftMost, borderWidth) inCanvas:canvas];
	[self drawRect:NSMakeRect(leftMost, bottomMost, borderWidth, topMost - bottomMost) inCanvas:canvas];
	[self drawRect:NSMakeRect(rightMost-borderWidth, bottomMost, borderWidth, topMost - bottomMost) inCanvas:canvas];
}

- (void)finalDrawFromPoint:(NSPoint)origin 
				   toPoint:(NSPoint)aPoint
				  inCanvas:(PXCanvas *)canvas
{
	[self drawFromPoint:origin toPoint:aPoint inCanvas:canvas shouldFill:[(PXRectangleToolPropertiesView *)propertiesView shouldFill]];
}

- (void)drawFromPoint:(NSPoint)origin 
			  toPoint:(NSPoint)aPoint
			 inCanvas:(PXCanvas *)canvas
{
	[super drawFromPoint:origin toPoint:aPoint inCanvas:canvas];
	[self drawFromPoint:origin toPoint:aPoint inCanvas:canvas shouldFill:NO];
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint
					  to:(NSPoint)finalPoint
    fromCanvasController:(PXCanvasController *)controller
{
    NSPoint backupOrigin = _origin;
    [super mouseDraggedFrom:initialPoint 
						 to:finalPoint
	   fromCanvasController:controller];
    _origin = backupOrigin;
}

- (BOOL)supportsPatterns
{
	return NO;
}

@end
