//
//  PXPaletteSelector.m
//  Pixen
//
//  Created by Andy Matuschak on 7/8/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPaletteSelector.h"
#import "PXCanvasDocument.h"
#import "PXCanvas.h"

@implementation PXPaletteSelector

- init
{
	[super init];
	palettes = (PXPalette **)malloc(sizeof(PXPalette *) * 20);
	memset((void *)palettes, 0, 20);
	return self;
}

- (void)dealloc
{
	free(palettes);
	[super dealloc];
}

- (void)setEnabled:(BOOL)enabled
{
	[selectionPopup setEnabled:enabled];
}

- (void)showPalette:(PXPalette *)pal
{
	for (id current in [[selectionPopup menu] itemArray])
	{
		if([[current representedObject] pointerValue] == pal)
		{
			[selectionPopup selectItem:current];
			return;
		}
	}
	for (id current in [[selectionPopup menu] itemArray])
	{
		if([[current title] isEqual:pal->name])
		{
			[selectionPopup selectItem:current];
			return;
		}
	}
}

- (PXPalette *)reloadDataExcluding:(PXCanvasDocument *)aDoc withCurrentPalette:(PXPalette *)currentPalette
{
	[selectionPopup removeAllItems];
	int index = 0;
	int i;
	for (i = 0; i < paletteCount; i++)
	{
		if(palettes[i] == currentPalette)
		{
			index = i;
		}
	}
	free(palettes);
	id docs = [NSMutableArray arrayWithArray:[[NSDocumentController sharedDocumentController] documents]];
	if(aDoc)
	{
		[docs removeObject:aDoc];
	}
//	int docPaletteCount = [docs count];	
	int docPaletteCount = 0;
	int userPaletteCount = PXPalette_getUserPalettes(NULL, 0);
	int sysPaletteCount = PXPalette_getSystemPalettes(NULL, 0);
	[selectionPopup setEnabled:YES];
	if(docPaletteCount == 0 && userPaletteCount == 0 && sysPaletteCount == 0)
	{
		[selectionPopup addItemWithTitle:NSLocalizedString(@"No Palettes", @"No Palettes")];
		[selectionPopup setEnabled:NO];
		paletteCount = 0;
	}
	paletteCount = docPaletteCount + userPaletteCount + sysPaletteCount;
	palettes = (PXPalette **)calloc(paletteCount, sizeof(PXPalette *));
	
	for (i = 0; i < docPaletteCount; i++)
	{
	//FIXME: no palette
/*	assert(0);
		PXCanvasDocument *doc = [docs objectAtIndex:i];
		PXPalette *pal = PXPalette_init(PXPalette_alloc());
		if([PXPalette_name(pal) isEqual:@""])
		{
			PXPalette_setName(pal, [doc displayName]);
		}
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:PXPalette_name(pal) action:@selector(selectionChanged:) keyEquivalent:@""] autorelease];
		[item setRepresentedObject:[NSValue valueWithPointer:pal]];
		[[selectionPopup menu] addItem:item];
		[item setTarget:self];
		palettes[i] = pal;*/
	}
	if((docPaletteCount > 0) && ((userPaletteCount > 0) || (sysPaletteCount > 0)))
	{
		[[selectionPopup menu] addItem:[NSMenuItem separatorItem]];
	}
	if(index >= paletteCount)
	{
		index = paletteCount - 1;
	}
	
	PXPalette_getUserPalettes(palettes, docPaletteCount);
	for (i = 0; i < userPaletteCount; i++)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:PXPalette_name(palettes[i + docPaletteCount]) action:@selector(selectionChanged:) keyEquivalent:@""] autorelease];
		[item setRepresentedObject:[NSValue valueWithPointer:palettes[i + docPaletteCount]]];
		[[selectionPopup menu] addItem:item];
		[item setTarget:self];
	}
	if((userPaletteCount > 0) && (sysPaletteCount > 0))
	{
		[[selectionPopup menu] addItem:[NSMenuItem separatorItem]];
	}
	if(index >= paletteCount)
	{
		index = paletteCount - 1;
	}
	
	PXPalette_getSystemPalettes(palettes, docPaletteCount + userPaletteCount);
	for (i = 0; i < sysPaletteCount; i++)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:PXPalette_name(palettes[i + docPaletteCount + userPaletteCount]) action:@selector(selectionChanged:) keyEquivalent:@""] autorelease];
		[item setRepresentedObject:[NSValue valueWithPointer:palettes[i + docPaletteCount + userPaletteCount]]];
		[[selectionPopup menu] addItem:item];
		[item setTarget:self];
	}
	//FIXME: this should do something about showing the document's palette
	if((docPaletteCount + sysPaletteCount) == 0)
	{
		return NULL;
	}
	else
	{
		return palettes[index];	
	}
}

- (IBAction)selectionChanged:sender
{
	int i;
	for (i = 0; i < paletteCount; i++)
	{
		if([[sender representedObject] pointerValue] == palettes[i])
		{
			if ([delegate respondsToSelector:@selector(paletteSelector:selectionDidChangeTo:)])
				[delegate paletteSelector:self selectionDidChangeTo:palettes[i]];
			return;
		}
	}
}

- (int)paletteCount
{
	return paletteCount;
}

- (PXPalette **)palettes
{
	return palettes;
}

@end
