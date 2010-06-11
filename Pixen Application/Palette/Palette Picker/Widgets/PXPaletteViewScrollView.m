//
//  PXPaletteViewScrollView.m
//  Pixen
//
//  Created by Andy Matuschak on 8/21/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPaletteViewScrollView.h"
#import "PXPaletteViewSizeSelector.h"

@implementation PXPaletteViewScrollView

- (void)awakeFromNib
{
	sizeSelector = [[PXPaletteViewSizeSelector alloc] initWithFrame:NSMakeRect(0, 0, 15, 29)];
	[sizeSelector setDelegate:[self documentView]];
	[self addSubview:sizeSelector];
}

- (void)dealloc
{
	[sizeSelector release];
	[super dealloc];
}

- (void)tile
{
	[super tile];
	NSRect scrollerRect, sizeSelectorRect;
	scrollerRect = [[self verticalScroller] frame];
	NSDivideRect(scrollerRect, &sizeSelectorRect, &scrollerRect, 29, NSMinYEdge);
	[[self verticalScroller] setFrame:scrollerRect];
	[sizeSelector setFrame:sizeSelectorRect];
	[sizeSelector setNeedsDisplay:YES];
}

- (void)setControlSize:(NSControlSize)size
{
	[sizeSelector setControlSize:size];
	[[self documentView] setControlSize:size];
}

@end
