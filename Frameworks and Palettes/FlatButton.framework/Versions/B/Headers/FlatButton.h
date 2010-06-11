/*
 *	File Name:		FlatButton.h
 *	Bundle Name:	FlatButton.framework
 *	Description:	Push, Toggle Button and Drop-down Menu Cocoa-based Controls.
 *	Format:			Mach-O binary, Objective-C language, application bundle-embedded framework.
 *	Author:			ExitToShell() Collective <http://www.ExitToShell.com/>
 *	Copyright:		© 2004-2005 by Tim Mityok dba ExitToShell() Collective, all rights reserved.
 *	Version:		1.1.0b6
 *	Released:		2005-12-02
 *
 *	Changes:		Change: Controls will now momentarily darken when "clicked" via Accessibility/UI Scripting as with manual clicks.
 *					Fixed: Rewrote notification code to support Flat Button views that are moved into windows dynamically.
 *
 *	Previously:		2005-11-15 Fixed: The push button was accidentally made a child of an "AXUnknown" object breaking UI scripting.
 *					Fixed: Disabled controls now report their actual state via Accessibility/UI scripting.
 *					Fixed: Toggle and Tab-emulation buttons report a number value instead of their title in the "value" attribute.
 *
 *					2005-11-08 Fixed "hidden" mode to work properly in both controls (set, saving in NIB)
 *					Fixed crashing of Interface Builder because of new message-based activation/dimming.
 *					Changed the IB Inspector to more closely match Apple-designed inspectors.
 *					Internal code cleanup (again) and synchronization between both control variants (internally).
 *
 *					2005-11-04 Changed control active/inactive states to use messaging; NSMatrix-based controls will now dim properly.
 *
 *					2005-10-28 Button controls with an icon and no title now use the icon file name for the title for Accessibility/UI scripting (e.g. text to speech).
 *
 *					2005-10-26 Implemented some Accessibility/UI Scripting support to the button control only (for now).
 *
 *					2004-08-19 Added text alignment support to both the regular button and drop-down menu button variant. This includes IB inspector support.
 *
 *					2004-12-07 The Flat Button IB inspector properly clears the icon name field so that it no longer displays the name of an icon 
 *					that was added to a Flat Button other than the currently edited control.
 *
 *					2004-11-12 Changed the header file to allow for proper compiling.
 *					Compiled without debugging info to considerably reduce the size of the framework.
 *
 *					2004-11-12 Cleaned up a few remaining issues from beta; Icon-only option in IB Inspector works, general icon fixes.
 *					Some IB Inspector options are not implemented right now, specifically "hidden" and text alignment.
 *
 *					2004-11-12 Minor tweaks to button behaviors e.g. clicking in a drop-down Flat Button and then in a regular Flat Button
 *					works as expected now (button no longer stays "on").
 *					Moved the drop-down's menu location to match Flat Button for Carbon (this may eventually match Apple's controls)
 *
 *					2004-11-08 API changed back to target/setTarget because that is apparently correct (I give up reading Cocoa headers).
 *					Drop-down menu available.
 *					Settings should be properly saved into a nib. Some options are not fully enabled in the IB Inspector (Hidden).
 *
 *					2004-10-25 API change! (id)target and setTarget(id) was changed to (id)delegate and setDelegate(id) to
 *					properly match other Cocoa controls.
 *					Fixed 'Icon only' to properly clear and reset the control's title when used.
 *
 *					2004-10-21 Supports push button, Tabs mode & toggle button (via method or Interface Builder) only at this time.
 *					Very basic support for Set/Get options. No drop-down menu - yet.
 *					Redrawing is a little sluggish with lots of controls and dynamic resizing (needs optimizing).
 *
 */

#import <Cocoa/Cocoa.h>

/*	Do NOT change anything below or you may break the framework and/or crash!	*/

/*
 *
 *	Flat Button control
 *
 *	Implement these methods in your app/object to manipulate
 *	an existing Flat Button control.
 *
 */
 
@interface FlatButtonControl : NSControl {

	/* Use the public methods to get/set instance variables	*/
	
}

/*	Standard Control Public Methods	*/

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)flag;

- (SEL)action;
- (void)setAction:(SEL)aSelector;

/* When using Tabs emulation mode, to turn "off" a Flat Button use [control setIntValue:0] */
- (int)intValue;
- (void)setIntValue:(int)anInt;

/* Text positioning using standard NSTextAlignment constants */
- (NSTextAlignment)alignment;
- (void)setAlignment:(NSTextAlignment)mode;

- (int)tag;
- (void)setTag:(int)anInt;

- (BOOL)sendAction;

- (id)target;
- (void)setTarget:(id)anObject;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)value;

- (BOOL)isContinuous;
- (void)setContinuous:(BOOL)flag;

/*	Flat Button-specfic Public Methods	*/

/* Turn on/off Toggle Emulation mode from code */
- (BOOL)getToggleMode;
- (void)setToggleMode:(BOOL)value;

/* Turn on/off Tabs Emulation mode from code */
- (BOOL)getTabMode;
- (void)setTabMode:(BOOL)value;

/* Turn on/off a "Metal" color scheme from code */
- (BOOL)getMetalMode;
- (void)setMetalMode:(BOOL)value;

- (NSString *)getIconFileString;
- (void)setIconFileString:(NSString *)value;

- (void)setBlankIconFileString;

@end

/*
 *
 *	Flat Button Drop down/Pop-up control
 *
 *	Implement these methods in your app/object to manipulate
 *	an existing Flat Button pop-up control.
 * 
 *	You must define a menu in a nib or in code, see above.
 *
 */

@interface FlatButtonPopupControl : NSControl {

	/* Use the public methods to get/set instance variables	*/
	
}

/*	Standard Control Public Methods	*/

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)flag;

- (SEL)action;
- (void)setAction:(SEL)aSelector;

/* Under Tabs emulation mode to turn "off" a button use [control setIntValue:0] */
- (int)intValue;
- (void)setIntValue:(int)anInt;

- (int)tag;
- (void)setTag:(int)anInt;

- (BOOL)sendAction;

- (id)target;
- (void)setTarget:(id)anObject;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)value;

- (BOOL)isContinuous;
- (void)setContinuous:(BOOL)flag;

/*	Flat Button Pop-up-specfic Public Methods	*/

/* Turn on/off Toggle Emulation mode from code */
- (BOOL)getToggleMode;
- (void)setToggleMode:(BOOL)value;

/* Turn on/off Tabs Emulation mode from code */
- (BOOL)getTabMode;
- (void)setTabMode:(BOOL)value;

/* Turn on/off a "Metal" color scheme from code */
- (BOOL)getMetalMode;
- (void)setMetalMode:(BOOL)value;

- (NSString *)getIconFileString;
- (void)setIconFileString:(NSString *)value;

- (void)setBlankIconFileString; // clears the Icon file name field

@end

/*
 *
 *	Drop-down menu handling
 *
 *	Implement these methods in your app/object to provide
 *	an existing menu/view to the Flat Button pop-up control.
 * 
 *	You can define a menu in a nib or in code, it won't matter.
 *
 */

@interface NSObject (FlatButtonPopupControlDelegate)

- (NSMenu *)menuForContextButton:(FlatButtonPopupControl *)contextButton;

- (NSView *)targetViewForContextButton:(FlatButtonPopupControl *)contextButton;

@end