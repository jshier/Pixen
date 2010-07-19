//
//  OSPALWriter.m
//  PALExport
//
//  Created by Andy Matuschak on 8/15/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "OSPALWriter.h"
#import "PXPalette.h"

#pragma pack(1)

typedef struct
{
	unsigned long signature;
	unsigned long fileLength;
	unsigned long riffType;
} OSPALHeader;

@implementation OSPALWriter

- init
{
	[NSException raise:@"SingletonError" format:@"OSPALWriter is a singleton; use sharedPALWriter to access the shared instance."];
	return nil;
}

- _init
{
	[super init];
	return self;
}

+ sharedPALWriter
{
	static OSPALWriter *sharedPALWriter = nil;
	if (sharedPALWriter) { return sharedPALWriter; }
	sharedPALWriter = [[OSPALWriter alloc] _init];
	return sharedPALWriter;
}

- (NSData *)palDataForPalette:(PXPalette *)palette
{
	NSMutableData *data = [NSMutableData data];
	uint32_t length = 24 + (4 * PXPalette_colorCount(palette));
	
	// Construct the header
	OSPALHeader header;
	header.signature = CFSwapInt32HostToLittle('FFIR'); // Magic number for PAL
	header.fileLength = CFSwapInt32HostToLittle(length - 8); // Size of the file minus this long and the previous one.
	header.riffType = CFSwapInt32HostToLittle(' LAP'); // Always the same for palettes
	[data appendBytes:&header length:sizeof(OSPALHeader)];
	
	// Construct the RIFF chunk
	unsigned long riffSignature = CFSwapInt32HostToLittle('atad');
	[data appendBytes:&riffSignature length:4];
	uint32_t chunkSize = CFSwapInt32HostToLittle(length - 20);
	[data appendBytes:&chunkSize length:4];
	
	// The first data long is in two shorts: a palette version and the number of colors in the palette.
	int colorCount = PXPalette_colorCount(palette);
	char riffHeader[4];
	riffHeader[0] = 0;
	riffHeader[1] = 3;
	riffHeader[2] = colorCount % 256;
	riffHeader[3] = colorCount / 256;
	[data appendBytes:riffHeader length:4];
	
	// Write the color data.
	int i;
	for (i = 0; i < colorCount; i++)
	{
		NSColor *color = [palette->colors[i].color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		char colorData[4];
		colorData[0] = (int)([color redComponent] * 255);
		colorData[1] = (int)([color greenComponent] * 255);
		colorData[2] = (int)([color blueComponent] * 255);
		colorData[3] = 0;
		[data appendBytes:colorData length:4];
	}
	
	return data;
}

#pragma pack()

@end
