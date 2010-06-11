//
//  OSPlasticButtonCell.m
//  Pixen
// 
//  Created by Andy Matuschak on 7/18/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "OSPlasticButtonCell.h"
#import "OSRectAdditions.h"

@implementation OSPlasticButtonCell

- (void)dealloc
{
	[glass release];
	[glassHighlighted release];
	[super dealloc];
}

- (void)setupImages
{
	if (glass && glassHighlighted) { return; }
	[self setShowsStateBy:0];
	glass = [[NSImage imageNamed:@"glass"] retain];
	if ([NSColor currentControlTint] == NSGraphiteControlTint)
		glassHighlighted = [[NSImage imageNamed:@"glass-h-graphite"] retain];
	else
		glassHighlighted = [[NSImage imageNamed:@"glass-h"] retain];
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
	[self setupImages];
	NSImage *drawingImage = ([self isHighlighted] || [self state] == NSOnState) ? glassHighlighted : glass;
	[drawingImage setFlipped:[view isFlipped]];
	[drawingImage drawInRect:(NSRect){frame.origin, NSMakeSize(frame.size.width, frame.size.height-1)}
					fromRect:NSMakeRect(0, 0, [drawingImage size].width, [drawingImage size].height)
				   operation:NSCompositeSourceAtop
					fraction:1.0];

	[[NSColor grayColor] set];
	[NSBezierPath setDefaultLineWidth:1];
	
	if (frame.origin.x != 0)
		[NSBezierPath strokeLineFromPoint:NSMakePoint(frame.origin.x+0.5, frame.origin.y)
								  toPoint:NSMakePoint(frame.origin.x+0.5, frame.origin.y+frame.size.height)];
	if (frame.origin.y != 0)
		[NSBezierPath strokeLineFromPoint:NSMakePoint(frame.origin.x, frame.origin.y+0.5)
							  toPoint:NSMakePoint(frame.origin.x+frame.size.width,frame.origin.y+0.5)];
	
	BOOL oldFlipped = [[self image] isFlipped];
	[[self image] setFlipped:[view isFlipped]];
	NSRect centeredFrame = OSCenterRectInRect((NSRect){NSZeroPoint, [[self image] size]}, frame, 2);
	[[self image] drawInRect:centeredFrame
					fromRect:(NSRect){NSZeroPoint, [[self image] size]}
				   operation:NSCompositeSourceOver
					fraction:1];
	[[self image] setFlipped:oldFlipped];
}

@end
