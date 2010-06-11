//
//  PXCanvas_Drawing.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvas_Drawing.h"
#import "PXLayer.h"
#import "PXCanvas_Selection.h"

@implementation PXCanvas(Drawing)

- (void)drawRect:(NSRect)rect
{
	[self drawInRect:rect fromRect:rect];
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src
{
	[self drawInRect:dst fromRect:src operation:NSCompositeSourceOver];
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(float)frac
{
	id enumerator = [layers objectEnumerator];
	id current;
	while ( (current = [enumerator nextObject]) )
	{
		[current drawInRect:dst fromRect:src operation:op fraction:frac];
	}	
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op
{
	[self drawInRect:dst fromRect:src operation:op fraction:1];
}

- (void)meldBezier:(NSBezierPath *)path ofColor:(NSColor *)color
{
	[activeLayer meldBezier:path ofColor:color];
}

- (void)unmeldBezier
{
	[activeLayer unmeldBezier];
}

@end
