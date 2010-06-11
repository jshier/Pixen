//
//  PXPalettePanel.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.12.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"
@class PXPaletteSelector, PXPalettePanelPaletteView;
@interface PXPalettePanel : NSPanel {
	PXPalette *palette;
	IBOutlet PXPaletteSelector *paletteSelector;
	IBOutlet PXPalettePanelPaletteView *paletteView;
	IBOutlet NSView *contents;
	IBOutlet NSPopUpButton *gearMenu;
	id namePrompter;
}
+ popWithPalette:(PXPalette *)pal fromWindow:(NSWindow *)window;
- initWithPalette:(PXPalette *)pal;
- (PXPalettePanelPaletteView *)paletteView;
- (IBAction)popOut:sender;
- (void)reloadDataAndShow:(PXPalette *)pal;
- (void)documentAdded:(NSNotification *)notification;
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (void)documentClosed:(NSNotification *)notification;
- (void)reloadData;
- (void)paletteSelector:(PXPaletteSelector *)selector selectionDidChangeTo:(PXPalette *)palette;
- (void)paletteChanged:(NSNotification *)notification;
- (void)showPalette:(PXPalette *)palette;
@end
