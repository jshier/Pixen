//
//  PXGifImporter.m
//  Pixen
//
//  Created by Andy Matuschak on Fri Jul 16 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXGifImporter.h"

@implementation PXGifImporter

+ (BOOL)fileAtURLIsAnimated:(NSURL *)url
{
	NSImage *tempImage = [[[NSImage alloc] initWithContentsOfURL:url] autorelease];
	int frameCount = [[[[tempImage representations] objectAtIndex:0] valueForProperty:NSImageFrameCount] intValue];
	return (frameCount > 1);
}

- initWithData:data
{
	[super init];
	[data writeToFile:@"/tmp/PAdummy.gif" atomically:NO];
	frames = [[NSMutableArray alloc] init];
	gifFile = DGifOpenFileName("/tmp/PAdummy.gif");
	GifRecordType type;
	char imageExtension[4];
	do
	{
		if (DGifGetRecordType(gifFile, &type) == GIF_ERROR)
		{
			NSLog(@"Couldn't read GIF record type.\n");
			return nil;
		}
		
		switch (type)
		{
			case EXTENSION_RECORD_TYPE:
			{
				int extensionCode;
				GifByteType * extensionBuffer;
				DGifGetExtension(gifFile, &extensionCode, &extensionBuffer);
				if (extensionCode == APPLICATION_EXT_FUNC_CODE)
				{
					DGifGetExtensionNext(gifFile, &extensionBuffer);
					[self parseIterationExtension:extensionBuffer];
				}
				else if (extensionCode == GRAPHICS_EXT_FUNC_CODE)
				{
					memcpy(imageExtension, extensionBuffer+1, 4);
				}
				while (extensionBuffer != NULL)
				{
					DGifGetExtensionNext(gifFile, &extensionBuffer);
				}
				break;
			}
			case IMAGE_DESC_RECORD_TYPE:
			{
				/*if (DGifGetImageDesc(gifFile) == GIF_ERROR)
				{
					NSLog(@"Error getting GIF image description.\n");
					return nil;
				}
				
				id frame = [[PAFrame alloc] init];
				id name = [NSString stringWithFormat:@"Imported Frame #%d", [frames count]];
				[frame setValue:name forKey:@"name"];
				
				NSTimeInterval duration = [self durationFromGraphicExtension:imageExtension] / 100.0f;
				[frame setValue:[NSNumber numberWithDouble:duration] forKey:@"duration"];
				
				id image = [[NSImage alloc] initWithSize:NSMakeSize(gifFile->Image.Width, gifFile->Image.Height)];
				[image lockFocus];
				[[[image representations] objectAtIndex:0] setAlpha:[self hasTransparency:imageExtension]];
				
				[frame setValue:[NSNumber numberWithInt:[self disposalMethodFromGraphicExtension:imageExtension]] forKey:@"disposalMethod"];
				int transparentIndex = [self transparentIndexFromGraphicExtension:imageExtension];
				int i, j;
				for (i = gifFile->Image.Height - 1; i >= 0; i--)
				{
					GifByteType *line = malloc(gifFile->Image.Width);
					if (DGifGetLine(gifFile, line, gifFile->Image.Width) == GIF_ERROR)
					{
						[image unlockFocus];
						NSLog(@"Couldn't get GIF line: %d\n", i);
						return nil;
					}
					
					for (j = 0; j < gifFile->Image.Width; j++)
					{
						ColorMapObject *colorMap;
						if (!gifFile->Image.ColorMap)
						{
							colorMap = gifFile->SColorMap;
						}
						else
						{
							colorMap = gifFile->Image.ColorMap;
						}
						double red = colorMap->Colors[line[j]].Red / 255.0f;
						double green = colorMap->Colors[line[j]].Green / 255.0f;
						double blue = colorMap->Colors[line[j]].Blue / 255.0f;
						double alpha = (line[j] == transparentIndex) ? 0 : 1;
						id color = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
						[color set];
						NSRectFill(NSMakeRect(j, i, 1, 1));
					}
				}
				[image unlockFocus];
				[frame setValue:image forKey:@"image"];
				[frame setValue:[NSValue valueWithPoint:NSMakePoint(gifFile->Image.Left, gifFile->Image.Top)] forKey:@"origin"];
				[frames addObject:frame];*/
				break;
			}
			default:
				break;
		}
		
	} while (type != TERMINATE_RECORD_TYPE);

	return self;
}

- (int)iterations
{
	return iterations;
}

- frames
{
	return frames;
}

- (unsigned int)durationFromGraphicExtension:(GifByteType *)extensionBuffer
{
	return (extensionBuffer[2] * 256) + extensionBuffer[1];
}

- (BOOL)hasTransparency:(GifByteType *)extensionBuffer
{
	return extensionBuffer[0] & 0x01;
}

- (unsigned int)transparentIndexFromGraphicExtension:(GifByteType *)extensionBuffer
{
	return extensionBuffer[3];
}

- (unsigned int)disposalMethodFromGraphicExtension:(GifByteType *)extensionBuffer
{
	return extensionBuffer[0] & 0x1c;
}

- (void)parseIterationExtension:(GifByteType *)extensionBuffer
{
	iterations = (extensionBuffer[3] * 256) + extensionBuffer[2];
}

@end
