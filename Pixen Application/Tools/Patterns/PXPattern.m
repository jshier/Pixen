//
//  PXPattern.m
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

//  Created by Ian Henderson on 07.10.04.
//  Copyright 2004 Open Sword Group. All rights reserved.
//

#import "PXPattern.h"


@implementation PXPattern

- copyWithZone:(NSZone *)zone
{
	PXPattern *newPattern = [[PXPattern alloc] init];
	[newPattern setSize:size];
	NSMutableSet *pointsCopy = [points mutableCopy];
	[newPattern setPoints:pointsCopy];
	[pointsCopy release];
	return newPattern;
}

- (id)init
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	points = [[NSMutableSet alloc] init];
	size = NSMakeSize(1, 1);
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if (self != nil) {
		points = [[coder decodeObjectForKey:@"points"] mutableCopy];
		size = [coder decodeSizeForKey:@"size"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:points forKey:@"points"];
	[coder encodeSize:size forKey:@"size"];
}

- (void)dealloc
{
	[points release];
	[pointsInBounds release];
	[super dealloc];
}

- (void)setSize:(NSSize)newSize
{
	size = newSize;
	[pointsInBounds release];
	pointsInBounds = nil;
}

- (void)setPoints:(NSMutableSet *)newPoints
{
	[newPoints retain];
	[points release];
	points = newPoints;
	[pointsInBounds release];
	pointsInBounds = nil;
}

- (NSSize)size
{
	return size;
}

- (BOOL)hasPixelAtPoint:(NSPoint)point
{
	NSString *string = NSStringFromPoint(point);
	return [points containsObject:string];
}

- (void)togglePoint:(NSPoint)point
{
	if ([self hasPixelAtPoint:point]) {
		[self removePoint:point];
	} else {
		[self addPoint:point];
	}
}

- (void)addPoint:(NSPoint)point
{
	[points addObject:NSStringFromPoint(point)];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternChangedNotificationName object:self userInfo:nil];
	[pointsInBounds release];
	pointsInBounds = nil;
}

- (void)removePoint:(NSPoint)point
{
	[points removeObject:NSStringFromPoint(point)];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternChangedNotificationName object:self userInfo:nil];
	[pointsInBounds release];
	pointsInBounds = nil;
}


- (NSArray *)pointsInPattern
{
	if (pointsInBounds == nil) {
		pointsInBounds = [[NSMutableArray alloc] init];
		NSEnumerator *pointEnumerator = [points objectEnumerator];
		NSString *string;
		NSPoint point;
		while ((string = [pointEnumerator nextObject]) != nil) {
			point = NSPointFromString(string);
			if (point.x >= 0 && point.y >= 0 && point.x < [self size].width && point.y < [self size].height) {
				[pointsInBounds addObject:string];
			}
		}
	}
	return pointsInBounds;
}

- (void)drawRect:(NSRect)rect
{
	NSEnumerator *pointEnumerator = [points objectEnumerator];
	NSString *string;
	NSPoint point;
	NSRect pixel;
	pixel.size = NSMakeSize(1,1);
	while ((string = [pointEnumerator nextObject]) != nil) {
		point = NSPointFromString(string);
		pixel.origin = point;
		if (NSIntersectsRect(rect, pixel)) {
			NSRectFill(pixel);
		}
	}
}

@end
