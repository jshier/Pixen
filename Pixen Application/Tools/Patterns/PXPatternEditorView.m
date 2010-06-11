//
//  PXPatternEditorView.m
//  Pixen
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

//  Created by Ian Henderson on 02.07.05.
//  Copyright (c) 2005 Open Sword Group. All rights reserved.
//

#import "PXPatternEditorView.h"
#import "PXPattern.h"
#import "PXGrid.h"
#import "InterpolatePoint.h"


@implementation PXPatternEditorView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		grid = [[PXGrid alloc] initWithUnitSize:NSMakeSize(1,1) color:[NSColor grayColor] shouldDraw:YES];
    }
    return self;
}

- (void)awakeFromNib
{
	[self registerForDraggedTypes:[NSArray arrayWithObject:PXPatternPboardType]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];
	[self setPattern:[NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:PXPatternPboardType]]];
	[delegate patternView:self changedPattern:pattern];
	return YES;
}

- (void)drawRect:(NSRect)rect {
	if (pattern == nil || transform == nil) {
		return;
	}
	[transform concat];
	[pattern drawRect:rect];
	[grid drawRect:rect];
	[transform invert];
	[transform concat];
	[transform invert];
}

- (void)redrawPattern:(NSNotification *)notification
{
	[self setNeedsDisplay:YES];
}

// unfortunately hard-coded to be the initial value in the nib
#define MIN_FRAME_SIZE 233.0f

// any smaller than 2x2 and you can just use the regular brush you bozo
#define MIN_PATTERN_SIZE 2.0f

// also hard-coded; don't let the window get any bigger than this
#define MAX_FRAME_SIZE 512.0f

// 16x16 is as high as it goes.
#define MAX_PATTERN_SIZE 16.0f

#define PATTERN_SIZE_STEP (MAX_PATTERN_SIZE - MIN_PATTERN_SIZE) / (MAX_FRAME_SIZE - MIN_FRAME_SIZE)
#define FRAME_SIZE_STEP  (MAX_FRAME_SIZE - MIN_FRAME_SIZE) / (MAX_PATTERN_SIZE - MIN_PATTERN_SIZE)

- (float)patternSizeForFrameSize:(float)frameSize
{
	return (PATTERN_SIZE_STEP * (frameSize - MIN_FRAME_SIZE)) + MIN_PATTERN_SIZE;
}

- (float)frameSizeForPatternSize:(float)patternSize
{
	return (FRAME_SIZE_STEP * (patternSize - MIN_PATTERN_SIZE)) + MIN_FRAME_SIZE;
}

- (NSSize)resizeToFitWidth:(float)frameSize
{
	if (frameSize < MIN_FRAME_SIZE) {
		frameSize = MIN_FRAME_SIZE;
	}
	if (frameSize > MAX_FRAME_SIZE) {
		frameSize = MAX_FRAME_SIZE;
	}
	float newPatternSize = [self patternSizeForFrameSize:frameSize];
	newPatternSize = floorf(newPatternSize);
	int pixelsPerPatternPixel = frameSize / newPatternSize;
	[transform release];
	transform = [[NSAffineTransform alloc] init];
	[transform scaleBy:pixelsPerPatternPixel];
	[pattern setSize:NSMakeSize(newPatternSize, newPatternSize)];
	[delegate patternView:self changedPattern:pattern];
	return NSMakeSize(pixelsPerPatternPixel * newPatternSize, pixelsPerPatternPixel * newPatternSize);
}

- (NSSize)resizeToFitPattern:(PXPattern *)fitPattern
{
	float patternSize = [fitPattern size].width;
	if (patternSize < MIN_PATTERN_SIZE) {
		patternSize = MIN_PATTERN_SIZE;
	}
	if (patternSize > MAX_PATTERN_SIZE) {
		patternSize = MAX_PATTERN_SIZE;
	}
	float frameSize = [self frameSizeForPatternSize:patternSize];
	frameSize = floorf(frameSize);
	int pixelsPerPatternPixel = frameSize / patternSize;
	[transform release];
	transform = [[NSAffineTransform alloc] init];
	[transform scaleBy:pixelsPerPatternPixel];
	return NSMakeSize(pixelsPerPatternPixel * patternSize, pixelsPerPatternPixel * patternSize);
}

- (NSPoint)convertFromPatternToViewPoint:(NSPoint)point
{
	return [transform transformPoint:point];
}

- (NSPoint)convertFromViewToPatternPoint:(NSPoint)point
{
	[transform invert];
	NSPoint floored = [transform transformPoint:point];
	[transform invert];
	floored.x = floorf(floored.x);
	floored.y = floorf(floored.y);
	return floored;
}

- (NSPoint)convertFromWindowToPatternPoint:(NSPoint)location
{
	return [self convertFromViewToPatternPoint:[self convertPoint:location fromView:nil]];
}

- (void)mouseUp:(NSEvent *)event
{
	[delegate patternView:self changedPattern:pattern];
}

- (void)mouseDown:(NSEvent *)event
{
	initialPoint = [self convertFromWindowToPatternPoint:[event locationInWindow]];
	[pattern togglePoint:initialPoint];
	erasing = ![pattern hasPixelAtPoint:initialPoint];
}

- (void)mouseDragged:(NSEvent *)event
{
	NSPoint finalPoint = [self convertFromWindowToPatternPoint:[event locationInWindow]];
	NSPoint differencePoint = NSMakePoint(finalPoint.x - initialPoint.x, finalPoint.y - initialPoint.y);
    NSPoint currentPoint = initialPoint;
    while(!NSEqualPoints(finalPoint, currentPoint))
    {
		currentPoint = InterpolatePointFromPointByPoint(currentPoint, initialPoint, differencePoint);		
		if (erasing) {
			[pattern removePoint:currentPoint];
		} else {
			[pattern addPoint:currentPoint];
		}
    }
	initialPoint = finalPoint;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[grid release];
	[transform release];
	[super dealloc];
}
	
- (void)setPattern:(PXPattern *)newPattern
{
	if (pattern == newPattern) {
		return;
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	pattern = newPattern;
	[self setNeedsDisplay:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawPattern:) name:PXPatternChangedNotificationName object:pattern];
}

- (void)setDelegate:del
{
	delegate = del;
}

@end
