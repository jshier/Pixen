//
//  PXCanvas_Modifying.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(Modifying)
- (BOOL)canDrawAtPoint:(NSPoint) aPoint;
- (NSColor *) mergedColorAtPoint:(NSPoint)aPoint;
- (NSColor *) surfaceColorAtPoint:(NSPoint)aPoint;
- (NSColor*) colorAtPoint:(NSPoint) aPoint;
- (void)setColor:(NSColor *)aColor atPoint:(NSPoint)aPoint;
- (void)setColor:(NSColor *)aColor atPoint:(NSPoint)aPoint onLayer:(PXLayer *)l;
- (void)setColor:(NSColor *)color atIndices:(NSArray *)indices updateIn:(NSRect)bounds;
- (void)setColor:(NSColor *)color atIndices:(NSArray *)indices updateIn:(NSRect)bounds onLayer:(PXLayer *)layer;
- (void)reduceColorsTo:(NSUInteger)colors withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor;
+ (void)reduceColorsInCanvases:(NSArray*)canvases 
				  toColorCount:(NSUInteger)colors
			  withTransparency:(BOOL)transparency 
					matteColor:(NSColor *)matteColor;

- (NSPoint)correct:(NSPoint)aPoint;
- (BOOL)containsPoint:(NSPoint)aPoint;
- (void)rotateByDegrees:(NSUInteger)degrees;

- (BOOL)wraps;
- (void)setWraps:(BOOL)newWraps;
- (void)setWraps:(BOOL)newWraps suppressRedraw:(BOOL)suppress;
- (void)changedInRect:(NSRect)rect;
- (void)changed;

- (void)flipHorizontally;
- (void)flipVertically;


- (void)clearUndoBuffers;
- (void)registerForUndo;
- (void)registerForUndoWithDrawnPoints:(NSArray *)pts
							 oldColors:(NSArray *)oldC
							 newColors:(NSArray *)newC
							   inLayer:(PXLayer *)layer
							   undoing:(BOOL)undoing;
- (void)replaceColorsAtPoints:(NSArray *)pts withColors:(NSArray *)colors inLayer:layer;
- (void)bufferUndoAtPoint:(NSPoint)pt fromColor:(NSColor *)oldColor toColor:(NSColor *)newColor;


- (void)applyImage:(NSImage *)img toLayer:(PXLayer *)layer;
@end
