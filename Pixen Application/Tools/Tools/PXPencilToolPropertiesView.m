//
//  PXPencilToolPropertiesView.m
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

//  Created by Ian Henderson on Wed Mar 17 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXPencilToolPropertiesView.h"
#import "PXCanvasDocument.h"
#import "PXPattern.h"
#import "PXCanvasController.h"
#import "PXNotifications.h"
#import "PXPatternEditorController.h"

@implementation PXPencilToolPropertiesView

-(NSString *)  nibName
{
    return @"PXPencilToolPropertiesView";
}

- (int)lineThickness
{
	return lineThickness;
}

- (IBAction)lineThicknessChanged:(id)sender
{
	lineThickness = [lineThicknessField intValue];
}

- (void)setPattern:(PXPattern *)pattern
{
	[drawingPattern release];
	drawingPattern = [pattern retain];
	[lineThicknessField setEnabled:NO];
	[clearButton setEnabled:YES];
	[modifyButton setTitle:NSLocalizedString(@"MODIFY_PATTERN", @"Modify Pattern…")];
	if([pattern size].width < 2 && [pattern size].height < 2) {
		[self clearPattern:self];
	}
}

- (void)patternEditor:editor finishedWithPattern:(PXPattern *)pattern
{
	if (pattern == nil) {
		return;
	}
	[self setPattern:pattern];
}

- (NSSize)patternSize
{
	if (drawingPattern != nil) {
		return [drawingPattern size];
	}
	return NSZeroSize;
}

- (NSArray *)drawingPoints
{
	return [drawingPattern pointsInPattern];
}

- (IBAction)clearPattern:(id) sender
{
	[drawingPattern release];
	drawingPattern = nil;
	[lineThicknessField setEnabled:YES];
	[clearButton setEnabled:NO];
	[modifyButton setTitle:NSLocalizedString(@"SET_PATTERN", @"Set Pattern…")];
}

- (IBAction)modifyPattern:(id) sender
{
	if (drawingPattern == nil) {
		drawingPattern = [[PXPattern alloc] init];
		[drawingPattern setSize:NSMakeSize([self lineThickness], [self lineThickness])];
		int x, y;
		for (x=0; x<[self lineThickness]; x++) {
			for (y=0; y<[self lineThickness]; y++) {
				[drawingPattern addPoint:NSMakePoint(x, y)];
			}
		}
	}
	
	[patternEditor window];
	[patternEditor setPattern:drawingPattern];
	[patternEditor showWindow:self];
}

- (void)awakeFromNib
{
	[self clearPattern:nil];
	lineThickness = 1;
}

- init
{
	self = [super init];
	if (self) {
		patternEditor = [[PXPatternEditorController alloc] init];
		[patternEditor setDelegate:self];
	}
	return self;
}

- (void)setToolName:name
{
	[patternEditor setToolName:name];
}

- (void)dealloc
{
	[patternEditor release];
	[drawingPattern release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
