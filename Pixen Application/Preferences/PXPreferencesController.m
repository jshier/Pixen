//
//  PXPreferencesController.m
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
//  Created by Andy Matuschak on Wed Jun 09 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXPreferencesController.h"
#import "PXHotkeyFormatter.h"
#import "PXDocumentController.h"

@implementation PXPreferencesController

PXPreferencesController * preferences = nil;

+ (PXPreferencesController *) sharedPreferencesController
{
	if(!preferences)
    {
		preferences = [[self alloc] init]; 
    }
	
	return preferences;
}

- (id) init
{
	return [super initWithWindowNibName:@"PXPreferences"];
}

- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults boolForKey:PXCrosshairEnabledKey])
		[crosshairColor setEnabled:YES];
    else
		[crosshairColor setEnabled:NO];
	
	if ([defaults boolForKey:PXAutosaveEnabledKey])
		[autoupdateFrequency setEnabled:YES];
	else 
		[autoupdateFrequency setEnabled:NO];
	
	for(id current in [form cells])
		[current setFormatter:[[[PXHotkeyFormatter alloc] init] autorelease]];
}

- (IBAction)switchCrosshair:(id)sender
{
	if ([sender state] == NSOnState)
		[crosshairColor setEnabled:YES];
	else
		[crosshairColor setEnabled:NO];
}

- (IBAction)switchAutoupdate:(id)sender
{
	[self updateAutoupdate:sender];
    
	if ([sender state] == NSOnState)
		[autoupdateFrequency setEnabled:YES];
	else
		[autoupdateFrequency setEnabled:NO];
}

- (IBAction)updateAutoupdate:(id)sender
{
	[(PXDocumentController *)[NSDocumentController sharedDocumentController] rescheduleAutosave];
}

- (void)controlTextDidChange:(NSNotification *) aNotification
{
	[(PXDocumentController *)[NSDocumentController sharedDocumentController] rescheduleAutosave];
}


@end
