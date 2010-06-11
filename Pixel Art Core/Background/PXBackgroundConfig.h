//
//  PXBackgroundConfig.h
//  Pixen
//
//  Created by Joe Osborn on 2007.11.12.
//  Copyright 2007 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PXBackground;

@interface PXBackgroundConfig : NSObject {
	PXBackground *mainBackground;
	PXBackground *alternateBackground;
	PXBackground *mainPreviewBackground;
	PXBackground *alternatePreviewBackground;	
}
- (PXBackground *)mainBackground;
- (void)setMainBackground:(PXBackground *)value;

- (PXBackground *)alternateBackground;
- (void)setAlternateBackground:(PXBackground *)value;

- (PXBackground *)mainPreviewBackground;
- (void)setMainPreviewBackground:(PXBackground *)value;

- (PXBackground *)alternatePreviewBackground;
- (void)setAlternatePreviewBackground:(PXBackground *)value;

- (void)setDefaultBackgrounds;
- (void)setDefaultPreviewBackgrounds;
@end
