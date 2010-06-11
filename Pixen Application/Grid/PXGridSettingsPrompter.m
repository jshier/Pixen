//
//  PXGridSettingsPrompter.m
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
//  Created by Andy Matuschak on Thu Mar 18 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXGridSettingsPrompter.h"
#import "PXDefaults.h"

@implementation PXGridSettingsPrompter

- (id) initWithSize:(NSSize)aSize 
			  color:(NSColor *)aColor
		 shouldDraw:(BOOL)newShouldDraw
{
	if ( ! ( self = [super initWithWindowNibName:@"PXGridSettingsPrompter"] )) 
		return nil;
	
	unitSize = aSize;
	color = aColor;
	shouldDraw = newShouldDraw;
	return self;
}

- (void)setDelegate:(id) newDelegate
{
	delegate = newDelegate;
}

- (void)prompt
{
	[self showWindow:self];
	[[sizeForm cellAtIndex:0] setIntValue:unitSize.width];
	[[sizeForm cellAtIndex:1] setIntValue:unitSize.height];
	[colorWell setColor:color];
	[shouldDrawCheckBox setState:(shouldDraw) ? NSOnState : NSOffState];
	[self update:self];
}

- (IBAction)update:(id)sender
{
	if ([shouldDrawCheckBox state] == NSOnState) {
		[sizeForm setEnabled:YES];
		[colorWell setEnabled:YES];
		[sizeLabel setTextColor:[NSColor blackColor]];
		[colorLabel setTextColor:[NSColor blackColor]];
	} else {
		[sizeForm setEnabled:NO];
		if ([colorWell isActive])
		{
			[[NSColorPanel sharedColorPanel] close];			
		}
		[colorWell setEnabled:NO];
		[sizeLabel setTextColor:[NSColor disabledControlTextColor]];
		[colorLabel setTextColor:[NSColor disabledControlTextColor]];
	}
	[delegate gridSettingsPrompter:self
				   updatedWithSize:NSMakeSize([[sizeForm cellAtIndex:0] intValue], [[sizeForm cellAtIndex:1] intValue]) 
							 color:[colorWell color] 
						shouldDraw:([shouldDrawCheckBox state] == NSOnState) ? YES : NO];
}

- (IBAction)useAsDefaults:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setBool:([shouldDrawCheckBox state] == NSOnState) 
			   forKey:PXGridShouldDrawKey];
	
	[defaults setFloat:[[sizeForm cellAtIndex:0] intValue] 
				forKey:PXGridUnitWidthKey];
	
	[defaults setFloat:[[sizeForm cellAtIndex:1] intValue]
				forKey:PXGridUnitHeightKey];
	
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[colorWell color]] 
				 forKey:PXGridColorDataKey];
	
	[self update:self];
}

- (IBAction)displayHelp:sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"grid" inBook:@"Pixen Help"];	
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([colorWell isActive])
	{
		[[NSColorPanel sharedColorPanel] close];
	}
}

@end
