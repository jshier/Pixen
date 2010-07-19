//
//  PXColorPickerColorWellCell.m
//  PXColorPicker
//
//  Created by Andy Matuschak on 7/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXColorPickerColorWellCell.h"
#import "NSBezierPath+PXRoundedRectangleAdditions.h"

@interface NSImage (PXTintedImage)
- (NSImage *)tintedImage;
@end

@implementation NSImage (PXTintedImage)
- (NSImage *)tintedImage
{	
	NSImage *tintImage = [[[NSImage alloc] initWithSize:[self size]] autorelease];
	[tintImage lockFocus];
	[[[NSColor blackColor] colorWithAlphaComponent:1] set];
	[[NSBezierPath bezierPathWithRect:(NSRect){NSZeroPoint, [self size]}] fill];
	[tintImage unlockFocus];
	
	NSImage *tintMaskImage = [[[NSImage alloc] initWithSize:[self size]] autorelease];
	[tintMaskImage lockFocus];
	[self compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
	[tintImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceIn];
	[tintMaskImage unlockFocus];
	
	NSImage *newImage = [[[NSImage alloc] initWithSize:[self size]] autorelease];
	[newImage lockFocus];
	[self dissolveToPoint:NSZeroPoint fraction:0.6];
	[tintMaskImage compositeToPoint:NSZeroPoint operation:NSCompositeDestinationAtop];
	[newImage unlockFocus];
	return newImage;
}
@end

@implementation PXColorPickerColorWellCell

- init
{
	[super init];
	smallNewColorImage = [[NSImage imageNamed:@"newcolorsmall"] retain];
	bigNewColorImage = [[NSImage imageNamed:@"newcolorbig"] retain];
	return self;
}

- (void)dealloc
{
	[smallNewColorImage release];
	[bigNewColorImage release];
	[super dealloc];
}

- (void)drawColorSwatchWithFrame:(NSRect)rect inView:(NSView *)view
{
	// Draw that black/white alpha helper and use non-blind compositing. But only if we have to.
	if ([color alphaComponent] != 1)
	{
		BOOL flipped = [view isFlipped];
		NSPoint points[3];
		NSBezierPath *path = [NSBezierPath bezierPath];
		
		// First draw the black triangle, which covers the upper-left portion of the rect.
		points[0] = NSMakePoint(NSMinX(rect), (flipped) ? NSMinY(rect) : NSMaxY(rect));
		points[1] = NSMakePoint(NSMaxX(rect), (flipped) ? NSMinY(rect) : NSMaxY(rect));
		points[2] = NSMakePoint(NSMinX(rect), (flipped) ? NSMaxY(rect) : NSMinY(rect));
		[path appendBezierPathWithPoints:points count:3];
		[[NSColor blackColor] set];
		[path fill];
		
		// Now for the white triangle.
		points[0] = NSMakePoint(NSMaxX(rect), (flipped) ? NSMinY(rect) : NSMaxY(rect));
		points[1] = NSMakePoint(NSMaxX(rect), (flipped) ? NSMaxY(rect) : NSMinY(rect));
		points[2] = NSMakePoint(NSMinX(rect), (flipped) ? NSMaxY(rect) : NSMinY(rect));
		[path removeAllPoints];
		[path appendBezierPathWithPoints:points count:3];
		[[NSColor whiteColor] set];
		[path fill];
		
		// Now composite over the actual color.
		[color set];
		NSRectFillUsingOperation(rect, NSCompositeSourceOver);
	}
	else
	{
		// Nothing fancy's required; just paint the color.
		[color set];
		NSRectFill(rect);
	}
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)aView
{
	BOOL flipped = [aView isFlipped];
	[color set];
	if (index == -1)
	{
		NSImage *image = ([self controlSize] == NSRegularControlSize ? bigNewColorImage : smallNewColorImage);
		[image setFlipped:flipped];
		NSEraseRect(frame);
		if ([self isHighlighted])
		{
			image = [image tintedImage];
		}
		[image drawInRect:frame fromRect:(NSRect){NSZeroPoint, [image size]} operation:NSCompositeCopy fraction:1];
	}
	else
	{
		[self drawColorSwatchWithFrame:frame inView:aView];
	}
	int fontSize = [NSFont systemFontSizeForControlSize:NSMiniControlSize];
	if (index > 9999)
		fontSize = floorf(fontSize * .85);
	NSAttributedString *badgeString = [[[NSAttributedString alloc] initWithString:(index == -1 ? @"new" : [NSString stringWithFormat:@"%d", index])
																	   attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:fontSize], NSFontAttributeName, nil]] autorelease];
	NSSize badgeSize = [badgeString size];	
	badgeSize.width += 6.5;
	badgeSize.height += 0;
	[[[NSColor grayColor] colorWithAlphaComponent:0.5] set];
	NSRect badgeRect = NSMakeRect(NSMaxX(frame) - badgeSize.width - 1.5, flipped ? NSMaxY(frame) - badgeSize.height - 2 : 2, badgeSize.width, badgeSize.height);
	NSFrameRectWithWidthUsingOperation(NSInsetRect(frame, 0, 0), 2, NSCompositeSourceOver);
	
	// Exceuse me for my mdrfkr hardcoded numbers and ternary operators.	
	int verticalTextOffset = (index > 9999) ? 1 : 2;	
	NSBezierPath *indexBadge = [NSBezierPath bezierPathWithRoundedRect:badgeRect cornerRadius:5 inCorners:flipped ? OSBottomLeftCorner : OSTopLeftCorner];
	
	if ([self controlSize] != NSRegularControlSize) { return; }
	
	[[[NSColor grayColor] colorWithAlphaComponent:0.5] set];
	[indexBadge fill];
	
	[badgeString drawAtPoint:NSMakePoint(NSMaxX(frame) - badgeSize.width + 3, flipped ? NSMaxY(frame) - badgeSize.height - verticalTextOffset : verticalTextOffset)];
}

- (NSUInteger)index
{
	return index;
}

- (void)setIndex:(NSUInteger)newIndex
{
	index = newIndex;
}

- (NSColor *)color
{
	return color;
}

- (void)setColor:(NSColor *)newColor
{
	color = newColor;
}

@end
