//
//  PXPaletteViewSizeSelector.m
//  Pixen
//
//  Created by Andy Matuschak on 8/21/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPaletteViewSizeSelector.h"


@implementation PXPaletteViewSizeSelector

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		if ([NSColor currentControlTint] == NSGraphiteControlTint)
		{
			smallImage = [[NSImage imageNamed:@"palette_small_graphite"] retain];
			bigImage = [[NSImage imageNamed:@"palette_big_graphite"] retain];
		}
		else
		{
			smallImage = [[NSImage imageNamed:@"palette_small_aqua"] retain];
			bigImage = [[NSImage imageNamed:@"palette_big_aqua"] retain];
		}
		size = NSRegularControlSize;
    }
    return self;
}

- (void)dealloc
{
	[smallImage release];
	[bigImage release];
	[super dealloc];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
	return YES;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (NSString *)toolTip
{
	return @"Switch to large swatch mode";
}

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData
{
	if (point.y > ceilf(NSHeight([self bounds])/2))
		return NSLocalizedString(@"SHOW_LARGE_COLOR_SWATCHES", @"Show large color swatches");
	else
		return NSLocalizedString(@"SHOW_SMALL_COLOR_SWATCHES", @"Show small color swatches");
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	[self removeAllToolTips];
	NSRect upper, lower;
	NSDivideRect([self bounds], &lower, &upper, NSHeight(frame) / 2, NSMinYEdge);
	lower.size.height--;
	upper.origin.y++;
	upper.size.height--;
	[self addToolTipRect:upper owner:self userData:nil];
	[self addToolTipRect:lower owner:self userData:nil];
}

- (void)updateButtonStateWithEvent:(NSEvent *)event
{
	NSPoint locationInView = [self convertPoint:[event locationInWindow] fromView:nil];
	if (locationInView.y >= (NSHeight([self bounds])/2))
	{
		size = NSRegularControlSize;
	}
	else
	{
		size = NSSmallControlSize;
	}
	[self setNeedsDisplay:YES];	
}

- (void)mouseDown:(NSEvent *)event
{
	[self updateButtonStateWithEvent:event];
}

- (void)mouseDragged:(NSEvent *)event
{
	[self updateButtonStateWithEvent:event];
}

- (void)mouseUp:(NSEvent *)event
{
	[delegate sizeSelector:self selectedSize:size];
}

- (void)setDelegate:aDelegate
{
	delegate = aDelegate;
}

- (void)setControlSize:(NSControlSize)aSize
{
	size = aSize;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
	NSImage *image = (size == NSRegularControlSize ? bigImage : smallImage);
	[image drawInRect:[self bounds] fromRect:(NSRect){NSZeroPoint, [image size]} operation:NSCompositeCopy fraction:1];
}

@end
