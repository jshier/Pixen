//
//  FlatButtonCocoa.h
//  flatbutton-cocoa
//
//  Created by Tim Mityok on 2004-10-06.
//  Copyright ExitToShell() Software 2004 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <InterfaceBuilder/IBDefines.h>
#import "FlatButtonCarbonFunc.h"

@interface FlatButtonCell : NSActionCell {

	/*	Custom Control Data	*/
	CustomPushButtonData myControlData;

	NSString *_titleCellString;
	NSString *_iconNameCellString;
	
	int _controlCellTag;
	int _controlCellValue;
	id _controlCellIDTarget;
	BOOL _controlCellContinuous;
	SEL _controlCellActionSelector;
}

/*	Required Cocoa CDEF "Cell" Methods	*/

- (BOOL)isCellEnabled;
- (void)setCellEnabled:(BOOL)flag;

- (void)setCellActive:(BOOL)flag;

- (NSString *)getCellTitleString;
- (void)setCellTitleString:(NSString *)value;

- (NSSize)minimumSizeForCellSize:(NSSize)cellSize knobPosition:(IBKnobPosition)knobPosition;

- (BOOL)isInInterfaceBuilder;

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag;
- (BOOL)trackMouseInControl:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView;

- (void) performClickWithFrame: (NSRect)cellFrame inView: (NSView *)controlView;

- (BOOL)sendCellAction;

- (int)tag;
- (void)setTag:(int)anInt;

- (id)target;
- (void)setTarget:(id)anObject;

- (void)setAction:(SEL)aSelector;
- (SEL)action;

- (int)intValue;
- (void)setIntValue:(int)anInt;

- (NSTextAlignment)alignment;
- (void)setAlignment:(NSTextAlignment)mode;

- (BOOL)sendCellAction:(SEL)theAction to:(id)theTarget;

- (BOOL)isCellContinuous;
- (void)setCellContinuous:(BOOL)flag;

- (BOOL)isCellHidden;
- (void)setCellHidden:(BOOL)flag;

/*	Control Custom CDEF "Cell" Methods	*/

- (void)setCellNotif;

- (BOOL)getCellTabMode;
- (void)setCellTabMode:(BOOL)value;

- (BOOL)getCellToggleMode;
- (void)setCellToggleMode:(BOOL)value;

- (BOOL)getCellMetalMode;
- (void)setCellMetalMode:(BOOL)value;

- (void)setCellClicked:(BOOL)value;

- (void)loadIconFile:(NSString *)value;
- (NSString *)getIconFileCellString;
- (void)setIconFileCellString:(NSString *)value;
- (void)setBlankIconFileCellString;

- (void)setBlankTitleCellString;

@end

@interface FlatButtonControl : NSControl {

	NSString *_titleString;
	NSString *_iconNameString;

}

/*	Required Cocoa CDEF Methods	*/

// Enable/disable and appearance
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)flag;

- (SEL)action;
- (void)setAction:(SEL)aSelector;

- (int)intValue;
- (void)setIntValue:(int)anInt;

- (NSTextAlignment)alignment;
- (void)setAlignment:(NSTextAlignment)mode;

- (int)tag;
- (void)setTag:(int)anInt;

- (id)target;
- (void)setTarget:(id)anObject;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)value;

- (BOOL)isContinuous;
- (void)setContinuous:(BOOL)flag;

/*	Control Custom CDEF Methods	*/

- (BOOL)getTabMode;
- (void)setTabMode:(BOOL)value;

- (BOOL)getToggleMode;
- (void)setToggleMode:(BOOL)value;

- (BOOL)getMetalMode;
- (void)setMetalMode:(BOOL)value;

- (NSString *)getIconFileString;
- (void)setIconFileString:(NSString *)value;
- (void)setBlankIconFileString;

- (void)setBlankTitleString;
@end