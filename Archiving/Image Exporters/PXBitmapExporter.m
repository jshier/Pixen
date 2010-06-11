//
//  PXBitmapExporter.m
//  Pixen-XCode
//
// Copyright (c) 2003,2004 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

//  Created by Andy Matuschak on Wed Jun 09 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXBitmapExporter.h"
#import "PXCanvas.h"
#import "PXCanvas_ImportingExporting.h"
#import <QuickTime/QuickTime.h>
//  PXBitmapExporter.m
//  Pixen-XCode
//
//  Created by Andy Matuschak on Wed Jun 09 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXBitmapExporter.h"
#import <QuickTime/QuickTime.h>

#define make_128(x) (x + 16 - (x % 16))

@interface NSBitmapImageRep (OSColorSpaceConversion)
- calibratedBitmapImageRep;
@end

@implementation NSBitmapImageRep (OSColorSpaceConversion)

- calibratedBitmapImageRep
{
	NSSize size = [self size];
	int samplesPerPixel = [self samplesPerPixel];
	int extraBytesPerPixel = [self bitsPerPixel] / 8 - samplesPerPixel;
	int extraBytesPerRow = [self bytesPerRow] - [self pixelsWide] * (samplesPerPixel + extraBytesPerPixel);
		
	CMBitmap sourceBitmap;
	sourceBitmap.image = (char *)[self bitmapData];
	sourceBitmap.space = (samplesPerPixel == 3) ? cmRGB24Space : cmRGBA32Space;
	sourceBitmap.width = size.width;
	sourceBitmap.height = size.height;
	sourceBitmap.pixelSize = 8 * (samplesPerPixel + extraBytesPerPixel);
	sourceBitmap.rowBytes = size.width * (samplesPerPixel + extraBytesPerPixel) + extraBytesPerRow;
	
	CMBitmap destinationBitmap;
	//long destinationLength = make_128((int)(size.width * size.height * samplesPerPixel));
	long destinationLength = (int)(size.width * size.height * samplesPerPixel);
	char **destination = (char **)malloc(sizeof(char **));
	*destination = (char *)malloc(destinationLength);
	destinationBitmap.image = *destination;
	destinationBitmap.space = (samplesPerPixel == 3) ? cmRGB24Space : cmRGBA32Space;
	destinationBitmap.width = size.width;
	destinationBitmap.height = size.height;
	destinationBitmap.pixelSize = 8 * samplesPerPixel;
	destinationBitmap.rowBytes = size.width * samplesPerPixel;
	
	CMProfileLocation profileLocation;
	id profileData = [self valueForProperty:NSImageColorSyncProfileData];
	if (profileData)
	{
		profileLocation.locType = cmPtrBasedProfile;
		profileLocation.u.ptrLoc.p = (Ptr)[profileData bytes];
	}
	
	CMProfileRef sourceProfile, destinationProfile;
	CMOpenProfile(&sourceProfile, (profileData) ? &profileLocation : NULL);
	
	// Now to get the default device profile...
	CMDeviceID device;
	CMDeviceProfileID deviceID;
	CMProfileLocation destinationProfileLocation;
	
	CMGetDefaultDevice(cmDisplayDeviceClass, &device);
	CMGetDeviceDefaultProfileID(cmDisplayDeviceClass, device, &deviceID);
	CMGetDeviceProfile(cmDisplayDeviceClass, device, deviceID, &destinationProfileLocation);
	CMOpenProfile(&destinationProfile, &destinationProfileLocation); 
	
	CMWorldRef colorWorld;
	NCWNewColorWorld(&colorWorld, sourceProfile, destinationProfile);
	CWMatchBitmap(colorWorld, &sourceBitmap, NULL, 0, &destinationBitmap);
	CWDisposeColorWorld(colorWorld);
	CMCloseProfile(sourceProfile);

	NSBitmapImageRep *resultingBitmap = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)destination pixelsWide:size.width pixelsHigh:size.height bitsPerSample:8 samplesPerPixel:samplesPerPixel hasAlpha:[self hasAlpha] isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:size.width * samplesPerPixel bitsPerPixel:8 * samplesPerPixel] autorelease];
	return resultingBitmap;
}

@end

// BMPDataForImage by Florrent Pillet
// myCreateHandleDataRef by Apple

@implementation PXBitmapExporter

Handle myCreateHandleDataRef(Handle dataHandle, Str255 fileName, OSType fileType, StringPtr mimeTypeString, Ptr initDataPtr, Size initDataByteCount)
{
  OSErr err;	
  Handle dataRef = nil;
  Str31 tempName;
  long atoms[3];
  StringPtr name;
	
  // First create a data reference handle for our data
  err = PtrToHand( &dataHandle, &dataRef, sizeof(Handle));
	
  if (err) goto bail;
	
  // If this is QuickTime 3 or later, we can add
  // the filename to the data ref to help importer
  // finding process. Find uses the extension.
	
  name = fileName;
  if (name == nil)
    {
      tempName[0] = 0;
      name = tempName;
    }
	
  // Only add the file name if we are also adding a
  // file type, MIME type or initialization data
	
  if ((fileType) || (mimeTypeString) || (initDataPtr))
    {
      err = PtrAndHand(name, dataRef, name[0]+1);
      if (err) goto bail;
    }
	
  // If this is QuickTime 4, the handle data handler
  // can also be told the filetype and/or
  // MIME type by adding data ref extensions. These
  // help the importer finding process.
  // NOTE: If you add either of these, you MUST add
  // a filename first -- even if it is an empty Pascal
  // string. Under QuickTime 3, any data ref extensions
  // will be ignored.
	
  // to add file type, you add a classic atom followed
  // by the Mac OS filetype for the kind of file
  if (fileType)
    {
      atoms[0] = EndianU32_NtoB(sizeof(long) * 3);
      atoms[1] = EndianU32_NtoB(kDataRefExtensionMacOSFileType);
      atoms[2] = EndianU32_NtoB(fileType);
      err = PtrAndHand(atoms, dataRef, sizeof(long) * 3);
      if (err) goto bail;
    }
	
  // to add MIME type information, add a classic atom followed by
  // a Pascal string holding the MIME type
	
  if (mimeTypeString)
    {
      atoms[0] = EndianU32_NtoB(sizeof(long) * 2 + mimeTypeString[0]+1);
      atoms[1] = EndianU32_NtoB(kDataRefExtensionMIMEType);
      err = PtrAndHand(atoms, dataRef, sizeof(long) * 2);
      if (err) goto bail;
      err = PtrAndHand(mimeTypeString, dataRef, mimeTypeString[0]+1);
      if (err) goto bail;
    }
	
  // add any initialization data, but only if a dataHandle was
  // not already specified (any initialization data is ignored
  // in this case)
  if((dataHandle == nil) && (initDataPtr))
    {
      atoms[0] = EndianU32_NtoB(sizeof(long) * 2 + initDataByteCount);
      atoms[1] = EndianU32_NtoB(kDataRefExtensionInitializationData);
      err = PtrAndHand(atoms, dataRef, sizeof(long) * 2);
      if (err) goto bail;
      err = PtrAndHand(initDataPtr, dataRef, initDataByteCount);
      if (err) goto bail;
    }
  return dataRef;
	
 bail:
  if (dataRef)
    {
      // make sure and dispose the data reference handle
      // once we are done with it
      DisposeHandle(dataRef);
    }
	
  return nil;
}

typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned long dword;

#pragma pack(1)

typedef struct tagBITMAPFILEHEADER {    /* bmfh */
	word    bfType;
	long   bfSize;
	word    bfReserved1;
	word    bfReserved2;
	long   bfOffBits;
} BITMAPFILEHEADER;

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


+ indexedBitmapDataForCanvas:(PXCanvas *)canvas
{
	id data = [NSMutableData data];
	BITMAPFILEHEADER fileHeader;
	fileHeader.bfType = CFSwapInt16HostToLittle(19778);
	PXPalette *pal = [canvas createFrequencyPalette];
	fileHeader.bfSize = CFSwapInt32HostToLittle(sizeof(BITMAPINFOHEADER) + PXPalette_colorCount(pal)*4 + [canvas size].width*[canvas size].height);
	fileHeader.bfReserved1 = 0;
	fileHeader.bfReserved2 = 0;
	fileHeader.bfOffBits = CFSwapInt32HostToLittle(sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + PXPalette_colorCount(pal)*4);
	[data appendBytes:&fileHeader length:sizeof(BITMAPFILEHEADER)];
	
	int colorCount = PXPalette_colorCount(pal);
	BITMAPINFOHEADER infoHeader;
	infoHeader.biSize = CFSwapInt32HostToLittle(sizeof(BITMAPINFOHEADER));
	infoHeader.biWidth = CFSwapInt32HostToLittle([canvas size].width);
	infoHeader.biHeight = CFSwapInt32HostToLittle([canvas size].height);
	infoHeader.biPlanes = CFSwapInt16HostToLittle(1);
	infoHeader.biBitCount = CFSwapInt16HostToLittle(8);
	infoHeader.biCompression = 0;
	infoHeader.biSizeImage = 0;
	infoHeader.biXPelsPerMeter = 0;
	infoHeader.biYPelsPerMeter = 0;
	infoHeader.biClrUsed = CFSwapInt32HostToLittle(colorCount);
	infoHeader.biClrImportant = 0;
	[data appendBytes:&infoHeader length:sizeof(BITMAPINFOHEADER)];
	
	int i;
	for (i = 0; i < colorCount; i++)
	{
		NSColor *color = PXPalette_colorAtIndex(pal, i);
		unsigned char outputColor[4];
		if ([color alphaComponent] < 0.5)
		{
			outputColor[0] = 255;
			outputColor[1] = 255;
			outputColor[2] = 255;
		}
		else
		{
			outputColor[0] = [color blueComponent] * 255;
			outputColor[1] = [color greenComponent] * 255;
			outputColor[2] = [color redComponent] * 255;
		}
		outputColor[3] = 0;
		[data appendBytes:outputColor length:4];
	}
	
	id bitmapRep = [NSBitmapImageRep imageRepWithData:[[canvas exportImage] TIFFRepresentation]];
	unsigned char *bitmapData = [bitmapRep bitmapData];
	BOOL hasAlpha = ([bitmapRep samplesPerPixel] == 4);
//	for (i = 0; i < [canvas size].width * [canvas size].height; i++)
	int j;
	for (j = [canvas size].height-1; j >= 0; j--)
	{
		int bytesWritten = 0;
		for (i = 0; i < [canvas size].width; i++)
		{
			int base = j * [bitmapRep bytesPerRow] + (hasAlpha ? i*4 : i*3);
			NSColor *color = [NSColor colorWithDeviceRed:bitmapData[base]/255.0 green:bitmapData[base + 1]/255.0 blue:bitmapData[base + 2]/255.0 alpha:(hasAlpha ? bitmapData[base + 3]/255.0 : 1)];
			unsigned char index = PXPalette_indexOfColor(pal, color);
			[data appendBytes:&index length:1];
			bytesWritten++;
		}
		
		while (bytesWritten % 4 != 0)
		{
			char blank = 0;
			[data appendBytes:&blank length:1];
			bytesWritten++;
		}
	}
	PXPalette_release(pal);
	return data;
}

#pragma pack()

+ dataForImage:image type:(int)type
{
	NSSize size = [image size];
	NSRect r = NSMakeRect(0,0,size.width,size.height);
	id whiteImage = [[NSImage alloc] initWithSize:size];
	[whiteImage lockFocus];
	NSEraseRect(r);
	[image compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
	/*// convert to device
	int i, j;
	for (i = 0; i < size.width; i++)
	{
		for (j = 0; j < size.height; j++)
		{
			NSPoint point = NSMakePoint(i, j);
			NSLog(@"Before (%dx%d): %@", i, j, NSReadPixel(point));
			[[NSReadPixel(point) colorUsingColorSpaceName:NSDeviceRGBColorSpace] set];
			NSLog(@"After (%dx%d): %@", i, j, NSReadPixel(point));
			NSRectFill((NSRect){point, {1, 1}});
		}
	}*/
	[whiteImage unlockFocus];
	NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[whiteImage TIFFRepresentation]];
	//NSLog(@"%@", [whiteImage TIFFRepresentation]);
	NSLog(@"%@", [rep colorSpaceName]);
	[whiteImage release];
	unsigned char *colorData = [rep bitmapData];
	NSLog(@"First color before: %dx%dx%d", colorData[60], colorData[61], colorData[62]);
	//rep = [rep calibratedBitmapImageRep];
	colorData = [rep bitmapData];
	NSLog(@"First color after: %dx%dx%d", colorData[60], colorData[61], colorData[62]);
	NSData *bmpData = [rep representationUsingType:NSBMPFileType properties:nil];
	
	if (bmpData == nil)
	{
		NSData *pngData = [rep representationUsingType:NSPNGFileType properties:nil];
		if ([pngData length] == 0)
		{
			[[NSAlert alertWithMessageText:NSLocalizedString(@"Export to BMP failed", @"Export to BMP failed") defaultButton:NSLocalizedString(@"OK", @"OK") alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"This really shouldn't happen. You might try saving the document as a Pixen Image, closing it, reopening it, then trying again.", @"This really shouldn't happen. You might try saving the document as a Pixen Image, closing it, reopening it, then trying again.")] runModal];
			[rep release];
			return nil;
		}
		
		// create a data reference handle for quicktime (see TN 1195 for myCreateHandleDataRef source)
		Handle pngDataH = NULL;
		PtrToHand([pngData bytes], &pngDataH, [pngData length]);
        Str255 name = "\pdummy.png";
		Handle dataRef = myCreateHandleDataRef(pngDataH, name, kQTFileTypePNG, nil, nil, 0);
		
		// create a Graphics Importer component that will read from the PNG data
		ComponentInstance importComponent=0, exportComponent=0;
		OSErr err = GetGraphicsImporterForDataRef(dataRef, HandleDataHandlerSubType, &importComponent);
		DisposeHandle(dataRef);
		if (err == noErr)
		{
			// create a Graphics Exporter component that will write BMP data
			err = OpenADefaultComponent(GraphicsExporterComponentType, type, &exportComponent);
			if (err == noErr)
			{
				// set export parameters
				Handle bmpDataH = NewHandle(0);
				GraphicsExportSetInputGraphicsImporter(exportComponent, importComponent);
				GraphicsExportSetOutputHandle(exportComponent, bmpDataH);
				
				// export data to BMP into handle
				unsigned long actualSizeWritten = 0;
				err = GraphicsExportDoExport(exportComponent, &actualSizeWritten);
				if (err == noErr)
				{
					// export done: create the NSData that will be returned
					HLock(bmpDataH);
					bmpData = [NSData dataWithBytes:*bmpDataH length:GetHandleSize(bmpDataH)];
					HUnlock(bmpDataH);
				}
				DisposeHandle(bmpDataH);
				CloseComponent(exportComponent);
			}
			CloseComponent(importComponent);
		}
		DisposeHandle(pngDataH);
	}
	return bmpData;
	
}

+ PICTDataForImage:image
{
	return [self dataForImage:image type:kQTFileTypePicture];
}

+ BMPDataForImage:image
{
	return [self dataForImage:image type:kQTFileTypeBMP];
}

@end
