//
//  PXBackgroundPreviewView.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.04.

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

#import "PXBackgroundPreviewView.h"


@implementation PXBackgroundPreviewView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (NSImage *)image
{
	return image;
}

- (void)setImage:(NSImage *)im
{
	[image autorelease];
	image = [im retain];
	NSSize imageSize = [image size];
	NSSize viewSize = [self bounds].size;
	functionalRect.origin = NSZeroPoint;
	if (imageSize.width > imageSize.height)
	{
		if (imageSize.width > viewSize.width)
		{
			functionalRect.size.width = viewSize.width;
			functionalRect.size.height = ceilf(imageSize.height * (viewSize.width / imageSize.width));
		}
		else
			functionalRect.size = imageSize;
	}
	else
	{
		if (imageSize.height > viewSize.height)
		{
			functionalRect.size.height = viewSize.height;
			functionalRect.size.width = ceilf(imageSize.width * (viewSize.height / imageSize.height));
		}
		else
			functionalRect.size = imageSize;
	}
	
	if (NSWidth(functionalRect) < viewSize.width)
		functionalRect.origin.x = ceilf((viewSize.width / 2) - (NSWidth(functionalRect) / 2));
	if (NSHeight(functionalRect) < viewSize.height)
		functionalRect.origin.y = ceilf((viewSize.height / 2) - (NSHeight(functionalRect) / 2));
}

- (void)drawRect:(NSRect)rect
{
	[NSGraphicsContext saveGraphicsState];
	NSShadow *shadow = [[NSShadow alloc] init];
	NSRect rectBounds = NSIntersectionRect(NSInsetRect([self bounds], 5, 5), functionalRect);
	[shadow setShadowBlurRadius:5];
	[shadow setShadowOffset:NSMakeSize(0, -2)];
	[shadow setShadowColor:[NSColor colorWithDeviceWhite:0.2 alpha:1]];
	[[NSColor blackColor] setStroke];
	[[NSColor whiteColor] setFill];
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:rectBounds];
	[path setLineWidth:1.5];
	[path setLineJoinStyle:NSMiterLineJoinStyle];
	[shadow set];
	[path fill];
	[shadow release];
	[NSGraphicsContext restoreGraphicsState];
	[[self image] drawInRect:rectBounds
					fromRect:NSMakeRect(0, 0, [[self image] size].width, [[self image] size].height)
				   operation:NSCompositeSourceOver
					fraction:1];
}

@end
