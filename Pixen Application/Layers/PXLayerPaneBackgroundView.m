//
//  PXLayerPaneBackgroundView.m
//  Pixen
//
//  Created by Andy Matuschak on 6/28/05.
//  Copyright 2007 Open Sword Group. All rights reserved.
//

#import "PXLayerPaneBackgroundView.h"
#import "CTGradient.h"

@implementation PXLayerPaneBackgroundView

- initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];
	gradient = [[CTGradient aquaNormalGradient] retain];
	return self;
}

- (void)dealloc
{
	[gradient release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
	NSRect targetRect = NSMakeRect(0, 0, NSWidth([self bounds]), 23);
	[gradient fillRect:NSIntersectionRect(rect, targetRect) angle:90];
}

@end
