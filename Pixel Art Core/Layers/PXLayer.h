//
//  PXLayer.h
//  Pixen-XCode
//
// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Joe Osborn on Sun Jan 04 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//
#import <AppKit/AppKit.h>
#import "PXImage.h"
#import "PXPalette.h"
@class PXLayerController, PXCanvas;
@interface PXLayer : NSObject <NSCoding, NSCopying> {
	id name;
	PXImage *image;
	double opacity;
	BOOL visible;
	NSPoint origin;
	
	NSBezierPath *meldedBezier;
	NSColor *meldedColor;
	
	NSImage *cachedSourceOutImage;
	
//	NSUndoManager *undoManager;
	
	PXCanvas *canvas;
}
+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image origin:(NSPoint)origin size:(NSSize)sz;
+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image size:(NSSize)sz;

- (id) initWithName:(NSString *)aName image:(PXImage *)anImage;
- (id)initWithName:(NSString *)aName size:(NSSize)size;
- initWithName:(NSString *)aName size:(NSSize)size fillWithColor:(NSColor *)c;
- (NSString *)name;
- (void)setName:(NSString *) aName;
- (PXImage *)image;
//- (void)setUndoManager:(NSUndoManager *)man;
- (NSSize)size;
- (void)setSize:(NSSize)aSize;
- (void)setSize:(NSSize)newSize 
	 withOrigin:(NSPoint)origin
backgroundColor:(NSColor *)color;

- (NSPoint)origin;
- (void)setOrigin:(NSPoint)pt;

- (double)opacity;
- (void)setOpacity:(double)opacity;

- (void)setCanvas:(PXCanvas *)canvas;
- (PXCanvas *)canvas;

- (BOOL)visible;
- (void)setVisible:(BOOL)visible;

- (NSColor *)colorAtIndex:(unsigned int)index;
- (NSColor *)colorAtPoint:(NSPoint)aPoint;
- (void)setColor:(NSColor *)aColor atPoint:(NSPoint)aPoint;
- (void)setColor:(NSColor *)c atIndex:(unsigned int)loc;

- (void)moveToPoint:(NSPoint)newOrigin;
- (void)translateXBy:(float)amountX yBy:(float)amountY;
- (void)finalizeMotion;
- (void)drawRect:(NSRect)rect;
- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(float)frac;
- (void)transformedDrawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(float)frac;
- (void)compositeUnder:(PXLayer *)aLayer flattenOpacity:(BOOL)flattenOpacity;
- (void)compositeUnder:(PXLayer *)aLayer inRect:(NSRect)aRect flattenOpacity:(BOOL)flattenOpacity;
- (void)compositeNoBlendUnder:(PXLayer *)aLayer inRect:(NSRect)aRect;
- (NSImage *)displayImage;
- (NSImage *)exportImage;
- (void)adaptToPalette:(PXPalette *)p withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor;

- (void)meldBezier:(NSBezierPath *)path ofColor:(NSColor *)color;
- (void)unmeldBezier;

- (void)flipHorizontally;
- (void)flipVertically;
- (void)rotateByDegrees:(int)degrees;

- (void)rotateByDegrees:(int)degrees;

- (void)applyImage:(NSImage *)img;

- (PXLayer *)layerAfterApplyingMove;
@end
