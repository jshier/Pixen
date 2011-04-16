//
//  PXLinearTool.m
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

//
//  Created by Ian Henderson on Mon Mar 15 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXLinearTool.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvasController.h"
#import "PXCanvasDocument.h"

@implementation PXLinearTool
-(id) init
{
	if (! ( self = [super init] ) ) 
		locked = NO;
	
	centeredOnOrigin = NO;
	return self;
}

- (NSPoint)transformOrigin:(NSPoint)origin withDrawingPoint:(NSPoint)aPoint
{
	if (centeredOnOrigin) {
		//  .      *      .
		//  3      10     17
		return NSMakePoint(2*origin.x - aPoint.x, 2*origin.y - aPoint.y);
	}
	return _origin;
}

- (void)fakeMouseDraggedIfNecessary
{
	// kind of a HACK
	if (isClicking)
	{
//FIXME: coupled
		[self mouseDraggedFrom:_origin to:_lastPoint fromCanvasController:[[[NSDocumentController sharedDocumentController] currentDocument] canvasController]];
	}
}

- (BOOL)shiftKeyDown
{
    locked = YES;
	[self fakeMouseDraggedIfNecessary];
    return YES;
}

- (BOOL)shiftKeyUp
{
	locked = NO;
	[self fakeMouseDraggedIfNecessary];
	return YES;
}

- (BOOL)optionKeyDown
{
	centeredOnOrigin = YES;
	[self fakeMouseDraggedIfNecessary];
	return YES;
}

- (BOOL)optionKeyUp
{
	centeredOnOrigin = NO;
	[self fakeMouseDraggedIfNecessary];
	return YES;
}

- (BOOL)drawsInitialPixel
{
	return NO;
}

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *)controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	path = [[NSBezierPath bezierPath] retain];
	wrappedPath = [[NSBezierPath bezierPath] retain];
	_origin = aPoint;
}

- (void)finalDrawFromPoint:(NSPoint)origin
				   toPoint:(NSPoint)finalPoint
				  inCanvas:(PXCanvas *) canvas
{
    // General class, no implementation.
}

- (void)drawFromPoint:(NSPoint)origin 
			  toPoint:(NSPoint)finalPoint
			 inCanvas:(PXCanvas *)canvas
{
    // General class, no implementation. Besides this.
}

- (BOOL)supportsAdditionalLocking
{
    return NO;
}

- (NSPoint)lockedPointFromUnlockedPoint:(NSPoint)unlockedPoint 
							 withOrigin:(NSPoint)origin
{
	NSPoint modifiedFinal = unlockedPoint;
	if (locked) {
		float slope = (unlockedPoint.y - origin.y) / (unlockedPoint.x - origin.x);
		if ([self supportsAdditionalLocking]) {
			if (fabs(slope) < .25) {
				//y constant
				modifiedFinal.y = origin.y;
				return modifiedFinal;
			} else if (fabs(slope) < .75) {
				//x=2y ((but why do we need the +1??))
				modifiedFinal.x = origin.x + (slope > 0 ? 1 : -1) * 2 * (modifiedFinal.y-origin.y) + (unlockedPoint.x > origin.x ? 1 : -1);
				return modifiedFinal;
			} else if (fabs(slope) < 1.5) {
				//x=y
				modifiedFinal.x = origin.x + (slope > 0 ? 1 : -1) * (modifiedFinal.y - origin.y);
				return modifiedFinal;
			} else if (fabs(slope) < 3) {
				//y=2x ((but why do we need the +1??))
				modifiedFinal.y = origin.y + (slope > 0 ? 1 : -1) * 2 * (unlockedPoint.x-origin.x) + (unlockedPoint.x > origin.x ? 1 : -1);
				return modifiedFinal;
			} else {
				//x constant
				modifiedFinal.x = origin.x;
				return modifiedFinal;
			}
		}
		if (slope < 0) { // different diagonal
			modifiedFinal.x = origin.x - (unlockedPoint.y - origin.y);
		} else {
			modifiedFinal.x = origin.x + (unlockedPoint.y - origin.y);
		}
	}
	return modifiedFinal;
}

- (BOOL)drawsInitialPoint
{
	return FALSE;
}

- (void)mouseUpAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *)controller
{
	isClicking = NO;
	[path release];
	path = nil;
	[wrappedPath release];
	wrappedPath = nil;
	NSPoint origin = [self transformOrigin:_origin withDrawingPoint:[self lockedPointFromUnlockedPoint:aPoint withOrigin:_origin]];
	
	[self finalDrawFromPoint:origin
					 toPoint:[self lockedPointFromUnlockedPoint:aPoint withOrigin:origin] 
					inCanvas:[controller canvas]];
	
	[super mouseUpAt:aPoint fromCanvasController:controller];
}

- (BOOL)shouldUseBezierDrawing
{
	return isClicking;
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint 
					  to:(NSPoint)finalPoint 
    fromCanvasController:(PXCanvasController *)controller
{
	_lastPoint = finalPoint;
	NSPoint origin = [self transformOrigin:_origin withDrawingPoint:[self lockedPointFromUnlockedPoint:finalPoint withOrigin:_origin]];
	if (!NSEqualPoints(initialPoint, finalPoint)) 
    {
		[path removeAllPoints];
		[wrappedPath removeAllPoints];
		[self drawFromPoint:origin 
					toPoint:[self lockedPointFromUnlockedPoint:finalPoint withOrigin:origin]
				   inCanvas:[controller canvas]];
	}
	NSRect updateRect = lastBounds;
	if (path != nil && ![path isEmpty]) {
		updateRect = NSUnionRect(updateRect, [path bounds]);
		lastBounds = [path bounds];
	} else {
		lastBounds = NSZeroRect;
	}
	if (!NSEqualRects(updateRect, NSZeroRect)) {
		[[controller canvas] changedInRect:updateRect];
	}
}
@end
