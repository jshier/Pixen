//
//  PXIconExporter.h
//  Pixen
//
//  Created by Andy Matuschak on 6/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PXCanvas;
@interface PXIconExporter : NSObject
{
	PXCanvas *canvas;
	NSMutableData *iconData;
}

- iconDataForCanvas:(PXCanvas *)aCanvas;

- (void)writeIconFileHeader;
- (void)writeImage;

- (void)writeImageData;
- (void)writeMask;


@end
