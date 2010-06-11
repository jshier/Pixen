//
//  PXPanelManager.m
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


//  Created by Ian Henderson on 25.11.04.
//  Copyright 2004 Open Sword Group. All rights reserved.
//

#import "PXPanelManager.h"
#import "UKFeedbackProvider.h"
#import "PXWelcomeController.h"
#import "PXAboutController.h"
#import "PXToolPaletteController.h"
#import "PXToolPropertiesController.h"
#import "PXPreferencesController.h"
#import "PXInfoPanelController.h"
#import "PXPreviewController.h"
#import "PXSpriteSheetExporter.h"
#import "PXPalette.h"
#import "PXPaletteView.h"
#import "PXPaletteViewScrollView.h"
#import "PXPalettePanel.h"

@implementation PXPanelManager

static PXPanelManager *sharedManager = nil;

+(id) sharedManager
{
	if (sharedManager == nil) {
		sharedManager = [[self alloc] init];
	}
	return sharedManager;
}

- (id) init
{
	if ( ! (self = [super init] ) ) 
		return nil;
	
	sharedManager = self;
	provider = [[UKFeedbackProvider alloc] init];
	return self;
}

- (void)dealloc
{
	[provider release];
	[super dealloc];
}
- (void)restorePanelStates
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Open some panels if the user have let them open the last time
	if ( [defaults boolForKey:PXLeftToolPropertiesIsOpenKey] ) {
		[self showLeftToolProperties:self];
	}
	if ( [defaults boolForKey:PXRightToolPropertiesIsOpenKey] ) {
		[self showRightToolProperties:self];
	}
	
	if ( [defaults boolForKey:PXInfoPanelIsOpenKey] ) {
		[self showInfo:self];
	}
	
	if ( [defaults boolForKey:PXPreviewWindowIsOpenKey] ) {
		[self showPreviewPanel:self];
	}
	
	//Always display toolPanel
	[self showToolPalette:self];
	
	// Palette panels!
	int systemPalettesCount = PXPalette_getSystemPalettes(NULL, 0);
	PXPalette **systemPalettes = malloc(sizeof(PXPalette *) * systemPalettesCount);
	PXPalette_getSystemPalettes(systemPalettes, 0);
	int userPalettesCount = PXPalette_getUserPalettes(NULL, 0);
	PXPalette **userPalettes = malloc(sizeof(PXPalette *) * userPalettesCount);
	PXPalette_getUserPalettes(userPalettes, 0);
	NSArray *palettePanels = [defaults objectForKey:PXPalettePanelsKey];
	for (id current in palettePanels)
	{
		BOOL isSystemPalette = [[current objectForKey:PXPalettePanelIsSystemPaletteKey] boolValue];
		int index = [[current objectForKey:PXPalettePanelPaletteIndexKey] intValue];
		PXPalette *palette = NULL;
		if ((isSystemPalette && index >= systemPalettesCount) || (!isSystemPalette && index >= userPalettesCount))
		{
			palette = systemPalettes[0];
		}
		else
		{
			palette = (isSystemPalette ? systemPalettes : userPalettes)[[[current objectForKey:PXPalettePanelPaletteIndexKey] intValue]];
		}
		PXPalettePanel *panel = [[PXPalettePanel alloc] initWithPalette:palette];
		[panel setFrame:NSRectFromString([current objectForKey:PXPalettePanelFrameKey]) display:NO];
		[(PXPaletteViewScrollView *)[[panel paletteView] enclosingScrollView] setControlSize:[[current objectForKey:PXPalettePanelPaletteViewSizeKey] intValue]];
		[panel makeKeyAndOrderFront:self];
	}
	
	// make sure this gets document open/close notification
	[PXSpriteSheetExporter sharedSpriteSheetExporter];
}

- (void)archivePanelStates
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL boolTmp;
	
	//Panel leftToolPropertiesPanel
	boolTmp = [[self leftToolPropertiesPanel] isVisible];
	[defaults setBool:boolTmp forKey:PXLeftToolPropertiesIsOpenKey];
	
	//rightToolPropertiesPanel
	boolTmp= [[self rightToolPropertiesPanel] isVisible];
	[defaults setBool:boolTmp forKey:PXRightToolPropertiesIsOpenKey];
	
	//info Panel
	boolTmp = [[self infoPanel] isVisible];
	[defaults setBool:boolTmp forKey:PXInfoPanelIsOpenKey];
	
	// Popout color panels
	NSMutableArray *palettePanels = [NSMutableArray array];
	
	int systemPalettesCount = PXPalette_getSystemPalettes(NULL, 0);
	PXPalette **systemPalettes = malloc(sizeof(PXPalette *) * systemPalettesCount);
	PXPalette_getSystemPalettes(systemPalettes, 0);
	int userPalettesCount = PXPalette_getUserPalettes(NULL, 0);
	PXPalette **userPalettes = malloc(sizeof(PXPalette *) * userPalettesCount);
	PXPalette_getUserPalettes(userPalettes, 0);
	
	for (id current in [NSApp windows])
	{
		if (![current isKindOfClass:[PXPalettePanel class]]) { continue; }
		if (![current isVisible]) { continue; }
		NSMutableDictionary *panelInfo = [NSMutableDictionary dictionary];
		[panelInfo setObject:NSStringFromRect([current frame]) forKey:PXPalettePanelFrameKey];
		[panelInfo setObject:[NSNumber numberWithInt:[[(PXPalettePanel *)current paletteView] controlSize]] forKey:PXPalettePanelPaletteViewSizeKey];
		
		// Now we've got to identify the palette and see how we're going to classify it.
		PXPalette *palette = [[(PXPalettePanel *)current paletteView] palette];
		int i;
		BOOL found = NO;
		for (i = 0; i < systemPalettesCount; i++)
		{
			if (systemPalettes[i] == palette)
			{
				found = YES;
				[panelInfo setObject:[NSNumber numberWithBool:YES] forKey:PXPalettePanelIsSystemPaletteKey];
				[panelInfo setObject:[NSNumber numberWithInt:i] forKey:PXPalettePanelPaletteIndexKey];
				break;
			}
		}
		if (!found) // Check the user palettes.
		{
			for (i = 0; i < userPalettesCount; i++)
			{
				if (userPalettes[i] == palette)
				{
					found = YES;
					[panelInfo setObject:[NSNumber numberWithBool:NO] forKey:PXPalettePanelIsSystemPaletteKey];
					[panelInfo setObject:[NSNumber numberWithInt:i] forKey:PXPalettePanelPaletteIndexKey];
				}
			}
			if (!found) // Okay, if it's -still- not found, we skip it.
			{
				continue;
			}
		}
		[palettePanels addObject:panelInfo];
	}
	[defaults setObject:palettePanels forKey:PXPalettePanelsKey];
	free(systemPalettes);
	if (userPalettes)
		free(userPalettes);
	
	[defaults synchronize];
}

- (void)show:panel
{
	[panel makeKeyAndOrderFront:self];
}

- (void)hide:panel
{
	[panel performClose:self];
}

- (void)toggle:panel
{
	if ([panel isVisible]) {
		[self hide:panel];
	} else {
		[self show:panel];
	}
}

- (NSPanel *)leftToolPropertiesPanel
{
	return [[PXToolPropertiesController leftToolPropertiesController] propertiesPanel];
}

- (NSPanel *)rightToolPropertiesPanel
{
	return [[PXToolPropertiesController rightToolPropertiesController] propertiesPanel];
}

- (NSPanel *)preferencesPanel
{
	return (NSPanel *)[[PXPreferencesController sharedPreferencesController] window];
}

- (NSPanel *)infoPanel
{
	return [[PXInfoPanelController sharedInfoPanelController] infoPanel];
}

- (NSPanel *)welcomePanel
{
	return (NSPanel *)[[PXWelcomeController sharedWelcomeController] window];
}

- (NSPanel *)toolPalettePanel
{
	return [[PXToolPaletteController sharedToolPaletteController] toolPanel];
}

- (NSPanel *)spriteSheetExporterPanel
{
	return (NSPanel *)[[PXSpriteSheetExporter sharedSpriteSheetExporter] window];
}

- (NSPanel *)previewPanel
{
	return (NSPanel *)[[PXPreviewController sharedPreviewController] window];
}

- (IBAction)showFeedback: (id)sender
{
	[provider orderFrontFeedbackWindow:self];
}

- (IBAction)showLeftToolProperties: (id)sender
{
	[self show:[self leftToolPropertiesPanel]];
}

- (IBAction)toggleLeftToolProperties: (id)sender
{
	[self toggle:[self leftToolPropertiesPanel]];
}

- (IBAction)showRightToolProperties: (id)sender
{
	[self show:[self rightToolPropertiesPanel]];
}

- (IBAction)toggleRightToolProperties: (id)sender
{
	[self toggle:[self rightToolPropertiesPanel]];
}

- (IBAction)showPreferences: (id)sender
{
	[self show:[self preferencesPanel]];
}

- (IBAction)showInfo: (id)sender
{
	[self show:[self infoPanel]];
}

- (IBAction)showWelcome: (id)sender
{
	[[self welcomePanel] center];
	[self show:[self welcomePanel]];
}

- (IBAction)showAbout: (id)sender
{
	[[PXAboutController sharedAboutController] showPanel:self];
}

- (IBAction)showToolPalette: (id)sender
{
	[self show:[self toolPalettePanel]];
}

- (IBAction)showSpriteSheetExporter: (id)sender
{
  [[PXSpriteSheetExporter sharedSpriteSheetExporter] recacheDocumentRepresentations];
	[self show:[self spriteSheetExporterPanel]];
}

- (IBAction)showPreviewPanel: (id)sender
{
	[self show:[self previewPanel]];
}

@end
