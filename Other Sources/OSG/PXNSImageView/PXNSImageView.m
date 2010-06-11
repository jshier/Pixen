//  PXNSImageView.m
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

// THE SOFTWdARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "PXNSImageView.h"
#import "OSRectAdditions.h"

@implementation PXNSImageView

- (void)initialize
{
	functionalRect = NSZeroRect;
	shadow = [[NSShadow alloc] init];
	[shadow setShadowBlurRadius:4];
	[shadow setShadowOffset:NSMakeSize(0, -2)];
	[shadow setShadowColor:[NSColor colorWithDeviceWhite:0.2 alpha:1]];	
}

- initWithFrame:(NSRect)rect
{
	[super initWithFrame:rect];
	[self initialize];
	return self;
}

- (void)mouseDown:(NSEvent *) event
{
	[[self superview] mouseDown:event];
}

- (void)rightMouseDown:(NSEvent *) event
{
	[[self superview] rightMouseDown:event];
}

- (void)mouseUp:(NSEvent *) event
{
	[[self superview] mouseUp:event];
}

- (void)rightMouseUp:(NSEvent *) event
{
	[[self superview] rightMouseUp:event];
}

- (void)mouseDragged:(NSEvent *) event
{
	[[self superview] mouseDragged:event];
}

- (void)rightMouseDragged:(NSEvent *) event
{
	[[self superview] rightMouseDragged:event];
}

- (void)awakeFromNib
{
	[self initialize];
}

- (void)dealloc
{
	[shadow release];
	[super dealloc];
}

- (NSSize)scaledSizeForImage:(NSImage *)image
{
	NSSize imageSize = [image size];
	NSSize viewSize = [self bounds].size;
	NSSize size;
	viewSize.width -= 8;
	viewSize.height -= 8;
	if (imageSize.width > imageSize.height)
	{
		if (imageSize.width > viewSize.width)
		{
			size.width = viewSize.width;
			size.height = ceilf(imageSize.height * (viewSize.width / imageSize.width));
		}
		else
			size = imageSize;
	}
	else
	{
		if (imageSize.height > viewSize.height)
		{
			size.height = viewSize.height;
			size.width = ceilf(imageSize.width * (viewSize.height / imageSize.height));
		}
		else
			size = imageSize;
	}
	return size;
}

- (void)setImage:(NSImage *)image
{
	[super setImage:image];
	functionalRect = OSCenterRectInRect((NSRect){NSZeroPoint, [image size]}, [self bounds], 4);	
	scaleFactor = [[self image] size].width / NSWidth(functionalRect);
}

- (NSRect)functionalRect
{
	return functionalRect;
}

- (void)drawRect:(NSRect)rect
{
	[NSGraphicsContext saveGraphicsState];
	// We'll create a blank clipped region to draw a shadow under; we don't want to shadow the image itself.
	[shadow set];
	NSEraseRect(functionalRect);
	[NSGraphicsContext restoreGraphicsState];
	
	NSRect inRect = NSIntersectionRect(rect, functionalRect);
	NSRect fromRect = NSOffsetRect(inRect, -NSMinX(functionalRect), -NSMinY(functionalRect));
	fromRect.origin.x *= scaleFactor;
	fromRect.origin.y *= scaleFactor;
	fromRect.size.width *= scaleFactor;
	fromRect.size.height *= scaleFactor;
	
	[[self image] drawInRect:inRect
					fromRect:fromRect
				   operation:NSCompositeSourceOver
					fraction:1];
}

- (void)setFunctionalRect:(NSRect)fr
{
	functionalRect = fr;
}

@end
