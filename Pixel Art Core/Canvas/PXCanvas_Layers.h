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
- (NSUInteger)indexOfLayer:(PXLayer *) aLayer;

- (void)setLayers:(NSArray *) newLayers;
- (void)setLayers:(NSArray*)layers fromLayers:(NSArray *)oldLayers;
- (void)setLayers:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers withDescription:(NSString *)desc;
- (void)setLayersNoResize:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers;

- (void)addLayer:(PXLayer *) aLayer suppressingNotification:(BOOL)suppress;
- (void)addLayer:(PXLayer *)aLayer;
- (void)insertLayer:(PXLayer *) aLayer atIndex:(NSUInteger)index suppressingNotification:(BOOL)suppress;
- (void)insertLayer:(PXLayer *) aLayer atIndex:(NSUInteger)index;
- (void)removeLayer: (PXLayer*) aLayer;
- (void)removeLayer: (PXLayer*) aLayer suppressingNotification:(BOOL)suppress;
- (void)removeLayerAtIndex:(NSUInteger)index;
- (void)removeLayerAtIndex:(NSUInteger)index suppressingNotification:(BOOL)suppress;

- (void)moveLayer:(PXLayer *)aLayer toIndex:(NSUInteger)anIndex;
- (void)layersChanged;

- (void)rotateLayer:(PXLayer *)layer byDegrees:(NSUInteger)degrees;

- (void)duplicateLayerAtIndex:(NSUInteger)index;
- (void)flipLayerHorizontally:aLayer;
- (void)flipLayerVertically:aLayer;

- (void)mergeDownLayer:aLayer;

- (void)moveLayer:(PXLayer *)aLayer byX:(NSUInteger)x y:(NSUInteger)y;
- (void)replaceLayer:(PXLayer *)oldLayer withLayer:(PXLayer *)newLayer actionName:(NSString *)act;
@end
