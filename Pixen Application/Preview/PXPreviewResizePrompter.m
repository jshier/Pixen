//
//  PXPreviewResizePrompter.m
//  Pixen
//
//  Created by Andy Matuschak on 6/11/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPreviewResizePrompter.h"


@implementation PXPreviewResizePrompter

- (id) init
{
	if (! ( self = [super initWithWindowNibName:@"PXPreviewResizePrompt"] ) )
		return nil;
	
	return self;
}

- (IBAction)updateForm:sender
{
	float zoomValue = MIN([zoomPercentage floatValue] / 100.0, 100);
	float widthValue = [width intValue];
	float heightValue = [height intValue];
	
	if (sender == zoomPercentage)
	{
		[width setIntValue:(int)(canvasSize.width * zoomValue)];
		[height setIntValue:(int)(canvasSize.height * zoomValue)];
	}
	else if (sender == width)
	{
		[height setIntValue:(int)(canvasSize.height * (widthValue / canvasSize.width))];
		[zoomPercentage setFloatValue:MIN((widthValue / canvasSize.width), 100) * 100];
	}
	else if (sender == height)
	{
		[width setIntValue:(int)(canvasSize.width * (heightValue / canvasSize.height))];
		[zoomPercentage setFloatValue:MIN((heightValue / canvasSize.height), 100) * 100];
	}
}

- (void)promptInWindow:(NSWindow *)window
{
	if([[[NSProcessInfo processInfo] arguments] containsObject:@"-SenTest"]) 
		return; 
	
	[NSApp beginSheet:[self window] 
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (IBAction)resize:sender
{
	[delegate prompter:self didFinishWithZoomFactor:MIN([zoomPercentage floatValue] / 100.0, 100)];
	[NSApp endSheet:[self window]];
	[self close];
}

- (IBAction)cancel:sender
{
	[NSApp endSheet:[self window]];
	[self close];
}

- (void)setZoomFactor:(float)zoomFactor
{
	[zoomPercentage setFloatValue:zoomFactor * 100];
	[width setIntValue:(int)(canvasSize.width * zoomFactor)];
	[height setIntValue:(int)(canvasSize.height * zoomFactor)];
}

- (void)setCanvasSize:(NSSize)newSize
{
	canvasSize = newSize;
}

- (void)setDelegate:newDelegate
{
	delegate = newDelegate;
}

@end
