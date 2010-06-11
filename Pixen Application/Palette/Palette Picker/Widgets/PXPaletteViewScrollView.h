//
//  PXPaletteViewScrollView.h
//  Pixen
//
//  Created by Andy Matuschak on 8/21/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PXPaletteViewSizeSelector;
@interface PXPaletteViewScrollView : NSScrollView {
	PXPaletteViewSizeSelector *sizeSelector;
}
- (void)setControlSize:(NSControlSize)size;
@end
