//
//  PXAnimatedGifExporter.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on Fri Jul 16 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>
#import "gif_lib.h"

@class PXCanvas;
@interface PXAnimatedGifExporter : NSObject
{
	GifFileType * gifFile;
	id finalData;
	int iterations;
	
	BOOL firstImage;
	NSString *tempFilePath;
}

- initWithSize:(NSSize)size iterations:(int)iterations;
- (int)writeHeaderWithSize:(NSSize)size usingColorMap:(ColorMapObject *)colorMap ofSize:(int)numberOfColors withTransparentColor:(int)color;
- (NSColor *)writeCanvas:(PXCanvas *)canvas withDuration:(NSTimeInterval)duration origin:(NSPoint)origin transparentColor:aColor;
- (NSColor *)writeCanvas:(PXCanvas *)canvas withDuration:(NSTimeInterval)duration transparentColor:aColor;
- (void)finalizeExport;
- data;

@end
