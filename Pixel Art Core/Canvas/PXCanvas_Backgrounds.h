//
//  PXCanvas_Backgrounds.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(Backgrounds)

- mainBackground;
- (void)setMainBackground:bg;
- alternateBackground;
- (void)setAlternateBackground:bg;

- mainPreviewBackground;
- (void)setMainPreviewBackground:bg;
- alternatePreviewBackground;
- (void)setAlternatePreviewBackground:bg;

@end
