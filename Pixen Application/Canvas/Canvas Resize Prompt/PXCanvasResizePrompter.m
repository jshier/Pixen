//
//  PXCanvasResizePrompter.m
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
//  Created by Ian Henderson on Wed Jun 09 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXCanvasResizePrompter.h"
#import "PXCanvasResizeView.h"


@implementation PXCanvasResizePrompter

- (id) init
{
	if (! ( self = [super initWithWindowNibName:@"PXCanvasResizePrompt"] ) )
		return nil;
	
	return self;
}

- (void)setDelegate:(id) newDelegate
{
	delegate = newDelegate;
}

- (void)promptInWindow:(NSWindow *)window
{
	if([[[NSProcessInfo processInfo] arguments] containsObject:@"-SenTest"]) 
		return; 

	[resizeView setTopOffset:0];
	[resizeView setLeftOffset:0];
	
	[NSApp beginSheet:[self window] 
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}
- backgroundColor
{
	return [resizeView backgroundColor];
}

- (void)setBackgroundColor:(NSColor *)c
{
	[bgColorWell setColor:c];
	[resizeView setBackgroundColor:c];
}

- (IBAction)updateBgColor:(id)sender
{
	[resizeView setBackgroundColor:[bgColorWell color]];
}

- (IBAction)useEnteredFrame:(id)sender
{
	[delegate prompter:self didFinishWithSize:[resizeView newSize] position:[resizeView resultPosition] backgroundColor:[bgColorWell color]];
	[NSApp endSheet:[self window]];
	[self close];
}

- (IBAction)cancel:sender
{
	[NSApp endSheet:[self window]];
	[self close];
}

- resizeView
{
	return resizeView;
}
- widthField
{
	return widthField;
}

- heightField
{
	return heightField;
}

- (IBAction)updateSize:sender
{
//FIXME: Why not float ? 
//Because a canvas that is 32.5 px by 38.2 px doesn't really make sense.
	int width = [[self widthField] intValue];
	int height = [[self heightField] intValue];
	
	[resizeView setNewImageSize:NSMakeSize(width,height)];
}

- (void)setCurrentSize:(NSSize)size
{
	[[self widthField] setIntValue:size.width];
	[[self heightField] setIntValue:size.height];
	
	[resizeView setNewImageSize:size];
	[resizeView setOldImageSize:size];
}

- (IBAction)displayHelp:sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"resize" inBook:@"Pixen Help"];	
}

- (void)setCachedImage:(NSImage *)image
{
	[resizeView setCachedImage:image];
}


@end
