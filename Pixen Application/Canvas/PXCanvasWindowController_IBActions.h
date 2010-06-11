//
//  PXCanvasWindowController_IBActions.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvasWindowController.h"

@interface PXCanvasWindowController(IBActions)
- (void)rotateLayerCounterclockwise:sender;
- (void)rotateLayerClockwise:sender;
- (void)rotateLayer180:sender;
- (IBAction)rotateCounterclockwise:sender;
- (IBAction)rotateClockwise:sender;
- (IBAction)rotate180:sender;
- (IBAction)resizeCanvas:(id) sender;
- (IBAction)scaleCanvas:(id) sender;
- (IBAction)increaseOpacity:(id)sender;
- (IBAction)decreaseOpacity:(id) sender;
- (IBAction)duplicateDocument:(id)sender;
- (IBAction)mergeDown:(id) sender;
- (BOOL)validateMenuItem:(NSMenuItem *)anItem;
- (IBAction)promoteSelection:(id) sender;
- (IBAction)newLayer:(id) sender;
- (IBAction)deleteLayer:sender;
- (IBAction)crop:sender;
- (IBAction)flipHorizontally:(id)sender;
- (IBAction)flipVertically:(id)sender;
- (IBAction)flipLayerHorizontally:(id) sender;
- (IBAction)flipLayerVertically:(id) sender;
- (IBAction)duplicateLayer:(id) sender;
- (IBAction)nextLayer:(id) sender;
- (IBAction)previousLayer:(id) sender;
- (IBAction) shouldTileToggled: (id) sender;
- (IBAction)setPatternToSelection:sender;
- (IBAction)showPreviewWindow:(NSEvent *) sender;
- (IBAction)togglePreviewWindow: (id) sender;
- (IBAction)showBackgroundInfo:(id) sender;
- (IBAction)showGridSettingsPrompter:(id) sender;
- (IBAction)toggleLayersDrawer:(id) sender;
- (IBAction)redrawCanvas: (id) sender;
- (void)prompter:aPrompter 
didFinishWithSize:(NSSize)aSize
		position:(NSPoint)position
 backgroundColor:(NSColor *)color;
- (IBAction)selectAll:sender;
- (IBAction)selectNone:sender;
- (IBAction)invertSelection: (id) sender;

- (IBAction)cut:sender;
- (IBAction)copy:sender;
- (IBAction)copyMerged:sender;
- (IBAction)paste:sender;
- (IBAction)pasteIntoActiveLayer:sender;
- (IBAction)delete:sender;

- (IBAction)cutLayer:sender;
- (IBAction)copyLayer:sender;
- (IBAction)pasteLayer:sender;
@end
