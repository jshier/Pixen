//
//  PXCanvas_Layers.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(Layers)
- (PXLayer *) activeLayer;
- (void)activateLayer:(PXLayer *) aLayer;
- (NSArray *) layers;
- (int)indexOfLayer:(PXLayer *) aLayer;

- (void)setLayers:(NSArray *) newLayers;
- (void)setLayers:(NSArray*)layers fromLayers:(NSArray *)oldLayers;
- (void)setLayers:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers withDescription:(NSString *)desc;
- (void)setLayersNoResize:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers;

- (void)addLayer:(PXLayer *) aLayer suppressingNotification:(BOOL)suppress;
- (void)addLayer:(PXLayer *)aLayer;
- (void)insertLayer:(PXLayer *) aLayer atIndex:(int)index suppressingNotification:(BOOL)suppress;
- (void)insertLayer:(PXLayer *) aLayer atIndex:(int)index;
- (void)removeLayer: (PXLayer*) aLayer;
- (void)removeLayer: (PXLayer*) aLayer suppressingNotification:(BOOL)suppress;
- (void)removeLayerAtIndex:(int)index;
- (void)removeLayerAtIndex:(int)index suppressingNotification:(BOOL)suppress;

- (void)moveLayer:(PXLayer *)aLayer toIndex:(int)anIndex;
- (void)layersChanged;

- (void)rotateLayer:(PXLayer *)layer byDegrees:(int)degrees;

- (void)duplicateLayerAtIndex:(unsigned)index;
- (void)flipLayerHorizontally:aLayer;
- (void)flipLayerVertically:aLayer;

- (void)mergeDownLayer:aLayer;

- (void)moveLayer:(PXLayer *)aLayer byX:(int)x y:(int)y;
- (void)replaceLayer:(PXLayer *)old withLayer:(PXLayer *)new actionName:(NSString *)act;
@end
