//
//  PXBackgroundTemplateView.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.03.

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

#import "PXBackgroundTemplateView.h"
#import "PXBackgrounds.h"

@implementation PXBackgroundTemplateView

- (id)initWithFrame:(NSRect)frame
{
	if(!(self = [super initWithFrame:frame]))
        return nil;
    
	[NSBundle loadNibNamed:@"PXBackgroundTemplateView" owner:self];
    [self setAutoresizesSubviews:NO];
	[self addSubview:view];
    
	return self;
}

- (id)init
{
	if (!(self = [self initWithFrame:NSMakeRect(0, 0, 0, 45)])) 
		return nil;
    
	return self;
}

- (void)setFrame:(NSRect)newFrame
{
	[super setFrame:newFrame];
	[view setFrameSize:[self frame].size];
}

- (void)resizeWithOldSuperviewSize:(NSSize)size
{
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] visibleRect]), [self frame].size.height)];
}

- (void)resizeSubviewsWithOldSize:(NSSize)size
{
	[view setFrameSize:[self frame].size];
}

- (PXBackground *)background
{
	return background;
}

- (void)setBackground:(PXBackground *)bg
{
	[background autorelease];
	background = [bg retain];
	if(!bg)
        return;
	[imageView setImage:[background previewImageOfSize:[imageView bounds].size]];
	[imageView display];
	[templateClassName setStringValue:[bg defaultName]];
	[templateName setStringValue:[bg name]];
}

- templateName
{
	return templateName;
}

- templateClassName
{
	return templateClassName;
}

- (void)setHighlighted:(BOOL)highlighted
{
	if(highlighted)
	{
		[templateClassName setTextColor:[NSColor whiteColor]];
		[templateName setTextColor:[NSColor whiteColor]];
	}
	else
	{
		[templateClassName setTextColor:[NSColor disabledControlTextColor]];
		[templateName setTextColor:[NSColor blackColor]];
	}
}

@end
