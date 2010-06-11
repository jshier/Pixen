//
//  NSColor+PXPaletteAdditions.m
//  Pixen
//
//  Created by Andy Matuschak on 7/2/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "NSColor+PXPaletteAdditions.h"


@implementation NSColor(PXPaletteAdditions)

  //we have to use this to keep the hash in the 0..65535 range
- (unsigned int)paletteHash
{
  CGFloat comps[4];
  [self getComponents:comps];
	unsigned int r = comps[0]*255;
	unsigned int g = comps[1]*255;
	unsigned int b = comps[2]*255;
	unsigned int a = comps[3]*255;
	return (r * g) ^ (b * a);
}

- (float)distanceTo:(NSColor *)other
{
	NSColor *here = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	NSColor *there = [other colorUsingColorSpaceName:NSDeviceRGBColorSpace];
  CGFloat hereC[4], thereC[4];
  [here getComponents:hereC];
  [there getComponents:thereC];
  
  float r = hereC[0]-thereC[0];
  float g = hereC[1]-thereC[1];
  float b = hereC[2]-thereC[2];
  float a = hereC[3]-thereC[3];

	return fabsf(r) + fabsf(g) + fabsf(b) + fabsf(a);
}

@end
