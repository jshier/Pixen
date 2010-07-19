//
//  PXCel.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"
@class PXCanvas, PXAnimation;
@interface PXCel : NSObject <NSCoding, NSCopying> {
	PXCanvas *canvas;
	NSTimeInterval duration;
}
- initWithImage:(NSImage *)image animation:(PXAnimation *)animation atIndex:(NSUInteger)index;
- initWithImage:(NSImage *)image animation:(PXAnimation *)animation;
- initWithCanvas:(PXCanvas *)initCanvas duration:(NSTimeInterval)initDuration;
- (PXCanvas *)canvas;
- (void)setCanvas:(PXCanvas *)canv;
- (NSSize)size;
- (void)setSize:(NSSize)size;
- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor;
- (void)setUndoManager:man;
- (NSTimeInterval) duration;
- (void)setDuration:(NSTimeInterval)duration;
- (NSDictionary *)info;
- (void)setInfo:(NSDictionary *)info;
- (NSImage *)displayImage;
@end
