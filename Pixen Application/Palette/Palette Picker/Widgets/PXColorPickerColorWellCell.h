//
//  PXColorPickerColorWellCell.h
//  PXColorPicker
//
//  Created by Andy Matuschak on 7/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// warning private interface
@interface NSColorPanelColorWell : NSColorWell
{
    BOOL _disabledAsColorDestination;
    BOOL _actsLikeButton;
}

- (void)registerForDraggedTypes:(id)fp8;
- (void)setAcceptsColorDrops:(BOOL)fp8;
- (void)setActsLikeButton:(BOOL)fp8;
- (void)mouseDown:(id)fp8;
- (BOOL)acceptsFirstResponder;
- (void)performClick:(id)fp8;
- (void)moveRight:(id)fp8;
- (void)moveLeft:(id)fp8;
- (struct _NSRect)_colorRect;
- (void)drawWellInside:(struct _NSRect)fp8;
- (void)_drawBorderInRect:(struct _NSRect)fp8;
- (void)setColor:(id)fp8;

@end

@interface PXColorPickerColorWellCell : NSCell {
	NSUInteger index;
	NSColor *color;
	NSImage *smallNewColorImage, *bigNewColorImage;
}

- (NSUInteger)index;
- (void)setIndex:(NSUInteger)newIndex;
- (NSColor *)color;
- (void)setColor:(NSColor *)newColor;

@end
