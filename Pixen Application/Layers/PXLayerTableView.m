//
//  PXLayerTableView.m
//  Pixen
//
//  Created by Andy Matuschak on 6/19/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXLayerTableView.h"
#import "PXLayerDetailsView.h"
#import "SubviewTableViewController.h"

@implementation PXLayerTableView

- (void)keyDown:(NSEvent*)theEvent { 
	if ([[theEvent characters] isEqualToString: @"\177"]) {
		[[self delegate] deleteKeyPressedInTableView:self];
	}
	[super keyDown:theEvent];
}

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (void)resizeWithOldSuperviewSize:(NSSize)size
{
	[super resizeWithOldSuperviewSize:size];
	[self display];
}

- (NSImage *)dragImageForRows:(NSArray *)dragRows event:(NSEvent *)dragEvent dragImageOffset:(NSPointPointer)dragImageOffset
{
	PXLayerDetailsView *view = (PXLayerDetailsView *)[[self delegate] tableView:self viewForRow:[[dragRows objectAtIndex:0] intValue]];
	
	NSColor *oldOpacityColor = [[view opacityText] textColor];
	NSColor *oldNameColor = [[view name] textColor];
	[[view name] setTextColor:[NSColor blackColor]];
	[[view opacityText] setTextColor:[NSColor blackColor]];
	
	NSData *viewData = [view dataWithPDFInsideRect:[view bounds]];
	[[view opacityText] setTextColor:oldOpacityColor];
	[[view name] setTextColor:oldNameColor];
	NSImage *viewImage = [[[NSImage alloc] initWithData:viewData] autorelease];
	NSImage *bgImage = [[[NSImage alloc] initWithSize:[view bounds].size] autorelease];
	[bgImage lockFocus];
	[[[NSColor whiteColor] colorWithAlphaComponent:0.66] set];
	NSRectFill([view bounds]);
	[[[NSColor lightGrayColor] colorWithAlphaComponent:0.66] set];
	[[NSBezierPath bezierPathWithRect:[view bounds]] stroke];
	[viewImage compositeToPoint:NSZeroPoint fromRect:[view bounds] operation:NSCompositeSourceOver fraction:0.66];
	[bgImage unlockFocus];
	
	NSPoint locationInView = [view convertPoint:[dragEvent locationInWindow] fromView:nil];
	locationInView.x -= NSWidth([view frame]) / 2;
	locationInView.x *= -1;
	locationInView.y -= NSHeight([view frame]) / 2;
	locationInView.y *= -1;
	*dragImageOffset = locationInView;
	return bgImage;
}

@end
