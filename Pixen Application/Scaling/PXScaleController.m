//
//  PXScaleController.m
//  Pixen-XCode
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
//  Created by Ian Henderson on Thu Jun 10 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXScaleController.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Selection.h"
#import "PXCanvasWindowController.h"
#import "PXCanvasWindowController_IBActions.h"
#import "PXNearestNeighborScaleAlgorithm.h"
#import "PXScale2xScaleAlgorithm.h"
#import "PXQuartzScaleAlgorithm.h"

@implementation PXScaleController

static NSArray *algorithms = nil;

+ (void)initialize
{
	static BOOL ready = NO;
	if(!ready)
	{
		ready = YES;
		algorithms = [[NSArray alloc] initWithObjects:
			[PXNearestNeighborScaleAlgorithm algorithm], 
			[PXScale2xScaleAlgorithm algorithm], 
			[PXQuartzScaleAlgorithm algorithm],
			nil];
	}
}

- (id) init
{
	return self = [super initWithWindowNibName:@"PXScalePrompt"];
}

- (void)scaleCanvasFromController:(PXCanvasWindowController *)controller 
				   modalForWindow:(NSWindow *)theWindow
{
	canvasController = controller;
	if ([self isWindowLoaded]) 
    {
		newSize = [[canvasController canvas] size];
		[[self pixelsWideField] setFloatValue:newSize.width];
		[[self pixelsHighField] setFloatValue:newSize.height];
		[[self percentageWideField] setFloatValue:100.0f];
		[[self percentageHighField] setFloatValue:100.0f];
    }
	
	[NSApp beginSheet:[self window]
	   modalForWindow:theWindow
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- pixelsWideField
{
	return pixelsWideField;
}

- pixelsHighField
{
	return pixelsHighField;
}

- percentageWideField
{
	return percentageWideField;
}

- percentageHighField
{
	return percentageHighField;
}

- (void)awakeFromNib
{
	NSEnumerator *algorithmEnumerator = [algorithms objectEnumerator];
	PXScaleAlgorithm *algorithm;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[algorithmButton removeAllItems];
	
	while ( (algorithm = [algorithmEnumerator nextObject]) ) 
    {
		[algorithmButton addItemWithTitle:[algorithm name]];
    }
	if ([defaults objectForKey:PXSelectedScaleAlgorithmKey] )
    {
		[algorithmButton selectItemWithTitle:[defaults objectForKey:PXSelectedScaleAlgorithmKey]];
    }
	
	[self setAlgorithm:algorithmButton];
	newSize = [[canvasController canvas] size];
	[self synchronizeForms:self];
}

- (PXScaleAlgorithm *)currentAlgorithm
{
	return [algorithms objectAtIndex:[algorithmButton indexOfSelectedItem]];
}

- (IBAction)setAlgorithm:(id) sender
{
	static BOOL lastAlgorithmHadParameterView = YES;
	
	NSSize newBoxSize = [scaleParameterView frame].size;
	
	if ([[self currentAlgorithm] hasParameterView]) 
    {
		NSSize margins = [scaleParameterView contentViewMargins];
		newBoxSize.height = NSHeight([[[self currentAlgorithm] parameterView] frame]) + margins.height * 2;
    }
	else 
    {
		newBoxSize.height = 0;
    }
	
	NSRect newWindowFrame = [[self window] frame];
	newWindowFrame.size.height += newBoxSize.height - [scaleParameterView frame].size.height;
	if (![[self currentAlgorithm] hasParameterView] && lastAlgorithmHadParameterView) {
		newWindowFrame.size.height -= 8;
	}
	[[self window] setFrame:newWindowFrame display:YES animate:YES];
	
	if ([[self currentAlgorithm] hasParameterView]) {
		[scaleParameterView setContentView:[[self currentAlgorithm] parameterView]]; // Don't move this to the top of the method or it breaks.  No, I don't know why.
	}
	[scaleParameterView setFrameSize:newBoxSize];
	[algorithmInfoView setString:[[self currentAlgorithm] algorithmInfo]];
	
	lastAlgorithmHadParameterView = [[self currentAlgorithm] hasParameterView];
	
	[[NSUserDefaults standardUserDefaults] setObject:[[sender selectedItem] title] forKey:PXSelectedScaleAlgorithmKey];
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window]];
	[self close];
}

- (NSSize)directSizeInput
{
	NSSize oldSize = [[canvasController canvas] size];
	NSSize directSizeInput;
	float xScale = [[self percentageWideField] floatValue] / 100.0f;
	float yScale = [[self percentageHighField] floatValue] / 100.0f;
	
	directSizeInput.width = [[self pixelsWideField] floatValue];
	
	if (fabs(oldSize.width * xScale - newSize.width) > .01) 
    {
		directSizeInput.width = oldSize.width * xScale;
    }
	
	directSizeInput.height = [[self pixelsHighField] floatValue];
	
	if (fabs(oldSize.height * yScale - newSize.height) > .01) 
    {  
		directSizeInput.height = oldSize.height * yScale;
    }
	
	return directSizeInput;
}

- (IBAction)synchronizeForms:(id) sender
{
	NSSize oldSize = [[canvasController canvas] size];
	NSSize directSizeInput = [self directSizeInput];
	float xScale = [[self percentageWideField] floatValue] / 100.0f;
	float yScale = [[self percentageHighField] floatValue] / 100.0f;
	BOOL scaleProportionally = ([scaleProportionallyCheckbox state] == NSOnState);
	directSizeInput.width = [[self pixelsWideField] floatValue];
	
	if (fabs(oldSize.width * xScale - newSize.width) > .01) {
		directSizeInput.width = oldSize.width * xScale;
	}
	
	directSizeInput.height = [[self pixelsHighField] floatValue];
	
	if (fabs(oldSize.height * yScale - newSize.height) > .01) {
		directSizeInput.height = oldSize.height * yScale;
	}
	
	if (directSizeInput.width != 0 && directSizeInput.width != newSize.width) {
		if (scaleProportionally) {
			newSize.height = rintf(directSizeInput.width * oldSize.height / oldSize.width);
		} 
		else {
			newSize.height = directSizeInput.height;
		}
		newSize.width = directSizeInput.width;
	} 
	else if (directSizeInput.height != 0 && directSizeInput.height != newSize.height) {
		if (scaleProportionally) {
			newSize.width = rintf(directSizeInput.height * oldSize.width / oldSize.height);
		} else {
			newSize.width = directSizeInput.width;
		}
		newSize.height = directSizeInput.height;
	}
	
	if (newSize.width < 1) { // prevent making things 0 during proportional scaling
		newSize.width = 1;
	}
	if (newSize.height < 1) {
		newSize.height = 1;
	}
	[[self pixelsWideField] setFloatValue:newSize.width];
	[[self pixelsHighField] setFloatValue:newSize.height];
	[[self percentageWideField] setFloatValue:newSize.width / oldSize.width * 100.0f];
	[[self percentageHighField] setFloatValue:newSize.height / oldSize.height * 100.0f];
}

- (IBAction)updateToScalePropotionally:(id) sender
{
	if ([sender state] != NSOnState) 
		return;
	
	else 
    {
		NSSize directSizeInput = [self directSizeInput];
		NSSize oldSize = [[canvasController canvas] size];
		newSize.width = directSizeInput.height * oldSize.width / oldSize.height;
		newSize.height = directSizeInput.height;
		[self synchronizeForms:sender];
    }
}

- (IBAction)displayHelp:sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"scale" inBook:@"Pixen Help"];	
}

- (void)scaleCanvas:(PXCanvas *)canvas
{
	[canvas beginUndoGrouping]; {
//FIXME: move undo
	// Do we really have to deselect when we change size? We can't adapt?
	// Ohhhh, the memory cost. The pain.

	PXSelectionMask oldMask = malloc([canvas selectionMaskSize]);
	memcpy(oldMask, [canvas selectionMask], [canvas selectionMaskSize]);
	PXSelectionMask newMask = (PXSelectionMask)calloc(newSize.width * newSize.height, sizeof(BOOL));
	[canvas setLayers:[[canvas layers] deepMutableCopy] 
		   fromLayers:[canvas layers]
	  withDescription:NSLocalizedString(@"Set Layers", @"Set Layers")];
	//this seems wrong.  you'd think we'd want to use the actual old canvas size, but whatever...
	NSData *oldMaskData = [NSData dataWithBytesNoCopy:oldMask length:[canvas selectionMaskSize]];
	NSData *newMaskData = [NSData dataWithBytesNoCopy:newMask length:newSize.width * newSize.height * sizeof(BOOL)];
	[canvas setMaskData:newMaskData withOldMaskData:oldMaskData];
	[[self currentAlgorithm] scaleCanvas:[canvasController canvas] 
								  toSize:newSize];
	[canvas setHasSelection:NO];
	
	} [canvas endUndoGrouping:NSLocalizedString(@"Scale Canvas", @"Scale Canvas")];	
}

- (IBAction)scale:(id) sender
{
	if ( [[self currentAlgorithm] canScaleCanvas:[canvasController canvas] 
										  toSize:newSize]) 
    {
		[self scaleCanvas:[canvasController canvas]];
		[canvasController updateCanvasSize];
		[NSApp endSheet:[self window]];
		[self close];
    } 
	else 
    {
		NSBeep();
    }
	
	if (delegate)
	{
		[delegate performSelector:callback withObject:self withObject:[NSNumber numberWithBool:[[self currentAlgorithm] canScaleCanvas:[canvasController canvas] toSize:newSize]]];
	}
	delegate = nil;
	callback = NULL;
}

- (void)setDelegate:aDelegate withCallback:(SEL)aCallback
{
	delegate = aDelegate;
	callback = aCallback;
}

@end
