//
//  PXPreviewBezelView.m
//  Pixen-XCode
//
//  Created by Andy Matuschak on 5/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPreviewBezelView.h"

#import <AppKit/NSBezierPath.h>
#import "NSBezierPath+PXRoundedRectangleAdditions.h"

@implementation PXPreviewBezelView

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)setDelegate:newDelegate
{
	[delegate release];
	delegate = [newDelegate retain];
}

- (void)setAlphaValue:(float)newAlpha
{
	alpha = newAlpha;
}

- (float)alphaValue
{
	return alpha;
}

- (void)dealloc
{
	[delegate release];
	[actionGear release];
	[menu release];
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		actionGear = [[NSImage imageNamed:@"actiongear"] retain];
		menu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"PXPreviewBezelMenu", @"PXPreviewBezelMenu")];
		[[menu addItemWithTitle:NSLocalizedString(@"Size To...", @"Size To...") action:@selector(sizeTo:) keyEquivalent:@""] setTarget:delegate];
		[[menu addItemWithTitle:NSLocalizedString(@"Actual Size", @"Actual Size") action:@selector(sizeToActual:) keyEquivalent:@""] setTarget:delegate];
		[menu addItem:[NSMenuItem separatorItem]];
		[[menu addItemWithTitle:NSLocalizedString(@"Set Background...", @"Set Background...") action:@selector(setBackground:) keyEquivalent:@""] setTarget:delegate];
    }
    return self;
}

- (void)drawCapsuleInRect:(NSRect)rect withFillColor:(NSColor *)fillColor outlineColor:(NSColor *)outlineColor
{
	NSRect frame = rect;
	id path = [NSBezierPath bezierPath];
	// is this correct?
	[path appendBezierPathWithOvalInRect:NSInsetRect(NSMakeRect(NSMinX(frame), NSMinY(frame), NSHeight(frame), NSHeight(frame)), 1, 1)];
	[path appendBezierPathWithOvalInRect:NSInsetRect(NSMakeRect(NSMaxX(frame) - NSHeight(frame), NSMinY(frame), NSHeight(frame), NSHeight(frame)), 1, 1)];
	[path appendBezierPathWithRect:NSInsetRect(NSMakeRect(NSMinX(frame) + NSHeight(frame)/2, NSMinY(frame), NSWidth(frame) - NSHeight(frame), NSHeight(frame)), 1, 1)];
	[path setLineWidth:2];
	[outlineColor set];
	[path stroke];
	[fillColor set];
	[path fill];
}

- (void)mouseDown:(NSEvent *)event
{
	[NSMenu popUpContextMenu:menu withEvent:event forView:self];
}

- (void)drawRect:(NSRect)rect {
	id path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(1, 1, 100, 100) cornerRadius:7];
	[[[NSColor lightGrayColor] colorWithAlphaComponent:alpha*.75] set];
	[path fill];
	[[[NSColor darkGrayColor] colorWithAlphaComponent:alpha] set];
	[path stroke];
	[actionGear compositeToPoint:NSMakePoint(3, 1) operation:NSCompositeSourceOver fraction:alpha];
}

@end
