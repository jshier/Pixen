//
//  PXPreviewBezelView.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on 5/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <AppKit/NSView.h>

@interface PXPreviewBezelView : NSView {
	NSImage * actionGear;
	NSMenu * menu;
	id delegate;
	float alpha;
}

- (void)setDelegate:delegate;
- (void)setAlphaValue:(float)alpha;
- (float)alphaValue;

@end
