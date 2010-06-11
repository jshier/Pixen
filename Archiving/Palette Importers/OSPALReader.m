//
//  OSPALReader.m
//  PALExport
//
//  Created by Andy Matuschak on 8/15/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "OSPALReader.h"


@implementation OSPALReader

- init
{
	[NSException raise:@"SingletonError" format:@"OSPALReader is a singleton; use sharedPALReader to access the shared instance."];
	return nil;
}

- _init
{
	[super init];
	return self;
}

+ sharedPALReader
{
	static OSPALReader *sharedPALReader = nil;
	if (sharedPALReader) { return sharedPALReader; }
	sharedPALReader = [[OSPALReader alloc] _init];
	return sharedPALReader;
}

- (PXPalette *)paletteWithData:(NSData *)data
{
	const unsigned char * bytes = [data bytes];
	if (bytes[0] != 'R' || bytes[1] != 'I' || bytes[2] != 'F' || bytes[3] != 'F')
	{
		[NSException raise:@"OSFileError" format:@"Passed data does not contain a Microsoft palette"];
		return NULL;
	}
	int colorCount = bytes[22] + (bytes[23] * 256);
	int i;
	PXPalette *palette = PXPalette_alloc();
	PXPalette_initWithoutBackgroundColor(palette);
	PXPalette_setName(palette, @"Imported palette");
	for (i = 0; i < colorCount; i++)
	{
		float red = bytes[24 + (i * 4) + 0] / 255.0;
		float green = bytes[24 + (i * 4) + 1] / 255.0;
		float blue = bytes[24 + (i * 4) + 2] / 255.0;
		PXPalette_addColor(palette, [NSColor colorWithDeviceRed:red green:green blue:blue alpha:1]);
	}
	return palette;
}

@end
