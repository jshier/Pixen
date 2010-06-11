//
//  OSProgressPopup.m
//  OSProgressPopup
//
//  Created by Andy Matuschak on 8/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "OSProgressPopup.h"
#import "ThreadWorker.h"

static NSLock *popupLock = nil;

@implementation OSProgressPopup

+ (void)initialize
{
	popupLock = [[NSLock alloc] init];
}

- init
{
	[NSException raise:@"Invalid initializer" format:@"OSProgressPopup is a singleton; use [OSProgressPopup sharedProgressPopup] to access the shared instance."];
	return nil;
}

- _init
{
	[super init];
	[NSBundle loadNibNamed:@"OSProgressPopup" owner:self];
	[progressIndicator setUsesThreadedAnimation:YES];
	[self setCanCancel:NO];	
	return self;
}

+ (OSProgressPopup *)sharedProgressPopup
{
	[popupLock lock];
	static OSProgressPopup *sharedProgressPopup = nil;
	if (!sharedProgressPopup)
		sharedProgressPopup = [[OSProgressPopup alloc] _init];
	[popupLock unlock];
	return sharedProgressPopup;
}

- (void)setStatusText:(NSString *)statusText
{
	[popupLock lock];
	[statusField setStringValue:statusText]; 
	[statusField display];
	[popupLock unlock];
}

- (void)setProgress:(double)newProgress
{
	[popupLock lock];
	if (indeterminate)
	{
		[progressIndicator setIndeterminate:NO];
		indeterminate = NO;
	}
	[progressIndicator setDoubleValue:newProgress];
	[progressIndicator display];
	[popupLock unlock];
}

- (void)setMaxProgress:(double)maxProgress
{
	[popupLock lock];
	if (indeterminate)
	{
		[progressIndicator setIndeterminate:NO];
		indeterminate = NO;
	}
	[progressIndicator setMaxValue:maxProgress];
	[popupLock unlock];
}

- (void)forwardStartSelector:userInfo
{
	[_target performSelector:_selector withObject:userInfo];
}

- (void)endOperation
{
	[popupLock lock];
	operationActive = NO;
	[popupLock unlock];
	[window orderOut:self];
	[NSApp endSheet:window];
}

- (IBAction)cancel:sender
{
	[self endOperation];
}

- (void)setCanCancel:(BOOL)canCancel
{
	if (canCancel)
	{
		[cancelButton setHidden:NO];
		NSRect frame = [progressIndicator frame];
		frame.size.width = NSWidth([window frame]) - 34 - NSWidth([cancelButton frame]);
		[progressIndicator setFrame:frame];
	}
	else
	{
		[cancelButton setHidden:YES];
		NSRect frame = [progressIndicator frame];
		frame.size.width = NSWidth([window frame]) - 34;
		[progressIndicator setFrame:frame];
	}
}

- (void)forwardEndSelector:userInfo
{
	if (_didEndSelector)
		[_target performSelector:_didEndSelector withObject:userInfo];
	[self endOperation];
}


- (void)beginOperationWithStatusText:(NSString *)statusText parentWindow:(NSWindow *)parentWindow
{
	[popupLock lock];
	if (operationActive)
		[NSException raise:@"Already running an operation" format:@"You are already running an operation using OSProgressPopup. End it before starting another."];
	operationActive = YES;
	
	indeterminate = YES;
	[progressIndicator setIndeterminate:YES];
	[progressIndicator startAnimation:self];
	
	if (statusText)
		[statusField setStringValue:statusText];
	[popupLock unlock];
	
	[NSApp beginSheet:window modalForWindow:parentWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
	
}

- (void)beginOperationWithSelector:(SEL)selector target:target object:object didEndSelector:(SEL)didEndSelector statusText:(NSString *)statusText parentWindow:(NSWindow *)parentWindow
{
	[popupLock lock];
	_target = target;
	_selector = selector;
	_didEndSelector = didEndSelector;
	[popupLock unlock];
	
	[self beginOperationWithStatusText:statusText parentWindow:parentWindow];
	[ThreadWorker workOn:self withSelector:@selector(forwardStartSelector:) withObject:object didEndSelector:@selector(forwardEndSelector:)];
}

@end
