//
//  PXPalettePanelPaletteView.m
//  Pixen
//
//  Created by Andy Matuschak on 8/20/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPalettePanelPaletteView.h"
#import "PXColorPickerColorWellCell.h"

@implementation PXPalettePanelPaletteView

- initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];
	return self;
}

- (void)mouseDown:(NSEvent *)event
{
	if ([event modifierFlags] & NSControlKeyMask)
	{
		[self rightMouseDown:event];
	}
	else
	{
		[super mouseDown:event];
	}
}

- (void)mouseUp:(NSEvent *)event
{
	if ([event modifierFlags] & NSControlKeyMask)
	{
		[self rightMouseUp:event];
	}
	else
	{
		[super mouseUp:event];
	}
}

- (void)rightMouseDown:(NSEvent *)event
{
	if(!enabled) { return; }
	int paletteIndex = [self indexOfCelAtPoint:[self convertPoint:[event locationInWindow] fromView:nil]];
	if (paletteIndex == -1) { return; }

	[delegate useColorAtIndex:paletteIndex event:event];
}

// Intentionally no-op:
- (void)rightMouseDragged:(NSEvent *)event {}
- (void)rightMouseUp:(NSEvent *)event {}

@end
