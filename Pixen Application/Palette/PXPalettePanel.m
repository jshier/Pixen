//
//  PXPalettePanel.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.12.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPalettePanel.h"
#import "PXPalettePanelPaletteView.h"
#import "PXPaletteSelector.h"
#import "PXCanvasDocument.h"
#import "PXAnimationDocument.h"
#import "PXCanvas.h"
#import "PXToolSwitcher.h"
#import "PXToolPaletteController.h"
#import "PXNamePrompter.h"
#import "PathUtilities.h"
#import "PXPaletteExporter.h"
#import "PXPaletteImporter.h"

@implementation PXPalettePanel

+ popWithPalette:(PXPalette *)pal fromWindow:(NSWindow *)window
{
	id panel = [[self alloc] initWithPalette:pal];
	static NSPoint previousPoint = {0, 0};
	static NSWindow *previousWindow = nil;
	NSPoint topLeft = NSMakePoint(NSMaxX([window frame]), NSMaxY([window frame]));
	if(previousWindow == window)
	{
		topLeft = previousPoint;
	}
	previousWindow = window;
	[panel setFrame:[window frame] display:NO];
	previousPoint = [panel cascadeTopLeftFromPoint:topLeft];
	[panel makeKeyAndOrderFront:self];
	return panel;
}

- initWithPalette:(PXPalette *)pal
{
	[super initWithContentRect:NSMakeRect(0, 0, 270, 283) styleMask:NSUtilityWindowMask | NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentAdded:) name:PXDocumentOpenedNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentClosed:) name:PXDocumentWillCloseNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged:) name:PXPaletteChangedNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged:) name:PXUserPalettesChangedNotificationName object:nil];
	[NSBundle loadNibNamed:@"PXPalettePanel" owner:self];
	[gearMenu setImage:[NSImage imageNamed:@"actiongear"]];
	[self setContentView:contents];
	namePrompter = [[PXNamePrompter alloc] init];
	[namePrompter setDelegate:self];
	[paletteView setDelegate:self];
	[self reloadDataAndShow:pal];
	return self;
}

- (IBAction)popOut:sender
{
	[[self class] popWithPalette:palette fromWindow:self];
}

- (PXPalettePanelPaletteView *)paletteView
{
	return paletteView;
}

- (void)reloadDataAndShow:(PXPalette *)pal
{
	[self reloadData];
	[self showPalette:pal];
}

- (void)documentAdded:(NSNotification *)notification
{
	[self reloadData];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	[self reloadData];
}

- (void)documentClosed:(NSNotification *)notification
{
	//FIXME: palette panels need a canvas reference, probably
	id canvas = nil;
	if([notification object] && ([[notification object] canvas] == canvas))
	{
		[self close];
		return;
	}
	[self reloadData];
}

- (void)reloadData
{
	PXPalette *newPalette = [paletteSelector reloadDataExcluding:nil withCurrentPalette:palette];
	if (palette == NULL) { [self showPalette:newPalette]; return; }
	NSUInteger paletteCount = [paletteSelector paletteCount];
	PXPalette **palettes = [paletteSelector palettes];
	int i;
	for (i = 0; i < paletteCount; i++)
	{
		if (palette == palettes[i] || [palette->name isEqualToString:palettes[i]->name])
		{
			[self showPalette:palette];
			return;
		}
	}
	[self showPalette:newPalette];	
}

- (void)paletteSelector:(PXPaletteSelector *)selector selectionDidChangeTo:(PXPalette *)pal
{
	[self showPalette:pal];
}

- (void)paletteChanged:(NSNotification *)notification
{
	[self reloadData];
}

- (void)showPalette:(PXPalette *)pal
{
	if (palette == pal) {
		return;
	}
	palette = pal;
	[self setTitle:palette->name];
	[paletteView setDocument:nil];
	[paletteView setPalette:palette];
	[paletteSelector showPalette:palette];
}

- (IBAction)displayHelp:sender
{
    [[NSHelpManager sharedHelpManager] openHelpAnchor:@"workingwithpalettes" inBook:@"Pixen Help"];
}

- (void)useColorAtIndex:(unsigned)index event:(NSEvent *)e
{
	PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	if([e buttonNumber] == 1 || ([e modifierFlags] & NSControlKeyMask))
	{
		switcher = [[PXToolPaletteController sharedToolPaletteController] rightSwitcher];
	}
	[switcher setColor:PXPalette_colorAtIndex(palette, index)];
}

- (IBAction)renamePalette:sender
{	
	[namePrompter promptInWindow:self context:NULL promptString:[NSString stringWithFormat:NSLocalizedString(@"Rename Palette %@", @"Rename Palette%@"), palette->name] defaultEntry:palette->name];
}

- (void)prompter:aPrompter didFinishWithName:aName context:context
{
	NSUInteger systemPaletteCount = PXPalette_getSystemPalettes(NULL, 0);
	PXPalette **systemPalettes = malloc(sizeof(PXPalette *) * systemPaletteCount);
	PXPalette_getSystemPalettes(systemPalettes, 0);
	int j;
	for (j = 0; j < systemPaletteCount; j++)
	{
		if ([aName isEqualToString:PXPalette_name(systemPalettes[j])])
		{
			[[NSAlert alertWithMessageText:NSLocalizedString(@"ALREADY_SYSTEM_PALETTE", @"There is already a system palette by that name.") defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
			free(systemPalettes);
			return;
		}
	}
	free(systemPalettes);

	PXPalette_setName(palette,aName);
	[self reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName object:self];
}

- (IBAction)newPalette:sender
{
	PXPalette *newPal = PXPalette_initWithoutBackgroundColor(PXPalette_alloc());
	newPal->isSystemPalette = NO;
	newPal->canSave = YES;
	NSString *base = NSLocalizedString(@"Untitled Palette", @"Untitled Palette");
	NSString *name = base;
	int i = 2;
	while([[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	PXPalette_setName(newPal, name);
	[self reloadDataAndShow:newPal];
	PXPalette_release(newPal);
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName object:self];
}

- (void)deleteSheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
	{
		[[NSFileManager defaultManager] removeItemAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:[paletteView palette]->name] stringByAppendingPathExtension:PXPaletteSuffix] error:NULL];
		[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName object:self];
		[self reloadData];
	}
}

- (IBAction)deletePalette:sender
{
	NSString *name = [paletteView palette]->name;
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"DELETE")] setKeyEquivalent:@""];
	NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
	[button setKeyEquivalent:@"\r"];
	[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Really delete palette %@?", @"PALETTE_DELETE_PROMPT"), name]];
	[alert setInformativeText:NSLocalizedString(@"This operation cannot be undone.", @"BACKGROUND_DELETE_INFORMATIVE_TEXT")];
	[alert beginSheetModalForWindow:self modalDelegate:self didEndSelector:@selector(deleteSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)duplicatePalette:sender
{
	PXPalette *newPal = PXPalette_copy(palette);
	newPal->isSystemPalette = NO;
	newPal->canSave = NO;
//FIXME: might not work for other languages
	NSString *base = [NSString stringWithFormat:@"%@ Copy", newPal->name];
	if([newPal->name rangeOfString:@" Copy"].location != NSNotFound)
	{
		base = [newPal->name substringToIndex:NSMaxRange([newPal->name rangeOfString:@" Copy"])];
	}
	NSString *name = base;
	int i = 2;
	while([[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	PXPalette_setName(newPal, name);
	newPal->canSave = YES;
	PXPalette_setName(newPal, name);
	[self reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName object:self];
	[self showPalette:newPal];
	PXPalette_release(newPal);
}

- (IBAction)installPalette:sender
{
	id importer = [[PXPaletteImporter alloc] init];
	[importer runInWindow:self];
}

- (IBAction)exportPalette:sender
{
	id exporter = [[PXPaletteExporter alloc] init];
	[exporter runWithPalette:palette inWindow:self];
}

- (BOOL)validateMenuItem:(id)item
{
	if([item action] == @selector(renamePalette:))
	{
		return (palette->canSave);
	}
	if([item action] == @selector(deletePalette:))
	{
		return (palette->canSave);
	}
	return YES;
}

@end
