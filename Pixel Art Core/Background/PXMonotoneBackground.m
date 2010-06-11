//
//  PXMonotoneBackground.m
//  Pixen-XCode
//
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

//  Created by Joe Osborn on Sun Oct 26 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXMonotoneBackground.h"

@implementation PXMonotoneBackground

-(NSString *) defaultName
{
	return NSLocalizedString(@"FLAT_BACKGROUND", @"Flat Background");
}

- (NSString *)nibName
{
    return @"PXMonotoneBackgroundConfigurator";
}

- (void)setConfiguratorEnabled:(BOOL)enabled
{
    [colorWell setEnabled:enabled];
}

- (IBAction)configuratorColorChanged:(id) sender
{
    [self setColor:[sender color]];
    [self changed];
	[cachedImage release];
	cachedImage = nil;
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([colorWell isActive])
		[[NSColorPanel sharedColorPanel] close];
	[colorWell deactivate];
}

- (id) init
{
	if ( ! ( self = [super init] ) ) 
		return nil;
	
	color = [[NSColor whiteColor] retain];
	return self;
}

- (void)dealloc
{
    [self setColor:nil];
    [super dealloc];
}

- (NSColor *) color
{
    return color;
}

- (void)setColor:(NSColor *) aColor
{
    [aColor retain];
    [color release];
    color = aColor;
    if( aColor) 
	{ 
		[colorWell setColor:aColor]; 
	}
}

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect
{
	[color set];
	NSRectFill(rect);
}

- (void)encodeWithCoder:(NSCoder *) coder
{
    [coder encodeObject:color forKey:@"color"];
    [super encodeWithCoder:coder];
}

-(id) initWithCoder:(NSCoder *) coder
{
    [super initWithCoder:coder];
    [self setColor:[coder decodeObjectForKey:@"color"]];
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    id copy = [super copyWithZone:zone];
    [copy setColor:color];
    return copy;
}

@end
