//
//  PXColorPicker.m
//  PXColorPicker
//
//  Created by Andy Matuschak on 7/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXColorPicker.h"
#import "PXPaletteView.h"
#import "PXPaletteSelector.h"
#import "PXCanvas.h"
#import "PXCanvasDocument.h"
#import "PXPalettePanel.h"
#import "PXNamePrompter.h"
#import "PathUtilities.h"
#import "PXPaletteViewScrollView.h"
#import "PXPaletteExporter.h"
#import "PXPaletteImporter.h"

int kPXColorPickerMode = 23421337;

@implementation PXColorPicker

- initWithPickerMask:(NSUInteger)mask colorPanel:(NSColorPanel *)owningColorPanel
{
	if (!(mask & NSColorPanelRGBModeMask))
	{
		// We only support RGB mode.
		return nil;
	}
	[super initWithPickerMask:mask colorPanel:owningColorPanel];
	[NSBundle loadNibNamed:@"PXColorPicker" owner:self];
	[gearMenu setImage:[NSImage imageNamed:@"actiongear"]];
	[gearMenu setEnabled:YES];
	icon = [[NSImage imageNamed:@"colorpalette"] retain];
	[paletteView setDelegate:self];
	namePrompter = [[PXNamePrompter alloc] init];
	[namePrompter setDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentAdded:) name:PXDocumentOpenedNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentClosed:) name:PXDocumentWillCloseNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged:) name:PXPaletteChangedNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged:) name:PXUserPalettesChangedNotificationName object:nil];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:PXColorPickerPaletteViewSizeKey] == nil)
		[[NSUserDefaults standardUserDefaults] setInteger:NSRegularControlSize forKey:PXColorPickerPaletteViewSizeKey];
	[(PXPaletteViewScrollView *)([paletteView enclosingScrollView]) setControlSize:[[NSUserDefaults standardUserDefaults] integerForKey:PXColorPickerPaletteViewSizeKey]];
	
	return self;
}

- (void)dealloc
{
	[icon release];
	[namePrompter release];
	[super dealloc];
}

- (void)alphaControlAddedOrRemoved:(id)sender {}
- (void)attachColorList:(NSColorList *)colorList {}
- (void)detachColorList:(NSColorList *)colorList {}

- (void)paletteViewSizeChangedTo:(NSControlSize)size
{
	[[NSUserDefaults standardUserDefaults] setInteger:size forKey:PXColorPickerPaletteViewSizeKey];
}

- (IBAction)installPalette:sender
{
	PXPaletteImporter *importer = [[PXPaletteImporter alloc] init];
	[importer runInWindow:[self colorPanel]];
    [importer release];
}

- (IBAction)exportPalette:sender
{
	PXPaletteExporter *exporter = [[PXPaletteExporter alloc] init];
	[exporter runWithPalette:[paletteView palette] inWindow:[self colorPanel]];
    [exporter release];
}

- (void)setColor:(NSColor *)aColor
{

}

- (void)useColorAtIndex:(unsigned)index event:(NSEvent *)e
{
	PXPalette *palette = [paletteView palette];
	[[self colorPanel] setShowsAlpha:YES];
	[[self colorPanel] setColor:PXPalette_colorAtIndex(palette, index)];
}

- (NSImage *)provideNewButtonImage
{
	return icon;
}

- (void)showPalette:(PXPalette *)palette
{
	PXPalette *currentPalette = palette;
	if ([paletteView palette] != palette)
	{
		[paletteView setPalette:palette];
	}
	if(currentPalette)
	{
		[paletteSelector showPalette:palette];
	}
	[gearMenu setEnabled:YES];
}

- (void)reloadDataExcluding:aDoc
{
	PXPalette *palette = [paletteView palette];
	PXPalette *newPalette = [paletteSelector reloadDataExcluding:aDoc withCurrentPalette:palette];
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

- (void)reloadData
{
	[self reloadDataExcluding:nil];
}

- (void)paletteSelector:(PXPaletteSelector *)selector selectionDidChangeTo:(PXPalette *)palette
{
	[self showPalette:palette];
}

- (void)insertNewButtonImage:(NSImage *)newButtonImage in:(NSButtonCell *)buttonCell
{
	[buttonCell setImage:newButtonImage];
}

- (void)setMode:(NSColorPanelMode)mode { }

- (NSView *)provideNewView:(BOOL)initialRequest
{
	[self reloadData];
	return pickerView;
}

- (NSString *)_buttonToolTip
{
	return @"Pixen Colors";
}

- (NSString *)_buttonImageToolTip
{
	return @"Pixen Colors";
}

- (void)viewSizeChanged:sender
{ 
	[pickerView setFrameOrigin:NSZeroPoint];
}

- (NSColorPanelMode)currentMode
{
	return kPXColorPickerMode;
}

- (BOOL)supportsMode:(NSColorPanelMode)mode
{
	return kPXColorPickerMode == mode;
}

- (void)reloadDataAndShow:(PXPalette *)pal
{
	[self reloadData];
	[self showPalette:pal];
}
- (void)reloadDataAndShowCanvas:(PXCanvas *)canvas
{
	[self reloadData];
	//FIXME: find the palette
	PXPalette *pal = PXPalette_init(PXPalette_alloc());
	[self showPalette:pal];
}


- (void)documentAdded:(NSNotification *)notification
{
	[self reloadDataAndShowCanvas:[[notification object] canvas]];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	if (![paletteView palette] || !PXPalette_isDocumentPalette([paletteView palette])) { return; }
	id object = [notification object];
	if ([[object delegate] respondsToSelector:@selector(document)] && [[[object delegate] document] respondsToSelector:@selector(canvas)]) {
		[self reloadDataAndShowCanvas:[[[object delegate] document] canvas]];
	}
}

- (void)documentClosed:(NSNotification *)notification
{
	[self reloadDataExcluding:[notification object]];
}

- (void)paletteChanged:(NSNotification *)notification
{
	[self reloadData];
}

- (IBAction)popOut:sender
{
	[PXPalettePanel popWithPalette:[paletteView palette] fromWindow:[self colorPanel]];
}

- (IBAction)displayHelp:sender
{
    [[NSHelpManager sharedHelpManager] openHelpAnchor:@"workingwithpalettes" inBook:@"Pixen Help"];
}

- (void)prompter:aPrompter didFinishWithName:aName context:context
{
	NSUInteger systemPaletteCount = PXPalette_getSystemPalettes(NULL, 0);
	PXPalette **systemPalettes = malloc(sizeof(PXPalette *) * systemPaletteCount);
	PXPalette_getSystemPalettes(systemPalettes, 0);
	NSUInteger j;
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
	
	PXPalette_setName([paletteView palette], aName);
	[self reloadDataAndShow:[paletteView palette]];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName object:self];
}

- (IBAction)renamePalette:sender
{
	PXPalette *palette = [paletteView palette];
	[namePrompter promptInWindow:[self colorPanel] context:NULL promptString:[NSString stringWithFormat:NSLocalizedString(@"Rename Palette %@", @"Rename Palette%@"), palette->name] defaultEntry:palette->name];
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
        //FIXME: Handle error.
		[[NSFileManager defaultManager] removeItemAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:[paletteView palette]->name] stringByAppendingPathExtension:PXPaletteSuffix] error:NULL];
		[self reloadData];
		[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName object:self];
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
	[alert beginSheetModalForWindow:[self colorPanel] modalDelegate:self didEndSelector:@selector(deleteSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)duplicatePalette:sender
{
	PXPalette *newPal = PXPalette_copy([paletteView palette]);
	newPal->isSystemPalette = NO;
	newPal->canSave = NO;
	NSString *base = [NSString stringWithFormat:@"%@ Copy", newPal->name];
//FIXME: might not work for other languages
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

- (BOOL)validateMenuItem:(id)item
{
	if([item action] == @selector(renamePalette:))
	{
		return ([paletteView palette]->canSave);
	}
	if([item action] == @selector(deletePalette:))
	{
		return ([paletteView palette]->canSave);
	}
	return YES;
}

@end
