//
//  PXLayerDetailsView.m
//  Pixen-XCode

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


//  Created by Joe Osborn on Thu Feb 05 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXLayerDetailsView.h"
#import "PXLayer.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_CopyPaste.h"
#import "PXCanvas_Modifying.h"
#import "PXNotifications.h"
#import "PXLayerTextField.h"
#import "PXNSImageView.h"
#import "PXLayerController.h"

#import <Foundation/NSNotification.h>


@implementation PXLayerDetailsView

-(id) initWithLayer:(PXLayer *)aLayer
{
	if ( ! (self = [super init] ) ) 
		return nil;
	
	[NSBundle loadNibNamed:@"PXLayerDetailsView" owner:self];
    [self setAutoresizesSubviews:NO];
	[self addSubview:view];
	[self setLayer:aLayer];
	[thumbnail setEditable:NO];
	isHidden = YES;
	return self;
}

- (void)setFrame:(NSRect)newFrame
{
	[super setFrame:newFrame];
	[view setFrameSize:[self frame].size];
}

- (void)resizeWithOldSuperviewSize:(NSSize)size
{
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] frame]), NSHeight([self frame]))];
}

- (void)resizeSubviewsWithOldSize:(NSSize)size
{
	[view setFrameSize:[self frame].size];
}

- opacityText
{
	return opacityText;
}

- (NSTextField *)name
{
	return name;
}

- layer
{
	return layer;
}

- (void)focusOnName
{
	[[self window] makeKeyAndOrderFront:nil];
	[name useEditAppearance];
	[[self window] makeFirstResponder:name];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- degreeString
{
	UniChar degree[] = { 0x00B0 };
	return [NSString stringWithCharacters:degree length:1];
}

- (void)setLayer:(PXLayer *)aLayer
{
	//set preview, name field, and other state
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc removeObserver:self];

	layer = aLayer;

	if(layer)
	{
		NSMenu *menu = [[[NSMenu alloc] initWithTitle:NSLocalizedString(@"Layer", @"Layer")] autorelease];
		NSMenuItem *item;
		
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:NSLocalizedString(@"Delete", @"Delete")];
		[item setAction:@selector(delete:)];
    [item setKeyEquivalent:[NSString stringWithCharacters:(const unichar[]){NSDeleteCharacter} length:1]];
    [item setKeyEquivalentModifierMask:0];
		[item setTarget:self];
		[menu addItem:item];
		
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:NSLocalizedString(@"Duplicate", @"Duplicate")];
		[item setAction:@selector(duplicate:)];
		[item setTarget:self];
		[menu addItem:item];
		
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:NSLocalizedString(@"Merge Down", @"Merge Down")];
		[item setAction:@selector(mergeDown:)];
		[item setTarget:self];
		[menu addItem:item];
		
		[menu addItem:[NSMenuItem separatorItem]];
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:NSLocalizedString(@"Cut", @"Cut")];
		[item setAction:@selector(cutLayer:)];
		[item setTarget:self];
		[menu addItem:item];
		
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:NSLocalizedString(@"Copy", @"Copy")];
		[item setAction:@selector(copyLayer:)];
		[item setTarget:self];
		[menu addItem:item];		
		
		NSMenu *subMenu = [[[NSMenu alloc] initWithTitle:NSLocalizedString(@"Transform Layer", @"Transform Layer")] autorelease];
		NSMenuItem *subMenuItem = [[[NSMenuItem alloc] init] autorelease];
		[subMenuItem setTitle:NSLocalizedString(@"Transform Layer", @"Transform Layer")];
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:subMenuItem];
		[menu setSubmenu:subMenu forItem:subMenuItem];
		
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:NSLocalizedString(@"Flip Horizontally", @"Flip Horizontally")];
		[item setAction:@selector(flipLayerHorizontally:)];
		[item setTarget:self];
		[subMenu addItem:item];
		
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:NSLocalizedString(@"Flip Vertically", @"Flip Vertically")];
		[item setAction:@selector(flipLayerVertically:)];
		[item setTarget:self];
		[subMenu addItem:item];
		
		[subMenu addItem:[NSMenuItem separatorItem]];
		
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 90%@ Left", @"Rotate 90%@ Left"), [self degreeString]]];
		[item setAction:@selector(rotateLayerCounterclockwise:)];
		[item setTarget:self];
		[subMenu addItem:item];

		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 90%@ Right", @"Rotate 90%@ Right"), [self degreeString]]];
		[item setAction:@selector(rotateLayerClockwise:)];
		[item setTarget:self];
		[subMenu addItem:item];
		
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 180%@", @"Rotate 180%@"), [self degreeString]]];
		[item setAction:@selector(rotateLayer180:)];
		[item setTarget:self];
		[subMenu addItem:item];
		
		[view setMenu:menu];
		[name setMenu:menu];
		[opacity setMenu:menu];
		[visibility setMenu:menu];
		[opacityText setMenu:menu];
		[thumbnail setMenu:menu];
		
		[name setStringValue:[layer name]];
		[opacity setFloatValue:[layer opacity]];
		[self updatePreview:nil];
		[visibility setState:[layer visible]];
		[nc addObserver:self 
			   selector:@selector(updatePreview:) 
				   name:PXCanvasChangedNotificationName
				 object:[layer canvas]];
		
		[nc addObserver:self selector:@selector(paletteChanged:) name:PXPaletteChangedNotificationName object:nil];
	}
	[self setNeedsDisplay:YES];
}

- (void)paletteChanged:note
{
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	// I'm so sorry. This is so bad.
	if ([anItem action] == @selector(mergeDown:)) {
		id layers = [[layerController canvas] layers];
		return [layers count] > 1 && [layers objectAtIndex:0] != layer;
	} else {
		return YES;
	}
}

- (void)updatePreview:(NSNotification* )notification
{
	NSRect rect= [[[notification userInfo] objectForKey:PXChangedRectKey] rectValue];
	[thumbnail setImage:[layer displayImage]];
	if(![[notification userInfo] objectForKey:PXChangedRectKey])
	{
		[thumbnail setNeedsDisplay:YES];
	}
	else
	{
		NSRect functionalRect = [thumbnail functionalRect];
		float scalingFactor = NSWidth(functionalRect) / [layer size].width;
		[thumbnail setNeedsDisplayInRect:NSMakeRect(NSMinX(rect) * scalingFactor + NSMinX(functionalRect), NSMinY(rect) * scalingFactor + NSMinY(functionalRect), NSWidth(rect) * scalingFactor, NSHeight(rect) * scalingFactor)];
	}	
}

- (IBAction)visibilityDidChange:(id) sender
{
	[layer setVisible:([sender state] == NSOnState) ? YES : NO];
	[[layer canvas] changed];
}


- (BOOL)isHidden
{
	if([super respondsToSelector:@selector(isHidden)])
    {
		return [super isHidden];
    }
	return isHidden;
}

- (void)setHidden:(BOOL)newHidden
{
	if([self isHidden] == newHidden) 
	{
		return; 
	}
	
	if([super respondsToSelector:@selector(setHidden:)]) 
	{
		[super setHidden:newHidden]; 
	}
	
	isHidden = newHidden;
	[self updatePreview:nil];
}

- (void)rightMouseDown:(NSEvent *)event
{
	[view rightMouseDown:event];
}

- (IBAction)opacityDidChange:(id)sender
{
	[opacity setFloatValue:[sender floatValue]];
	[layer setOpacity:[sender floatValue]];
	[[layer canvas] changed];
}

- (IBAction)nameDidChange:(id)sender
{
	[(PXLayer *)layer setName:[name stringValue]];
}

- (void)setLayerController:cont
{
	layerController = cont;
}

- (void)delete:(id) sender
{
	[layerController removeLayerObject:layer];
}

- (void)duplicate:(id) sender
{
	[layerController duplicateLayerObject:layer];
}

- (void)mergeDown:(id) sender
{
	[layerController mergeDownLayerObject:layer];
}

- (void)cutLayer:sender
{
	[[layer canvas] cutLayer:layer];
}

- (void)copyLayer:sender
{
	[[layer canvas] copyLayer:layer toPasteboard:[NSPasteboard generalPasteboard]];
}

- (void)rotateLayerCounterclockwise:sender
{
	[[layer canvas] rotateLayer:layer byDegrees:90];
}

- (void)rotateLayerClockwise:sender
{
	[[layer canvas] rotateLayer:layer byDegrees:270];
}

- (void)rotateLayer180:sender
{
	[[layer canvas] rotateLayer:layer byDegrees:180];
}

- (IBAction)flipLayerHorizontally:(id) sender
{		
	[[layer canvas] flipLayerHorizontally:layer];
}

- (IBAction)flipLayerVertically:(id) sender
{
	[[layer canvas] flipLayerVertically:layer];
}

@end
