//
//  PXPaletteExporter.m
//  Pixen
//
//  Created by Andy Matuschak on 8/21/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPaletteExporter.h"
#import "OSPALWriter.h"
#import "OSJASCPALWriter.h"
#import "OSACTWriter.h"

@implementation PXPaletteExporter

+ types
{
	return [NSArray arrayWithObjects:PixenPaletteType, MicrosoftPaletteType, JascPaletteType, AdobePaletteType, nil];
}

- (void)dealloc
{
	[savePanel release];
	[super dealloc];
}

- (void)panelDidEnd:(NSSavePanel *)panel returnCode:(int)code contextInfo:(void *)info
{
	if (code == NSCancelButton) 
	{
		PXPalette_release(palette);
		return; 
	}
	NSString *type = [[(NSPopUpButton *)[panel accessoryView] selectedItem] title];
	if ([type isEqualToString:PixenPaletteType])
	{
		[NSKeyedArchiver archiveRootObject:PXPalette_dictForArchiving(palette) toFile:[panel filename]];
	}
	else
	{
		id writer = nil;
		if ([type isEqualToString:MicrosoftPaletteType]) { writer = [OSPALWriter sharedPALWriter]; }
		else if ([type isEqualToString:JascPaletteType]) { writer = [OSJASCPALWriter sharedJASCPALWriter]; }
		else if ([type isEqualToString:AdobePaletteType]) { writer = [OSACTWriter sharedACTWriter]; }
		if (writer == nil) { return; }
		id data = [writer palDataForPalette:palette];
		if (data == nil) { return; }
		[data writeToFile:[panel filename] atomically:YES];
	}
	PXPalette_release(palette);
}

- (void)typeChanged:sender
{
	NSString *type = [[(NSPopUpButton *)[savePanel accessoryView] selectedItem] title];
	id newString = [[[[savePanel filename] lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"."];
	if ([type isEqualToString:PixenPaletteType])
		newString = [newString stringByAppendingString:PXPaletteSuffix];
	else if ([type isEqualToString:MicrosoftPaletteType])
		newString = [newString stringByAppendingString:MicrosoftPaletteSuffix];
	else if ([type isEqualToString:JascPaletteType])
		newString = [newString stringByAppendingString:MicrosoftPaletteSuffix];
	else
		newString = [newString stringByAppendingString:AdobePaletteSuffix];
	[[savePanel valueForKey:@"_nameField"] setStringValue:newString]; // warning: private key!
}

- (void)runWithPalette:(PXPalette *)aPalette inWindow:(NSWindow *)window
{
	if (aPalette == NULL) { return; }
	palette = PXPalette_retain(aPalette);
	savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObjects:PXPaletteSuffix, MicrosoftPaletteSuffix, AdobePaletteSuffix, nil]];
	[savePanel setPrompt:@"Export"];
	NSPopUpButton *typePopup = [[[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 250, 40) pullsDown:NO] autorelease];
	[typePopup setTarget:self];
	[typePopup setAction:@selector(typeChanged:)];
	[typePopup addItemsWithTitles:[[self class] types]];
	[savePanel setAccessoryView:typePopup];
	[savePanel setCanSelectHiddenExtension:NO];
	[savePanel beginSheetForDirectory:nil file:palette->name modalForWindow:window modalDelegate:self didEndSelector:@selector(panelDidEnd:returnCode:contextInfo:) contextInfo:nil];
	[self typeChanged:self];
}

@end
