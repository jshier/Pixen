//
//  PXPaletteViewSizeSelector.h
//  Pixen
//
//  Created by Andy Matuschak on 8/21/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXPaletteViewSizeSelector : NSView {
	NSImage *bigImage, *smallImage;
	NSControlSize size;
	id delegate;
}
- (void)setDelegate:delegate;
- (void)setControlSize:(NSControlSize)size;
@end

@interface NSObject (PXPaletteViewSizeSelectorDelegateProtocol)
- (void)sizeSelector:(PXPaletteViewSizeSelector *)selector selectedSize:(NSControlSize)size;
@end