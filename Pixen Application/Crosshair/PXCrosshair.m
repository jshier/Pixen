//
//  PXCrosshair.m
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
//  Created by Ian Henderson on Fri Jun 11 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXCrosshair.h"
#import "PXToolPaletteController.h"
#import "PXTool.h"
#import "PXDefaults.h"
#import <AppKit/NSGraphicsContext.h>
#import <AppKit/NSBezierPath.h>
#import <AppKit/NSColor.h>

@implementation PXCrosshair

- (void)drawRect:(NSRect)drawingRect withTool:tool tileOffset:(NSPoint)offset
{
	if (![self shouldDraw]) 
		return; 
	
	NSRect rect = [tool crosshairRectCenteredAtPoint:cursorPosition];
	rect.origin.x += offset.x;
	rect.origin.y += offset.y;
	
	BOOL oldShouldAntialias = [[NSGraphicsContext currentContext] shouldAntialias];
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	float lineWidth = [NSBezierPath defaultLineWidth];
	[NSBezierPath setDefaultLineWidth:0];
	[[self color] set];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(rect), NSMinY(drawingRect)) 
							  toPoint:NSMakePoint(NSMinX(rect), NSMaxY(drawingRect))];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(drawingRect), NSMinY(rect)) 
							  toPoint:NSMakePoint(NSMaxX(drawingRect), NSMinY(rect))];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(rect), NSMinY(drawingRect))
							  toPoint:NSMakePoint(NSMaxX(rect), NSMaxY(drawingRect))];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(drawingRect), NSMaxY(rect)) 
							  toPoint:NSMakePoint(NSMaxX(drawingRect), NSMaxY(rect))];
	
	[NSBezierPath setDefaultLineWidth:lineWidth];
	
	[[NSGraphicsContext currentContext] setShouldAntialias:oldShouldAntialias];     
}

- (NSColor *)color
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSData *colorData = [defaults objectForKey:PXCrosshairColorKey];
	
	if (!colorData)
    {
		colorData = [NSArchiver archivedDataWithRootObject:[NSColor redColor]];
		[defaults setObject:colorData forKey:PXCrosshairColorKey];
	}
	
	return [NSUnarchiver unarchiveObjectWithData:colorData];
}

- (BOOL)shouldDraw
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	return [defaults boolForKey:PXCrosshairEnabledKey];
}

- (NSPoint)cursorPosition
{
	return cursorPosition;
}

- (void)setCursorPosition:(NSPoint)position
{
	cursorPosition = position;
}

@end
