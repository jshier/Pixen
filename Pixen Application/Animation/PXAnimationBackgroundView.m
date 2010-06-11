//
//  PXAnimationBackgroundView.m
//  Pixen
//
//  Created by Andy Matuschak on 10/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "CTGradient.h"
#import "PXAnimationBackgroundView.h"
		
@implementation PXAnimationBackgroundView

- (void)awakeFromNib
{
	horizontalGradient = [[CTGradient gradientWithBeginningColor:[NSColor blackColor] endingColor:[NSColor colorWithDeviceRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1]] retain];
}

- (void)dealloc
{
	[horizontalGradient release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {
	NSRect visibleRect = [self bounds];	
	NSPoint middle = NSMakePoint(NSMidX(visibleRect), NSMidY(visibleRect));
	double leftMiddle = floorf(middle.x - NSWidth(visibleRect)*0.2);
	double rightMiddle = floorf(middle.x + NSWidth(visibleRect)*0.2);
	
	[horizontalGradient fillRect:NSMakeRect(NSMinX(visibleRect), NSMinY(visibleRect), leftMiddle - NSMinX(visibleRect), NSHeight(visibleRect)) angle:0];
	[horizontalGradient fillRect:NSMakeRect(rightMiddle, NSMinY(visibleRect), NSWidth(visibleRect) - rightMiddle, NSHeight(visibleRect)) angle:180];
	
	
	[[NSColor colorWithDeviceRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1] set];
	NSRectFill(NSMakeRect(leftMiddle, NSMinY(visibleRect), rightMiddle - leftMiddle, NSHeight(visibleRect)));
	
	
	NSRect lowerRect = visibleRect;
	lowerRect.size.height /= 2.0;
	
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(NSMinX([filmStrip frame])-1, 0, 1.5, NSHeight([self bounds])));	
	NSRectFill(NSMakeRect(NSMaxX([filmStrip frame]), 0, 1.5, NSHeight([self bounds])));
}

@end
