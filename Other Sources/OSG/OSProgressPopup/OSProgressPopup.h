//
//  OSProgressPopup.h
//  OSProgressPopup
//
//  Created by Andy Matuschak on 8/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSProgressThread;
@interface OSProgressPopup : NSObject
{
	BOOL operationActive;
	IBOutlet NSTextField *statusField;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSWindow *window;
	
	SEL _selector;
	SEL _didEndSelector;
	id _target;
	
	BOOL indeterminate;
}

// This method returns the singleton instance of the progress popup. Don't allocate your own; use this method.
+ (OSProgressPopup *)sharedProgressPopup;

// Use this method to begin a non-threaded operation with the progress popup.
- (void)beginOperationWithStatusText:(NSString *)statusText parentWindow:(NSWindow *)parentWindow;

// Use this method to begin an operation with the progress popup. If you don't care about getting sent a message when the thread exits, 
- (void)beginOperationWithSelector:(SEL)selector target:target object:object didEndSelector:(SEL)didEndSelector statusText:(NSString *)statusText parentWindow:(NSWindow *)parentWindow;

- (void)endOperation;

- (void)setCanCancel:(BOOL)canCancel;
- (void)setStatusText:(NSString *)statusText;
- (void)setProgress:(double)progress;
- (void)setMaxProgress:(double)maxProgress;

@end
