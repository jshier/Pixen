//
//  PXCanvas_Modifying.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXLayer.h"
#import "PXCanvas_Selection.h"
#import "gif_lib.h"
#import "NSString_DegreeString.h"


@implementation PXCanvas(Modifying)

- (BOOL)wraps
{
	return wraps;
}

- (void)setWraps:(BOOL)newWraps suppressRedraw:(BOOL)suppress
{
	wraps = newWraps;
	if (!suppress)
		[self changed];	
}

- (void)setWraps:(BOOL)newWraps
{
	[self setWraps:newWraps suppressRedraw:NO];
}

- (BOOL)containsPoint:(NSPoint)aPoint
{
	return wraps || NSPointInRect(aPoint, canvasRect);
}

- (NSPoint)correct:(NSPoint)aPoint
{
	if(!wraps) { return aPoint; }
	NSPoint corrected = aPoint;
	while(corrected.x < 0)
	{
		corrected.x += [self size].width;
	}
	while(corrected.y < 0)
	{
		corrected.y += [self size].height;
	}
	corrected.x = (int)(corrected.x) % (int)([self size].width);
	corrected.y = (int)(corrected.y) % (int)([self size].height);
	return corrected;	
}

- (void)setColor:(NSColor *)color atPoint:(NSPoint)aPoint
{
	if(![self containsPoint:aPoint]) { return; }
	[self setColor:color atPoint:[self correct:aPoint] onLayer:activeLayer];
}

- (void)setColor:(NSColor *)aColor atPoint:(NSPoint)aPoint onLayer:(PXLayer *)l
{
  [self refreshPaletteDecreaseColorCount:[l colorAtPoint:aPoint] increaseColorCount:aColor];
  [l setColor:aColor atPoint:aPoint];
}

- (void)setColor:(NSColor *)color atIndices:(NSArray *)indices updateIn:(NSRect)bounds onLayer:(PXLayer *)layer
{
	if([indices count] == 0) { return; }
	for (id current in indices)
	{
		int val = [current intValue];
		int x = val % (int)[self size].width;
		int y = [self size].height - ((val - x)/[self size].width) - 1;
    NSColor *oldColor = [layer colorAtIndex:val];
    NSPoint pt = NSMakePoint(x, y);
		[self bufferUndoAtPoint:pt fromColor:oldColor toColor:color];
		[self setColor:color atPoint:pt onLayer:layer];
	}
	[self changedInRect:bounds];
}

- (void)setColor:(NSColor *)color atIndices:(NSArray *)indices updateIn:(NSRect)bounds
{
	[self setColor:color atIndices:indices updateIn:bounds onLayer:activeLayer];
}

- (NSColor *) mergedColorAtPoint:(NSPoint)aPoint
{
  NSColor * currentColor = [NSColor clearColor];
  for(PXLayer *layer in layers)
  {
    if([layer visible] && [layer opacity] > 0)
    {
      NSColor *layerColor = [layer colorAtPoint:aPoint];
      layerColor = [layerColor colorWithAlphaComponent:([layer opacity]/100.0f) * [layerColor alphaComponent]];
      currentColor = PXImage_blendColors(nil, currentColor, layerColor);
    }
  }
  return [currentColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];  
}


- (NSColor *) surfaceColorAtPoint:(NSPoint)aPoint
{
  for(PXLayer *layer in [layers reverseObjectEnumerator])
  {
    if([layer visible] && [layer opacity] > 0)
    {
      NSColor *layerColor = [layer colorAtPoint:aPoint];
      if([layerColor alphaComponent] > 0)
      {
        return layerColor;
      }
    }
  }
  return [[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];  
}


- (NSColor*) colorAtPoint:(NSPoint)aPoint
{
	if( ! [self containsPoint:aPoint] ) 
		return nil; 
	
	return [activeLayer colorAtPoint:aPoint];
}


- (void)rotateByDegrees:(NSUInteger)degrees
{
	[self beginUndoGrouping];
    for (PXLayer *current in layers)
    {
        [self rotateLayer:current byDegrees:degrees];
    }
    [self endUndoGrouping:[NSString stringWithFormat:NSLocalizedString(@"Rotate %d%@", @"Rotate %d%@"), degrees, [NSString degreeString]]];
}

- (void)changed
{
	[self changedInRect:NSMakeRect(0,0,[self size].width,[self size].height)];
}

- (void)changedInRect:(NSRect)rect
{
	if(NSEqualSizes([self size], NSZeroSize) || NSEqualRects(rect, NSZeroRect)) { return; }
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSValue valueWithRect:rect],
						  PXChangedRectKey, 
						  activeLayer, PXActiveLayerKey, 
						  nil];
	
	[nc postNotificationName:PXCanvasChangedNotificationName
					  object:self
					userInfo:dict];
}

- (BOOL)canDrawAtPoint:(NSPoint)point
{
	if([self hasSelection])
	{
		if (![self pointIsSelected:point]) 
		{
			return NO; 
		}
	}
	return YES;
}

- (void)flipHorizontally
{
	[self beginUndoGrouping];
    for (PXLayer *current in layers)
    {
        [self flipLayerHorizontally:current];
    }
    [self endUndoGrouping:NSLocalizedString(@"Flip Canvas Horizontally", @"Flip Canvas Horizontally")];
}

- (void)flipVertically
{
	[self beginUndoGrouping];
    for (PXLayer *current in layers)
    {
        [self flipLayerVertically:current];
    }
	[self endUndoGrouping:NSLocalizedString(@"Flip Canvas Vertically", @"Flip Canvas Vertically")];
}

- (void)reduceColorsTo:(NSUInteger)colors withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor
{
	[PXCanvas reduceColorsInCanvases:[NSArray arrayWithObject:self] 
						toColorCount:colors
					withTransparency:transparency 
						  matteColor:matteColor];
}

+(void)reduceColorsInCanvases:(NSArray*)canvases 
				 toColorCount:(NSUInteger)colors
			 withTransparency:(BOOL)transparency 
				   matteColor:(NSColor *)matteColor
{
	PXCanvas *first = [canvases objectAtIndex:0];
	unsigned char *red = calloc([first size].width * [first size].height * [canvases count], sizeof(unsigned char));
	unsigned char *green = calloc([first size].width * [first size].height * [canvases count], sizeof(unsigned char));
	unsigned char *blue = calloc([first size].width * [first size].height * [canvases count], sizeof(unsigned char));
	int i;
	int quantizedPixels = 0;
	
	for (id current in canvases)
	{
		if(!NSEqualSizes([first size], [current size]))
		{
			[NSException raise:@"Reduction Exception" format:@"Canvas sizes not equal!"];
		}
		NSImage *image = [[[current displayImage] copy] autorelease];
		id bitmapRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
		unsigned char *bitmapData = [bitmapRep bitmapData];
		
		if ([bitmapRep samplesPerPixel] == 3)
		{
			for (i = 0; i < [image size].width * [image size].height; i++)
			{
				int base = (i * 3);
				red[quantizedPixels + i] = bitmapData[base + 0];
				green[quantizedPixels + i] = bitmapData[base + 1];
				blue[quantizedPixels + i] = bitmapData[base + 2];
			}
			quantizedPixels += [image size].width * [image size].height;
		}
		else
		{
			for (i = 0; i < [image size].width * [image size].height; i++)
			{
				int base = (i * 4);
				if (bitmapData[base + 3] == 0 && transparency) { continue; }
				if (bitmapData[base + 3] < 255 && matteColor)
				{
					NSColor *sourceColor = [NSColor colorWithDeviceRed:bitmapData[base + 0] / 255.0f green:bitmapData[base + 1] / 255.0f blue:bitmapData[base + 2] / 255.0f alpha:1];
					NSColor *resultColor = [matteColor blendedColorWithFraction:(bitmapData[base + 3] / 255.0f) ofColor:sourceColor];
					red[quantizedPixels] = [resultColor redComponent] * 255;
					green[quantizedPixels] = [resultColor greenComponent] * 255;
					blue[quantizedPixels] = [resultColor blueComponent] * 255;
				}
				else
				{
					red[quantizedPixels] = bitmapData[base + 0];
					green[quantizedPixels] = bitmapData[base + 1];
					blue[quantizedPixels] = bitmapData[base + 2];
				}
				quantizedPixels++;
			}
		}
	}
	
	GifColorType *map = malloc(sizeof(GifColorType) * 256);
	NSUInteger size = colors - (transparency ? 1 : 0);
	unsigned char *output = malloc(sizeof(unsigned char*) * [first size].width * [first size].height * [canvases count]);
	if (quantizedPixels)
		QuantizeBuffer(quantizedPixels, (int *)&size, red, green, blue, output, map);
	//NSLog(@"Quantized to %d colors", size);

	PXPalette *palette = PXPalette_init(PXPalette_alloc());
	for (i = 0; i < size; i++)
	{
		PXPalette_addColor(palette, [NSColor colorWithDeviceRed:map[i].Red / 255.0f green:map[i].Green / 255.0f blue:map[i].Blue / 255.0f alpha:1]);
	}
	if (transparency)
		PXPalette_addColorWithoutDuplicating(palette, [[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]);
	
	for (id current in canvases)
	{
		for (id currentLayer in [current layers])
		{
			[currentLayer adaptToPalette:palette withTransparency:transparency matteColor:matteColor];
		}
    [current refreshWholePalette];
		[current changed];
	}
	free(red); free(green); free(blue); free(output); free(map);
}

- (void)clearUndoBuffers
{
	[drawnPoints release];
	drawnPoints = [[NSMutableArray alloc] initWithCapacity:200];
	oldColors = [[NSMutableArray alloc] initWithCapacity:200];
	newColors = [[NSMutableArray alloc] initWithCapacity:200];
}

- (void)registerForUndo
{
	[self registerForUndoWithDrawnPoints:drawnPoints
							   oldColors:oldColors 
							   newColors:newColors 
								 inLayer:[self activeLayer] 
								 undoing:NO];
}

- (void)registerForUndoWithDrawnPoints:(NSArray *)pts
							 oldColors:(NSArray *)oldC
							 newColors:(NSArray *)newC
							   inLayer:(PXLayer *)layer
							   undoing:(BOOL)undoing
{
	[[[self undoManager] prepareWithInvocationTarget:self] registerForUndoWithDrawnPoints:pts
																				oldColors:newC
																				newColors:oldC
																				  inLayer:layer
																				  undoing:YES];
	if(undoing)
	{
		[self replaceColorsAtPoints:pts withColors:newC inLayer:layer];
	}
}

- (void)replaceColorsAtPoints:(NSArray *)pts withColors:(NSArray *)colors inLayer:layer
{
	NSRect changedRect = NSZeroRect;
	NSPoint pt;
	if([pts count] > 0) {
		pt = [[pts objectAtIndex:0] pointValue];
		changedRect = NSMakeRect(pt.x, pt.y, 1, 1);
	}
	NSUInteger i;
	for (i = [pts count] - 1; i >= 0; i--) 
	{
		pt = [[pts objectAtIndex:i] pointValue];
		NSColor *c = [colors objectAtIndex:i];
		if([c isEqual:[NSNull null]]) {
			c = [[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		}
		[self setColor:c atPoint:pt onLayer:layer];
		changedRect = NSUnionRect(changedRect, NSMakeRect(pt.x, pt.y, 1, 1));
	}
	[self changedInRect:changedRect];
}

- (void)bufferUndoAtPoint:(NSPoint)pt fromColor:(NSColor *)oldColor toColor:(NSColor *)newColor
{
	[drawnPoints addObject:[NSValue valueWithPoint:pt]];
	[oldColors addObject:((oldColor == nil) ? (id)[NSNull null] : (id)oldColor)];
	[newColors addObject:(newColor == nil) ? (id)[NSNull null] : (id)newColor];
}

- (void)applyImage:(NSImage *)img toLayer:(PXLayer *)layer
{
  [layer applyImage:img];
  [self refreshWholePalette];
}
@end
