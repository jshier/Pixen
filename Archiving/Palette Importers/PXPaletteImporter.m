//
//  PXPaletteImporter.m
//  Pixen
//
//  Created by Andy Matuschak on 8/22/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPaletteImporter.h"
#import "OSPALReader.h"
#import "OSJASCPALReader.h"
#import "OSACTReader.h"
#import "PathUtilities.h"
#import "PXPalette.h"

@implementation PXPaletteImporter

- (void)importPaletteAtPath:(NSString *)path
{
	id reader = nil;
	if ([[path pathExtension] isEqualToString:MicrosoftPaletteSuffix])
	{
		id data = [NSData dataWithContentsOfFile:path];
		if (!data)
		{
			[NSException raise:@"OSFileError" format:@"Couldn't open %@ for reading", path];
			return;
		}
		
		// We have to determine now if it's a JASC palette or a Microsoft palette. JASC palettes start with "JASC-PAL", so we check against that.
		const unsigned char *bytes = [data bytes];
		if (bytes[0] == 'J' && bytes[1] == 'A' && bytes[2] == 'S' && bytes[3] == 'C' && bytes[4] == '-' && bytes[5] == 'P' && bytes[6] == 'A' && bytes[7] == 'L')
		{
			reader = [OSJASCPALReader sharedJASCPALReader];
		}
		else
		{
			reader = [OSPALReader sharedPALReader];
		}
	}
	else if ([[path pathExtension] isEqualToString:AdobePaletteSuffix])
	{
		reader = [OSACTReader sharedACTReader];
	}
	
	NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
	NSString *base = [NSString stringWithString:name];
	int i = 2, j;
	
	// First make the name not conflict with system palettes
	NSUInteger systemPaletteCount = PXPalette_getSystemPalettes(NULL, 0);
	PXPalette **systemPalettes = malloc(sizeof(PXPalette *) * systemPaletteCount);
	PXPalette_getSystemPalettes(systemPalettes, 0);
	id names = [NSMutableArray array];
	for (j = 0; j < systemPaletteCount; j++)
	{
		[names addObject:PXPalette_name(systemPalettes[j])];
	}
	free(systemPalettes);
	while ([names containsObject:name])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	
	// Then user palettes.
	while([[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	NSString *finalPath = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix];
	
	PXPalette *newPal = NULL;
	if (reader) // If we've got a reader, we've got to import the format first.
	{
		newPal = [reader paletteWithData:[NSData dataWithContentsOfFile:path]];
	}
	else // It must be a pxpalette.
	{
		newPal = PXPalette_initWithDictionary(PXPalette_alloc(), [NSKeyedUnarchiver unarchiveObjectWithFile:path]);
	}
	
	PXPalette_setName(newPal, name);
	newPal->isSystemPalette = NO;
	newPal->canSave = YES;
	[NSKeyedArchiver archiveRootObject:PXPalette_dictForArchiving(newPal) toFile:finalPath];
	PXPalette_release(newPal);
}

- (void)panelDidEnd:(NSOpenPanel *)panel returnCode:(NSInteger)code contextInfo:(void *)info
{
	if (code == NSCancelButton) { return; }
	for (id current in [panel filenames])
	{
		[self importPaletteAtPath:current];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName object:self];
}

- (void)runInWindow:(NSWindow *)window
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setPrompt:@"Install"];
	[openPanel setTitle:@"Install"];
	id types = [NSArray arrayWithObjects:PXPaletteSuffix, MicrosoftPaletteSuffix, AdobePaletteSuffix, nil];
	if (window)
	{
		[openPanel beginSheetForDirectory:nil file:nil types:types modalForWindow:window modalDelegate:self didEndSelector:@selector(panelDidEnd:returnCode:contextInfo:) contextInfo:nil];
	}
	else
	{
		NSInteger code = [openPanel runModalForTypes:types];
		[self panelDidEnd:openPanel returnCode:code contextInfo:nil];
	}
}

@end
