//
//  PXCanvasController.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PXCanvas, PXCanvasView, PXBackground;
@interface PXCanvasController : NSObject {
	PXCanvas *canvas;
	IBOutlet PXCanvasView *view;
	IBOutlet NSScrollView *scrollView;
	NSDocument *document;
	IBOutlet NSWindow *window;
	id gridSettingsPrompter;

	id prompter;
	id previewController;
	id layerController;
	id backgroundController;
	
	NSPoint initialPoint;
	NSPoint mouseMovePoint;
	NSPoint lastDrawnPoint;
	BOOL downEventOccurred;
	BOOL usingSpaceKey;
	
	NSPoint panLeftovers; // used to integerify the pan coords
	
	NSColor *oldColor;

	id delegate;
	BOOL wraps; // used in setCanvas
}
- view;
- scrollView;
- layerController;
- window;
- (void)dealloc;
- (void)layerSelectionDidChange:(NSNotification *) aNotification;
- (void)setLayerController:contro;
- (void)prepare;
- (void)gridSettingsPrompter:aPrompter 
			 updatedWithSize:(NSSize)aSize
					   color:color
				  shouldDraw:(BOOL)shouldDraw;
- (void)toolSwitched:(NSNotification *)notification;
- (void)canvasSizeDidChange:(NSNotification *) aNotification;
- (PXCanvas *) canvas;
- (void)setColor:(NSColor *) aColor;
- (void)promptForImageSize;
- (void)prompter:aPrompter didFinishWithSize:(NSSize)aSize backgroundColor:(NSColor *)bg;
- (void)setCanvas:(PXCanvas *)canv;
- (void)canvasDidChange:(NSNotification *) aNotification;
- (void)activate;
- (void)deactivate;
- (void)updatePreview;
- mainBackground;
- alternateBackground;
- (void)setMainBackground:(id) aBackground;
- (void)setAlternateBackground:(id) aBackground;
- (PXBackground *)defaultMainBackground;
- (void)setDefaultMainBackground:(PXBackground *)bg;
- (PXBackground *)defaultAlternateBackground;
- (void)setDefaultAlternateBackground:(PXBackground *)bg;
- (void)toggleShouldTile;
- (void)setPatternToSelection;
- (void)showBackgroundInfo;
- (void)showGridSettings;
- (void)updateCanvasSizeZoomingToFit:(BOOL)zooming;
- (void)updateCanvasSize;
- document;
- (void)setDocument:doc;
- window;
- (void)setWindow:win;
- delegate;
- (void)setDelegate:del;
- (void)zoomInOnCanvasPoint:(NSPoint)point;
- (void)zoomOutOnCanvasPoint:(NSPoint)point;

- (void)mouseDown:event forTool:aTool;
- (void)mouseDragged:(NSEvent *)event forTool:aTool;
- (void)mouseUpAt:(NSPoint)loc forTool:aTool;
- (void)mouseMovedTo:(NSPoint)point forTool:aTool;
- (void)updateMousePosition:(NSPoint)newLocation;
- (void)mouseDown:(NSEvent *)event;
- (void)eraserDown:(NSEvent *)event;
- (void)eraserDragged:(NSEvent *)event;
- (void)eraserUp:(NSEvent *)event;
- (void)eraserMoved:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *) event;
- (void)mouseMoved:(NSEvent *) event;
- (void)mouseUp:(NSEvent *) event;
- (void)rightMouseDown:(NSEvent *) event;
- (void)rightMouseDragged:(NSEvent *) event;
- (void)rightMouseUp:(NSEvent *) event;
- (void)scrollWheel:(NSEvent *)event;
- (void)otherMouseDragged:(NSEvent *)event;
- (void)keyUp:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;
- (void)flagsChanged:(NSEvent *) event;
- (void)panViewWithEvent:(NSEvent *)event;
- (BOOL)caresAboutPressure;


- (void)setLastDrawnPoint:(NSPoint)point;
- (NSPoint)lastDrawnPoint;

@end


@interface NSObject(PXCanvasControllerDelegate)
- (void)canvasController:(PXCanvasController *)controller zoomInOnCanvasPoint:(NSPoint)point;
- (void)canvasController:(PXCanvasController *)controller zoomOutOnCanvasPoint:(NSPoint)point;
- (void)zoomToFitCanvasController:(PXCanvasController *)controller;
- (void)canvasController:(PXCanvasController *)controller setSize:(NSSize)size backgroundColor:(NSColor *)bg;
@end
