//
//  PXAnimatedGifExporter.m
//  Pixen-XCode
//
//  Created by Andy Matuschak on Fri Jul 16 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXAnimatedGifExporter.h"
#import "gif_lib.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXPalette.h"

#define GIF_ITERATION_HEADER "NETSCAPE2.0"

@implementation PXAnimatedGifExporter

- initWithSize:(NSSize)aSize iterations:(int)someIterations
{
	[super init];
	iterations = someIterations;
	EGifSetGifVersion("89a");
	tempFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"pxa_gif_export.gif"] retain];
	gifFile = EGifOpenFileName([tempFilePath UTF8String], NO);
	firstImage = YES;
	return self;
}

- (void)dealloc
{
    //the GIF file gets closed on export
	[finalData release];
	[super dealloc];
}

- (int)writeHeaderWithSize:(NSSize)size usingColorMap:(ColorMapObject *)colorMap ofSize:(int)numberOfColors withTransparentColor:(int)transColor
{
	iterations = 0;
	char iterationString[3];
	iterationString[0] = 0x01;
	iterationString[1] = iterations % 256;
	iterationString[2] = iterations / 256;
	iterationString[3] = 0;
	
	int result = EGifPutScreenDesc(gifFile, size.width, size.height, numberOfColors, transColor, colorMap);
	if (result == GIF_ERROR) { return result; }
	result = EGifPutExtensionFirst(gifFile, 0xFF, strlen(GIF_ITERATION_HEADER), GIF_ITERATION_HEADER);
	if (result == GIF_ERROR) { return result; }
	result = EGifPutExtensionLast(gifFile, 0, 3, iterationString);
	if (result == GIF_ERROR) { return result; }
	
	return GIF_OK;
}

- (NSColor *)writeCanvas:(PXCanvas *)canvas withDuration:(NSTimeInterval)duration origin:(NSPoint)origin transparentColor:aColor
{	
	PXPalette *palette = [canvas createFrequencyPalette];
	int colorCount = PXPalette_colorCount(palette);
	// The animated gif writer only supports <= 256 color palettes. If you have a palette bigger than that, quantize it first then come back.
	if (colorCount > 256)
	{
		[NSException raise:@"PXTooManyColorsException" format:@"PXAnimatedGifExporter requires <= 256 colors in the palette."];
		PXPalette_release(palette);
		return nil;
	}
	
	int i, j;
	NSSize size = [canvas size];
	
	// First we must determine if the palette has any transparent (< .5 alpha) colors.
	BOOL hasAlpha = NO;
	for (i = 0; i < size.width; i++)
	{
		for (j = 0; j < size.height; j++)
		{
			if ([[canvas mergedColorAtPoint:NSMakePoint(i, j)] alphaComponent] < .5)
			{
				hasAlpha = YES;
				break;
			}
		}
	}
	
	// If we're using alpha, we have to remove all the colors in the palette with alpha < .5 and replace them all with a single color entry for the previously determined transparent color. In order to do that, we must first go through and find how many colors we're -really- going to have.
	int colorMapSize = 0;
	for (i = 0; i < colorCount; i++)
	{
		// We're only including colors that are (or will be) opaque.
		if ([palette->colors[i].color alphaComponent] >= .5)
			colorMapSize++;
	}
	if (hasAlpha)
		colorMapSize++; // Add one more at the end for the transparent index.
	
	// We now set up the GIF color map with the PXPalette.  It has to be a power of two size.
	int mapSize = MAX(pow(2, ceilf(log2(colorMapSize))), 2);
	ColorMapObject *colorMap = MakeMapObject(mapSize, NULL);
	if (colorMap == NULL)
	{
		[NSException raise:@"GIF Error" format:@"Couldn't allocate color map."];
		PXPalette_release(palette);
		return nil;
	}
	//colorMap->BitsPerPixel = 8;
	int mapIndex = 0;
	for (i = 0; i < colorCount; i++)
	{
		// Check to see if the current color is transparent; if so, don't deal with it now: we'll add the sole transparent color at the end.
		if ([palette->colors[i].color alphaComponent] < 0.5) { continue; }
		NSColor *color = [palette->colors[i].color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		colorMap->Colors[mapIndex].Red = (int)([color redComponent] * 255);
		colorMap->Colors[mapIndex].Green = (int)([color greenComponent] * 255);
		colorMap->Colors[mapIndex].Blue = (int)([color blueComponent] * 255);
		mapIndex++;
	}
	int transparentIndex = -1;
	// Now if we're using alpha, we add a color to be used as transparent.
	if (hasAlpha)
	{
		colorMap->Colors[mapIndex].Red = 255;
		colorMap->Colors[mapIndex].Green = 255;
		colorMap->Colors[mapIndex].Blue = 255;
		transparentIndex = mapIndex;
	}
	
	// We will now actually populate the output buffer with the indices
	GifByteType *outputBuffer = malloc(size.width * size.height * sizeof(GifByteType));
	int bufferIndex = 0;
	for (j = size.height - 1; j >= 0; j--)
	{
		for (i = 0; i < size.width; i++, bufferIndex++)
		{
			NSPoint point = NSMakePoint(i, j);
			if ([[canvas mergedColorAtPoint:point] alphaComponent] < 0.5) // transparent colors
			{
				outputBuffer[bufferIndex] = transparentIndex;
			}
			else // opaque colors
			{
				// If we're using alpha, we could potentially have changed around index ordering due to the removal of partially or multiple transparent colors. Thus, we must go through the color map and find the appropriate color... but since that's kind of slow, we'll still use PXCanvas's functionality here so long as we're not using alpha.
				//if (hasAlpha)
				//{
					NSColor *color = [[canvas mergedColorAtPoint:point] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
					for (mapIndex = 0; mapIndex < colorMapSize; mapIndex++)
					{
						if ((floorf([color redComponent] * 255) == colorMap->Colors[mapIndex].Red) && (floorf([color greenComponent] * 255) == colorMap->Colors[mapIndex].Green) && (floorf([color blueComponent] * 255) == colorMap->Colors[mapIndex].Blue))
						{
							outputBuffer[bufferIndex] = mapIndex;
							break;
						}
					}
				//}
			}
		}
	}
		
	if (firstImage)
	{
		firstImage = NO;
		if ([self writeHeaderWithSize:size usingColorMap:colorMap ofSize:mapSize withTransparentColor:(hasAlpha ? 0 : 0)] == GIF_ERROR)
		{
			NSLog(@"Failed to write header of GIF\n");
			PXPalette_release(palette);
			return nil;
		}
	}
	
	hasAlpha = YES; // this... works for some reason. I KNOW NOT WHY
	// If we're using alpha, use 2 as our disposal method (which uses the background color); otherwise no redraw is required: code 0.
	unsigned char disposalMethod = hasAlpha ? 2 : 0;
	
	int tempDuration = duration *= 100;
	unsigned char extension[4] = { 0 };
	extension[0] = hasAlpha | (disposalMethod << 2); // byte 1 is a flag; 00000001 turns transparency on.
	extension[1] = tempDuration % 256; // byte 2 is delay time, presumably for animation.
	extension[2] = tempDuration / 256; // byte 3 is continued delay time.
	extension[3] = transparentIndex; // byte 4 is the index of the transparent color in the palette.
	int result = EGifPutExtension(gifFile, 0xF9, sizeof(extension), extension); // 0xf9 is the transparency extension magic code		
	if (result == GIF_ERROR) 
	{ 
		NSLog(@"Couldn't write GIF image extension block.\n"); 
		PXPalette_release(palette);
		return nil; 
	}
	EGifPutImageDesc(gifFile, (int)origin.x, (int)origin.y, size.width, size.height, 0, NULL);
	if (result == GIF_ERROR)
	{ 
		NSLog(@"Couldn't write GIF image description.\n"); 
		PXPalette_release(palette);
		return nil; 
	}

	GifByteType * position = outputBuffer;
	for (i = 0; i < size.height; i++)
	{
		result = EGifPutLine(gifFile, position, size.width);
		if (result == GIF_ERROR) { NSLog(@"Couldn't write GIF line number %d\n", i); return nil; }
		position += (int)size.width;
	}
	free(outputBuffer);
	FreeMapObject(colorMap);
	PXPalette_release(palette);

	return nil;
}

- (NSColor *)writeCanvas:(PXCanvas *)canvas withDuration:(NSTimeInterval)duration transparentColor:aColor
{
	return [self writeCanvas:(PXCanvas *)canvas withDuration:duration origin:NSZeroPoint transparentColor:aColor];
}

- (void)finalizeExport
{
	EGifCloseFile(gifFile);
	finalData = [[NSData dataWithContentsOfFile:tempFilePath] retain];
	remove([tempFilePath UTF8String]);
	[tempFilePath release];
}

- data
{
	return finalData;
}

@end
