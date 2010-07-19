//
//  PXIconExporter.m
//  Pixen
//
//  Created by Andy Matuschak on 6/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXIconExporter.h"
#import "PXCanvas.h"
#import "PXCanvas_ImportingExporting.h"

typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned long dword;

#pragma pack(1)

typedef struct
{
    byte        bWidth;          // Width, in pixels, of the image
    byte        bHeight;         // Height, in pixels, of the image
    byte        bColorCount;     // Number of colors in image (0 if >=8bpp)
    byte        bReserved;       // Reserved ( must be 0)
    word        wPlanes;         // Color Planes
    word        wBitCount;       // Bits per pixel
    long       dwBytesInRes;    // How many bytes in this resource?
    long       dwImageOffset;   // Where in the file is this image?
} ICONDIRENTRY, *LPICONDIRENTRY;

typedef struct ICONDIR
{
    word          idReserved;
    word          idType;
    word          idCount;
	
    // we're only using one resolution, so there's only one entry.
	ICONDIRENTRY idEntry;
} ICONHEADER;

typedef struct tagBITMAPINFOHEADER
{
	long   biSize;
	long    biWidth;
	long    biHeight;
	word    biPlanes;
	word    biBitCount;
	long   biCompression;
	long   biSizeImage;
	long    biXPelsPerMeter;
	long    biYPelsPerMeter;
	long   biClrUsed;
	long   biClrImportant;
} BITMAPINFOHEADER;

typedef struct tagRGBQUAD
{
	byte    rgbBlue;
	byte    rgbGreen;
	byte    rgbRed;
	byte    rgbReserved;
} RGBQUAD;

typedef struct
{
	BITMAPINFOHEADER   icHeader;      // DIB header
	
	// writing these separately due to sizing issues
	// RGBQUAD         icColors[1];   // Color table
	// byte            icXOR[1];      // DIB bits for XOR mask
	// byte            icAND[1];      // DIB bits for AND mask
} ICONIMAGE, *LPICONIMAGE;

@implementation PXIconExporter

- (void)dealloc
{
	if (iconData)
		[iconData release];
	[super dealloc];
}

- iconDataForCanvas:(PXCanvas *)aCanvas
{
	if ([aCanvas size].width > 128 || [aCanvas size].height > 128)
	{
		[[NSAlert alertWithMessageText:NSLocalizedString(@"Can't save image", @"Can't save image")
						 defaultButton:NSLocalizedString(@"OK", @"OK")
					   alternateButton:nil
						   otherButton:nil
			 informativeTextWithFormat:NSLocalizedString(@"The Windows icon format doesn't support images with width or height above 128.", @"The Windows icon format doesn't support images with width or height above 128.")] runModal];
		return nil;
	}
	canvas = aCanvas;
	iconData = [[NSMutableData alloc] init];
	[self writeIconFileHeader];
	[self writeImage];
	return iconData;
}

- (int)alignBitsToDWord:(int)num
{
	// round to the nearest four bytes
	return (((num + 31) >> 5) << 2);
}

- (int)imageSize
{
	// determine size of icon image data
	NSSize canvasSize = [canvas size];
	int xorPitch = canvasSize.width * 3;
	while (xorPitch % 4 != 0)
		xorPitch++;
	int xorSize = xorPitch * canvasSize.height;
	int andSize = [self alignBitsToDWord:canvasSize.width] * canvasSize.height;
	return xorSize + andSize;
}

- (void)writeIconFileHeader
{
	ICONHEADER iconHeader;
	iconHeader.idReserved = CFSwapInt16HostToLittle(0); // reserved is always 0
	iconHeader.idType = CFSwapInt16HostToLittle(1); // icons are 1
	iconHeader.idCount = CFSwapInt16HostToLittle(1); // we're only gonna deal with one resolution
	
	ICONDIRENTRY dirEntry;
	NSSize canvasSize = [canvas size];
	dirEntry.bWidth = canvasSize.width;
	dirEntry.bHeight = canvasSize.height;
	dirEntry.bColorCount = 0; // not dealing with color tables
	dirEntry.bReserved = 0; // this is always 0
	dirEntry.wPlanes = CFSwapInt16HostToLittle(1); // I think this is supposed to always be 1 for icons
	dirEntry.wBitCount = CFSwapInt16HostToLittle(24);	
	dirEntry.dwBytesInRes = CFSwapInt32HostToLittle(sizeof(BITMAPINFOHEADER) + [self imageSize]);
	dirEntry.dwImageOffset = CFSwapInt32HostToLittle(sizeof(ICONHEADER));
	iconHeader.idEntry = dirEntry;
	
	[iconData appendBytes:&iconHeader length:sizeof(ICONHEADER)];
}

- (void)writeImageData
{
	// write color data
	int i, j;
	NSSize canvasSize = [canvas size];
	for (j = 0; j < canvasSize.height; j++)
	{
		int bytesWritten = 0;
		for (i = 0; i < canvasSize.width; i++)
		{
			NSColor *color = [NSReadPixel(NSMakePoint(i, j)) colorUsingColorSpaceName:NSDeviceRGBColorSpace];
			byte colors[3];
			colors[2] = [color redComponent] * 255;
			colors[1] = [color greenComponent] * 255;
			colors[0] = [color blueComponent] * 255;
			[iconData appendBytes:colors length:3 * sizeof(byte)];
			bytesWritten += 3;
		}
		// fill in zeroes to make scanline end on dword boundary
		while (bytesWritten % 4 != 0)
		{
			char blank = 0;
			[iconData appendBytes:&blank length:1];
			bytesWritten++;
		}
	}	
}

- (void)writeMask
{
	// write mask data
	NSSize canvasSize = [canvas size];
	int maskWidthBytes = [self alignBitsToDWord:canvasSize.width];
	int maskSize = maskWidthBytes * canvasSize.height;
	unsigned char *mask = malloc(maskSize);
	memset(mask, 0, maskSize);
	unsigned char *workingMask = mask;
	int i, j;
	for (j = 0; j < canvasSize.height; j++)
	{
		for (i = 0; i < canvasSize.width; i++)
		{
			// make anything with alpha of less than 0.5 be invisible
			if ([[NSReadPixel(NSMakePoint(i, j)) colorUsingColorSpaceName:NSDeviceRGBColorSpace] alphaComponent] < 0.5)
			{
				workingMask[i >> 3] |= (0x80 >> (i & 0x07));
			}
		}
		workingMask += maskWidthBytes;
	}
	[iconData appendBytes:mask length:maskSize];
	free(mask);	
}

- (void)writeImage
{
	// set up bitmap info header
	BITMAPINFOHEADER bitmapHeader;
	memset(&bitmapHeader, 0, sizeof(BITMAPINFOHEADER));
	NSSize canvasSize = [canvas size];
	// note all the endian swaps; these are important
	bitmapHeader.biSize = CFSwapInt32HostToLittle(sizeof(BITMAPINFOHEADER));
	bitmapHeader.biWidth = CFSwapInt32HostToLittle(canvasSize.width);
	bitmapHeader.biHeight = CFSwapInt32HostToLittle(canvasSize.height*2); // height is doubled because it covers the mask, too
	bitmapHeader.biPlanes = CFSwapInt16HostToLittle(1); // I think this is always supposed to be 1 for icons
	bitmapHeader.biBitCount = CFSwapInt16HostToLittle(24); // We're only gonna write 24-bit images for now.
	bitmapHeader.biSizeImage = CFSwapInt32HostToLittle([self imageSize]);
	[iconData appendBytes:&bitmapHeader length:sizeof(BITMAPINFOHEADER)];
	
	// get merged image
	NSImage *mergedImage = [canvas exportImage];
	[mergedImage lockFocus];
	
	[self writeImageData];
	[self writeMask];

	[mergedImage unlockFocus];
}

#pragma pack()

@end
