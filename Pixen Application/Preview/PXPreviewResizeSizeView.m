//
//  PXPreviewResizeSizeView.m
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
//  Created by Andy Matuschak on Wed Jun 09 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.


//  Created by Ian Henderson on Fri Jul 16 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXPreviewResizeSizeView.h"


@implementation PXPreviewResizeSizeView

- (id) initWithFrame:(NSRect)frame
{
	if ( ! ( self = [super initWithFrame:frame]) ) 
		return nil;
	
	shadow = [[NSShadow alloc] init];
	[shadow setShadowBlurRadius:1];
	[shadow setShadowOffset:NSMakeSize(0, 0)];
	[shadow setShadowColor:[NSColor blackColor]];
	[self updateScale:0];
	return self;
}

- (void)dealloc
{
	[shadow release];
	[super dealloc];
}

- (BOOL)updateScale:(float)scale
{
	if (scale > 100000) {
		return NO;
	}
	[scaleString release];
	scaleString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%%", (int)(scale * 100)] attributes:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"Verdana" size:20], NSFontAttributeName,
		[NSColor blackColor], NSForegroundColorAttributeName,
		//shadow, NSShadowAttributeName,
		nil]];
	[self setNeedsDisplay:YES];
	return YES;
}

- (void)drawRect:(NSRect)rect
{
//dontreadthisoritwillhurtyourhead, evidently.
	[[NSColor clearColor] set];
	NSRectFill([self frame]);
	NSRect frame = [self frame];
	NSBezierPath *background = [NSBezierPath bezierPath];
	NSPoint stringPoint = frame.origin;
	float x = NSMinX(frame), y = NSMinY(frame), width = NSWidth(frame), height = NSHeight(frame), maxX = NSMaxX(frame);
	if (height >= width) {
		[background appendBezierPathWithOvalInRect:frame];
	} else {
		NSRect leftSide = NSMakeRect(x, y, height, height);
		NSRect rightSide = NSMakeRect(maxX - height, y, height, height);
		NSRect middle = NSMakeRect(x + (height / 2.0f), y, width - height, height);
		NSRect topLeftCorner = NSMakeRect(x, y+(height/2), height/2, height/2);
		
		[background appendBezierPathWithOvalInRect:leftSide];
		[background appendBezierPathWithOvalInRect:rightSide];
		[background appendBezierPathWithRect:middle];
		
		[background appendBezierPathWithRect:topLeftCorner];
	}
	stringPoint.x += (width - [scaleString size].width) / 2;
	stringPoint.y += (height - [scaleString size].height) / 2 + [scaleString size].height / 9;
	[[NSColor whiteColor] set];
	[background fill];
	[scaleString drawAtPoint:stringPoint];
}

- (NSSize)scaleStringSize
{
	NSSize size = [scaleString size];
	return NSMakeSize(size.width * 1.3, size.height);
}

@end
