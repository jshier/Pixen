//
//  OSACTReader.m
//  PALExport
//
//  Created by Andy Matuschak on 8/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "OSACTReader.h"


@implementation OSACTReader

- init
{
	[NSException raise:@"SingletonError" format:@"OSACTReader is a singleton; use sharedACTReader to access the shared instance."];
	return nil;
}

- _init
{
	[super init];
	return self;
}

+ sharedACTReader
{
	static OSACTReader *sharedACTReader = nil;
	if (sharedACTReader) { return sharedACTReader; }
	sharedACTReader = [[OSACTReader alloc] _init];
	return sharedACTReader;
}

- (PXPalette *)paletteWithData:(NSData *)data
{
	if ([data length] != 768)
	{
		[NSException raise:@"OSFileError" format:@"This is an invalid ACT palette: normal ACT palettes are exactly 768 bytes long; this one is %d", [data length]];
		return NULL;
	}
	PXPalette *palette = PXPalette_alloc();
	PXPalette_initWithoutBackgroundColor(palette);
	PXPalette_setName(palette, @"Imported palette");
	int i;
	const unsigned char *bytes = [data bytes];
	for (i = 0; i < 256; i++)
	{
		int red, green, blue;
		red = bytes[i * 3 + 0];
		green = bytes[i * 3 + 1];
		blue = bytes[i * 3 + 2];
		// There's a bunch of black at the end of the file to pad it to 768 bytes; if we already have a black color in our palette and we find another black, it means that the file is over.
		if ((red == 0) && (green == 0) && (blue == 0) && PXPalette_bucketForColor(palette, [[NSColor blackColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]))
		{
			// If the rest of the file is black, break.
			int j = 0;
			BOOL shouldBreak = YES;
			for (j = i+1; j < 256; j++)
			{
				if ((bytes[j * 3 + 0] != 0) || (bytes[j * 3 + 1] != 0) || (bytes[j * 3 + 2] != 0))
				{
					shouldBreak = NO;
					break;
				}
			}
			if (shouldBreak)
				break;
		}
		PXPalette_addColor(palette, [NSColor colorWithDeviceRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1]);
	}
	return palette;
}

@end
