//
//  PXLayer.m
//  Pixen-XCode
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

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

#import "PXLayer.h"
#import "PXLayerController.h"
#import "PXImage.h"
#import "PXPalette.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"

@implementation PXLayer

+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image origin:(NSPoint)origin size:(NSSize)sz
{
	id layer = [[PXLayer alloc] initWithName:name size:sz];
	// okay, now we have to make sure the image is the same size as the canvas
	// if it isn't, the weird premade image thing will cause serious problems.
	// soooo... haxx!
	NSImage *layerImage = [[[NSImage alloc] initWithSize:sz] autorelease];
	[layerImage lockFocus]; {
		[image drawAtPoint:origin fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeCopy fraction:1];			
	} [layerImage unlockFocus];
	[layer applyImage:layerImage];
	return layer;
}

+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image size:(NSSize)sz
{
	return [self layerWithName:name image:image origin:NSZeroPoint size:sz];
}

- (id) initWithName:(NSString *) aName 
			  image:(PXImage *)anImage
{
	[super init];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(paletteChanged:)
			   name:PXPaletteChangedNotificationName
			 object:nil];
	[self setName:aName];
	if(anImage)
	{
		image = PXImage_retain(anImage);
	}
	origin = NSZeroPoint;
	meldedColor = nil;
	meldedBezier = nil;
	canvas = nil;
	opacity = 100;
	visible = YES;
	return self;
}

-(id) initWithName:(NSString *) aName size:(NSSize)size
{
	return [self initWithName:aName size:size fillWithColor:[[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]];
}

- initWithName:(NSString *)aName size:(NSSize)size fillWithColor:(NSColor *)c
{
	[self initWithName:aName image:nil];
	image = PXImage_initWithSize(PXImage_alloc(), size);
	if (image)
	{
//FIXME: this is unconscionable - just RectFill into the CGImages!
		int i;
		for (i = 0; i < size.width * size.height; i++)
		{
			PXImage_setColorAtIndex(image, c, i);
		}
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[meldedBezier release];
	[meldedColor release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	PXImage_release(image);
	[super dealloc];
}

-(NSString *) name
{
	return name;
}

- (void)setName:(NSString *)aName
{
	[name release];
	name = [aName copy];
}

- (PXImage *)image
{
	return image;
}

- (double)opacity
{
	return opacity;
}

- (void)setOpacity:(double)newOpacity
{
	opacity = newOpacity;
}

- (BOOL)visible
{
	return visible;
}

- (void)setVisible:(BOOL)isVisible
{
	visible = isVisible;
}

- (NSColor *)colorAtIndex:(unsigned int)index
{
	if (!canvas) { return nil; }
	return PXImage_colorAtIndex(image, index);
}

- (NSColor *)colorAtPoint:(NSPoint)pt
{
	NSPoint point = pt;
	if(canvas)
	{
		point = [canvas correct:pt];
		if(point.x >= [self size].width ||
		   point.x < 0 ||
		   point.y >= [self size].height ||
		   point.y < 0)
		{
			return [[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		}
	}
	return PXImage_colorAtXY(image, point.x, point.y);
}

- (void)setColor:(NSColor *)c atIndex:(NSUInteger)loc
{
	PXImage_setColorAtIndex(image, c, loc);
}

- (void)setColor:(NSColor *)color atPoint:(NSPoint)pt
{
	NSPoint point = pt;
	if(canvas)
	{
		point = [canvas correct:pt];
		if(point.x >= [self size].width ||
		   point.x < 0 ||
		   point.y >= [self size].height ||
		   point.y < 0)
		{
			return;
		}
	}
	PXImage_setColorAtXY(image, color, point.x, point.y);
}

- (void)rotateByDegrees:(NSUInteger)degrees
{
	PXImage_rotateByDegrees(image, degrees);
}

- (void)moveToPoint:(NSPoint)newOrigin
{
	origin = newOrigin;
}

- (NSSize)size
{
	if (image == NULL) {
		return NSZeroSize;
	}
	return NSMakeSize(image->width, image->height);
}

- (void)setCanvas:(PXCanvas *)c
{
	canvas = c;
}

- (PXCanvas *)canvas
{
	return canvas;
}

- (void)meldBezier:(NSBezierPath *)path ofColor:(NSColor *)color
{
	[meldedColor release];
	meldedColor = [color retain];
	meldedBezier = [path retain];
}

- (void)unmeldBezier
{
	[meldedBezier release];
	meldedBezier = nil;
}

- (void)setSize:(NSSize)newSize withOrigin:(NSPoint)point backgroundColor:(NSColor *)color
{
	PXImage_setSize(image, newSize, point, color);
}

- (void)setSize:(NSSize)newSize
{
	PXImage_setSize(image, newSize, NSZeroPoint, [[self canvas] eraseColor]);
}

- (NSPoint)origin
{
	return origin;
}

- (void)setOrigin:(NSPoint)pt
{
	origin = pt;
}

- (void)finalizeMotion
{
	NSPoint point = [canvas correct:origin];
	PXImage_translate(image, point.x, point.y, [canvas wraps]);
	origin = NSZeroPoint;
	[canvas changedInRect:NSMakeRect(0, 0, [self size].width, [self size].height)];
}

- (void)translateXBy:(float)amountX yBy:(float)amountY
{
	[self moveToPoint:NSMakePoint(origin.x + amountX, origin.y + amountY)];
}

- (void)transformedDrawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(float)frac
{
	if(NSWidth(src) == 0 || NSHeight(src) == 0) {
		return;
	}
	if(meldedBezier != nil) {
		float widthScale = NSWidth(dst) / NSWidth(src);
		float heightScale = NSHeight(dst) / NSHeight(src);
		NSAffineTransform *transform = [NSAffineTransform transform];
		[transform scaleXBy:widthScale yBy:heightScale];

		if([meldedColor alphaComponent] == 1) {
			PXImage_drawInRectFromRectWithOperationFraction(image, dst, src, op, frac * ([self opacity] / 100.0));
			[meldedColor set];
			[[transform transformBezierPath:meldedBezier] fill];
		} else {
			NSSize fullSize = NSMakeSize((widthScale * NSWidth(src)),
										 (heightScale * NSHeight(src)));
			if(!cachedSourceOutImage || 
			   (fullSize.width > [cachedSourceOutImage size].width) || 
			   (fullSize.height > [cachedSourceOutImage size].height))
			{
				[cachedSourceOutImage autorelease];
				cachedSourceOutImage = [[NSImage alloc] initWithSize:fullSize];
			}
			[cachedSourceOutImage lockFocus];
			NSRectFillUsingOperation(NSMakeRect(0, 0, [cachedSourceOutImage size].width, [cachedSourceOutImage size].height), NSCompositeClear);
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
			[[NSGraphicsContext currentContext] setShouldAntialias:NO];
			[[NSColor blackColor] set];
			NSAffineTransform *translate = [NSAffineTransform transform];
			[translate translateXBy:-src.origin.x*widthScale yBy:-src.origin.y*heightScale];
			[translate concat];
			[[transform transformBezierPath:meldedBezier] fill];
			PXImage_drawInRectFromRectWithOperationFraction(image, 
															NSMakeRect(0, 0, NSWidth(src)*widthScale, NSHeight(src)*heightScale), 
															src, 
															NSCompositeSourceOut, 
															1);
			[translate invert];
			[translate concat];
			[cachedSourceOutImage unlockFocus];
			[cachedSourceOutImage drawInRect:dst 
									fromRect:NSMakeRect(0, 0, NSWidth(src)*widthScale, NSHeight(src)*heightScale) 
								   operation:op
									fraction:frac * ([self opacity] / 100.0)];
			[meldedColor set];
			[[transform transformBezierPath:meldedBezier] fill];
		}
		
	} else {
		PXImage_drawInRectFromRectWithOperationFraction(image, dst, src, op, frac * ([self opacity] / 100.0));
	}
} 

- (void)drawRect:(NSRect)rect
{
	[self drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1];
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src
{
	[self drawInRect:dst fromRect:src operation:NSCompositeSourceOver fraction:1];
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(float)frac
{
	if (!visible || opacity == 0) { return; }
//FIXME: this shouldn't be here
	float widthScale = NSWidth(dst) / NSWidth(src);
	float heightScale = NSHeight(dst) / NSHeight(src);
	float xOff = widthScale*origin.x+(dst.origin.x-(src.origin.x*widthScale));
	float yOff = heightScale*origin.y+(dst.origin.y-(src.origin.y*heightScale));
	CGContextTranslateCTM([[NSGraphicsContext currentContext] graphicsPort], xOff, yOff);
	[self transformedDrawInRect:dst fromRect:src operation:op fraction:frac];
	CGContextTranslateCTM([[NSGraphicsContext currentContext] graphicsPort], -xOff, -yOff);
}

//FIXME: maybe should not be here ? 
//It's called, it makes the calling simpler, it's worth keeping.
- (void)compositeUnder:(PXLayer *)aLayer flattenOpacity:(BOOL)flattenOpacity
{
	[self compositeUnder:aLayer inRect:NSMakeRect(0, 0, [self size].width, [self size].height) flattenOpacity:flattenOpacity];
}

- (void)compositeUnder:(PXLayer *)aLayer inRect:(NSRect)aRect flattenOpacity:(BOOL)flattenOpacity
{
	int i, j;
	if(flattenOpacity)
	{
		for (i=NSMinX(aRect); i < NSMaxX(aRect); i++)
		{
			for (j=NSMinY(aRect); j < NSMaxY(aRect); j++)
			{
				NSPoint point = NSMakePoint(i, j);
				id color1 = PXImage_colorAtXY(image,point.x,point.y), color2 = PXImage_colorAtXY([aLayer image],point.x,point.y);
				PXImage_setColorAtXY(image,((flattenOpacity) ? [color1 colorWithAlphaComponent:[color1 alphaComponent]*([self opacity]/100.00)] : color1),point.x,point.y);
				PXImage_setColorAtXY([aLayer image],((flattenOpacity) ? [color2 colorWithAlphaComponent:[color2 alphaComponent]*([aLayer opacity]/100.00)] : color2),point.x,point.y);
			}
		}
	}
	PXImage_compositeUnderInRect(image, [aLayer image], aRect, YES);
	if (flattenOpacity) 
	{ 
		[self setOpacity:MAX(opacity, [aLayer opacity])]; 
	}
}

- (void)compositeNoBlendUnder:(PXLayer *)aLayer inRect:(NSRect)aRect
{
	PXImage_compositeUnderInRect(image, [aLayer image], aRect, NO);	
}

- (NSImage *)exportImage
{
	return PXImage_bitmapImage(image);
}

- (NSImage *)displayImage
{
	return PXImage_NSImage(image);
}

- (void)flipHorizontally
{
	PXImage_flipHorizontally(image);
}

- (void)flipVertically
{
	PXImage_flipVertically(image);
}

-(id) initWithCoder:(NSCoder *)coder
{
	[super init];
	
	image = PXImage_initWithCoder(PXImage_alloc(), coder);
	name = [[coder decodeObjectForKey:@"name"] retain];
	
	if([coder containsValueForKey:@"visible"])
	{
		visible = [coder decodeBoolForKey:@"visible"];
	}
	else
	{
		visible = YES;
	}
	
	if([coder decodeObjectForKey:@"opacity"] != nil)
	{	
		opacity = [[coder decodeObjectForKey:@"opacity"] doubleValue];
	}
	else
	{
		opacity = 100;
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	PXImage_encodeWithCoder(image, coder);
	[coder encodeObject:name forKey:@"name"];
	[coder encodeBool:visible forKey:@"visible"];
	[coder encodeObject:[NSNumber numberWithDouble:opacity] forKey:@"opacity"];
}

- (void)_setImage:(PXImage *)newImage
{
	image = newImage;
}

-(id) copyWithZone:(NSZone *)zone
{
	PXLayer * copy = [[[self class] alloc] initWithName:name image:PXImage_copy(image)];
	PXImage_release([copy image]);
	[copy setCanvas:[self canvas]];
	[copy setOpacity:opacity];
	[copy setVisible:visible];
	return copy;
}

- (PXLayer *)layerAfterApplyingMove
{
	PXLayer *newLayer = [[self copy] autorelease];
	PXImage_setSize(newLayer->image, [self size], [self origin], [canvas eraseColor]);
	return newLayer;
}

- (void)applyImage:(NSImage *)anImage
{
  NSBitmapImageRep *imageRep=nil;
    //this is probably pretty fragile.  there should be a better way of doing this, no?
	NSImageRep *ir = [[anImage representations] objectAtIndex:0];
	if (![ir isKindOfClass:[NSBitmapImageRep class]])
	{
		[anImage lockFocus];
		id oldRep = imageRep;
		imageRep = [NSBitmapImageRep imageRepWithData:[anImage TIFFRepresentation]];
		[anImage unlockFocus];
		[anImage removeRepresentation:oldRep];
		[anImage addRepresentation:imageRep];
	}
  else
  {
    imageRep = (NSBitmapImageRep *)ir;
  }
  int width = floorf([imageRep pixelsWide]);
	int height = floorf([imageRep pixelsHigh]);
	NSPoint dest = NSZeroPoint;
  for(int i = 0; i < width; i++)
  {
    dest.x = i;
    for (int j = 0; j < height; j++)
    {
      dest.y = height - j - 1;
      [self setColor:[imageRep colorAtX:i y:j] atPoint:dest]; 
    }
  }
}

- (void)adaptToPalette:(PXPalette *)p withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor
{
	id outputImage = [[[self displayImage] copy] autorelease];
	id rep = [NSBitmapImageRep imageRepWithData:[outputImage TIFFRepresentation]];
	unsigned char *bitmapData = [rep bitmapData];
	NSUInteger i;
	id calibratedClear = [[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	for (i = 0; i < [self size].width * [self size].height; i++)
	{
		NSUInteger base = i * [rep samplesPerPixel];
		NSColor *color;
		if (transparency && bitmapData[base + 3] == 0)
		{
			color = calibratedClear;
		}
		else if (transparency && matteColor && bitmapData[base + 3] < 255)
		{
			NSColor *sourceColor = [NSColor colorWithDeviceRed:bitmapData[base + 0] / 255.0f green:bitmapData[base + 1] / 255.0f blue:bitmapData[base + 2] / 255.0f alpha:1];
			color = [matteColor blendedColorWithFraction:(bitmapData[base + 3] / 255.0f) ofColor:sourceColor];
		}
		else
		{
			color = [NSColor colorWithDeviceRed:bitmapData[base + 0] / 255.0f green:bitmapData[base + 1] / 255.0f blue:bitmapData[base + 2] / 255.0f alpha:1];
		}
		[self setColor:PXPalette_colorClosestTo(p, color) atIndex:i];
	}
}

@end
