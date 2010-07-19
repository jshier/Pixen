//
//  PXImageBackground.h
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

//  Created by Joe Osborn on Tue Oct 28 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//


#import <AppKit/AppKit.h>

typedef struct {
	CGContextRef painting; //we draw into its bytes and make an image out of it when it changes
	CGImageRef image; //we draw it onto the context during drawrect
	CGPoint location;
} PXTile;

typedef struct {
	PXTile** tiles;
	NSUInteger tileCount;
	CGColorSpaceRef colorspace;	

	NSUInteger retainCount;
		
	NSUInteger width, height;
} PXImage;

PXTile* PXTileCreate(CGPoint loc, CGSize size, CGColorSpaceRef colorspace, unsigned char *data);
void PXTileRelease(PXTile* t);
void PXTileDraw(PXTile* t, CGRect source, CGRect dest);
CGColorRef PXTileColorAtXY(PXTile *t, NSUInteger xv, NSUInteger yv);
void PXTileSetAtXY(PXTile *t, NSUInteger xv, NSUInteger yv, CGColorRef color);
NSUInteger PXTileGetData(PXTile *t, unsigned char **data);

PXImage *PXImage_alloc(void);

PXImage *PXImage_init(PXImage *self);
PXImage *PXImage_initWithSize(PXImage *self, NSSize size);
void PXImage_dealloc(PXImage *self);
PXImage *PXImage_copy(PXImage *self);
PXImage *PXImage_retain(PXImage *self);
PXImage *PXImage_release(PXImage *self);

NSColor *PXImage_backgroundColor(PXImage *self);

NSColor *PXImage_colorAtIndex(PXImage *self, NSUInteger loc);
NSColor *PXImage_colorAtXY(PXImage *self, NSUInteger x, NSUInteger y);
void PXImage_setColorAtXY(PXImage *self, NSColor *color, NSUInteger x, NSUInteger y);
void PXImage_setColorAtIndex(PXImage *self, NSColor *c, NSUInteger loc);

PXTile *PXImage_tileAtXY(PXImage *self, NSUInteger xv, NSUInteger yv);
void PXImage_swapTiles(PXImage *self, PXImage *other);
void PXImage_drawRect(PXImage *self, NSRect rect, double opacity);

void PXImage_flipHorizontally(PXImage *self);
void PXImage_flipVertically(PXImage *self);
void PXImage_translate(PXImage *self, NSInteger deltaX, NSInteger deltaY, BOOL wrap);
void PXImage_rotateByDegrees(PXImage *self, NSInteger degrees);

void PXImage_setSize(PXImage *self, NSSize newSize, NSPoint origin, NSColor * backgroundColor);

void PXImage_drawInRectFromRectWithOperationFraction(PXImage *self, NSRect dst, NSRect src, NSCompositingOperation operation, double opacity);
void PXImage_compositeUnder(PXImage *self, PXImage *other, BOOL blend);
void PXImage_compositeUnderInRect(PXImage *self, PXImage *other, NSRect aRect, BOOL blend);

NSColor * PXImage_blendColors(PXImage * self, NSColor * bottomColor, NSColor * topColor);

NSData *PXImage_encodedData(PXImage *self);
PXImage *PXImage_initWithData(PXImage *self, NSData *data);

PXImage *PXImage_initWithCoder(PXImage *self, NSCoder *coder);
void PXImage_encodeWithCoder(PXImage *self, NSCoder *coder);

NSImage *PXImage_NSImage(PXImage *self);
NSImage *PXImage_bitmapImage(PXImage *self);
