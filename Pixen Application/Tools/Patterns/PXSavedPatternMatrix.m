//
//  PXSavedPatternMatrix.m
//  Pixen
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

//  Created by Ian Henderson on 03.07.05.
//  Copyright (c) 2005 Open Sword Group. All rights reserved.
//

#import "PXSavedPatternMatrix.h"
#import "PXPatternCell.h"
#import "PXPattern.h"

@implementation PXSavedPatternMatrix

- (void)patternsChanged:(NSNotification *)notification
{
	NSMutableArray *oldPatterns = patterns;
	patterns = [[[notification userInfo] objectForKey:@"patterns"] mutableCopy];
	[self setupCells];
	if([patterns count] > [oldPatterns count])
	{
		[self selectCell:[[self cells] objectAtIndex:[patterns count] - 1]];
	}
	[oldPatterns release];
	[self setNeedsDisplay:YES];
}


- initWithWidth:(float)width patternFile:(NSString *)file
{
	self = [super initWithFrame:NSMakeRect(0, 0, width, 1)];
	if (self) {
		patterns = [[NSMutableArray alloc] init];
		id prototype = [[PXPatternCell alloc] init];
		[self setPrototype:prototype];
		[self setSelectionByRect:NO];
		[self setDrawsBackground:YES];
		[self setDrawsCellBackground:YES];
		[self setCellSize:[prototype properSize]];
		[self setAutosizesCells:NO];
		[self setIntercellSpacing:NSZeroSize];
		[self setBackgroundColor:[NSColor whiteColor]];
		[self setMode:NSRadioModeMatrix];
		[self setPatternFile:file];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patternsChanged:) name:PXPatternsChangedNotificationName object:nil];
	}
	return self;
}

- (int)columns
{
	return 3;
}

- (PXPattern *)selectedPattern
{
	return [[self selectedCell] pattern];
}

- (void)setupCells
{
	int columns = [self columns];
	int rows = ceilf((float)[patterns count] / (float)columns);
	NSInteger currentRow = [self selectedRow], currentColumn = [self selectedColumn];
	while([self numberOfRows] < rows)
	{
		[self addRow];
	}
	while([self numberOfColumns] < columns)
	{
		[self addColumn];
	}
	NSUInteger i;
	for (i=0; i<[patterns count]; i++)
	{
		PXPatternCell *patternCell = [[self cells] objectAtIndex:i];
		[patternCell setDelegate:self];
		[patternCell setPattern:[patterns objectAtIndex:i]];
	}
	for (i = [patterns count]; i < columns * rows; i++)
	{
		[[[self cells] objectAtIndex:i] setPattern:nil];
	}
	
	[self renewRows:rows columns:columns];
	NSSize cellSize = [self cellSize];
	NSSize intercellSpacing = [self intercellSpacing];
	NSSize newFrameSize;
	newFrameSize.width = cellSize.width * columns + intercellSpacing.width * (columns-1);
	newFrameSize.height = cellSize.height * rows + intercellSpacing.height * (rows-1);
	[self setFrameSize:newFrameSize];
	
	if (currentRow * currentColumn <= ([self numberOfColumns] * [self numberOfRows]) && [patterns count] != 0)
		[self selectCellAtRow:currentRow column:currentColumn];
}

- (void)addPattern:(PXPattern *)pattern
{
	NSMutableArray *newPatterns = [[patterns mutableCopy] autorelease];
	[newPatterns addObject:[[pattern copy] autorelease]];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName object:self userInfo:[NSDictionary dictionaryWithObject:newPatterns forKey:@"patterns"]];
	[NSKeyedArchiver archiveRootObject:patterns toFile:patternFileName];
}

- (void)removePattern:(PXPattern *)pattern
{
	[patterns removeObject:pattern];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName object:self userInfo:[NSDictionary dictionaryWithObject:patterns forKey:@"patterns"]];
	[NSKeyedArchiver archiveRootObject:patterns toFile:patternFileName];
}

- (void)removeSelectedPattern
{
	[self removePattern:[self selectedPattern]];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)mouseDown:(NSEvent *)event
{
	[super mouseDown:event];
	[[self window] makeFirstResponder:self];
}

- (void)keyDown:(NSEvent *)event
{
	if ([[event characters] isEqualToString: @"\177"] || ([[event characters] characterAtIndex:0] == NSDeleteFunctionKey))
	{
		[self removePattern:[self selectedPattern]];
	}
}

- (void)reloadPatterns
{
	BOOL isDirectory;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:patternFileName isDirectory:&isDirectory] || isDirectory) {
		return;
    }
	[patterns release];
	patterns = [[NSKeyedUnarchiver unarchiveObjectWithFile:patternFileName] mutableCopy];
	
	if ([patterns count] != 0) {
		[self setupCells];
	}
}

- (void)setPatternFile:(NSString *)file
{
	[file retain];
	[patternFileName release];
	patternFileName = file;
	[self reloadPatterns];
}

- (void)dealloc
{
	[patternFileName release];
	[patterns release];
	[super dealloc];
}

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationCopy;
}

@end
