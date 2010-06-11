//
//  PXQuartzScaleAlgorithm.m
//  Pixen
//
//  Created by Andy Matuschak on 7/21/06.
//  Copyright 2003-2006 Open Sword Group. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "PXQuartzScaleAlgorithm.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"

@implementation PXQuartzScaleAlgorithm

- (NSString *)name
{
	return @"Quartz";
}

- (NSString *)algorithmInfo
{
	return @"This algorithm uses Quartz's built-in scaling behavior.";
}

- (BOOL)canScaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size
{
	if (canvas == nil || size.width == 0 || size.height == 0) 
		return NO;
	
	return YES;
}

- (void)scaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size
{
	if (! canvas ) 
		return;
	
	NSEnumerator *layerEnumerator = [[canvas layers] objectEnumerator];
	PXLayer *layer;	
	while ( ( layer = [layerEnumerator nextObject] ) ) {
		NSImage *newLayerImage = [[[NSImage alloc] initWithSize:size] autorelease];
		int oldOpacity = [layer opacity];
		[layer setOpacity:100];
		[newLayerImage lockFocus];
		[layer drawInRect:(NSRect){NSZeroPoint, size} fromRect:(NSRect){NSZeroPoint, [layer size]} operation:NSCompositeCopy fraction:1];
		[newLayerImage unlockFocus];
		[layer setOpacity:oldOpacity];
			
		[layer setSize:size];
		[canvas applyImage:newLayerImage toLayer:layer];
	}
	[canvas layersChanged];
	[canvas changed];
}

@end