//
//  PXToolPaletteController.m
//  Pixen-XCode
//
// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

//  Author : Andy Matuschak 


#import "PXToolPaletteController.h"
#import "PXToolSwitcher.h"
#import "PXPanelManager.h"


#import <Foundation/NSNotification.h>
#import <Foundation/NSUserDefaults.h>

#import <AppKit/NSButton.h>
#import <AppKit/NSColorPanel.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSPanel.h>

#import "PXNotifications.h"

static PXToolPaletteController *singleInstance = nil;

@interface PXToolPaletteController (Private)
- (void)_openRightToolSwitcher;
- (void)_closeRightToolSwitcher;
@end 

@implementation PXToolPaletteRightToolGradientView

- (BOOL)mouseDownCanMoveWindow
{
	return YES;
}

@end

//
// PXToolPalette : Private categories
//

@implementation PXToolPaletteController (Private)

- (void)_openRightToolSwitcher
{
	[minimalView setFrameOrigin:NSMakePoint(0, NSHeight([rightSwitchView frame]))];
	[rightSwitchView setFrameOrigin:NSZeroPoint];
	
	NSRect windowFrame = [[self window] frame];
	NSRect rightFrame = [rightSwitchView frame];
	[[self window] setFrame:NSMakeRect(NSMinX(windowFrame), NSMinY(windowFrame)-NSHeight(rightFrame), NSWidth(windowFrame), NSHeight(windowFrame)+NSHeight(rightFrame)) display:YES	animate:NO];
	
	[triangle setState:NSOnState];
	
	[[NSUserDefaults standardUserDefaults] setBool:YES
											forKey:PXRightToolSwitcherIsOpenKey];
}

- (void)_closeRightToolSwitcher
{
	[minimalView setFrameOrigin:NSZeroPoint];
	[rightSwitchView setFrameOrigin:NSMakePoint(0, -1 * NSHeight([rightSwitchView frame]))];
	NSRect windowFrame = [[self window] frame];
	NSRect rightFrame = [rightSwitchView frame];
	[[self window] setFrame:NSMakeRect(NSMinX(windowFrame), NSMinY(windowFrame)+NSHeight(rightFrame), NSWidth(windowFrame), NSHeight(windowFrame)-NSHeight(rightFrame)) display:YES	animate:NO];
	[triangle setState:NSOffState];
	[[NSUserDefaults standardUserDefaults] setBool:NO 
											forKey:PXRightToolSwitcherIsOpenKey];
}

@end


//
// PXToolPaletteController implementation
//

@implementation PXToolPaletteController


-(id) init
{
	if ( singleInstance ) 
    {
		[self dealloc];
		return singleInstance;
    }
	
	if ( ! (self = [super initWithWindowNibName:@"PXToolPalette"] ) ) 
		return nil;

	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(lock:)
												 name:PXLockToolSwitcherNotificationName 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(unlock:)
												 name:PXUnlockToolSwitcherNotificationName 
											   object:nil];
	
	[[self window] setMovableByWindowBackground:YES];
	
	singleInstance = self;
	return singleInstance;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)mouseDown:(NSEvent *)event
{
	if (!([event modifierFlags] & NSCommandKeyMask))
		[[self window] makeKeyWindow];
}

- (void)lock:(NSNotification *)aNotification
{
	usingRightToolBeforeLock = [self usingRightTool];
    _locked = YES;
    [leftSwitcher lock];
    [rightSwitcher lock];
}

- (void)unlock:(NSNotification *)aNotification
{
    _locked = NO;
    [leftSwitcher unlock];
    [rightSwitcher unlock];
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[leftSwitcher release];
	[rightSwitcher release];
	[super dealloc];
}

+(id) sharedToolPaletteController
{
	if(! singleInstance ) 
		singleInstance = [[self alloc] init];
	
	return singleInstance;
}

- (void)leftToolDoubleClicked:notification
{
	[[PXPanelManager sharedManager] toggleLeftToolProperties:nil];
}

- (void)rightToolDoubleClicked:notification
{
	[[PXPanelManager sharedManager] toggleRightToolProperties:nil];
}

-(void) awakeFromNib
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	[[NSColorPanel sharedColorPanel] setColor:[[NSColor blackColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]];
	//[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
	
	[leftSwitcher useToolTagged:PXPencilToolTag];
	[rightSwitcher useToolTagged:PXEraserToolTag];
		
	[nc addObserver:self 
		   selector:@selector(leftToolDoubleClicked:)
			   name:PXToolDoubleClickedNotificationName 
			 object:leftSwitcher];
	
	[nc addObserver:self
		   selector:@selector(rightToolDoubleClicked:) 
			   name:PXToolDoubleClickedNotificationName 
			 object:rightSwitcher];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PXRightToolSwitcherIsOpenKey]) {
		NSPoint panelOrigin = [[self window] frame].origin;
		panelOrigin.y += [rightSwitchView frame].size.height;
		[[self window] setFrameOrigin:panelOrigin];
		[self _openRightToolSwitcher];
	}
	
//FIXME: use named constant?
	[[self window] setFrameAutosaveName:@"PXToolPaletteFrame"];
	keyMask = 0x0;
}

- (void)clearBeziers;
{
	[rightSwitcher clearBeziers];
	[leftSwitcher clearBeziers];
}

//Action method
- (IBAction)disclosureClicked:(id)sender
{
	if([sender state] == NSOnState) 
		[self _openRightToolSwitcher]; 
	else 
		[self _closeRightToolSwitcher]; 
}


//Events methods

- (void)toolChanged
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PXToolDidChangeNotificationName object:self];
}

- (BOOL)usingRightTool
{
	if (_locked) {
		return usingRightToolBeforeLock;
	}
	NSUInteger modFlags = [[[NSApplication sharedApplication] currentEvent] modifierFlags];
	BOOL controlReallyDown = ((modFlags & NSControlKeyMask) == NSControlKeyMask); // sometimes we don't actually receive the message.  what a bother...
	if (controlKeyDown != controlReallyDown) {
		controlKeyDown = controlReallyDown;
		[self toolChanged];
	}
	return rightMouseDown || controlKeyDown;
}

- (void)setRightMouseDown:(BOOL)down
{
	BOOL oldUsingRightTool = [self usingRightTool];
	rightMouseDown = down;
	if (oldUsingRightTool != [self usingRightTool]) {
		[self toolChanged];
	}
}

- (void)setControlKeyDown:(BOOL)down
{
	BOOL oldUsingRightTool = [self usingRightTool];
	controlKeyDown = down;
	if (oldUsingRightTool != [self usingRightTool]) {
		[self toolChanged];
	}	
}

- (void)rightMouseDown
{
	[self setRightMouseDown:YES];
}

- (void)rightMouseUp
{
	[self setRightMouseDown:NO];
}

- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc
{
	if([event modifierFlags] & NSControlKeyMask)
		[rightSwitcher keyDown:event fromCanvasController:cc];
	else
		[leftSwitcher keyDown:event fromCanvasController:cc];
}

- (BOOL)keyWasDown:(NSUInteger)mask
{
    return (keyMask & mask) == mask;
}

- (BOOL)isMask:(NSUInteger)newMask upEventForModifierMask:(NSUInteger)mask
{
    return [self keyWasDown:mask] && ((newMask & mask) == 0x0000);
}

- (BOOL)isMask:(NSUInteger)newMask downEventForModifierMask:(NSUInteger)mask
{
    return ![self keyWasDown:mask] && ((newMask & mask) == mask);
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	if([self isMask:[theEvent modifierFlags] downEventForModifierMask:NSControlKeyMask])
    {
		[self setControlKeyDown:YES];
		keyMask |= NSControlKeyMask;
    }
	else if([self isMask:[theEvent modifierFlags] upEventForModifierMask:NSControlKeyMask])
    {
		[self setControlKeyDown:NO];
		keyMask ^= NSControlKeyMask;
    }
	
	if([self isMask:[theEvent modifierFlags] downEventForModifierMask:NSAlternateKeyMask])
    {
		[leftSwitcher optionKeyDown];
		[rightSwitcher optionKeyDown];
		keyMask |= NSAlternateKeyMask;
    }
	else if([self isMask:[theEvent modifierFlags] upEventForModifierMask:NSAlternateKeyMask])
    {
		[leftSwitcher optionKeyUp];
		[rightSwitcher optionKeyUp];
		keyMask ^= NSAlternateKeyMask;
    }
    
	if([self isMask:[theEvent modifierFlags] downEventForModifierMask:NSShiftKeyMask])
    {
		[leftSwitcher shiftKeyDown];
		[rightSwitcher shiftKeyDown];
		keyMask |= NSShiftKeyMask;
    }
	else if([self isMask:[theEvent modifierFlags] upEventForModifierMask:NSShiftKeyMask])
    {
		[leftSwitcher shiftKeyUp];
		[rightSwitcher shiftKeyUp];
		keyMask ^= NSShiftKeyMask;
    }
	
	if([self isMask:[theEvent modifierFlags] downEventForModifierMask:NSCommandKeyMask])
    {
		[leftSwitcher commandKeyDown];
		[rightSwitcher commandKeyDown];
		keyMask |= NSCommandKeyMask;
    }
	else if([self isMask:[theEvent modifierFlags] upEventForModifierMask:NSCommandKeyMask])
    {
		[leftSwitcher commandKeyUp];
		[rightSwitcher commandKeyUp];
		keyMask ^= NSCommandKeyMask;
    }
}

//
//Accessors methods
//
-(id) leftTool
{
	return [leftSwitcher selectedTool];
}

-(id) rightTool
{
	return [rightSwitcher selectedTool];
}

-(id) currentTool
{
	PXToolSwitcher *currentSwitcher = [self usingRightTool] ? rightSwitcher : leftSwitcher;
	return [currentSwitcher selectedTool];
}

- (PXToolSwitcher *) leftSwitcher
{
	return leftSwitcher;
}

- (PXToolSwitcher *) rightSwitcher
{
	return rightSwitcher;
}

-(NSPanel *) toolPanel
{
	return (NSPanel *)[self window];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[rightToolGradient setHidden:NO];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	[rightToolGradient setHidden:YES];
}

@end
