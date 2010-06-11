//
//  OSJASCPALWriter.m
//  PALExport
//
//  Created by Andy Matuschak on 8/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "OSJASCPALWriter.h"


@implementation OSJASCPALWriter

- init
{
	[NSException raise:@"SingletonError" format:@"OSJASCPALWriter is a singleton; use sharedJASCPALWriter to access the shared instance."];
	return nil;
}

- _init
{
	[super init];
	return self;
}

+ sharedJASCPALWriter
{
	static OSJASCPALWriter *sharedJASCPALWriter = nil;
	if (sharedJASCPALWriter) { return sharedJASCPALWriter; }
	sharedJASCPALWriter = [[OSJASCPALWriter alloc] _init];
	return sharedJASCPALWriter;
}

- (NSData *)palDataForPalette:(PXPalette *)palette
{
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:"JASC-PAL\n0100\n" length:14]; // Header and version
	int colorCount = PXPalette_colorCount(palette);
	char countString[5];
	sprintf(countString, "%d\n", colorCount);
	[data appendBytes:countString length:strlen(countString)];
	int i;
	for (i = 0; i < colorCount; i++)
	{
		NSColor *color = [palette->colors[i].color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		char colorString[12];
		sprintf(colorString, "%d %d %d\n", (int)([color redComponent] * 255), (int)([color greenComponent] * 255), (int)([color blueComponent] * 255));
		[data appendBytes:colorString length:strlen(colorString)];
	}
	return data;
}

@end
