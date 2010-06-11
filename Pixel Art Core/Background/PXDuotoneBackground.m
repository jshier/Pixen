//
//  PXDuotoneBackground.m
//  Pixen-XCode

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
//  Created by Joe Osborn on Tue Oct 28 2003.
//  Copyright (c) 2003 Open Sword xGroup. All rights reserved.
//

#import "PXDuotoneBackground.h"
#import <AppKit/NSColorWell.h>

@implementation PXDuotoneBackground

- (NSString *)nibName
{
    return @"PXDuotoneBackgroundConfigurator";
}

- (void)setConfiguratorEnabled:(BOOL)enabled
{
    [backWell setEnabled:enabled];
    [super setConfiguratorEnabled:enabled];
}

- (IBAction)configuratorBackColorChanged:(id)sender
{
    [self setBackColor:[sender color]];
    [self changed];
	[cachedImage release];
	cachedImage = nil;
}

- (void)setBackColor:(NSColor *)aColor
{
	[aColor retain];
	[backColor release];
	backColor = aColor;
	if(aColor) 
	{ 
		[backWell setColor:aColor]; 
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
	[super windowWillClose:notification];
	if ([backWell isActive])
		[[NSColorPanel sharedColorPanel] close];
	[backWell deactivate];
}

-(id) init
{
	if ( ! ( self = [super init] )) 
		return nil;
	
	[self setColor:[NSColor lightGrayColor]];
	[self setBackColor:[NSColor whiteColor]];
	
	return self;
}

-(id) copyWithZone:(NSZone *)zone
{
	id copy = [super copyWithZone:zone];
	[copy setBackColor:backColor];
	
	return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:backColor forKey:@"backColor"];
	[super encodeWithCoder:coder];
}

-(id) initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	[self setBackColor:[coder decodeObjectForKey:@"backColor"]];
	return self;
}

- (void)dealloc
{
	[self setBackColor:nil];
	[super dealloc];
}

@end
