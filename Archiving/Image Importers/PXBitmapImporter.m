//
//  PXBitmapImporter.m
//  Pixen
//
//  Created by Andy Matuschak on 8/25/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXBitmapImporter.h"

const int PXBMPBitcountPosition = 28;
const int PXBMPColorTablePosition = 54;
const int PXBMPColorCountPosition = 46;

@implementation PXBitmapImporter

- init
{
	[NSException raise:@"Invalid initializer" format:@"OSProgressPopup is a singleton; use [PXBitmapImporter sharedBitmapImporter] to access the shared instance."];
	return nil;
}

- _init
{
	[super init];
	return self;
}

+ sharedBitmapImporter
{
	static PXBitmapImporter *sharedBitmapImporter = nil;
	if (!sharedBitmapImporter)
		sharedBitmapImporter = [[PXBitmapImporter alloc] _init];
	return sharedBitmapImporter;
}

- (BOOL)bmpDataHasColorTable:(NSData *)data
{
	if (!data || [data length] < 28) { return NO; }
	const unsigned char *bitmapData = [data bytes];
	return (bitmapData[PXBMPBitcountPosition] == 8);
}

- (NSArray *)colorsInBMPData:(NSData *)data
{
	if (![self bmpDataHasColorTable:data]) { return nil; }
	const unsigned char *bitmapData = [data bytes];
	
	long colorCount = bitmapData[PXBMPColorCountPosition];
	colorCount += (bitmapData[PXBMPColorCountPosition + 1] * 256);
	colorCount += (bitmapData[PXBMPColorCountPosition + 2] * 256 * 256);
	colorCount += (bitmapData[PXBMPColorCountPosition + 3] * 256 * 256 * 256);
	if (colorCount == 0) { colorCount = 256; }
	
	id colorArray = [NSMutableArray array];
	int i;
	for (i = 0; i < colorCount; i++)
	{
		int base = PXBMPColorTablePosition + i*4;
		unsigned char red = bitmapData[base + 2];
		unsigned char green = bitmapData[base + 1];
		unsigned char blue = bitmapData[base + 0];
		
		[colorArray addObject:[NSColor colorWithDeviceRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1]];
	}
	return colorArray;
}

@end
