//
//  PXInfoPanelController.m
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


// Author : Andy Matuschak 
//on Thu Jul 29 2004.


#import "PXInfoPanelController.h"

#import <Foundation/NSUserDefaults.h>

#import <AppKit/NSColor.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSTextField.h>


static PXInfoPanelController *singleInstance = nil;

@implementation PXInfoPanelController


-(id) init
{
	if ( singleInstance )
    {
		[self dealloc];
		return singleInstance;
    }
	
	if ( ! (self = [super init] ) ) 
		return nil;
	
	if ( ! [NSBundle loadNibNamed:@"PXInfoPanel" owner:self] )
    {
		[self dealloc];
		return nil;
    }
	
	singleInstance = self;
	
	return singleInstance;
}

-(void) awakeFromNib
{
	[panel setBecomesKeyOnlyIfNeeded: YES];
	[panel setFrameAutosaveName:PXInfoPanelFrameAutosaveName];
}


+(id) sharedInfoPanelController
{
	if ( ! singleInstance ) 
		singleInstance = [[self alloc] init]; 
	return singleInstance;
}

- (void)setCanvasSize:(NSSize)size
{
	[width setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"WIDTH", @"Width"), (int)(size.width)]];
	[height setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"HEIGHT", @"Height"), (int)(size.height)]];
}

- (void)setColorInfo:(NSColor *) color
{
	if (color)
	{
		if ([color colorSpaceName] != NSDeviceRGBColorSpace)
			color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace]; 
				
		[red setStringValue:
			[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"RED", @"Red"), (int)([color redComponent] * 255)]];
		[green setStringValue:
			[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"GREEN", @"Green"), (int)([color greenComponent] * 255)]];
		[blue setStringValue:
			[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"BLUE", @"Blue"), (int)([color blueComponent] * 255)]];
		[alpha setStringValue:
			[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"ALPHA", @"Alpha"), (int)([color alphaComponent] * 255)]];
		[hex setStringValue:
			[NSString stringWithFormat:@"%@: #%02X%02X%02X", NSLocalizedString(@"Hex", @"Hex"), (int)([color redComponent] * 255), (int)([color greenComponent] * 255), (int)([color blueComponent] * 255)]];
	}
	else
	{
		[red setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"RED", @"Red")]];
		[green setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"GREEN", @"Green")]];
		[blue setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"BLUE", @"Blue")]];
		[alpha setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"ALPHA", @"Alpha")]];
		[hex setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"Hex", @"Hex")]];
	}
}

- (void)setDraggingOrigin:(NSPoint)point
{
	draggingOrigin = point;
}

- (void)setCursorPosition:(NSPoint)point
{
	NSPoint difference = point;
	difference.x -= draggingOrigin.x;
	difference.y -= draggingOrigin.y;
	
	if ( ( difference.x > 0.1 )  ||  ( difference.x < -0.1 ) ) {
		[cursorX setStringValue:
			[NSString stringWithFormat:@"X: %d (%@%d)", (int)(point.x), difference.x >= 0 ? @"+" : @"", (int)(difference.x)]];
	} 
	else {
		[cursorX setStringValue:[NSString stringWithFormat:@"X: %d", (int)(point.x)]];
	}
	
	if (difference.y > 0.1 || difference.y < -0.1) {
		[cursorY setStringValue:
			[NSString stringWithFormat:@"Y: %d (%@%d)", (int)(point.y), difference.y >= 0 ? @"+" : @"", (int)(difference.y)]];
	} 
	else {
		[cursorY setStringValue:[NSString stringWithFormat:@"Y: %d", (int)(point.y)]];
	}
}

//Accessor
-(NSPanel *) infoPanel
{
	return panel;
}

@end

