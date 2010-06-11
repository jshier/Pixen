//
//  PXCanvas_ImportingExporting.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(ImportingExporting)

+ canvasWithContentsOfFile:(NSString *)aFile;
-(id) initWithContentsOfFile:(NSString* ) aFile;
- imageDataWithType:(NSBitmapImageFileType)storageType
		 properties:(NSDictionary *)properties;
- PICTData;
- (void)replaceActiveLayerWithImage:(NSImage *)anImage;
- initWithImage:(NSImage *)anImage type:(NSString *)type;
- initWithImage:(NSImage *)anImage;
- initWithPSDData:(NSData *)data;
- (NSImage *)exportImageWithBackgroundColor:(NSColor *)color;
- (NSImage *)exportImage; // suitable for writing to file
- (NSImage *)displayImage; // suitable for drawing to the screen


@end
