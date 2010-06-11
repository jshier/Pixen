//
//  PXAboutController.m
//  Pixen-XCode
//
//  Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

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
//
//  Created by Andy Matuschak on Sun Aug 01 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXAboutController.h"
#import "PXAboutPanel.h"
#import "Constants.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSTimer.h>
#import <Foundation/NSValue.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSTextStorage.h>
#import <AppKit/NSTextView.h>

static PXAboutController *singleInstance = nil;

@implementation PXAboutController

-(id) init
{
	if ( singleInstance ) 
    {
		[self dealloc];
		return singleInstance;
    }
	
	
	if ( ! ( self = [super init] ) ) 
		return nil;
	
	if ( ! [NSBundle loadNibNamed :@"PXAbout" owner:self] ) {
		NSLog(@"!!! Could not load PXAbout NIB !!!");
		[self dealloc];
		return nil;
	}
	
	singleInstance = self;
	
	return singleInstance;
}

+(id) sharedAboutController
{
	if ( ! singleInstance  ) 
		singleInstance = [[self alloc] init]; 
	
	return singleInstance;
}


- (void)loadCreditsText
{
	id linkString = [NSString stringWithFormat:@"<a href=\"http://www.opensword.org/license.php\">MIT License</a>"];
	
	id plainString = [[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"]] autorelease];
	
	[plainString replaceOccurrencesOfString:@"<PXLICENSE>"
								 withString:linkString
									options:NSLiteralSearch
									  range:NSMakeRange(0,[(NSString *)plainString length])];
	
	
	NSData *htmlData = [NSData dataWithBytes:[plainString cString] length:[(NSString *)plainString length]];
	NSDictionary *attributedOptions = [NSDictionary dictionaryWithObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]] forKey:@"BaseURL"];
	NSAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithHTML:htmlData options:attributedOptions documentAttributes:nil] autorelease];
	[[credits textStorage] setAttributedString:attributedString];
}


- (void)createPanel
{
	id content;
	aboutPanel = [[PXAboutPanel alloc]
		 initWithContentRect:[[panelInNib contentView] frame]
				   styleMask:NSBorderlessWindowMask
					 backing:[panelInNib backingType]
					   defer:NO];
	
	[aboutPanel setBackgroundColor: [NSColor whiteColor]];
	[aboutPanel setHasShadow: YES];
	[aboutPanel setNextResponder: self];
	[aboutPanel setBecomesKeyOnlyIfNeeded: NO];
	[aboutPanel setDelegate: self];
	[aboutPanel setLevel:NSModalPanelWindowLevel];
	
	
	content = [[panelInNib contentView] retain];
	[content removeFromSuperview];
	[(PXAboutPanel *)aboutPanel setContentView:content];
	
	[content release];
}

//Watch for notifications that the application is no longer active, or that
//another window has replaced the About panel as the main window, and hide
//on either of these notifications.
- (void) watchForNotificationsWhichShouldHidePanel
{
	//This works better than just making the panel hide when the app
	//deactivates (setHidesOnDeactivate:YES), because if we use that
	//then the panel will return when the app reactivates.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver: self
		   selector: @selector(hidePanel)
			   name: NSApplicationDidResignActiveNotification
			 object: nil];
	
	//If the panel is no longer main, hide it.
	//(We could also use the delegate notification for this.)
	[nc addObserver: self
		   selector: @selector(hidePanel)
			   name: NSWindowDidResignMainNotification
			 object: aboutPanel];
	
	[nc addObserver: self
		   selector: @selector(hidePanel)
			   name: NSWindowDidResignKeyNotification
			 object: aboutPanel];
	
}

- (void)dealloc
{
	[aboutPanel release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)setupPanel
{
	[self createPanel];
	[self loadCreditsText];
	[aboutPanel center];
	[self watchForNotificationsWhichShouldHidePanel];
}

- (void)showPanel:(id) sender
{
	NSDictionary *dictUserInfo;
	if (!aboutPanel) 
    { 
		[self setupPanel]; 
    }
	[aboutPanel setAlphaValue:0.0];
	[aboutPanel makeKeyAndOrderFront:nil];
	[fadeTimer invalidate];
	[fadeTimer release];
	
	dictUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:0.0], PXFadeOpacityKey,
		[NSNumber numberWithFloat:.1], PXFadeDirectionKey,
		nil];
	
	fadeTimer = [[NSTimer scheduledTimerWithTimeInterval:.05 
												  target:self 
												selector:@selector(fade:) 
												userInfo:dictUserInfo			  
												 repeats:NO] retain];
}


- (void)hidePanel
{
	NSDictionary *dictUserInfo;
	
	[fadeTimer invalidate];
	[fadeTimer release];
	
	dictUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:1.0], PXFadeOpacityKey, 
		[NSNumber numberWithFloat:-.1], PXFadeDirectionKey, 
		nil];
	
	fadeTimer = [[NSTimer scheduledTimerWithTimeInterval:.05 
												  target:self 
												selector:@selector(fade:) 
												userInfo:dictUserInfo
												 repeats:NO] retain];
}

- (void)fade:(NSTimer *)timer
{
	NSDictionary *userInfo = [timer userInfo];

	float alphaValue = [[userInfo objectForKey:PXFadeOpacityKey] floatValue];
	float fadeDirection = [[userInfo objectForKey:PXFadeDirectionKey] floatValue];
	
	[aboutPanel setAlphaValue:alphaValue];
	[fadeTimer invalidate];
	[fadeTimer release];
	
	if ( ( (alphaValue > 0 ) &&  ( fadeDirection < 0 ) )
		 || ( (alphaValue < 1)  && (fadeDirection > 0 ) ) )
    {
		NSNumber *opacityNum = [NSNumber numberWithFloat:alphaValue+fadeDirection];
		NSNumber *dirNum = [NSNumber numberWithFloat:fadeDirection];
		
		NSDictionary *dictUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			opacityNum, PXFadeOpacityKey, 
			dirNum, PXFadeDirectionKey,nil];
		
		fadeTimer = [[NSTimer scheduledTimerWithTimeInterval:.02 
													  target:self 
													selector:@selector(fade:) 
													userInfo: dictUserInfo
													 repeats:NO] retain];
    }
	else
    {
		fadeTimer = nil;
		if (alphaValue <= 0) {
			[aboutPanel orderOut:nil];
		}
    }
}

- (void)mouseDown:(NSEvent *) event
{
	[self hidePanel];
}

@end
