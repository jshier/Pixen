//
//  membrane_cocoa.h
//  membrane-cocoa
//
//  Created by Tim Mityok on 2004-10-06.
//  Copyright ExitToShell() Software 2004 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <InterfaceBuilder/IBDefines.h>
#import "FlatButtonCarbonFunc.h"

@interface FlatButtonPopupCell : NSActionCell {

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

- (id)target;
- (void)setTarget:(id)anObject;

- (SEL)action;
- (void)setAction:(SEL)aSelector;

- (int)tag;
- (void)setTag:(int)anInt;

- (BOOL)isCellContinuous;
- (void)setCellContinuous:(BOOL)flag;

- (BOOL)isCellHidden;
- (void)setCellHidden:(BOOL)flag;

- (int)intValue;
- (void)setIntValue:(int)anInt;

- (NSTextAlignment)alignment;
- (void)setAlignment:(NSTextAlignment)mode;

- (BOOL)sendCellAction;
- (BOOL)sendCellAction:(SEL)theAction to:(id)theTarget;

/*	Control Custom CDEF "Cell" Methods	*/

- (void)setCellNotif;

- (void)setCellToggleMode:(BOOL)value;
- (BOOL)getCellToggleMode; // Always NO

- (void)setCellMetalMode:(BOOL)value;
- (BOOL)getCellMetalMode;

- (void)setCellTabMode:(BOOL)value;
- (BOOL)getCellTabMode; // Always NO

- (void)setCellClicked:(BOOL)value;

- (void)loadIconFile:(NSString *)value;
- (NSString *)getIconFileCellString;
- (void)setIconFileCellString:(NSString *)value;
- (void)setBlankIconFileCellString;

- (void)setBlankTitleCellString;

@end

@interface FlatButtonPopupCell (PrivateAPI)
- (void)_getMenu:(NSMenu **)outMenu targetView:(NSView **)outTargetView;
@end

@interface FlatButtonPopupControl : NSControl {

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

- (BOOL)sendAction;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)value;

- (BOOL)isContinuous;
- (void)setContinuous:(BOOL)flag;

/*	Control Custom CDEF Methods	*/

- (BOOL)getToggleMode; // Always NO
- (void)setToggleMode:(BOOL)value;

- (BOOL)getTabMode; // Always NO
- (void)setTabMode:(BOOL)value;

- (BOOL)getMetalMode;
- (void)setMetalMode:(BOOL)value;

- (NSString *)getIconFileString;
- (void)setIconFileString:(NSString *)value;
- (void)setBlankIconFileString;

- (void)setBlankTitleString;

@end

@interface NSObject (FlatButtonPopupControlDelegate)
- (NSMenu *)menuForContextButton:(FlatButtonPopupControl *)contextButton;
- (NSView *)targetViewForContextButton:(FlatButtonPopupControl *)contextButton;
@end
/*
@interface FlatButtonPopupMatrix : NSMatrix {

}

@end
*/