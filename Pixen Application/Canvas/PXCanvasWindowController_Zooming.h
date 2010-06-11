//
//  PXCanvasWindowController_Zooming.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvasWindowController.h"

@interface PXCanvasWindowController(Zooming)

- (void)prepareZoom;
- (IBAction)zoomToFit:sender;
- (void)zoomToIndex:(float)index;
- (void)zoomToPercentage:(NSNumber *)percentage;
- (void)zoomToFit;
- (void)canvasController:(PXCanvasController *)controller zoomInOnCanvasPoint:(NSPoint)point;
- (void)canvasController:(PXCanvasController *)controller zoomOutOnCanvasPoint:(NSPoint)point;
- (void)zoomToFitCanvasController:(PXCanvasController *)controller;
- (IBAction)zoomIn: (id) sender;
- (IBAction)zoomOut: (id) sender;
- (IBAction)zoomStandard: (id) sender;
- (IBAction)zoomPercentageChanged:sender;
- (IBAction)zoomStepperStepped:(id) sender;

@end
