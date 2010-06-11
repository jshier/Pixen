//
//  PXColorPicker.h
//  PXColorPicker
//
//  Created by Andy Matuschak on 7/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
extern int kPXColorPickerMode;
@class PXPaletteView, PXPaletteSelector;
@interface PXColorPicker : NSColorPicker <NSColorPickingDefault, NSColorPickingCustom>
{
	NSImage *icon;
	IBOutlet NSView *pickerView;
	IBOutlet PXPaletteView *paletteView;
	IBOutlet PXPaletteSelector *paletteSelector;
	IBOutlet NSPopUpButton *gearMenu;
	
	id namePrompter;
}

- (IBAction)popOut:sender;

@end
