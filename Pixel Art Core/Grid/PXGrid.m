//
//  PXGrid.m
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

//  Created by Andy Matuschak on Wed Mar 17 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXGrid.h"

@implementation PXGrid

-(id) init
{
	[super init];
	[self setDefaultParameters];
	return self;
}

-(id) initWithUnitSize:(NSSize)newUnitSize
				 color:(NSColor*)newColor
			shouldDraw:(BOOL)newShouldDraw;
{
	[self init];
	if(newColor)
	{
		[self setUnitSize:newUnitSize];
		[self setColor:newColor];
		[self setShouldDraw:newShouldDraw];		
	}
	return self;
}

- initWithCoder:(NSCoder *)coder
{
	return [self initWithUnitSize:[coder decodeSizeForKey:@"gridUnitSize"] color:[coder decodeObjectForKey:@"gridColor"] shouldDraw:[coder decodeBoolForKey:@"gridShouldDraw"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeBool:[self shouldDraw] forKey:@"gridShouldDraw"];
	[coder encodeSize:[self unitSize] forKey:@"gridUnitSize"];
	[coder encodeObject:[self color] forKey:@"gridColor"];	
}

- (void)drawRect:(NSRect)drawingRect
{
	if (!shouldDraw) 
		return; 
	
	NSSize dimensions = drawingRect.size;
	int i;
	float lineWidth = [NSBezierPath defaultLineWidth];;
	BOOL oldShouldAntialias = [[NSGraphicsContext currentContext] shouldAntialias];
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[NSBezierPath setDefaultLineWidth:0];
	[color set];
	
	for (i = 0; i < dimensions.width + unitSize.width; i+=unitSize.width)
    {
		[NSBezierPath strokeLineFromPoint:NSMakePoint(i, 0) 
								  toPoint:NSMakePoint(i, dimensions.height)];
    }
	
	for (i = 0; i < dimensions.height + unitSize.height; i+=unitSize.height)
    {
		[NSBezierPath strokeLineFromPoint:NSMakePoint(0, i) 
								  toPoint:NSMakePoint(dimensions.width, i)];
    }
	
	[NSBezierPath setDefaultLineWidth:lineWidth];
	[[NSGraphicsContext currentContext] setShouldAntialias:oldShouldAntialias];	
}

- (NSSize)unitSize
{
	return unitSize;
}

- (NSColor *)color
{
	return color;
}

- (BOOL)shouldDraw
{
	return shouldDraw;
}

- (void)setShouldDraw:(BOOL)newShouldDraw
{
	shouldDraw = newShouldDraw;
}

- (void)setColor:(NSColor *)newColor
{
	[color autorelease];
	color = [newColor retain];
}

- (void)setUnitSize:(NSSize)newUnitSize
{
	unitSize = newUnitSize;
}

- (void)setDefaultParameters
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(! [defaults objectForKey:PXGridColorDataKey] )
	{
		[self setShouldDraw:NO];
		[self setUnitSize:NSMakeSize(1,1)];
		[self setColor:[NSColor blackColor]];
	}
	else
	{
		NSSize uS;
		uS.width = [defaults floatForKey:PXGridUnitWidthKey];
		uS.height = [defaults floatForKey:PXGridUnitHeightKey];
		
		[self setShouldDraw:[defaults boolForKey:PXGridShouldDrawKey]];
		[self setUnitSize:uS];
		
		[self setColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:PXGridColorDataKey]]];	
	}
}

- copyWithZone:(NSZone *)zn
{
	id copy = [[PXGrid allocWithZone:zn] initWithUnitSize:unitSize color:color shouldDraw:shouldDraw];
	return copy;
}

@end
