//
//  membrane_cocoaInspector.h
//  membrane-cocoa
//
//  Created by Tim Mityok on 2004-10-06.
//  Copyright ExitToShell() Software 2004. All rights reserved.
//

#import <InterfaceBuilder/InterfaceBuilder.h>

@interface FlatButtonCellInspector : IBInspector
{
	IBOutlet NSTextField *controlTitleTextField;
	IBOutlet NSTextField *controlTagTextField;
	IBOutlet NSTextField *controlIconNameTextField;

	IBOutlet NSButton *controlIconOnly;
	IBOutlet NSButton *controlMetalMode;	
	IBOutlet NSButton *controlToggleMode;
	IBOutlet NSButton *controlTabMode;
	IBOutlet NSButton *controlEnableMode;
	IBOutlet NSButton *controlContinuousMode;
	IBOutlet NSButton *controlHiddenMode;
	IBOutlet NSPopUpButton *controlTextAlign;
}

- (void)setControlEnable:(id)sender;

- (void)metalButton:(id)sender;

- (void)toggleButton:(id)sender;

- (void)tabsButton:(id)sender;

- (void)continuousButton:(id)sender;

- (void)hiddenButton:(id)sender;

- (void)iconOnlyButton:(id)sender;

- (void)textAlignButton:(id)sender;

@end