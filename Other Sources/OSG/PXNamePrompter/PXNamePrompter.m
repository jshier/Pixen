//
//  PXNamePrompter.m
//  Pixel Editor
//
//  Created by Open Sword Group on Thu May 01 2003.

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
//  Author : Andy Matuschak 
//  Created  on Tue Dec 09 2003.

#import "PXNamePrompter.h"
#import "PXCanvasView.h"
//FIXME: obsolete, should be removed - I think this is false, since it's still used in PXPalettePanel and PXColorPicker

@implementation PXNamePrompter

- (id) init
{
	if ( ! ( self = [super init] ) ) 
		return nil;
	
	if (! [NSBundle loadNibNamed:@"PXNamePrompt" owner: self] ) {
		NSLog(@"!!! Could not load PXNamePrompt NIB !!!");
		[self dealloc];
		return nil;
	}
	
	return self;
}

- (void)setDelegate: (id)newDelegate
{
	_delegate = newDelegate;
}

- (void)promptInWindow:(NSWindow *) window context:(id)contextInfo
{
	[self promptInWindow:window
				 context:contextInfo 
			promptString:NSLocalizedString(@"Please name the new configuration.", @"Please name the new configuration.")
			defaultEntry:@""];
}

- (void)promptInWindow:(NSWindow *) window
			   context:(id) contextInfo 
		  promptString:(NSString* )string
		  defaultEntry:(NSString *)entry
{
	_context = contextInfo;
	
	[promptString setStringValue:string];
	
	[NSApp beginSheet:panel
	   modalForWindow:window
		modalDelegate:nil 
	   didEndSelector:NULL 
		  contextInfo:NULL];
	
	[nameField setStringValue:entry];
}

+ (NSString *)promptModalWithPromptString:(NSString *)string
{
	return [[[[self alloc] init] autorelease] promptModalWithPromptString:string];
}

- (NSString *)promptModalWithPromptString:(NSString *)string
{
	_runningModal = YES;
	_modalString = nil;
	[promptString setStringValue:string];
	NSInteger result = [NSApp runModalForWindow:panel];
	_runningModal = NO;
	[panel close];
	if (result == NSRunAbortedResponse) {
		return nil;
	} else {
		return [nameField stringValue];
	}
}

//Action from 'use this entered name" button
//TODO probably warm the use if it is empty.
// Maybye do external check or use formater for nameField
- (IBAction)useEnteredName:(id)sender
{
	if([[nameField stringValue] isEqualToString:@""]) 
		return;
	
	if (_runningModal) {
		[NSApp stopModal];
		return;
	}
	
	if( [_delegate respondsToSelector:@selector(prompter:didFinishWithName:context:)] )
		[_delegate prompter:self didFinishWithName:[nameField stringValue] context:_context]; 
	
	[NSApp endSheet:panel];
	[panel close];
}

//Action from 'use this entered name" button
//this method end the sheet (OSX), close the panel 
//and send prompter:didCancelWithContext: to the delegate
- (IBAction)cancel:(id)sender
{
	if (_runningModal) {
		[NSApp abortModal];
		return;
	}
	[NSApp endSheet:panel];
	
	[panel close];
	
	if( [_delegate respondsToSelector:@selector(prompter:didCancelWithContext:)] ) 
		[_delegate prompter:self didCancelWithContext:_context]; 
}

//
// Accessor method
//
-(NSPanel *) namePrompterPanel
{
	return panel;
}

@end
