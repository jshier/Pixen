//
//  PXActionButton.m
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
//
//  Created by Andy Matuschak on 4/3/05.

//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXActionButton.h"
#import <AppKit/NSImage.h>

@implementation PXActionButton

- (void)setImage:(NSImage *)image
{
	_image = [image retain];
}

- (void)dealloc
{
	[_image release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
	NSPoint point;
	
	NSSize rectSize = [self frame].size;
	float rectWidth = rectSize.width;
	float rectHeight = rectSize.height;
	
	NSSize imageSize = [_image size];
	float imageWidth = imageSize.width;
	float imageHeight = imageSize.height;
	
	[super drawRect:rect];
	
	point.x = (rectWidth - 18) / 2 - (imageWidth / 2) + 1;
	point.y = (rectHeight / 2) - ( imageHeight / 2) - 1;
	
	[_image drawAtPoint:point
			   fromRect:NSMakeRect(0, 0, imageWidth, imageHeight)
			  operation:NSCompositeSourceOver 
			   fraction:1.0];
}

@end
