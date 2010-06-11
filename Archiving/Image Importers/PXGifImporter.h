//
//  PAGifImporter.h
//  Pixen Animator
//
//  Created by Andy Matuschak on Fri Jul 16 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "gif_lib.h"

@interface PXGifImporter : NSObject {
	GifFileType *gifFile;
	int iterations;
	
	id frames;
}

+ (BOOL)fileAtURLIsAnimated:(NSURL *)url;
- initWithData:data;
- frames;
- (int)iterations;

- (unsigned int)durationFromGraphicExtension:(GifByteType *)extensionBuffer;
- (unsigned int)disposalMethodFromGraphicExtension:(GifByteType *)extensionBuffer;
- (unsigned int)transparentIndexFromGraphicExtension:(GifByteType *)extensionBuffer;
- (void)parseIterationExtension:(GifByteType *)extensionBuffer;
- (BOOL)hasTransparency:(GifByteType *)extensionBuffer;


@end
