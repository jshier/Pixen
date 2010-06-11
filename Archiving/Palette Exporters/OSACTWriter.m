//
//  OSACTWriter.m
//  PALExport
//
//  Created by Andy Matuschak on 8/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "OSACTWriter.h"


@implementation OSACTWriter

- init
{
	[NSException raise:@"SingletonError" format:@"OSACTWriter is a singleton; use sharedACTWriter to access the shared instance."];
	return nil;
}

- _init
{
	[super init];
	return self;
}

+ sharedACTWriter
{
	static OSACTWriter *sharedACTWriter = nil;
	if (sharedACTWriter) { return sharedACTWriter; }
	sharedACTWriter = [[OSACTWriter alloc] _init];
	return sharedACTWriter;
}

- (NSData *)palDataForPalette:(PXPalette *)palette
{
	NSMutableData *data = [NSMutableData data];
	int colorCount = PXPalette_colorCount(palette);
	if (colorCount > 256)
	{
		NSLog(@"This palette has more than 256 colors, and the ACT format only supports that many; %d will be truncated.", colorCount-256);
		colorCount = 256;
	}
	int i;
	for (i = 0; i < colorCount; i++)
	{
		NSColor *color = [palette->colors[i].color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		char colorData[3];
		colorData[0] = (int)([color redComponent] * 255);
		colorData[1] = (int)([color greenComponent] * 255);
		colorData[2] = (int)([color blueComponent] * 255);
		[data appendBytes:colorData length:3];
	}
	// ACT files must be exactly 768 bytes, so we pad with black.
	for (; i < 256; i++)
	{
		char colorData[3] = {0, 0, 0};
		[data appendBytes:colorData length:3];
	}
	return data;
}

@end
