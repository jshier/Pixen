//
//  PXTool.m
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
//  Created by Joe Osborn on Sat Dec 06 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXTool.h"
#import "PXPalette.h"
#import "PXCanvas.h"
#import "PXCanvasController.h"
#import "PXToolSwitcher.h"

@implementation PXTool

- (NSString *)name
{
	return @"";
}

- (void)setSwitcher:(PXToolSwitcher *)aSwitcher 
{
	switcher = aSwitcher; 
}

- init
{
	self = [super init];
	if (self != nil) {
		path = [[NSBezierPath bezierPath] retain];
		wrappedPath = [[NSBezierPath bezierPath] retain];
		color = [[[NSColor blackColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace] retain];
	}
	return self;
}

- (void)dealloc
{
	[wrappedPath release];
	[path release];
	[color release];
	[super dealloc];
}

- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc
{
	//no-op
}

- (void)mouseDownAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController*)controller
{
//FIXME: move undo
	[[controller canvas] beginUndoGrouping];
	isClicking = YES;
}

- (BOOL)shouldUseBezierDrawing
{
	return NO;
}

- (NSBezierPath *)wrappedPath
{
	return wrappedPath;
}

- (NSBezierPath *)path
{
	return path;
}

- (NSColor *)colorForCanvas:(PXCanvas *)aCanvas
{
	return color;
}

- (void)setColor:(NSColor *) aColor
{
	[aColor retain];
	[color release];
	color = aColor;
}

- (NSRect)crosshairRectCenteredAtPoint:(NSPoint)aPoint
{
	return NSMakeRect(aPoint.x, aPoint.y, 1, 1);
}

- (void)recacheColorIfNecessaryFromController:(PXCanvasController*)controller
{
}

- (void)mouseDraggedFrom:(NSPoint)origin 
					  to:(NSPoint)destination 
    fromCanvasController:(PXCanvasController*) controller 
{
}

- (void)mouseMovedTo:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *)controller
{
	
}

- actionName
{
	return NSLocalizedString(@"Drawing", @"Drawing");
}

- (void)mouseUpAt:(NSPoint)point 
fromCanvasController:(PXCanvasController *)controller
{
	isClicking = NO;
//FIXME: move undo
	if ([[[controller canvas] undoManager] groupingLevel] > 0) {
		[[controller canvas] endUndoGrouping:[self actionName]];
	}
}

- (PXToolPropertiesView *)propertiesView 
{ 
	return propertiesView; 
}

- (BOOL)shiftKeyDown 
{ 
	return NO; 
}

- (BOOL)shiftKeyUp 
{ 
	return NO;
}

- (BOOL)optionKeyDown 
{
	return NO; 
}

- (BOOL)optionKeyUp 
{ 
	return NO; 
}

- (BOOL)commandKeyDown 
{
	return NO; 
}

- (BOOL)commandKeyUp 
{ 
	return NO; 
}

- (BOOL)supportsPatterns
{
	return NO;
}

- (void)clearBezier { }

- (void)setPattern:(PXPattern *)pat
{
	
}

@end
