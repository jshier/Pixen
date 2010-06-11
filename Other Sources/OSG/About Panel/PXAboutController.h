//
//  PXAboutController.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on Sun Aug 01 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <AppKit/NSResponder.h>
#import <AppKit/NSNibDeclarations.h>
@class NSTimer;
@class NSTextField;
@class NSTextView;

@interface PXAboutController : NSResponder 
{
	id aboutPanel;
	id panelInNib;
	IBOutlet NSTextView *credits;
	IBOutlet NSTextField *version;
	
	NSTimer *fadeTimer;
}

+(id) sharedAboutController;
- (void)showPanel:(id)sender;

@end
