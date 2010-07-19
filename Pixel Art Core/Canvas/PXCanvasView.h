//  PXCanvasView.h
//  Pixen
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
//  Created by Joe Osborn on Sat Sep 13 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import <AppKit/AppKit.h>
@class PXCanvas, PXCrosshair, PXBackground;

@interface PXCanvasView : NSView 
{
	PXCanvas *canvas;

	PXCrosshair *crosshair;
	NSAffineTransform *transform;
	
	NSBezierPath *cachedMarqueePath;
	NSColor *antsPattern;
	NSTimer *marqueeAnimationTimer;
	NSPoint marqueePatternOffset;
	BOOL drawsSelectionMarquee;
	
	float zoomPercentage;
	NSPoint centeredPoint;
	BOOL shouldDrawMainBackground;
	BOOL shouldDrawGrid;
	
	BOOL drawsWrappedCanvases;
	BOOL drawsToolBeziers;
	BOOL acceptsFirstMouse;
	
	NSTrackingRectTag trackingRect;
	
	NSPoint lastMousePosition;
	
	BOOL erasing;
	
	id delegate;
}
- (void)setDelegate:(id) aDelegate;
- (void)setCrosshair:aCrosshair;
- (PXCrosshair *)crosshair;
- (id) initWithFrame:(NSRect)rect;

- (float)zoomPercentage;

- (void)setZoomPercentage:(float)percent;
- (void)setCanvas:(PXCanvas *)aCanvas;

- (NSPoint)convertFromCanvasToViewPoint:(NSPoint)point;
- (NSRect)convertFromCanvasToViewRect:(NSRect)rect;
- (NSPoint)convertFromViewToCanvasPoint:(NSPoint)point;
- (NSPoint)convertFromViewToPartialCanvasPoint:(NSPoint)point;
- (NSPoint)convertFromWindowToCanvasPoint:(NSPoint)location;

- (void)updateMousePosition:(NSPoint)locationInWindow dragging:(BOOL)dragging;

- (void)setDrawsWrappedCanvases:(BOOL)drawsWrappedCanvases;
- (void)setShouldDrawSelectionMarquee:(BOOL)drawsSelectionMarquee;
- (void)setNeedsDisplayInCanvasRect:(NSRect)rect;
- (void)sizeToCanvas;
- (void)centerOn:(NSPoint)aPoint;
- (NSAffineTransform *)setupTransform;
- (NSAffineTransform *)setupScaleTransform;
- (NSAffineTransform *)transform;

- (void)panByX:(float)x y:(float)y;

- (void)drawSelectionMarqueeWithRect:(NSRect)rect offset:(NSPoint)off;
- (void)scrollUpBy:(int)amount;
- (void)scrollRightBy:(int)amount;
- (void)scrollDownBy:(int)amount;
- (void)scrollLeftBy:(int)amount;

- (void)setShouldDrawMainBackground:(BOOL)newShouldDraw;
- (void)setShouldDrawGrid:(BOOL)newShouldDraw;
- grid;
- (NSRect)convertFromViewToCanvasRect:(NSRect)viewRect;

- (void)setAcceptsFirstMouse:(BOOL)accepts;
- (void)setShouldDrawToolBeziers:(BOOL)newShouldDraw;

- (void)updateCrosshairs:(NSPoint)newLocation;
- (void)updateInfoPanelWithMousePosition:(NSPoint)point dragging:(BOOL)dragging;


- (PXBackground *)mainBackground;
- (PXBackground *)alternateBackground;
@end

void PXDebugRect(NSRect r, float alpha);

@interface NSObject(PXCanvasViewDelegate)
- (void)mouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseMoved:(NSEvent *)event;
- (void)eraserDown:(NSEvent *)event;
- (void)eraserUp:(NSEvent *)event;
- (void)eraserDragged:(NSEvent *)event;
- (void)eraserMoved:(NSEvent *)event;
@end
