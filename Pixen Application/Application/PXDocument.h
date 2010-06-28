//
//  PXDocument.h
//  Pixen
//
//  Created by Joe Osborn on 2007.11.17.
//  Copyright 2007 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PXCanvas, PXCanvasWindowController;
@interface PXDocument : NSDocument {
	IBOutlet PXCanvasWindowController *windowController;
}
- (PXCanvasWindowController *)windowController;
- (PXCanvas *)canvas;
- (NSArray *)canvases;
- (BOOL)containsCanvas:(PXCanvas *)c;
- (void)close;
- (void)setFileURL:(NSURL *)fileName;
- (void)initWindowController;
- (void)setWindowControllerData;
- frameAutosaveName;
- (void)makeWindowControllers;
@end
