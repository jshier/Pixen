//
//  PXPatternEditorController.m
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

//  Created by Ian Henderson on 02.07.05.
//  Copyright (c) 2005 Open Sword Group. All rights reserved.

#import "PXPatternEditorController.h"

#import "PXPattern.h"
#import "PXPatternEditorView.h"
#import "PXSavedPatternMatrix.h"
#import "PathUtilities.h"
#import "PXPatternCell.h"

@implementation PXPatternEditorController


- (void)setDelegate:del
{
	delegate = del;
}

- (NSSize)properContentSize
{
	NSSize viewSize = [view resizeToFitPattern:pattern];
	NSSize contentViewSize = [[[self window] contentView] frame].size;
	NSSize newSize;
	newSize.width = viewSize.width;
	newSize.height = contentViewSize.height + (viewSize.width - contentViewSize.width);
	return newSize;
}

- (void)setPattern:(PXPattern *)pat
{
	[pattern release];
	pattern = [pat copy];
	NSSize patternSize = [pattern size];
	if(patternSize.width < 2) {
		patternSize.width = 2;
	}
	if (patternSize.height < 2) {
		patternSize.height = 2;
	}
	if (!NSEqualSizes([pattern size], patternSize)) {
		[pattern setSize:patternSize];
	}
	if (view) {
		[view setPattern:pattern];
	}
	[[self window] setContentSize:[self properContentSize]];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	NSSize viewSize = [view resizeToFitWidth:proposedFrameSize.width];
	NSSize newSize;
	newSize.width = viewSize.width;
	newSize.height = NSHeight([sender frame]) + (viewSize.width - NSWidth([sender frame]));
	return newSize;
}


- (void)setToolName:name
{
	[toolName autorelease];
	toolName = [name copy];
}

- (void)windowDidLoad
{
	[view setDelegate:self];
	[[self window] setContentAspectRatio:[[self window] contentAspectRatio]];
	[[self window] setContentSize:[self properContentSize]];
	[[self window] setTitle:[NSLocalizedString(@"Pattern Editor: ", @"Pattern Editor:") stringByAppendingString:toolName]];
	
	matrix = [[PXSavedPatternMatrix alloc] initWithWidth:[scrollView contentSize].width patternFile:GetPixenPatternFile()];
	[matrix setDoubleAction:@selector(load:)];
	[matrix setTarget:self];
	[scrollView setDocumentView:matrix];
} 

- (IBAction)displayHelp:sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"patterns" inBook:@"Pixen Help"];	
}

- (IBAction)newPattern:sender
{
	PXPattern *newPattern = [[[PXPattern alloc] init] autorelease];
	[newPattern setSize:NSMakeSize(2, 2)];
	[newPattern togglePoint:NSMakePoint(0, 0)];
	[self setPattern:newPattern];
	[delegate patternEditor:self finishedWithPattern:pattern];
}

- (IBAction)save:sender
{
	[matrix addPattern:pattern];
	[drawer open:self];
}

- (IBAction)load:sender
{
	[self setPattern:[matrix selectedPattern]];
	[delegate patternEditor:self finishedWithPattern:pattern];
}


- (void)deleteSheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
	{
		[matrix removeSelectedPattern];
	}
}

- (IBAction)deleteSelected:sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"DELETE")] setKeyEquivalent:@""];
	NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
	[button setKeyEquivalent:@"\r"];
	[alert setMessageText:NSLocalizedString(@"Really delete pattern?", @"PATTERN_DELETE_PROMPT")];
	[alert setInformativeText:NSLocalizedString(@"This operation cannot be undone.", @"PATTERN_DELETE_INFORMATIVE_TEXT")];
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(deleteSheetDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (void)awakeFromNib
{
	NSSize drawerContentSize = [drawer contentSize];
	NSSize drawerMinSize = [drawer minContentSize];
	NSSize drawerMaxSize = [drawer maxContentSize];
	if (drawerContentSize.width < drawerMinSize.width) {
		drawerContentSize.width = drawerMinSize.width;
	}
	if (drawerContentSize.width > drawerMaxSize.width) {
		drawerContentSize.width = drawerMaxSize.width;
	}
	[drawer setContentSize:drawerContentSize];
}

- init
{
	return [super initWithWindowNibName:@"PXPatternEditor"];
}

- (void)patternView:(PXPatternEditorView *)pv changedPattern:(PXPattern *)pat
{
	if (pat != pattern) {
		[self setPattern:pat];
	}
	[delegate patternEditor:self finishedWithPattern:pat];
}

- (PXPattern *)selectedPattern
{
	return [matrix selectedPattern];
}

@end
