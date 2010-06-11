//
//  PXCanvas_CopyPaste.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(CopyPaste)
- (int)runPasteTooBigAlert:(NSString *)pastedThing size:(NSSize)aSize;
- (BOOL)canContinuePasteOf:(NSString *)pastedThing size:(NSSize)aSize;
- (void)pasteLayer:(PXLayer *)layer;
- (void)pasteLayerFromPasteboard:(NSPasteboard *)board type:type;
- (void)pasteFromPasteboard:(NSPasteboard *) board type:type intoLayer:(PXLayer *)layer;
- (void)pasteFromPasteboard:(NSPasteboard *) board type:type;
- (void)copyLayer:(PXLayer *)layer toPasteboard:(NSPasteboard *)board;
- (void)performCopyMergingLayers:(BOOL)merge;
- (void)copySelection;
- (void)copyMergedSelection;
- (void)cutSelection;
- (void)paste;
- (void)pasteIntoLayer:(PXLayer *)layer;
- (void)cutLayer:aLayer;
- (void)copyActiveLayer;
- (void)cutActiveLayer;
- (void)pasteLayer;
@end
