//
//  PXCanvasResizeView.m
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
//

//  Created by Ian Henderson on Wed Jun 09 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXCanvasResizeView.h"
#import <math.h>

@implementation PXCanvasResizeView

- (void)awakeFromNib
{
	cachedImage = [[NSImage imageNamed:@"greybox"] retain];
	scaleTransform = [[NSAffineTransform alloc] init];
	[self setBackgroundColor:[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0]];
}

- (void)dealloc
{
	[backgroundColor release];
	[scaleTransform release];
	[cachedImage release];
	[super dealloc];
}


- (NSRect)applyTransformation:(NSAffineTransform *)transform 
					   toRect:(NSRect)rect
{
	NSRect newRect;
	newRect.size = [transform transformSize:rect.size];
	newRect.origin = [transform transformPoint:rect.origin];
	return newRect;
}

- (void)drawRect:(NSRect)rect
{
	// Find the new size of the canvas
	NSRect newRect = NSMakeRect(0, 0, newSize.width, newSize.height); 
	// Find the old size of the canvas
	NSRect oldRect = NSMakeRect(position.x, newSize.height-(oldSize.height-(position.y*-1)), oldSize.width, oldSize.height); 
	// Find the size we need to display in the view
	NSSize maxSize = NSMakeSize(MAX(newSize.width, oldSize.width), MAX(newSize.height, oldSize.height)); 
	NSSize frameSize = [self frame].size;
	
	// Find the scaling factor by looking at the rect that contains both the new size
	// and old size, then scaling it to fit our frame
	float scale = 1.0f / MAX(maxSize.height / frameSize.height, maxSize.width / frameSize.width); 
	
	oldRect.origin.x = round(oldRect.origin.x);
	oldRect.origin.y = round(oldRect.origin.y);
	
	[scaleTransform release];
	// transform the image-pixel scale to screen-pixel scale
	scaleTransform = [[NSAffineTransform transform] retain]; 
	[scaleTransform scaleBy:scale];
	
	newRect = [self applyTransformation:scaleTransform toRect:newRect]; // transform our rects
	oldRect = [self applyTransformation:scaleTransform toRect:oldRect];
	
	NSAffineTransform *translateTransform = [NSAffineTransform transform];
	// center the view on the new frame
	[translateTransform translateXBy:(frameSize.width - NSWidth(newRect)) / 2 yBy:(frameSize.height - NSHeight(newRect)) / 2]; 
	
	// transform the rects again
	newRect = [self applyTransformation:translateTransform toRect:newRect];
	oldRect = [self applyTransformation:translateTransform toRect:oldRect];
	[[NSColor whiteColor] set];
	NSRectFillUsingOperation(newRect, NSCompositeCopy);
	NSRectFillUsingOperation(oldRect, NSCompositeCopy);
	[backgroundColor set];
	NSRectFillUsingOperation(newRect, NSCompositeSourceOver);
	[[NSColor whiteColor] set];
	NSRectFillUsingOperation(NSIntersectionRect(newRect, oldRect), NSCompositeCopy);
	[cachedImage drawInRect:oldRect 
				   fromRect:NSMakeRect(0, 0, [cachedImage size].width, [cachedImage size].height)
				  operation:NSCompositeSourceOver
				   fraction:1.0f]; // draw the image in the old frame
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect:oldRect]; // draw an outline around the image
	
	NSBezierPath *canvasOutline = [NSBezierPath bezierPathWithRect:newRect];
	CGFloat dashed[2] = {3, 3};
	[canvasOutline setLineDash:dashed count:2 phase:0];
	[canvasOutline stroke]; // draw an outline around the canvas
	[canvasOutline setLineDash:dashed count:2 phase:3];
	[[NSColor whiteColor] set];
	[canvasOutline stroke]; // dash white and black
}

- (NSSize)newSize
{
	return newSize;
}

- (NSPoint)resultPosition
{
	NSPoint roundedPosition = position;
	roundedPosition.x = round(roundedPosition.x);
	roundedPosition.y = round((newSize.height-oldSize.height)-roundedPosition.y);
	return roundedPosition;
}

- (void)setNewImageSize:(NSSize)size
{
	newSize = size;
	[self setNeedsDisplay:YES];
}

- (void)setOldImageSize:(NSSize)size
{
	oldSize = size;
	position = NSMakePoint(0,0);
	[self setNeedsDisplay:YES];
}

- (void)setCachedImage:(NSImage *)image
{
	[cachedImage release];
	cachedImage = [[NSImage alloc] initWithSize:[image size]];
	
	[cachedImage lockFocus];
//	[[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1] set];
//	NSRectFill(NSMakeRect(0,0,[image size].width,[image size].height));
	[image compositeToPoint:NSMakePoint(0, 0) operation:NSCompositeSourceOver];
	[cachedImage unlockFocus];
	
	[self setNeedsDisplay:YES];
}

- backgroundColor
{
	return backgroundColor;
}
- (void)setBackgroundColor:(NSColor *)color
{
	[color retain];
	[backgroundColor autorelease];
	backgroundColor = color;
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{

	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event
{
//FIXME: this is kind of clumsy, doesn't move enough
	NSAffineTransform *affineTransform = [scaleTransform copy];
	[affineTransform invert];
	NSPoint deltaVector = [affineTransform transformPoint:NSMakePoint([event deltaX], [event deltaY])];
	[self setLeftOffset:[self leftOffset] + deltaVector.x];
	[self setTopOffset:[self topOffset] + deltaVector.y];
	[self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)event
{
	NSString *characters = [event charactersIgnoringModifiers];
	NSPoint deltaVector = NSMakePoint(0, 0);
	
	if ([characters characterAtIndex:0] == NSUpArrowFunctionKey) {
		deltaVector.y = 1;
	} else if ([characters characterAtIndex:0] == NSDownArrowFunctionKey) {
		deltaVector.y = -1;
	} else if ([characters characterAtIndex:0] == NSRightArrowFunctionKey) {
		deltaVector.x = 1;
	} else if ([characters characterAtIndex:0] == NSLeftArrowFunctionKey) {
		deltaVector.x = -1;
	} else {
		[super keyDown:event];
		return;
	}
	
	if ([event modifierFlags] & NSShiftKeyMask) {
		deltaVector.x *= 10;
		deltaVector.y *= 10;
	}
	
	[self setLeftOffset:[self leftOffset] + deltaVector.x];
	[self setTopOffset:[self topOffset] - deltaVector.y];
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (int)leftOffset
{
	return position.x;
}
- (void)setLeftOffset:(int)nx
{
	[self willChangeValueForKey:@"rightOffset"];
	position.x = nx;
	[self didChangeValueForKey:@"rightOffset"];
	[self setNeedsDisplay:YES];
}
- (int)topOffset
{
	return position.y;
}
- (void)setTopOffset:(int)nv
{
	[self willChangeValueForKey:@"bottomOffset"];
	position.y = nv;
	[self didChangeValueForKey:@"bottomOffset"];
	[self setNeedsDisplay:YES];
}
- (int)bottomOffset
{
	return -1 * position.y;
}
- (void)setBottomOffset:(int)nv
{
	[self willChangeValueForKey:@"topOffset"];
	position.y = -1 * nv;
	[self didChangeValueForKey:@"topOffset"];
	[self setNeedsDisplay:YES];
}
- (int)rightOffset
{
	return -1 * position.x;
}
- (void)setRightOffset:(int)nv
{
	[self willChangeValueForKey:@"leftOffset"];
	position.x = -1*nv;
	[self didChangeValueForKey:@"leftOffset"];
	[self setNeedsDisplay:YES];
}

@end
