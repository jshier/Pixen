//
//  PXWelcomeController.m
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

//  Created by Andy Matuschak on Sat Jun 12 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXWelcomeController.h"

static PXWelcomeController *sharedWelcomeController = nil;

@implementation PXWelcomeController

+(id) sharedWelcomeController
{
	if (! sharedWelcomeController ) 
		sharedWelcomeController = [[self alloc] init];
	
	return sharedWelcomeController;
}

/*---------------------------------------------------------
Constructor:
----------------------------------------------------------- */

-(id) init
{
	if(! ( self = [super initWithWindowNibName:@"PXDiscoverPixen"] ) ) 
		return nil;
	
	tabView = nil;
	itemsList = [[NSMutableDictionary alloc] init];
	baseWindowName = [@"Welcome" retain];
	
	return self;
}


/*-------------------------------------------------------------
Destructor:
---------------------------------------------------------------- */

-(void)	dealloc
{
	[itemsList release];
	[baseWindowName release];
	[super dealloc];
}


-(void)	awakeFromNib
{
	[prev setEnabled:NO];
	[tabView selectTabViewItemAtIndex: 0];
	[tabView setTabViewType:NSNoTabsNoBorder];
}


/*-------------------------------------------------------------------------
setTabView:
Accessor for specifying the tab view to query.
---------------------------------------------------------------------- */

-(void)	setTabView: (NSTabView*)tv
{
	tabView = tv;
}


-(NSTabView*)   tabView
{
	return tabView;
}


/* -------------------------------------------------------------------------
changePanes:
Action for our custom toolbar items that causes the window title to
reflect the current pane and the proper pane to be shown in response to
a click.
--------------------------------------------------------------------- */

-(IBAction)changePanes: (id)sender
{
	[[self window] setTitle: [baseWindowName stringByAppendingString: [sender label]]];
	
	[tabView selectTabViewItemAtIndex: [sender tag]];
}

- (IBAction)next:sender
{
	if ([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] == 0)
    {
		[prev setEnabled:YES];
    }
	
	if ([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] == 7)
	{
		[next setTitle:NSLocalizedString(@"Close", @"Close")];
		[close setHidden:YES];
	}
	
	if ([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] == 8)
	{
		[self close];
	}
	else
	{
		[tabView selectNextTabViewItem:sender];
	}
}

- (IBAction)prev:sender
{
	if ([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] == 1)
	{
		[prev setEnabled:NO];
	}
	
	if ([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] == 8)
	{
		[next setTitle:NSLocalizedString(@"Next", @"Next")];
		[close setHidden:NO];
	}
	[tabView selectPreviousTabViewItem:sender];
}

@end
