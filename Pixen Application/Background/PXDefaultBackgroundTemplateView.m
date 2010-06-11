//
//  PXDefaultBackgroundTemplateView.m
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

#import "PXDefaultBackgroundTemplateView.h"
#import "NSBezierPath+PXRoundedRectangleAdditions.h"

@implementation PXDefaultBackgroundTemplateView

- (void)dealloc
{
	[backgroundTypeText release];
	[super dealloc];
}

- (NSString *)backgroundTypeText
{
	return backgroundTypeText;
}

- (void)setBackgroundTypeText:(NSString *)typeText;
{
	[backgroundTypeText autorelease];
	backgroundTypeText = [typeText retain];
	[templateClassName setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Default %@", @"Default %@"), backgroundTypeText]];
}

- (void)setActiveDragTarget:(BOOL)adt
{
	activeDragTarget = adt;
	[self setNeedsDisplay:YES];
}

- (void)setBackground:(PXBackground *)bg
{
	[super setBackground:bg];
	if (bg == nil)
	{
		[templateName setHidden:YES];
		[templateClassName setHidden:YES];
		[imageView setHidden:YES];
	}
	else
	{
		[templateName setHidden:NO];
		[templateClassName setHidden:NO];
		[imageView setHidden:NO];
	}
	
	if (backgroundTypeText)
	{
		[self setBackgroundTypeText:backgroundTypeText];
	}
	[self setNeedsDisplay:YES];
}

- (void)drawDottedOutline
{
	NSBezierPath *dottedPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 7, 7)
														  cornerRadius:10];
	[dottedPath setLineWidth:2];
	float pattern[2] = { 9.0, 3.0 };
	[dottedPath setLineDash:pattern count:2 phase:0.0];
	[[(highlighted ? [NSColor whiteColor] : [NSColor lightGrayColor]) colorWithAlphaComponent:0.5] set];
	[dottedPath stroke];	
}

- (void)drawNoDefaultText
{
	NSSize stringSize = NSMakeSize(180, 20);
	NSRect drawFrame;
	drawFrame.origin = NSMakePoint(NSWidth([self bounds]) / 2 - stringSize.width / 2, NSHeight([self bounds]) / 2 - stringSize.height / 2);
	drawFrame.size = stringSize;
	
	NSTextFieldCell *textCell = [[NSTextFieldCell alloc] init];
	[textCell setAlignment:NSCenterTextAlignment];
	[textCell setTextColor:(highlighted) ? [NSColor whiteColor] : [NSColor disabledControlTextColor]];
	[textCell setStringValue:NSLocalizedString(@"Default Alternate Background", @"ALTERNATE_BACKGROUND_INFO")];
	[textCell drawWithFrame:drawFrame inView:self];
}

- (void)drawRect:(NSRect)rect
{
	if (activeDragTarget)
	{
		NSFrameRectWithWidth([self bounds], 3);
	}
	
	if (background == nil)
	{
		[self drawDottedOutline];
		[self drawNoDefaultText];
	}
	else
	{
		[super drawRect:rect];
	}
}

- (void)setHighlighted:(BOOL)h
{
	highlighted = h;
	[super setHighlighted:highlighted];
}

@end
