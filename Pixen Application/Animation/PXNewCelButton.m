//
//  PXNewCelButton.m
//  Pixen
//
//  Created by Andy Matuschak on 10/25/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXNewCelButton.h"
#import "NSBezierPath+PXRoundedRectangleAdditions.h"

@implementation PXNewCelButton

const float PXPlusButtonSize = 12;
const float PXPlusButtonPadding = 12;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        buttonPath = [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 4, 4) cornerRadius:10] retain];
		[buttonPath setLineWidth:3];
		CGFloat pattern[2] = { 9.0, 3.0 };
		[buttonPath setLineDash:pattern count:2 phase:0.0];
		
		plusPath = [[NSBezierPath bezierPath] retain];
		NSPoint tempPoint = NSMakePoint(NSMaxX([self bounds]) - PXPlusButtonSize/2 - PXPlusButtonPadding, NSMaxY([self bounds]) - PXPlusButtonSize - PXPlusButtonPadding);
		[plusPath moveToPoint:tempPoint];
		tempPoint.y += PXPlusButtonSize;
		[plusPath lineToPoint:tempPoint];
		tempPoint.x -= PXPlusButtonSize/2;
		tempPoint.y -= PXPlusButtonSize/2;
		[plusPath moveToPoint:tempPoint];
		tempPoint.x += PXPlusButtonSize;
		[plusPath lineToPoint:tempPoint];
		[plusPath setLineWidth:2.5];
		
		[self setToolTip:NSLocalizedString(@"ADD_CEL", @"ADD_CEL")];
    }
    return self;
}

- (void)dealloc
{
	[buttonPath release];
	[plusPath release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
    [(state == NSOnState) ? [NSColor whiteColor] : [NSColor lightGrayColor] set];
	[buttonPath stroke];
	[plusPath stroke];
}

- (void)mouseDown:(NSEvent *)event
{
	state = NSOnState;
	[self setNeedsDisplay:YES];
}

- (BOOL)containsWindowPoint:(NSPoint)point
{
	return NSPointInRect([self convertPoint:point fromView:nil], [self bounds]);
}

- (void)mouseDragged:(NSEvent *)event
{
	if ([self containsWindowPoint:[event locationInWindow]])
	{
		if (state == NSOnState) { return; }
		state = NSOnState;
		[self setNeedsDisplay:YES];
	}
	else
	{
		if (state == NSOffState) { return; }
		state = NSOffState;
		[self setNeedsDisplay:YES];
	}
}

- (void)mouseUp:(NSEvent *)event
{
	state = NSOffState;
	[self setNeedsDisplay:YES];
	
	if ([self containsWindowPoint:[event locationInWindow]])
		[delegate newCel:self];
}

@end
