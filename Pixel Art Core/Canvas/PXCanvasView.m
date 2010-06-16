//  PXCanvasView.m
//  Pixen

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

#import "PXCanvasView.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXBackgrounds.h"
#import "PXBackgroundController.h"
#import "PXToolPaletteController.h"
#import "PXToolSwitcher.h"
#import "PXTool.h"
#import "PXEyedropperTool.h"
#import "PXInfoPanelController.h"
#import "PXGrid.h"
#import "PXCrosshair.h"
#import "PXCanvasDocument.h"

//Taken from a man calling himself "BROCK BRANDENBERG" 
//who is here to save the day.

#import "SBCenteringClipView.h"

#import "PXApplication.h"
#import "TabletEvents.h"
#import "Wacom.h"
#import "TAEHelpers.h"

#import "PXCanvasController.h"

@interface PXTool(DrawRectOnTopInViewWarningSilencer)
- (void)drawRectOnTop:(NSRect)rect inView:(PXCanvasView *)view;
@end

void PXDebugRect(NSRect r, float alpha)
{
	[[NSColor colorWithDeviceRed:(rand() % 255) / 255.0 green:(rand() % 255) / 255.0 blue:(rand() % 255) / 255.0 alpha:alpha] set];
	NSRectFillUsingOperation(r, NSCompositeSourceOver);
}

@implementation PXCanvasView

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
	return acceptsFirstMouse;
}

- (void)setAcceptsFirstMouse:(BOOL)accepts
{
	acceptsFirstMouse = accepts;
}

- (void)rightMouseDown:(NSEvent*) event
{
	[delegate rightMouseDown:event];
}

- (void)setDelegate:(id) aDelegate
{
	delegate = aDelegate;
}

- (void)setShouldDrawToolBeziers:(BOOL)newShouldDraw
{
	drawsToolBeziers = newShouldDraw;
}

-(id) initWithFrame:(NSRect)rect
{	
	if ( ! (self = [super initWithFrame:rect] ) ) 
		return nil;
	
	drawsWrappedCanvases = YES;
	acceptsFirstMouse = YES;
	zoomPercentage = 100;
	shouldDrawGrid = YES;
	shouldDrawMainBackground = YES;
	trackingRect = -1;
	
	crosshair = [[PXCrosshair alloc] init];
	drawsSelectionMarquee = YES;
	drawsToolBeziers = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(selectionMaskChanged:)
												 name:PXSelectionMaskChangedNotificationName
											   object:canvas];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(selectionStatusChanged:)
												 name:PXCanvasSelectionStatusChangedNotificationName
											   object:canvas];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleProximity:)
												 name:kProximityNotification
											   object:nil];
	
	marqueePatternOffset = NSZeroPoint;
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[cachedMarqueePath release];
	[marqueeAnimationTimer invalidate];
	[marqueeAnimationTimer release];
	[crosshair release];
	[antsPattern release];
	[super dealloc];
}

- (void)setCrosshair:aCrosshair
{
	[crosshair release];
	crosshair = [aCrosshair retain];
}

- (PXCrosshair *)crosshair
{
	return crosshair;
}

- (void)selectionMaskChanged:(NSNotification *)notification
{
	[cachedMarqueePath release];
	cachedMarqueePath = nil;
}

- (void)setNeedsDisplayInCanvasRect:(NSRect)rect
{	
	if ([canvas wraps])
	{
		int xTiles = 0;
		int yTiles = 0;
		NSRect r = [self convertFromViewToCanvasRect:[self visibleRect]];
		while(((xTiles * [canvas size].width)) < NSWidth(r)) { xTiles++; }
		if(xTiles % 2 == 0) { xTiles += 1; }
		while(((yTiles * [canvas size].height)) < NSHeight(r)) { yTiles++; }
		if(yTiles % 2 == 0) { yTiles += 1; }
		float i, j;
		for (i = 0; i < xTiles; i++)
		{
			for (j = 0; j < yTiles; j++)
			{
				float xLoc = i * [canvas size].width - ((xTiles * [canvas size].width - NSWidth(r)) / 2.0);
				float yLoc = j * [canvas size].height - ((yTiles * [canvas size].height - NSHeight(r)) / 2.0);
				[self setNeedsDisplayInRect:[self convertFromCanvasToViewRect:NSInsetRect(NSMakeRect(xLoc + NSMinX(rect), yLoc + NSMinY(rect), NSWidth(rect), NSHeight(rect)), -1, -1)]];
			}
		}	
	}
	else
	{
		NSRect buffedRect = [self convertFromCanvasToViewRect:NSInsetRect(rect, -1, -1)];
		[self setNeedsDisplayInRect:buffedRect];
	}
}

- (void)setCanvas:(PXCanvas *) aCanvas
{
	canvas = aCanvas;
	[self sizeToCanvas];
	[self selectionMaskChanged:nil];
}

- (NSPoint)convertFromCanvasToViewPoint:(NSPoint)point
{
	id transformation = [self setupTransform];
	return [transformation transformPoint:point];
}

- (NSRect)convertFromCanvasToViewRect:(NSRect)rect
{
	id transformation = [self setupTransform];
	NSPoint origin = [transformation transformPoint:rect.origin];
	NSSize size = [transformation transformSize:rect.size];
	return NSMakeRect(origin.x, origin.y, size.width, size.height);
}

- (NSPoint)convertFromViewToPartialCanvasPoint:(NSPoint)point
{
	id transformation = [self setupTransform];
	[transformation invert];
	return [transformation transformPoint:point];
}

- (NSPoint)convertFromViewToCanvasPoint:(NSPoint)point
{
	if (NSEqualSizes([canvas size], NSZeroSize)) { return point; }
	NSPoint floored = [self convertFromViewToPartialCanvasPoint:point];	
	floored.x = floorf(floored.x);
	floored.y = floorf(floored.y);
	
	return floored;
}

- (NSPoint)convertFromWindowToCanvasPoint:(NSPoint)location
{
	NSPoint point = [self convertFromViewToCanvasPoint:[self convertPoint:location fromView:nil]];
	//modify the point's origin
	NSRect canvasRect = [self convertFromViewToCanvasRect:[self bounds]];
	float xCenter = [canvas wraps] ? (NSWidth(canvasRect) - [canvas size].width) / 2.0 : 0;
	float yCenter = [canvas wraps] ? (NSHeight(canvasRect) - [canvas size].height) / 2.0 : 0;
	point.x -= xCenter;
	point.y -= yCenter;
	point.x = floorf(point.x);
	point.y = floorf(point.y);
	return point;
}

- (NSRect)convertFromViewToCanvasRect:(NSRect)viewRect
{
	id transformation = [self setupTransform];
	[transformation invert];
	NSRect rect;
	rect.origin = [self convertFromViewToPartialCanvasPoint:viewRect.origin];
	rect.size = [transformation transformSize:viewRect.size];
	return rect;
}

- (void)centerOn:(NSPoint)aPoint
{
	if(![[self superview] isKindOfClass:[NSClipView class]]) { return; }
	NSRect clipFrame = [[self superview] frame];
	[self scrollPoint:NSMakePoint(aPoint.x - NSWidth(clipFrame)/2.0, aPoint.y - NSHeight(clipFrame)/2.0)];
	centeredPoint = [self convertFromViewToCanvasPoint:aPoint];
}

- (void)sizeToCanvas
{
	
	if(NSEqualSizes([canvas size], NSZeroSize))
		return;
	
	
	transform = [self setupTransform];
	NSSize transformedSize;
	
	// if we're tiling, make ourselves fit to the clipview
	if ([canvas wraps] && drawsWrappedCanvases)
	{
		transformedSize = [transform transformSize:[canvas size]];
		transformedSize.width = MAX(transformedSize.width, NSWidth([[self superview] frame]));
		transformedSize.height = MAX(transformedSize.height, NSHeight([[self superview] frame])); 
	}
	else
	{
		transformedSize = NSMakeSize([transform transformSize:[canvas size]].width, [transform transformSize:[canvas size]].height);
	}
	[self setFrameSize:transformedSize];
	
	[self centerOn:[self convertFromCanvasToViewPoint:centeredPoint]];
	[[self window] invalidateCursorRectsForView:self];
	[self setNeedsDisplay:YES];
}

- (float)zoomPercentage
{
	return zoomPercentage;
}

- (void)setZoomPercentage:(float)percent
{
	NSRect rect = [self visibleRect];
	centeredPoint = [self convertFromViewToCanvasPoint:NSMakePoint(NSMinX(rect) + NSWidth(rect)/2, NSMinY(rect) + NSHeight(rect)/2)];
	zoomPercentage = percent;
	[cachedMarqueePath release];
	cachedMarqueePath = nil;
	[self sizeToCanvas];
	[self updateInfoPanelWithMousePosition:[self convertFromWindowToCanvasPoint:[[self window] mouseLocationOutsideOfEventStream]] dragging:NO];
}

- (BOOL)shouldDrawMainBackground
{
	return shouldDrawMainBackground;
}

- (void)setShouldDrawMainBackground:(BOOL)newShouldDrawBG
{
	if([self mainBackground] != [self alternateBackground] && [self alternateBackground] != nil)
	{
		shouldDrawMainBackground = newShouldDrawBG;
		[self setNeedsDisplay:YES];
	}
}

- (void)setShouldDrawGrid:(BOOL)newShouldDraw;
{
	shouldDrawGrid = newShouldDraw;
}

- (PXBackground *)mainBackground
{
	return [canvas mainBackground];
}

- (PXBackground *)alternateBackground
{
	return [canvas alternateBackground];
}

- grid
{
	return [canvas grid];
}

- (void)selectionStatusChanged:(NSNotification *)notification
{
	if((marqueeAnimationTimer != nil) && [marqueeAnimationTimer isValid])
	{
		[marqueeAnimationTimer invalidate];
		[marqueeAnimationTimer release];
		marqueeAnimationTimer = nil;
	}
	if ([canvas hasSelection])
	{
		marqueeAnimationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.10f
																  target:self
																selector:@selector(animateMarquee:)
																userInfo:nil
																 repeats:YES] retain];
	}
}

- (void)drawBezierFromPoint:(NSPoint)fromPoint 
					toPoint:(NSPoint)toPoint
{
	fromPoint.y = [canvas size].height - fromPoint.y;
	toPoint.y = [canvas size].height - toPoint.y;
	
	fromPoint = [transform transformPoint:fromPoint];
	toPoint = [transform transformPoint:toPoint];
	
	fromPoint.x = MIN(fromPoint.x, NSWidth([self frame]) - 1);
	toPoint.x = MIN(toPoint.x, NSWidth([self frame]) - 1);
	fromPoint.y = MIN(fromPoint.y, NSHeight([self frame]) - 1);
	toPoint.y = MIN(toPoint.y, NSHeight([self frame]) - 1);
	
	[cachedMarqueePath moveToPoint:fromPoint];
	[cachedMarqueePath lineToPoint:toPoint];
}

- (NSBezierPath *)cachedSelectionMarqueePath
{
	if (cachedMarqueePath == nil)
	{
		unsigned int i, j;
		unsigned int width = [canvas size].width;
		unsigned int height = [canvas size].height;
		
		NSRect rect = [canvas selectedRect];
		rect.origin.y = height - NSMaxY(rect);
		PXSelectionMask mask = [canvas selectionMask];
		
		[[NSColor blackColor] set];
		cachedMarqueePath = [[NSBezierPath alloc] init];
		[cachedMarqueePath setLineWidth:1.0f];
		// now we step through each pixel in the rect.
		// for each one, if it's not selected, keep going.
		// if it is, check each side. if the adjacent pixel on a given
		// side is not selected, draw a line on that side, signifying the
		// edge of this particular area of selection.
		for (i = MAX(NSMinX(rect), 0); i < MIN(NSMaxX(rect), width); i++)
		{
			for (j = MAX(NSMinY(rect), 0); j < MIN(NSMaxY(rect), height); j++)
			{
				if(!mask[i + (j * width)]) { continue; }
				if(![canvas wraps])
				{
					if(i == 0)
					{
						[self drawBezierFromPoint:NSMakePoint(i, j) toPoint:NSMakePoint(i, j + 1)];
					}
					else if((i + 1) == (width))
					{
						[self drawBezierFromPoint:NSMakePoint(i+1, j) toPoint:NSMakePoint(i+1, j + 1)];
					}
				}
				if ((((i - 1) + (j * width)) < (width * height)))
				{
					if (!mask[(i - 1) + (j * width)]) 
					{
						[self drawBezierFromPoint:NSMakePoint(i, j) toPoint:NSMakePoint(i, j + 1)];
					}
				}
				else if(![canvas wraps])
				{	
					[self drawBezierFromPoint:NSMakePoint(i, j) toPoint:NSMakePoint(i, j + 1)];
				}
				
				if ((((i + 1) + (j * width)) < (width * height)))
				{
					if (!mask[(i + 1) + (j * width)]) 
					{
						[self drawBezierFromPoint:NSMakePoint(i + 1, j) toPoint:NSMakePoint(i + 1, j + 1)];
					}
				}
				else if(![canvas wraps])
				{	
					[self drawBezierFromPoint:NSMakePoint(i + 1, j) toPoint:NSMakePoint(i + 1, j + 1)];
				}
				
				if (((i+ ((j - 1) * width)) < (width * height)))
				{
					if (!mask[i + ((j - 1) * width)]) 
					{
						[self drawBezierFromPoint:NSMakePoint(i, j) toPoint:NSMakePoint(i + 1, j)];
					}
				}
				else if(![canvas wraps])
				{	
					[self drawBezierFromPoint:NSMakePoint(i, j) toPoint:NSMakePoint(i + 1, j)];
				}
				
				if (((i + ((j + 1) * width)) < (width * height)))
				{
					if (!mask[i + ((j + 1) * width)]) 
					{
						[self drawBezierFromPoint:NSMakePoint(i, j + 1) toPoint:NSMakePoint(i + 1, j + 1)];
					}
				}
				else if(![canvas wraps])
				{	
					[self drawBezierFromPoint:NSMakePoint(i, j + 1) toPoint:NSMakePoint(i + 1, j + 1)];
				}
			}
		}
	}
	return cachedMarqueePath;
}

- (void)animateMarquee:(NSTimer *)timer
{
	if (![canvas hasSelection] || !drawsSelectionMarquee) { return; }
	marqueePatternOffset.x += 1;
	if (marqueePatternOffset.x >= 8)
		marqueePatternOffset = NSZeroPoint;
	NSRect selectedRect = [canvas selectedRect];
	NSPoint selectionOrigin = [canvas selectionOrigin];
	selectedRect.origin.x += selectionOrigin.x;
	selectedRect.origin.y += selectionOrigin.y;
	[self setNeedsDisplayInCanvasRect:NSInsetRect(selectedRect, -2, -2)];
}

- (void)drawSelectionMarqueeWithRect:(NSRect)aRect offset:(NSPoint)off
{
	NSPoint origin = [canvas selectionOrigin];
	origin.x += off.x;
	origin.y += off.y;
	NSAffineTransform * translationTransform = [NSAffineTransform transform];
	[translationTransform translateXBy:[transform transformPoint:origin].x yBy:[transform transformPoint:origin].y];
	
	[translationTransform concat];
	
	NSBezierPath *path = [self cachedSelectionMarqueePath];
	
	if (antsPattern == nil)
		antsPattern = [[NSColor colorWithPatternImage:[NSImage imageNamed:@"ants"]] retain];
	
	[antsPattern set];
	[[NSGraphicsContext currentContext] setPatternPhase:marqueePatternOffset];
	[path stroke];
	
	[translationTransform invert];
	[translationTransform concat];
}

- (NSAffineTransform *)transform
{
	return transform;
}

- (void)drawRect:(NSRect)rect
{
	if(canvas == nil || NSEqualSizes([canvas size], NSZeroSize)) { return; }

	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	transform = [self setupTransform];
	
	NSRect canvasRect = [self convertFromViewToCanvasRect:[self bounds]];
	
	float xCenter = [canvas wraps] ? (NSWidth(canvasRect) - [canvas size].width) / 2.0 : 0;
	float yCenter = [canvas wraps] ? (NSHeight(canvasRect) - [canvas size].height) / 2.0 : 0;
	int xTiles = 0;
	int yTiles = 0;
	BOOL oldCanvasWraps = [canvas wraps];
	[canvas setWraps:[canvas wraps] && drawsWrappedCanvases suppressRedraw:YES];
	if([canvas wraps])
	{
		while(((xTiles * [canvas size].width)) < NSWidth(canvasRect)) { xTiles++; }
		if(xTiles % 2 == 0) { xTiles += 1; }
		while(((yTiles * [canvas size].height)) < NSHeight(canvasRect)) { yTiles++; }
		if(yTiles % 2 == 0) { yTiles += 1; }
	}
	
	NSAffineTransform *bgTransform = [self setupTransform];
	[bgTransform translateXBy:xCenter yBy:yCenter];
	[bgTransform concat];
	if(shouldDrawMainBackground || [self alternateBackground] == nil) 
	{ 
		[[self mainBackground] drawRect:rect withinRect:[self visibleRect] withTransform:bgTransform onCanvas:canvas]; 
	}
	else 
	{ 
		[[self alternateBackground] drawRect:rect withinRect:[self visibleRect] withTransform:bgTransform onCanvas:canvas]; 
	}
	[bgTransform invert];
	[bgTransform concat];
	
	
	// High coupling alert.
	PXToolPaletteController *paletteController = [PXToolPaletteController sharedToolPaletteController];
	PXTool *currentTool = [paletteController currentTool];
	if(erasing)
	{
		currentTool = [[paletteController leftSwitcher] toolWithTag:PXEraserToolTag];
	}
	if(!currentTool)
	{
		currentTool = [paletteController leftTool];
	}
	if (drawsToolBeziers && [currentTool shouldUseBezierDrawing] && [[self window] isMainWindow]) {
		[canvas meldBezier:([canvas wraps] ? [currentTool wrappedPath] : [currentTool path]) ofColor:[[currentTool colorForCanvas:canvas] colorWithAlphaComponent:([[canvas activeLayer] opacity] / 100.0f) * [[currentTool colorForCanvas:canvas] alphaComponent]]];
	}
	
	float factor = (zoomPercentage / 100.0);
	if ([canvas wraps])
	{
		NSRect destination = NSMakeRect(0, 0, [canvas size].width * factor, [canvas size].height * factor);
		NSRect source = NSMakeRect(0, 0, [canvas size].width, [canvas size].height);
		float i, j;
		for (i = 0; i < xTiles; i++)
		{
			for (j = 0; j < yTiles; j++)
			{
				float xLoc = i * [canvas size].width - ((xTiles * [canvas size].width - NSWidth(canvasRect)) / 2.0);
				float yLoc = j * [canvas size].height - ((yTiles * [canvas size].height - NSHeight(canvasRect)) / 2.0);
				if(NSIntersectsRect(rect, NSMakeRect(xLoc*factor, yLoc*factor, [canvas size].width*factor, [canvas size].height*factor)))
				{
					//					CGContextScaleCTM([[NSGraphicsContext currentContext] graphicsPort], factor, factor);
					CGContextTranslateCTM([[NSGraphicsContext currentContext] graphicsPort], xLoc*factor, yLoc*factor);
					[canvas drawInRect:destination fromRect:source];
					CGContextTranslateCTM([[NSGraphicsContext currentContext] graphicsPort], -xLoc*factor, -yLoc*factor);
					//					CGContextScaleCTM([[NSGraphicsContext currentContext] graphicsPort], 1.0/factor, 1.0/factor);
				}
			}
		}
	}
	else
	{
		//			CGContextScaleCTM([[NSGraphicsContext currentContext] graphicsPort], factor, factor);
		[canvas drawInRect:rect fromRect:[self convertFromViewToCanvasRect:rect]];      
		//			CGContextScaleCTM([[NSGraphicsContext currentContext] graphicsPort], 1.0/factor, 1.0/factor);
	}
	[canvas unmeldBezier];
	[transform concat];
	
	
	if ([canvas wraps])
	{
		float i, j;
		for (i = 0; i < xTiles; i++)
		{
			for (j = 0; j < yTiles; j++)
			{
				float xLoc = i * [canvas size].width - ((xTiles * [canvas size].width - NSWidth(canvasRect)) / 2.0);
				float yLoc = j * [canvas size].height - ((yTiles * [canvas size].height - NSHeight(canvasRect)) / 2.0);
				NSAffineTransform *toolTransform = [NSAffineTransform transform];
				[toolTransform translateXBy:xLoc yBy:yLoc];
				[toolTransform concat];
				if (drawsToolBeziers && [currentTool respondsToSelector:@selector(drawRectOnTop:inView:)]) {
					[currentTool drawRectOnTop:rect inView:self];
				}
				[toolTransform invert];
				[toolTransform concat];
			}
		}
	}
	else
	{
		if (drawsToolBeziers && [currentTool respondsToSelector:@selector(drawRectOnTop:inView:)]) {
			[currentTool drawRectOnTop:rect inView:self];
		}
	}
	
	NSRect gridRect = canvasRect;
	if(shouldDrawGrid) 
	{
		NSAffineTransform *gridTransform = [NSAffineTransform transform];
		//		[gridTransform translateXBy:-xCenter yBy:-yCenter];
		[gridTransform concat];
		//		gridRect.size.width += xCenter;
		//		gridRect.size.height += yCenter;
		//		gridRect.size.width = ceilf(NSWidth(gridRect));
		//		gridRect.size.height = ceilf(NSHeight(gridRect));
		if ((zoomPercentage / 100.0f) * [[canvas grid] unitSize].width >= 4 && (zoomPercentage / 100.0f) * [[canvas grid] unitSize].height >= 4)
		{
			[[canvas grid] drawRect:gridRect];
		}
		[gridTransform invert];
		[gridTransform concat];			
	}
	if ([[self window] isMainWindow])
	{	
		[crosshair drawRect:gridRect withTool:currentTool tileOffset:NSMakePoint(xCenter, yCenter)];
	}
	[transform invert];
	[transform concat];
	[transform invert];
	
	// the selection unfortunately needs to be drawn outside the transform
	// so that the pattern renders correctly. this creates a lot of ugly
	// code. sorry.
	if ([canvas hasSelection] && drawsSelectionMarquee)
	{
		if ([canvas wraps])
		{
			float i, j;
			for (i = 0; i < xTiles; i++)
			{
				for (j = 0; j < yTiles; j++)
				{
					float xLoc = i * [canvas size].width - ((xTiles * [canvas size].width - NSWidth(canvasRect)) / 2.0);
					float yLoc = j * [canvas size].height - ((yTiles * [canvas size].height - NSHeight(canvasRect)) / 2.0);
					[self drawSelectionMarqueeWithRect:rect offset:NSMakePoint(xLoc, yLoc)];
				}
			}
		}
		else
		{
			[self drawSelectionMarqueeWithRect:rect offset:NSMakePoint(xCenter, yCenter)];
		}
	}
	[canvas setWraps:oldCanvasWraps suppressRedraw:YES];
}

- (void)setDrawsWrappedCanvases:(BOOL)draws
{
	drawsWrappedCanvases = draws;
}

- (NSAffineTransform *)setupScaleTransform
{
	id transformation = [NSAffineTransform transform];
	
	[transformation scaleBy:zoomPercentage/100.0f];
	return transformation;	
}

- (NSAffineTransform *)setupTransform
{
	return [self setupScaleTransform];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)isOpaque
{
	return YES;
}

- (void)setShouldDrawSelectionMarquee:(BOOL)drawsMarquee
{
	drawsSelectionMarquee = drawsMarquee;
}

- (void)panByX:(float)x y:(float)y
{
	[self centerOn:[self convertFromCanvasToViewPoint:NSMakePoint(centeredPoint.x-x, centeredPoint.y+y)]];
}

- (void)scrollUpBy:(int)amount
{
	[self centerOn:[self convertFromCanvasToViewPoint:NSMakePoint(centeredPoint.x, centeredPoint.y+amount)]];
}

- (void)scrollRightBy:(int)amount
{
	[self centerOn:[self convertFromCanvasToViewPoint:NSMakePoint(centeredPoint.x+amount, centeredPoint.y)]];
}

- (void)scrollDownBy:(int)amount
{
	[self centerOn:[self convertFromCanvasToViewPoint:NSMakePoint(centeredPoint.x, centeredPoint.y-amount)]];
}

- (void)scrollLeftBy:(int)amount
{
	[self centerOn:[self convertFromCanvasToViewPoint:NSMakePoint(centeredPoint.x-amount, centeredPoint.y)]];   
}

- (void)otherMouseDragged:(NSEvent *)event
{
	[delegate otherMouseDragged:event];
}

- (void)resetCursorRects
{
	if(trackingRect != -1) { [self removeTrackingRect:trackingRect]; }
	BOOL inside = NSPointInRect([[self window] mouseLocationOutsideOfEventStream], [self convertRect:[self bounds] toView:nil]);
	trackingRect = [self addTrackingRect:[self visibleRect] owner:self userData:NULL assumeInside:inside];
	[self setShouldDrawMainBackground:inside];
}

- (void)mouseEntered:event
{
	[self setShouldDrawMainBackground:YES];
}

- (void)mouseExited:event
{
	[self setShouldDrawMainBackground:NO];
}

- (void)updateCrosshairs:(NSPoint)newLocation
{
	if (![crosshair shouldDraw]) 
	{ 
		return; 
	}
	
	[crosshair setCursorPosition:newLocation];
}

- (void)updateInfoPanelWithMousePosition:(NSPoint)point dragging:(BOOL)dragging
{
	if (![[[PXInfoPanelController sharedInfoPanelController] infoPanel] isVisible]) { return; }
	
	NSPoint cursorPoint = point;
	cursorPoint.y = [canvas size].height - cursorPoint.y - 1;
	if (!dragging) {
		[[PXInfoPanelController sharedInfoPanelController] setDraggingOrigin:cursorPoint];
	}
	[[PXInfoPanelController sharedInfoPanelController] setCursorPosition:cursorPoint];
	NSColor *currentColor = [[[[PXToolPaletteController sharedToolPaletteController] leftSwitcher] toolWithTag:PXEyedropperToolTag] compositeColorAtPoint:point fromCanvas:canvas];
	[[PXInfoPanelController sharedInfoPanelController] setColorInfo:currentColor];
}

- (void)scrollWheel:(NSEvent *)event
{
	[delegate scrollWheel:event];
}

- (void) handleProximity:(NSNotification *)proxNotice
{
	NSDictionary *proxDict = [proxNotice userInfo];
	UInt8 enterProximity;
	UInt8 pointerType;
	UInt16 pointerID;
	
	[[proxDict objectForKey:kEnterProximity] getValue:&enterProximity];
	[[proxDict objectForKey:kPointerID] getValue:&pointerID];
	erasing = NO;
	// Only interested in Enter Proximity for 1st concurrent device
	if(enterProximity != 0)
	{
		[[proxDict objectForKey:kPointerType] getValue:&pointerType];
		erasing = (pointerType == EEraser);
	}
}

- (void)mouseDown:(NSEvent *) event
{
	if(erasing)
	{
		[delegate eraserDown:event];
	}
	else
	{
		[delegate mouseDown:event];
	}
	[self updateInfoPanelWithMousePosition:[self convertFromWindowToCanvasPoint:[event locationInWindow]] dragging:NO];	
}

- (void)updateMousePosition:(NSPoint)locationInWindow dragging:(BOOL)dragging
{
	NSPoint coords = [self convertFromWindowToCanvasPoint:locationInWindow];
	if (!NSEqualPoints(coords, lastMousePosition)) {
		NSPoint oldCursorLoc = [crosshair cursorPosition];
		[self updateCrosshairs:coords];
		[self updateInfoPanelWithMousePosition:coords dragging:dragging];
		
		if([crosshair shouldDraw])
		{
			float x = NSMinX([self visibleRect]);
			float y = NSMinY([self visibleRect]);
			float w = NSWidth([self visibleRect]);
			float h = NSHeight([self visibleRect]);
			float unitSize = zoomPercentage / 100.0;
			NSPoint oldLoc = [self convertFromCanvasToViewPoint:oldCursorLoc];
			NSPoint newLoc = [self convertPoint:locationInWindow fromView:nil];
			
			NSRect oldHorizontal = NSMakeRect(x, oldLoc.y-unitSize*2, w, unitSize*4);
			NSRect oldVertical = NSMakeRect(oldLoc.x-unitSize*2, y, unitSize*4, h);
			NSRect newHorizontal = NSMakeRect(x, newLoc.y-unitSize*2, w, unitSize*4);
			NSRect newVertical = NSMakeRect(newLoc.x-unitSize*2, y, unitSize*4, h);
			[self setNeedsDisplayInRect:oldHorizontal];
			[self setNeedsDisplayInRect:newHorizontal];
			[self setNeedsDisplayInRect:oldVertical];
			[self setNeedsDisplayInRect:newVertical];
		}
		lastMousePosition = coords;
	}
}

- (void)mouseUp:(NSEvent*) event
{
	NSPoint oldMousePosition = lastMousePosition;
	[self updateMousePosition:[event locationInWindow] dragging:NO];
	if(erasing)
	{
		[delegate eraserUp:event];
	}
	else
	{	
		[delegate mouseUp:event];
	}
	
	// If we haven't moved the mouse, updateMousePosition won't update the crosshair,
	// but it should because the crosshair's center rect may have changed.
	NSPoint coords = [self convertFromWindowToCanvasPoint:[event locationInWindow]];
	if (NSEqualPoints(coords, oldMousePosition))
	{
		[self updateCrosshairs:coords];
	}
}

- (void)mouseMoved:(NSEvent *)event
{
	[self updateMousePosition:[event locationInWindow] dragging:NO];
	if(erasing)
	{	
		[delegate eraserMoved:event];
	}
	else
	{
		[delegate mouseMoved:event];
	}
//	NSPoint loc = [self convertPoint:[event locationInWindow] fromView:nil];
//	[self setNeedsDisplayInRect:NSInsetRect(NSMakeRect(loc.x, loc.y, 0, 0), -32, -32)];
}

- (void)mouseDragged:(NSEvent *)event
{
	if(erasing)
	{	
		[delegate eraserDragged:event];
	}
	else
	{
		[delegate mouseDragged:event];
	}	
	[self updateMousePosition:[event locationInWindow] dragging:YES];
}

- (void)rightMouseDragged:(NSEvent *)event
{
	[self updateMousePosition:[event locationInWindow] dragging:YES];
	[delegate rightMouseDragged:event];
}

@end
