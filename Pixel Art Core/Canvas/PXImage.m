//
//  PXImage.m
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

#import "PXImage.h"
#import <Foundation/NSGeometry.h>

int PXTileBitsPerComponent = 8;
int PXTileComponentsPerPixel = 4;
int PXTileDimension = 256;

PXTile* PXTileCreate(CGPoint loc, CGSize size, CGColorSpaceRef colorspace, unsigned char *data)
{
	PXTile *t = calloc(1, sizeof(PXTile));
	int bytesPerRow = PXTileComponentsPerPixel * size.width;
	if(data == NULL)
	{
		data = calloc(bytesPerRow*size.height, 1);
	}
	t->location = loc;
	t->painting = CGBitmapContextCreate(data, 
										size.width, 
										size.height, 
										PXTileBitsPerComponent, 
										bytesPerRow, 
										colorspace, 
										kCGImageAlphaPremultipliedLast);
	t->image = CGBitmapContextCreateImage(t->painting);
	return t;
}
void PXTileRelease(PXTile* t)
{
	void*data = CGBitmapContextGetData(t->painting);
	CGContextRelease(t->painting);
	if(data)
	{
		free(data);
	}
	CGImageRelease(t->image);
}
void PXTileDraw(PXTile* t, CGRect source, CGRect dest)
{
	CGRect fullRect = CGRectMake(t->location.x, t->location.y, CGBitmapContextGetWidth(t->painting), CGBitmapContextGetHeight(t->painting));
	if(!CGRectIntersectsRect(source, fullRect)) { return; }
	if(!t->image)
	{
		t->image = CGBitmapContextCreateImage(t->painting);
	}
    CGContextRef target = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextDrawImage(target, dest, t->image);
}
CGColorRef PXTileColorAtXY(PXTile *t, NSUInteger xv, NSUInteger yv)
{
	if(xv < t->location.x || xv >= t->location.x + CGBitmapContextGetWidth(t->painting)) { return NULL; }
	if(yv < t->location.y || yv >= t->location.y + CGBitmapContextGetHeight(t->painting)) { return NULL; }
	unsigned x = xv - t->location.x;
	unsigned y = yv - t->location.y;
	
	unsigned char *data = CGBitmapContextGetData(t->painting);
	size_t bytesPerRow = CGBitmapContextGetBytesPerRow(t->painting);
	NSUInteger startIndex = (CGBitmapContextGetHeight(t->painting) - 1 - y)*bytesPerRow+x*PXTileComponentsPerPixel;
	CGFloat a,b,c,d;
	d = data[startIndex+3] / 255.0;
	if(d > 0)
	{
		a = data[startIndex+0] / (255.0*d);
		b = data[startIndex+1] / (255.0*d);
		c = data[startIndex+2] / (255.0*d);
	}
	else
	{
		a = b = c = 0;
	}
	const CGFloat components[4] = {a, b, c, d};
	return CGColorCreate(CGBitmapContextGetColorSpace(t->painting), components);
}
void PXTileSetAtXY(PXTile *t, NSUInteger xv, NSUInteger yv, CGColorRef color)
{
	if(xv < t->location.x || xv >= t->location.x + CGBitmapContextGetWidth(t->painting)) { return; }
	if(yv < t->location.y || yv >= t->location.y + CGBitmapContextGetHeight(t->painting)) { return; }
	unsigned x = xv - t->location.x;
	unsigned y = yv - t->location.y;
	
	if(t->image)
	{		
		CGImageRelease(t->image);
		t->image = NULL;
	}
	unsigned char *data = CGBitmapContextGetData(t->painting);
	size_t bytesPerRow = CGBitmapContextGetBytesPerRow(t->painting);
	NSUInteger startIndex = (CGBitmapContextGetHeight(t->painting) - 1 - y)*bytesPerRow+x*PXTileComponentsPerPixel;
	const CGFloat *components = CGColorGetComponents(color);
	float a = components[3];
	data[startIndex+0] = a*components[0]*255;
	data[startIndex+1] = a*components[1]*255;
	data[startIndex+2] = a*components[2]*255;
	data[startIndex+3] = a*255;
}
NSUInteger PXTileGetData(PXTile *t, unsigned char **data)
{
	if(data != NULL)
	{
		*data = CGBitmapContextGetData(t->painting);
	}
	return CGBitmapContextGetBytesPerRow(t->painting) * CGBitmapContextGetHeight(t->painting);
}

PXImage *PXImage_alloc()
{
	PXImage *image = (PXImage *)malloc(sizeof(PXImage));
	image->retainCount = 1;
	return image;
}

PXImage *PXImage_init(PXImage *self)
{
	self->width = 0;
	self->height = 0;
	self->tileCount = 0;
	self->tiles = calloc(1, sizeof(PXTile *));
	self->colorspace = CGColorSpaceCreateDeviceRGB();
	return self;
}

void PXImage_encodeWithCoder(PXImage *self, NSCoder *coder)
{
	id dict = [NSMutableDictionary dictionaryWithCapacity:4];
	[dict setObject:[NSNumber numberWithInteger:(self->width)] forKey:@"width"];
	[dict setObject:[NSNumber numberWithInteger:(self->height)] forKey:@"height"];
	NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:self->tileCount];
	int i;
	for (i = 0; i < self->tileCount; i++)
	{
		PXTile *t = self->tiles[i];
		unsigned char *bytes;
		NSUInteger length = PXTileGetData(t, &bytes);
		NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
						   NSStringFromPoint((*(NSPoint *)&(t->location))), @"location",
						   [NSData dataWithBytes:bytes length:length], @"data", nil];
		[tiles addObject:d];
	}
	[dict setObject:tiles forKey:@"tiles"];
	[coder encodeObject:dict forKey:@"image"];
}

PXImage *PXImage_initWithCoder(PXImage *self, NSCoder *coder)
{
	PXImage_init(self);
	NSDictionary *dict = [coder decodeObjectForKey:@"image"];
	self->width = [[dict objectForKey:@"width"] intValue];
	self->height = [[dict objectForKey:@"height"] intValue];
	self->tileCount = 0;
	NSArray *tileArray = [dict objectForKey:@"tiles"];
	self->tiles = calloc([tileArray count], sizeof(PXTile *));
	for (id current in tileArray)
	{
		NSPoint pt = NSPointFromString([current objectForKey:@"location"]);
		int bytesPerRow = PXTileComponentsPerPixel * PXTileDimension;
		unsigned char *data = calloc(bytesPerRow*PXTileDimension, 1);
		memcpy(data, [[current objectForKey:@"data"] bytes], sizeof(unsigned char) * bytesPerRow * PXTileDimension);
		self->tiles[self->tileCount] = PXTileCreate((*(CGPoint *)&(pt)), CGSizeMake(PXTileDimension, PXTileDimension), self->colorspace, data);
		self->tileCount++;
	}
	return self;
}

PXImage *PXImage_initWithSize(PXImage *self, NSSize size)
{
	PXImage_init(self);
	self->width = size.width;
	self->height = size.height;
	return self;
}

void PXImage_dealloc(PXImage *self)
{
	CGColorSpaceRelease(self->colorspace);
	if(self->tiles)
	{
		unsigned i;
		for (i = 0; i < self->tileCount; i++)
		{
			if(self->tiles[i])
			{
				PXTileRelease(self->tiles[i]);
			}
		}
		free(self->tiles);
	}
	free(self);
}

PXImage *PXImage_copy(PXImage *self)
{
	PXImage *image = PXImage_init(PXImage_alloc());
	image->width = self->width;
	image->height = self->height;
	image->tileCount = self->tileCount;
	free(image->tiles);
	image->tiles = calloc(self->tileCount, sizeof(PXTile *));
	int i;
	for (i = 0; i < self->tileCount; i++)
	{
		PXTile *t = self->tiles[i];
		unsigned char *bytes;
		NSUInteger length = PXTileGetData(t, &bytes);
		unsigned char *copyBytes = calloc(length, sizeof(unsigned char));
		memcpy(copyBytes, bytes, length);
		image->tiles[i] = PXTileCreate(t->location, 
									   CGSizeMake(PXTileDimension, PXTileDimension), 
									   self->colorspace, 
									   copyBytes);
	}	
	return image;
}

PXImage *PXImage_retain(PXImage *self)
{
	if (self == nil) {
		return self;
	}
	self->retainCount++;
	return self;
}

PXImage *PXImage_release(PXImage *self)
{
	if (self == nil) {
		return self;
	}
	self->retainCount--;
	if (self->retainCount <= 0) {
		PXImage_dealloc(self);
	}
	return self;
}

PXTile *PXImage_tileAtXY(PXImage *self, NSUInteger xv, NSUInteger yv)
{
	CGPoint tileLocation = CGPointMake((xv / PXTileDimension) * PXTileDimension, (yv / PXTileDimension) * PXTileDimension);
	PXTile *t;
	BOOL found = NO;
	int i;
	for (i = 0; i < self->tileCount; i++)
	{
		t = self->tiles[i];
		if(CGPointEqualToPoint(t->location, tileLocation))
		{
			found = YES;
			break;
		}
	}
	if(!found)
	{
		self->tileCount++;
		self->tiles = realloc(self->tiles, self->tileCount * sizeof(PXTile*));
		self->tiles[self->tileCount-1] = PXTileCreate(tileLocation, CGSizeMake(PXTileDimension, PXTileDimension), self->colorspace, NULL);
		t = self->tiles[self->tileCount-1];
	}
	return t;
}

NSColor *PXImage_colorAtIndex(PXImage *self, NSUInteger loc)
{
	NSUInteger xLoc = loc % self->width;
	NSUInteger yLoc = (loc - (loc % self->width))/self->width;
	return PXImage_colorAtXY(self, xLoc, self->height - yLoc - 1);
}

NSColor *PXImage_backgroundColor(PXImage *self)
{
	return [[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
}

NSColor *PXImage_colorAtXY(PXImage *self, NSUInteger x, NSUInteger y)
{
	CGColorRef c = PXTileColorAtXY(PXImage_tileAtXY(self, x, y), x, y);
	if(c == NULL)
	{
		return PXImage_backgroundColor(self);
	}
	NSColor *color = [NSColor colorWithColorSpace:[NSColorSpace deviceRGBColorSpace] components:CGColorGetComponents(c) count:CGColorGetNumberOfComponents(c)];
	CGColorRelease(c);
	return color;
}

void PXImage_setColorAtIndex(PXImage *self, NSColor *c, NSUInteger loc)
{
	NSUInteger xLoc = loc % self->width;
	NSUInteger yLoc = (loc - (loc % self->width))/self->width;
	PXImage_setColorAtXY(self, c, xLoc, self->height - yLoc - 1);
}

void PXImage_setColorAtXY(PXImage *self, NSColor *color, NSUInteger xv, NSUInteger yv)
{
	PXTile *t = PXImage_tileAtXY(self, xv, yv);
	CGFloat components[4];
	[[color colorUsingColorSpaceName:NSDeviceRGBColorSpace] getComponents:components];
	CGColorRef c = CGColorCreate(self->colorspace, components);
	PXTileSetAtXY(t, xv, yv, c);
	CGColorRelease(c);
}

void PXImage_flipHorizontally(PXImage *self)
{
	NSColor * leftColor, *rightColor;
	int x, y;
	for (y=0; y<self->height; y++) {
		for (x=0; x<self->width/2; x++) {
			leftColor = PXImage_colorAtXY(self, x, y);
			rightColor = PXImage_colorAtXY(self, self->width - x - 1, y);
			PXImage_setColorAtXY(self, rightColor, x, y);
			PXImage_setColorAtXY(self, leftColor, self->width - x - 1, y);
		}
	}
}

void PXImage_flipVertically(PXImage *self)
{
	NSColor * leftColor, *rightColor;
	int x, y;
	for (y=0; y<self->height/2; y++) {
		for (x=0; x<self->width; x++) {
			leftColor = PXImage_colorAtXY(self, x, y);
			rightColor = PXImage_colorAtXY(self, x, self->height - y - 1);
			PXImage_setColorAtXY(self, rightColor, x, y);
			PXImage_setColorAtXY(self, leftColor, x, self->height - y - 1);
		}
	}
}

#define WRAP(thing) {\
while(x##thing < 0) { x##thing += self->width; }\
while(y##thing < 0) { y##thing += self->height; }\
if(x##thing >= self->width) { x##thing -= self->width; }\
if(y##thing >= self->height) { y##thing -= self->height; }\
}	

void PXImage_translate(PXImage *self, NSInteger deltaX, NSInteger deltaY, BOOL wrap)
{
	if (deltaX == 0 && deltaY == 0) { return; }
	PXImage *copy = PXImage_copy(self);
	NSUInteger startX=0, startY=0, endX=self->width-1, endY=self->height-1, x, y;
	int directionX=1, directionY=1;
	if (deltaX > 0) {
		startX = endX;
		endX = 0;
		directionX *= -1;
	}
	if (deltaY > 0) {
		startY = endY;
		endY = 0;
		directionY *= -1;
	}
	for (y=startY; y*directionY <= endY*directionY; y+=directionY) {
		for (x=startX; x*directionX <= endX*directionX; x+=directionX) {
			NSInteger xDst = x, yDst = y, xSrc = x-deltaX, ySrc = y-deltaY;
			if(wrap)
			{
				WRAP(Dst)
				WRAP(Src)
			}
			PXImage_setColorAtXY(self, PXImage_colorAtXY(copy, xSrc, ySrc), xDst, yDst);
		}
	}
	PXImage_release(copy);
}

void PXImage_swapTiles(PXImage *self, PXImage *other)
{
	NSUInteger swapC = self->tileCount;
	self->tileCount = other->tileCount;
	other->tileCount = swapC;
	PXTile **swapT = self->tiles;
	self->tiles = other->tiles;
	other->tiles = swapT;
}

void PXImage_setSize(PXImage *self, NSSize newSize, NSPoint origin, NSColor * backgroundColor)
{
	PXImage *dup = PXImage_initWithSize(PXImage_alloc(), newSize);
	int i, j;
	int newWidth = newSize.width, newHeight = newSize.height;
	dup->width = newWidth;
	dup->height = newHeight;
	int originX = origin.x, originY = origin.y;
	for (i=0; i < newWidth; i++) {
		for (j=0; j < newHeight; j++) {
			if (i < originX || j < originY || 
				i >= self->width + originX || j >= self->height + originY) {
				PXImage_setColorAtXY(dup, backgroundColor, i, j);
			} else {
				PXImage_setColorAtXY(dup, PXImage_colorAtXY(self, i-originX, j-originY), i, j);
			}
		}
	}
	self->width = newWidth;
	self->height = newHeight;
	PXImage_swapTiles(self, dup);
	PXImage_release(dup);
}

void PXImage_rotateByDegrees(PXImage *self, NSInteger degrees)
{
	if (degrees != 90 && degrees != 180 && degrees != 270) { return; } // only support orthogonal rotation
	NSUInteger i, j;
	PXImage *dup = PXImage_copy(self);
	
	// update our size if necessary
	NSUInteger oldWidth = self->width;
	NSUInteger oldHeight = self->height;
	if (degrees != 180)
	{
		self->height = oldWidth;
		self->width = oldHeight;
	}
	
	for (j = 0; j < oldHeight; j++)
	{
		for (i = 0; i < oldWidth; i++)
		{
			NSUInteger x=0, y=0;
			if (degrees == 270)
			{
				x = j;
				y = self->height - 1 - i;
			}
			else if (degrees == 180)
			{
				x = self->width - 1 - i;
				y = self->height - 1 - j;
			}
			else if (degrees == 90)
			{
				x = self->width - 1 - j;
				y = i;
			}
			PXImage_setColorAtXY(dup, PXImage_colorAtXY(self, i, j), x, y);
		}
	}
	PXImage_swapTiles(self, dup);
	PXImage_release(dup);
}

void PXImage_compositeUnderInRect(PXImage *self, PXImage *other, NSRect aRect, BOOL blend)
{
	int i, j;
	
	NSColor * topColor;
	NSColor * bottomColor;
	NSColor * usedColor;
	
    for (i = NSMinX(aRect); i < NSMaxX(aRect); i++)
    {
        for (j = NSMinY(aRect); j < NSMaxY(aRect); j++)
        {
			topColor = PXImage_colorAtXY(other, i, j);
			bottomColor = PXImage_colorAtXY(self, i, j);
			usedColor = topColor;
			
			if (blend) {
				usedColor = PXImage_blendColors(self, bottomColor, topColor);
			}
			if ([usedColor alphaComponent] != 0)
			{
				PXImage_setColorAtXY(self, usedColor, i, j);
			}
        }
    }
}

void PXImage_compositeUnder(PXImage *self, PXImage *other, BOOL blend)
{
	PXImage_compositeUnderInRect(self, other, NSMakeRect(0,0,self->width,self->height), blend);
}

void PXImage_drawRect(PXImage *self, NSRect rect, double opacity)
{
	PXImage_drawInRectFromRectWithOperationFraction(self, rect, rect, NSCompositeSourceOver, opacity);
}

void PXImage_drawInRectFromRectWithOperationFraction(PXImage *self, NSRect dst, NSRect src, NSCompositingOperation operation, double opacity)
{
	NSGraphicsContext *nsContext = [NSGraphicsContext currentContext];
	[nsContext setCompositingOperation:operation];
    CGContextRef target = (CGContextRef)[nsContext graphicsPort];
	CGContextSetAlpha(target, opacity);
	CGRect source = (*(CGRect *)&(src));

	float widthScale = NSWidth(dst) / NSWidth(src);
	float heightScale = NSHeight(dst) / NSHeight(src);
	NSRect fullDest = dst;
	fullDest.origin.x -= widthScale * (NSMinX(src) - floorf(NSMinX(src)));
	fullDest.origin.y -= heightScale * (NSMinY(src) - floorf(NSMinY(src)));
	fullDest.size.width += widthScale * (ceilf(NSWidth(src)) - NSWidth(src));
	fullDest.size.height += heightScale * (ceilf(NSHeight(src)) - NSHeight(src));
	NSAffineTransform *transform = [[NSAffineTransform alloc] init];
	[transform translateXBy:fullDest.origin.x yBy:fullDest.origin.y];
	[transform scaleXBy:widthScale yBy:heightScale];
	CGContextTranslateCTM(target, -fullDest.origin.x, -fullDest.origin.y);
	NSSize drawSize = [transform transformSize:NSMakeSize(PXTileDimension, PXTileDimension)];
	unsigned i;
	for (i = 0; i < self->tileCount; i++)
	{
		CGPoint tileLoc = self->tiles[i]->location;
		NSPoint drawPoint = [transform transformPoint:(*(NSPoint *)&(tileLoc))];
		PXTileDraw(self->tiles[i], source, CGRectMake(drawPoint.x, drawPoint.y, drawSize.width, drawSize.height));
	}
    [transform release];
	CGContextTranslateCTM(target, fullDest.origin.x, fullDest.origin.y);
}

NSColor * PXImage_blendColors(PXImage * self, NSColor * bottomColor, NSColor * topColor)
{
	bottomColor = [bottomColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	topColor = [topColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	float compositeRedComponent;
	float compositeGreenComponent;
	float compositeBlueComponent;
	float compositeAlphaComponent;
	float topBlueComponent = [topColor blueComponent];
	float topRedComponent = [topColor redComponent];
	float topGreenComponent = [topColor greenComponent];
	float topAlphaComponent = [topColor alphaComponent];
	float bottomBlueComponent = [bottomColor blueComponent];
	float bottomRedComponent = [bottomColor redComponent];
	float bottomGreenComponent = [bottomColor greenComponent];
	float bottomAlphaComponent = [bottomColor alphaComponent];			
	compositeAlphaComponent = topAlphaComponent + bottomAlphaComponent - (topAlphaComponent * bottomAlphaComponent);
	if(compositeAlphaComponent == 0)
	{
		return [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0];
	}
	else
	{	
		compositeRedComponent = bottomRedComponent + ((topRedComponent - bottomRedComponent) * (topAlphaComponent / compositeAlphaComponent));
		compositeBlueComponent = bottomBlueComponent + ((topBlueComponent - bottomBlueComponent) * (topAlphaComponent / compositeAlphaComponent));
		compositeGreenComponent = bottomGreenComponent + ((topGreenComponent - bottomGreenComponent) * (topAlphaComponent / compositeAlphaComponent));
		return [NSColor colorWithDeviceRed:compositeRedComponent green:compositeGreenComponent blue:compositeBlueComponent alpha:compositeAlphaComponent];
	}	
}

NSImage *PXImage_NSImage(PXImage *self)
{
	if ((self->width <= 0) || (self->height <= 0))
		return nil;

	NSImage *nsimage = [[NSImage alloc] initWithSize:NSMakeSize(self->width, self->height)];

	if (!nsimage)
		return nil;

	[nsimage lockFocus];
	PXImage_drawRect(self, NSMakeRect(0, 0, self->width, self->height), 1);
	[nsimage unlockFocus];
	return [nsimage autorelease];
}

NSImage *PXImage_bitmapImage(PXImage *self)
{
	id nsimage = PXImage_NSImage(self);
	id rep = [[nsimage representations] objectAtIndex:0];
	if (![rep isKindOfClass:[NSBitmapImageRep class]])
	{
		NSLog(@"Converting cached to bitmap...");
		NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[nsimage TIFFRepresentation]];
		
		[nsimage removeRepresentation:rep];
		[nsimage addRepresentation:imageRep];
	}
	rep = [[nsimage representations] objectAtIndex:0]; // could be different now.
	if (![rep hasAlpha])
	{
		unsigned char * newData = malloc(self->width * self->height * 4);
		NSBitmapImageRep *tempRep = [NSBitmapImageRep imageRepWithData:[rep TIFFRepresentation]];
		unsigned char * oldData = [tempRep bitmapData];
		int i, j;
		NSSize imageSize = NSMakeSize([tempRep pixelsWide], [tempRep pixelsHigh]);
		NSInteger bytesPerRow = [tempRep bytesPerRow];
		NSInteger samplesPerPixel = [tempRep samplesPerPixel];
		for (j = 0; j < imageSize.height; j++)
		{
			for (i = 0; i < imageSize.width; i++)
			{
				NSInteger oldBase = j * bytesPerRow + i * samplesPerPixel;
				NSUInteger newBase = j * 4 * self->width + i * 4;
				newData[newBase + 0] = oldData[oldBase + 0];
				newData[newBase + 1] = oldData[oldBase + 1];
				newData[newBase + 2] = oldData[oldBase + 2];
				newData[newBase + 3] = 255;
			}
		}
		id imageRep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&newData 
															   pixelsWide:self->width 
															   pixelsHigh:self->height 
															bitsPerSample:8 
														  samplesPerPixel:4 
																 hasAlpha:YES 
																 isPlanar:NO 
														   colorSpaceName:NSDeviceRGBColorSpace 
															  bytesPerRow:self->width * 4 
															 bitsPerPixel:32] autorelease];
		[nsimage removeRepresentation:rep];
		[nsimage addRepresentation:imageRep];
	}
	rep = [[nsimage representations] objectAtIndex:0]; // could be different now.
	
	if ([[rep valueForKey:@"bitmapFormat"] intValue] & 1) // == argb instead of rgba
	{
		unsigned char *bitmapData = [rep bitmapData];
		int i, j;
		for (j = 0; j < self->height; j++)
		{
			for (i = 0; i < self->width; i++)
			{
				NSInteger baseIndex = j * [rep bytesPerRow] + i*4;
				unsigned char temp;
				temp = bitmapData[baseIndex];
				bitmapData[baseIndex] = bitmapData[baseIndex+1];
				bitmapData[baseIndex+1] = bitmapData[baseIndex+2];
				bitmapData[baseIndex+2] = bitmapData[baseIndex+3];
				bitmapData[baseIndex+3] = temp;
			}
		}
	}	
	return nsimage;
}
