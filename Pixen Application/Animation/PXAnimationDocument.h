//
//  PXAnimationDocument.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXDocument.h"
@class PXAnimationWindowController, PXAnimation;
@interface PXAnimationDocument : PXDocument {
	PXAnimation *animation;
}

- (PXAnimation *)animation;

@end
