//
//  PXImageSizePrompter.m
//  Pixel Editor
//
//  PXImageSizePrompter.m
//  Pixen-XCode
//
// Copyright (c) 2003,2004,2005 Open Sword Group

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

//  Created by Joe Osborn on Tue Oct 28 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//
//
//  Created by Open Sword Group on Thu May 01 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXImageSizePrompter.h"
#import "PXCanvasView.h"
#import "PXNSImageView.h"
#import "PXBackgrounds.h"

@implementation PXImageSizePrompter

-(id) init
{
	[super initWithWindowNibName:@"PXImageSizePrompt"];
	[self setBackgroundColor:[NSColor clearColor]];
	return self;
}

- (void)dealloc
{
	[self setBackgroundColor:nil];
	[image release];
	[super dealloc];
}

- (void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}

- imageWithWidth:(float)width height:(float)height
{
	if (image) { return image; }
	NSSize imageSize;
	if (width > height)
	{
		imageSize.width = MIN(85, width);
		imageSize.height = MAX(MIN(85, width) * (height / width), 1);
	}
	else
	{
		imageSize.height = MIN(85, height);
		imageSize.width = MAX(MIN(85, height) * (width / height), 1);
	}
		
	if (imageSize.width == 0 || imageSize.height == 0) { return nil; }
	image = [[NSImage alloc] initWithSize:imageSize];
	[image lockFocus];
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:PXCanvasDefaultMainBackgroundKey];
	PXBackground *background = (data) ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : [[[PXSlashyBackground alloc] init] autorelease];
	NSSize ceiledSize = NSMakeSize(ceilf(imageSize.width), ceilf(imageSize.height));
	[background drawRect:(NSRect){NSZeroPoint, ceiledSize} withinRect:(NSRect){NSZeroPoint, ceiledSize}];
	[backgroundColor set];
	NSRectFillUsingOperation(NSMakeRect(0, 0, imageSize.width, imageSize.height), NSCompositeSourceOver);
	[image unlockFocus];
	return image;
}

- backgroundColor
{
	return backgroundColor;
}
- (void)setBackgroundColor:(NSColor *)c
{
//	[self willChangeValueForKey:@"backgroundColor"];
	[c retain];
	id oldColor = backgroundColor;
	backgroundColor = c;
	[oldColor autorelease];
	[image release]; image = nil;
	[preview setImage:[self imageWithWidth:initialSize.width height:initialSize.height]];
//	[self didChangeValueForKey:@"backgroundColor"];
}

- (void)updateFieldsFromDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:PXDefaultNewDocumentWidth])
		[defaults setInteger:64 forKey:PXDefaultNewDocumentWidth];
	if (![defaults objectForKey:PXDefaultNewDocumentHeight])
		[defaults setInteger:64 forKey:PXDefaultNewDocumentHeight];
	if (![defaults objectForKey:PXDefaultNewDocumentBackgroundColor])
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor clearColor]] forKey:PXDefaultNewDocumentBackgroundColor];
	
	[self setBackgroundColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:PXDefaultNewDocumentBackgroundColor]]];
	[widthField setIntValue:[defaults integerForKey:PXDefaultNewDocumentWidth]];
	[heightField setIntValue:[defaults integerForKey:PXDefaultNewDocumentHeight]];
}

- (void)updateSizeIndicators
{
	NSSize imageSize = [image size];
	NSRect functionalRect = [preview functionalRect];
	
	if (NSIsEmptyRect(initialWidthIndicatorFrame)) { initialWidthIndicatorFrame = [widthIndicator frame]; }
	[widthIndicator setFrame:NSMakeRect(NSMinX(functionalRect) + NSMinX([preview frame]), NSMinY([widthIndicator frame]), imageSize.width, NSHeight([widthIndicator frame]))];
	
	if (NSIsEmptyRect(initialHeightIndicatorFrame)) { initialHeightIndicatorFrame = [heightIndicator frame]; }
	[heightIndicator setFrame:NSMakeRect(NSMinX([heightIndicator frame]), NSMinY(functionalRect) + NSMinY([preview frame]), NSWidth([heightIndicator frame]), imageSize.height)];
	[[[self window] contentView] setNeedsDisplay:YES];	
}

- (void)promptInWindow:(NSWindow *) window
{
	if([[[NSProcessInfo processInfo] arguments] containsObject:@"-SenTest"]) 
		return;
	
	[self window];
	[self updateFieldsFromDefaults];
	float width = [widthField intValue], height = [heightField intValue];
	[image release];
	image = nil;
	[preview setImage:[self imageWithWidth:width height:height]];
	[self updateSizeIndicators];
	initialSize = NSMakeSize(width, height);
	targetSize = initialSize;
	
	animationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updatePreviewImageFrame:) userInfo:nil repeats:YES] retain];
	
	[NSApp beginSheet:[self window] 
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (void)updatePreviewImageFrame:event
{
	NSSize previewSize = initialSize;
	float projectedFraction = (sin(animationFraction) + 1.0)/2.0 - 0.01; // the 0.01 is so it goes below 0
	if (projectedFraction < 0) {
		return;
	}
	previewSize.width = targetSize.width * (1.0 - projectedFraction) + initialSize.width * projectedFraction;
	previewSize.height = targetSize.height * (1.0 - projectedFraction) + initialSize.height * projectedFraction;
	
	[image release]; image = nil;
	[preview setImage:[self imageWithWidth:previewSize.width height:previewSize.height]];
	[self updateSizeIndicators];
	
	//[preview setFunctionalRect:previewRect];
	[preview setNeedsDisplay];
	
	animationFraction -= 0.25;
}

- (IBAction)sizeChanged:sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:[widthField intValue] forKey:PXDefaultNewDocumentWidth];
	[[NSUserDefaults standardUserDefaults] setInteger:[heightField intValue] forKey:PXDefaultNewDocumentHeight];
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:backgroundColor] forKey:PXDefaultNewDocumentBackgroundColor];
	[image release];
	image = nil;
	
	float width = [widthField intValue];
	float height = [heightField intValue];
	
	initialSize = [preview functionalRect].size;
	targetSize = [preview scaledSizeForImage:[self imageWithWidth:width height:height]];
	
	animationFraction = 1;
}

- (void)controlTextDidChange:note
{
	if ([widthField intValue] == 0)
	{
		NSBeep();
		[widthField setIntValue:1];
	}
	if ([heightField intValue] == 0)
	{
		NSBeep();
		[heightField setIntValue:1];
	}
	[self sizeChanged:self];
}

- (IBAction)useEnteredSize:(id)sender
{
	[[self window] makeFirstResponder:nil];
	int width = MAX([widthField intValue], 1);
	int height = MAX([heightField intValue], 1);
	[delegate prompter:self 
	 didFinishWithSize:NSMakeSize(width, height)
	   backgroundColor:backgroundColor];
	
	if (animationTimer)
		[animationTimer invalidate];
	[animationTimer release];
	[NSApp endSheet:[self window]];
	[self close];
}
- (IBAction)cancel:(id)sender
{	
    [NSApp endSheet:[self window]];
    [self close];
	[delegate prompterDidCancel:self];
}

@end
