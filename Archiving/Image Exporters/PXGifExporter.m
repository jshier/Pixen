//
//  PXGifExporter.m
//  Pixen-XCode
//
//  Created by Andy Matuschak on Fri Jul 16 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXGifExporter.h"
#import "gif_lib.h"

@implementation PXGifExporter

+ gifDataForImage:anImage
{
	id image = [[[NSImage alloc] initWithData:[anImage TIFFRepresentation]] autorelease];
	NSSize size = [image size];
	[image lockFocus];
	
	// first we find a valid transparent color
	id transparentColor = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1];
	BOOL found = YES;
	while (found) // I know this is ugly. It works.
	{
		found = NO;
		int i, j;
		for (i = 0; i < size.width; i++)
		{
			for (j = 0; j < size.height; j++)
			{
				id converted = [NSReadPixel(NSMakePoint(i, j)) colorUsingColorSpaceName:NSDeviceRGBColorSpace];
				if ((unsigned char)([converted redComponent] * 255) == (unsigned char)([transparentColor redComponent] * 255) && (unsigned char)([converted greenComponent] * 255) == (unsigned char)([transparentColor greenComponent] * 255) && (unsigned char)([converted blueComponent] * 255) == (unsigned char)([transparentColor blueComponent] * 255))
				{
					if ([transparentColor redComponent] < 1)
					{
						transparentColor = [NSColor colorWithDeviceRed:[transparentColor redComponent]+0.1 green:[transparentColor greenComponent] blue:[transparentColor blueComponent] alpha:1];
					}
					else if ([transparentColor greenComponent] < 1)
					{
						transparentColor = [NSColor colorWithDeviceRed:[transparentColor redComponent] green:[transparentColor greenComponent]+0.1 blue:[transparentColor blueComponent] alpha:1];
					}
					else if ([transparentColor blueComponent] < 1)
					{
						transparentColor = [NSColor colorWithDeviceRed:[transparentColor redComponent] green:[transparentColor greenComponent] blue:[transparentColor blueComponent]+0.1 alpha:1];
					}
					found = YES;
				}
			}
		}
	}
	
	int colorMapSize = 256;
	GifByteType *redBuffer = malloc(size.width * size.height);
	GifByteType *greenBuffer = malloc(size.width * size.height);
	GifByteType *blueBuffer = malloc(size.width * size.height);
	EGifSetGifVersion("89a");
	
	int i, j, count = 0;
	for (j = size.height - 1; j >= 0; j--)
	{
		for (i = 0; i < size.width; i++, count++)
		{
			NSColor * color = [NSReadPixel(NSMakePoint(i, j)) colorUsingColorSpaceName:NSDeviceRGBColorSpace];
			if ([color alphaComponent] < 0.5) { color = transparentColor; }
			
			redBuffer[count] = (GifByteType)([color redComponent] * 255);
			greenBuffer[count] = (GifByteType)([color greenComponent] * 255);
			blueBuffer[count] = (GifByteType)([color blueComponent] * 255);
		}
	}
	
	ColorMapObject *colorMap = MakeMapObject(colorMapSize, NULL);
	GifByteType *outputBuffer = malloc(size.width * size.height * sizeof(GifByteType));
	QuantizeBuffer(size.width* size.height, &colorMapSize, redBuffer, greenBuffer, blueBuffer, outputBuffer, colorMap->Colors);
	
	NSString *dummyPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"dummy.gif"];
	
	GifFileType *gifFile = EGifOpenFileName([dummyPath UTF8String], NO);
	
	//find the index of the transparent color in the color map
	unsigned transparentIndex = 0, bestDelta = 1000;
	for (i = 0; i < colorMapSize; i++)
	{
		unsigned char transRed = (unsigned char)([transparentColor redComponent] * 255);
		unsigned char transGreen = (unsigned char)([transparentColor greenComponent] * 255);
		unsigned char transBlue = (unsigned char)([transparentColor blueComponent] * 255);			
		GifColorType color = colorMap->Colors[i];
		if (color.Red == transRed && color.Green == transGreen && color.Blue == transBlue)
		{
			transparentIndex = i;
		}
		else
		{
			unsigned int tempDelta = (color.Red < transRed ? transRed - color.Red : color.Red - transRed) +
			(color.Green < transGreen ? transGreen - color.Green : color.Green - transGreen) +
			(color.Blue < transBlue ? transBlue - color.Blue : color.Blue - transBlue);
			if (tempDelta < bestDelta)
			{
				transparentIndex = i;
				bestDelta = tempDelta;
			}
		}
	}
	
	EGifPutScreenDesc(gifFile, size.width, size.height, colorMapSize, 0, colorMap);
	unsigned char extension[4] = { 0 };
	extension[0] = 0x01; // byte 1 is a flag; 00000001 turns transparency on.
	extension[1] = 0x00; // byte 2 is delay time, presumably for animation.
	extension[2] = 0x00; // byte 3 is continued delay time.
	extension[3] = transparentIndex; // byte 4 is the index of the transparent color in the palette.
	EGifPutExtension(gifFile, 0xF9, sizeof(extension), extension); // 0xf9 is the transparency extension magic code		
	EGifPutImageDesc(gifFile, 0, 0, size.width, size.height, 0, NULL);
	
	GifByteType * position = outputBuffer;
	for (i = 0; i < size.height; i++)
	{
		EGifPutLine(gifFile, position, size.width);
		position += (int)size.width;
	}
	EGifCloseFile(gifFile);
	
	[image unlockFocus];
	id finalData = [NSData dataWithContentsOfFile:dummyPath];
	remove([dummyPath UTF8String]);
	return finalData;
}

@end
