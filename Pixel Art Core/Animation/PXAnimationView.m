//
//  PXAnimationView.m
//  Pixen
//
//  Created by Andy Matuschak on 8/11/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXAnimationView.h"
#import "PXDocumentController.h"

@implementation PXAnimationView

- (void)dealloc
{
	[previousCel release];
	[super dealloc];
}

- (void)setPreviousCelImage:(NSImage *)image
{
	[previousCel release];
	previousCel = [image retain];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	if (![[NSDocumentController sharedDocumentController] showsPreviousCelOverlay]) { return; }
	if (!previousCel) { return; }
	NSSize previousCelSize = [previousCel size];
	NSRect canvasRect = [self convertFromViewToCanvasRect:[self bounds]];
	if ([canvas wraps])
	{
		int xTiles = 0;
		int yTiles = 0;
		if([canvas wraps])
		{
			while(((xTiles * previousCelSize.width)) < NSWidth(canvasRect)) { xTiles++; }
			if(xTiles % 2 == 0) { xTiles += 1; }
			while(((yTiles * previousCelSize.height)) < NSHeight(canvasRect)) { yTiles++; }
			if(yTiles % 2 == 0) { yTiles += 1; }
		}
		float factor = (zoomPercentage / 100.0);
		NSRect destination = NSMakeRect(0, 0, previousCelSize.width * factor, previousCelSize.height * factor);
		NSRect source = NSMakeRect(0, 0, previousCelSize.width, previousCelSize.height);
		float i, j;
		for (i = 0; i < xTiles; i++)
		{
			for (j = 0; j < yTiles; j++)
			{
				float xLoc = i * previousCelSize.width - ((xTiles * previousCelSize.width - NSWidth(canvasRect)) / 2.0);
				float yLoc = j * previousCelSize.height - ((yTiles * previousCelSize.height - NSHeight(canvasRect)) / 2.0);
				NSAffineTransform *tileTransform = [NSAffineTransform transform];
				[tileTransform translateXBy:xLoc * factor yBy:yLoc * factor];
				[tileTransform concat];
				[previousCel drawInRect:destination fromRect:source operation:NSCompositeSourceOver fraction:0.33];
				[tileTransform invert];
				[tileTransform concat];
			}
		}
	}
	else
	{
		[previousCel drawInRect:rect fromRect:[self convertFromViewToCanvasRect:rect] operation:NSCompositeSourceOver fraction:0.33];      
	}
}

@end
