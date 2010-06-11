//
//  PXNearestNeighborScaleAlgorithm.m
//  Pixen-XCode

// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

//  Created by Ian Henderson on Thu Jun 10 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXNearestNeighborScaleAlgorithm.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"

@implementation PXNearestNeighborScaleAlgorithm

- (NSString *)name
{
	return @"Nearest Neighbor";
}

- (NSString *)algorithmInfo
{
	return NSLocalizedString(@"NEAREST_NEIGHBOR_INFO", "Nearest Neighbor Info Here");
}

- (BOOL)canScaleCanvas:canvas toSize:(NSSize)size
{
	if (canvas == nil || size.width == 0 || size.height == 0) {
		return NO;
	}
	return YES;
}

- (void)scaleCanvas:canvas toSize:(NSSize)size
{
	if (! canvas ) {
		return;
	}
	NSEnumerator *layerEnumerator = [[canvas layers] objectEnumerator];
	PXLayer *layer, *layerCopy;
	int x, y;
	float xScale = size.width / [canvas size].width;
	float yScale = size.height / [canvas size].height;
	
	NSPoint currentPoint;
	while ( (layer = [layerEnumerator nextObject]) ) {
		layerCopy = [[layer copy] autorelease];
		[layer setSize:size];
		for (x=0; x<size.width; x++) {
			for (y=0; y<size.height; y++) {
				currentPoint = NSMakePoint((int)(x/xScale),(int)(y/yScale));
				[canvas setColor:[layerCopy colorAtPoint:currentPoint]
                 atPoint:NSMakePoint(x, y) 
                 onLayer:layer];
			}
		}
	}
	
	[canvas layersChanged];
	[canvas changed];
}

@end
