//
//  PXLayerTextField.m
//  Pixen
//
//  Created by Andy Matuschak on 6/28/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXLayerTextField.h"


@implementation PXLayerTextField

- (void)resetCursorRects
{
	// no-op on purpose; we don't want the text cursor showing up over this
	return;
}

- (void)useEditAppearance
{
	reachedByClicking = NO;
	[self setBackgroundColor:[NSColor whiteColor]];
	[self setDrawsBackground:YES];
	[self setBezeled:YES];
	[self setSelectable:YES];
	[self setEditable:YES];
	[self setTextColor:[NSColor blackColor]];
	isEditing = YES;
	isFirstEnd = YES;
	NSRect frame = [self frame];
	frame.origin.y += 3;
	frame.origin.x -= 2;
	[self setFrame:frame];	
}

- (void)mouseDown:(NSEvent *)event
{
	if (isEditing) { return; }
	if ([event clickCount] < 2)
	{
		[self abortEditing];
		[[self superview] mouseDown:event];
		return;
	}
	[self useEditAppearance];
	reachedByClicking = YES;
	[super mouseDown:event];
}

- (void)rightMouseDown:(NSEvent *) event
{
	[[self superview] rightMouseDown:event];
}

- (void)rightMouseUp:(NSEvent *) event
{
	[[self superview] rightMouseUp:event];
}

- (void)setTextColor:(NSColor *)color
{
	// silly table tries to override things
	if (isEditing)
		[super setTextColor:[NSColor blackColor]];
	else
		[super setTextColor:color];
}

- (BOOL)textShouldBeginEditing:text
{
	return [super textShouldBeginEditing:text];
}

- (void)textDidEndEditing:(NSNotification *)notification
{
	if (reachedByClicking && isFirstEnd)
	{
		isFirstEnd = NO;
		return;
	}
	isEditing = NO;
	[self setDrawsBackground:NO];
	[self setBezeled:NO];
	[self setTextColor:[NSColor whiteColor]];
	[super textDidEndEditing:notification];
	[self abortEditing];
	[self setFocusRingType:NSFocusRingTypeNone];
	[self setSelectable:NO];
	NSRect frame = [self frame];
	frame.origin.y -= 3;
	frame.origin.x += 2;
	[self setFrame:frame];		
}

@end
