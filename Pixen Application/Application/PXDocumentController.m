//
//  PXDocumentController.m
//  Pixen-XCode
//
// Copyright (c) 2003,2004 Open Sword Group

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

//  Author : Andy Matuschak 
//  Created  on Tue Dec 09 2003.




//This class is the application delegate.
//it respond as delegate for  applicationShouldOpenUntitledFile: 
//applicationDidFinishLaunching: applicationWillTerminate: 
//methods (see NSApplication documentation)
// it also responds to message from menu (only menu ??) 
// TODO : finish that 

#import "PXDocumentController.h"
#import "PXDocument.h"
#import "PXAboutController.h"
#import "PXWelcomeController.h"
#import "PXPreferencesController.h"
#import "PXCanvasWindowController.h"
#import "PXCanvasWindowController_IBActions.h"
#import "PXCanvasController.h"
#import "PXCanvasDocument.h"
#import "PXAnimationDocument.h"
#import "PXLayer.h"
#import "PXCanvas.h"
#import "PXPalette.h"
#import "PXPanelManager.h"
#import "PathUtilities.h"
#import "PXToolPaletteController.h"
#import "PXToolSwitcher.h"
#import "PXTool.h"
#import "PXCanvasWindowController.h"
#import "PXCanvasView.h"
#import "PXGifImporter.h"
#import "PXCel.h"
#import "PXAnimation.h"
#import "PXPaletteImporter.h"

#import "PXCanvas_ImportingExporting.h"

#import <Foundation/NSFileManager.h>
#import <AppKit/NSAlert.h>

/***********************************/
/******** Private method ***********/
/***********************************/

@interface PXDocumentController (Private)
//Call from applicationDidFinishLaunching:
- (void) _createApplicationSupportSubdirectories;
@end

@implementation PXDocumentController (Private)

//TODO Create Subdirectories for colors too
- (void) _createApplicationSupportSubdirectory:(NSString *)sub
								   inDirectory:(NSString *)root
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir;
	NSString *path = [root stringByAppendingPathComponent:sub];
	
	if  (![fileManager fileExistsAtPath:path isDirectory:&isDir])
	{
		if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL]) 
		{
			//FIXME: Turn exceptions into error reports.
            [NSException raise:@"Directory Error" format:@"Couldn't create Pixen support directory."];
			return;
		}
	}
	else
	{
		if (!isDir) 
		{
			[NSException raise:@"Directory Error" format:@"Couldn't create Pixen support directory."];
			return;
		}
	}	
}
NSString *appSupportSubdirName = @"Pixen";
NSString *backgroundsSubdirName = @"Backgrounds";
NSString *backgroundPresetSubdirName = @"Presets";
NSString *presetsSubdirName = @"Presets";
NSString *palettesSubdirName = @"Palettes";

- (void) _createApplicationSupportSubdirectories
{
	NSString *path = GetApplicationSupportDirectory();
	
	// ./Pixen
	[self _createApplicationSupportSubdirectory:appSupportSubdirName inDirectory:path];   
	
	// ./Pixen/Backgrounds
	path = [path stringByAppendingPathComponent:appSupportSubdirName];
	[self _createApplicationSupportSubdirectory:backgroundsSubdirName inDirectory:path];
	
	
	// ./Pixen/Backgrounds/Presets 
	[self _createApplicationSupportSubdirectory:backgroundPresetSubdirName
									inDirectory:[path stringByAppendingPathComponent:backgroundsSubdirName]]; 
	
	// ./Pixen/Palettes
	[self _createApplicationSupportSubdirectory:palettesSubdirName inDirectory:path];
}
@end


@implementation PXDocumentController

- (void)updateShowsToolPreviewCache
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:PXToolPreviewEnabledKey] == nil)
	{
		cachedShowsToolPreview = YES;
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:PXToolPreviewEnabledKey];
	}
	else
	{
		cachedShowsToolPreview = [[NSUserDefaults standardUserDefaults] boolForKey:PXToolPreviewEnabledKey];
	}
}


- (void)updateShowsPreviousCelOverlayCache
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:PXPreviousCelOverlayEnabledKey] == nil)
	{
		cachedShowsPreviousCelOverlay = NO;
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:PXPreviousCelOverlayEnabledKey];
	}
	else
	{
		cachedShowsPreviousCelOverlay = [[NSUserDefaults standardUserDefaults] boolForKey:PXPreviousCelOverlayEnabledKey];
	}
}

- (IBAction)globalInstallPalette:(id)sender
{
	PXPaletteImporter *importer = [[[PXPaletteImporter alloc] init] autorelease];
	[importer runInWindow:nil];
}

//
// Delegate methods
//
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[self updateShowsToolPreviewCache];
	[self updateShowsPreviousCelOverlayCache];
	
	//Create some directories needs to store backgrounds and Colors 
	[self _createApplicationSupportSubdirectories];
	
	[[PXPanelManager sharedManager] restorePanelStates];
	
	if ([defaults boolForKey:@"PXActivateColorWellOnStartup"]) {
		[[[PXToolPaletteController sharedToolPaletteController] leftSwitcher] activateColorWell];
	}
	
	//If it is the first time Pixen run launch the welcome Panel
	//TODO (could be cleaner) : Fabien
	if (! [defaults boolForKey:PXHasRunBeforeKey] )
	{
		//id welcome = [[PXWelcomeController alloc] init];
		[defaults setBool:YES forKey:@"PXActivateColorWellOnStartup"];
		[defaults setBool:YES forKey:@"SUCheckAtStartup"];
		[defaults setInteger:60 forKey:PXAutosaveIntervalKey];
		[defaults setBool:YES forKey:PXAutosaveEnabledKey];
		[defaults setBool:YES forKey:PXZoomNewDocumentsToFitKey];
		[defaults setBool:YES forKey:PXInfoPanelIsOpenKey];
		[defaults setBool:YES forKey:PXHasRunBeforeKey];
		[defaults synchronize];
		[[NSColorPanel sharedColorPanel] setMode:NSCustomPaletteModeColorPanel];
		[[[PXPanelManager sharedManager] welcomePanel] makeKeyAndOrderFront:self];
		//[welcome showWindow:self];
	}
	
	
	if ( [defaults floatForKey:PXVersionKey] < 3 ) // <3 <3 <3
	{
		[defaults setBool:YES forKey:PXZoomNewDocumentsToFitKey];
		[defaults setFloat:3 forKey:@"PXVersion"];
	}
	
	mouseTrackingTimer = [[NSTimer scheduledTimerWithTimeInterval:.05
														   target:self
														 selector:@selector(updateMousePosition:)
														 userInfo:nil
														  repeats:YES] retain];
	
	[self rescheduleAutosave];
}

- (void)rescheduleAutosave
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSTimeInterval repeatTime = [defaults floatForKey:PXAutosaveIntervalKey];
	if([defaults boolForKey:PXAutosaveEnabledKey])
	{
		[self setAutosavingDelay:repeatTime];
	}
	else
	{
		[self setAutosavingDelay:0];
	}
}

- (void)applicationWillResignActive:(NSNotification *)aNotification
{
	for (PXCanvasDocument *current in [self documents])
	{
		[[[current canvasController] view] setAcceptsFirstMouse:NO];
	}
}

- (void)updateMousePosition:(NSTimer *)timer
{
	PXCanvasDocument *doc = [self currentDocument];
	if(doc)
	{
//FIXME: coupled to canvas controller
		PXCanvasController *canvasController = [doc canvasController];
		NSWindow *window = [canvasController window];
		if (![window isKeyWindow]) {
			[canvasController updateMousePosition:[window mouseLocationOutsideOfEventStream]];
		}
	}
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if([[filename pathExtension] isEqual:PXBackgroundSuffix])
	{
		NSString *bgName = [filename lastPathComponent];
		NSString *dest = [GetBackgroundPresetsDirectory() stringByAppendingPathComponent:bgName];
		NSInteger result = [[NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Install Background Template \"%@\"?", @"Install Background Template \"%@\"?"), bgName] defaultButton:NSLocalizedString(@"Install", @"Install") alternateButton:NSLocalizedString(@"Cancel", @"CANCEL") otherButton:nil informativeTextWithFormat:NSLocalizedString(@"%@ will be copied to %@.", @"%@ will be copied to %@."), [filename stringByAbbreviatingWithTildeInPath], [dest stringByAbbreviatingWithTildeInPath]] runModal];
		if(result == NSAlertDefaultReturn)
		{
			[[NSFileManager defaultManager] copyItemAtPath:filename toPath:dest error:NULL];
            //FIXME: Handle errors.
			[[NSNotificationCenter defaultCenter] postNotificationName:PXBackgroundTemplateInstalledNotificationName object:self];
		}
	}
	if([[filename pathExtension] isEqual:PXPatternSuffix])
	{
		NSString *patternName = [filename lastPathComponent];
		NSInteger result = [[NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Install Pattern \"%@\"?", @"Install Pattern \"%@\"?"), patternName] defaultButton:NSLocalizedString(@"Install", @"Install") alternateButton:NSLocalizedString(@"Cancel", @"CANCEL") otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The pattern %@ will be added to Pixen's saved pattern list.", @"The pattern %@ will be added to Pixen's saved pattern list."), [filename stringByAbbreviatingWithTildeInPath]] runModal];
		if(result == NSAlertDefaultReturn)
		{
			NSString *patternArchiveFilename = GetPixenPatternFile();
			NSArray *patterns = [[NSKeyedUnarchiver unarchiveObjectWithFile:patternArchiveFilename] arrayByAddingObject:[NSKeyedUnarchiver unarchiveObjectWithFile:filename]];
			[NSKeyedArchiver archiveRootObject:patterns toFile:patternArchiveFilename];
			[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName object:self userInfo:[NSDictionary dictionaryWithObject:patterns forKey:@"patterns"]];
		}
	}
	if([[filename pathExtension] isEqual:PXPaletteSuffix] || [[filename pathExtension] isEqual:MicrosoftPaletteSuffix] || [[filename pathExtension] isEqual:AdobePaletteSuffix])
	{
		NSString *paletteName = [filename lastPathComponent];
		NSString *dest = [GetPixenPaletteDirectory() stringByAppendingPathComponent:paletteName];
		NSInteger result = [[NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Install Palette \"%@\"?", @"Instal Palette \"%@\"?"), paletteName] defaultButton:NSLocalizedString(@"Install", @"Install") alternateButton:NSLocalizedString(@"Cancel", @"CANCEL") otherButton:nil informativeTextWithFormat:NSLocalizedString(@"%@ will be copied to %@.", @"%@ will be copied to %@."), [filename stringByAbbreviatingWithTildeInPath], [dest stringByAbbreviatingWithTildeInPath]] runModal];
		if(result == NSAlertDefaultReturn)
		{
			PXPaletteImporter *importer = [[[PXPaletteImporter alloc] init] autorelease];
			[importer importPaletteAtPath:filename];
			[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName object:self];
		}
	}
	[self openDocumentWithContentsOfURL:[NSURL fileURLWithPath: filename] display:YES error:NULL];
    //FIXME: Handle errors.
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[[PXPanelManager sharedManager] archivePanelStates];
	[mouseTrackingTimer invalidate];
	[mouseTrackingTimer release];
}


//IBAction 

- (IBAction)newFromClipboard:(id)sender
{
	PXCanvasDocument *doc = [self makeUntitledDocumentOfType:PixenImageFileType error:NULL];
    //FIXME: Handle error.
	[self addDocument:doc];
	[doc loadFromPasteboard:[NSPasteboard generalPasteboard]];
}

- (IBAction)donate:(id)sender
{
	NSString *urlString = @"http://www.opensword.org/donate.php";
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

// It occurs to me (after having renamed this object to be a document controller, of course)
// that this sort of method really should be in, like, an app delegate. But I'm not going
// to deal with that right now.
- (IBAction)toggleAlignmentCrosshairs:(id)sender
{
	BOOL showCrosshairs = [[NSUserDefaults standardUserDefaults] boolForKey:PXCrosshairEnabledKey];
	showCrosshairs = !showCrosshairs;
	[[NSUserDefaults standardUserDefaults] setBool:showCrosshairs forKey:PXCrosshairEnabledKey];
//FIXME: coupled to canvas window controller
	[[[[self currentDocument] windowControllers] objectAtIndex:0] redrawCanvas:self];
}

- (BOOL)showsToolPreview
{
	return cachedShowsToolPreview;
}

- (IBAction)toggleToolPreview:(id)sender
{
	BOOL showToolPreview = [[NSUserDefaults standardUserDefaults] boolForKey:PXToolPreviewEnabledKey];
	cachedShowsToolPreview = !showToolPreview;
	if (!cachedShowsToolPreview) // clear what's there
	{
		[[PXToolPaletteController sharedToolPaletteController] clearBeziers];
	}
	[[NSUserDefaults standardUserDefaults] setBool:cachedShowsToolPreview forKey:PXToolPreviewEnabledKey];
//FIXME: coupled to canvas window controller 
	[[[[self currentDocument] windowControllers] objectAtIndex:0] redrawCanvas:self];
}

- (BOOL)showsPreviousCelOverlay
{
	return cachedShowsPreviousCelOverlay;
}

- (void)togglePreviousCelOverlay:(id)sender
{
	BOOL showPreviousCelOverlay = [[NSUserDefaults standardUserDefaults] boolForKey:PXPreviousCelOverlayEnabledKey];
	cachedShowsPreviousCelOverlay = !showPreviousCelOverlay;
	[[NSUserDefaults standardUserDefaults] setBool:cachedShowsPreviousCelOverlay forKey:PXPreviousCelOverlayEnabledKey];
//FIXME: coupled to canvas window controller
	[[[self currentDocument] windowControllers] makeObjectsPerformSelector:@selector(redrawCanvas:) withObject:self];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	if ([anItem action] == @selector(newFromClipboard:))
	{
		NSPasteboard *board = [NSPasteboard generalPasteboard];
		if ([[board types] containsObject:PXLayerPboardType])
			return YES;
		
		NSEnumerator *enumerator = [[NSImage imagePasteboardTypes] objectEnumerator];
		id current;
		while ((current = [enumerator nextObject]))
		{
			if ([[board types] containsObject:current])
			{
				return YES;
			}
		}
		
		return NO;
	}
	else if ([anItem action] == @selector(toggleAlignmentCrosshairs:))
	{
		BOOL showCrosshairs = [[NSUserDefaults standardUserDefaults] boolForKey:PXCrosshairEnabledKey];
		[anItem setTitle:(showCrosshairs) ? NSLocalizedString(@"HIDE_ALIGNMENT_CROSSHAIRS", @"Hide Alignment Crosshairs") :
			NSLocalizedString(@"SHOW_ALIGNMENT_CROSSHAIRS", @"Show Alignment Crosshairs")];
		return YES;
	}
	else if ([anItem action] == @selector(toggleToolPreview:))
	{
		BOOL showsToolPreview = [self showsToolPreview];
		[anItem setTitle:(showsToolPreview) ? NSLocalizedString(@"HIDE_TOOL_PREVIEW", @"Hide Tool Preview") :
			NSLocalizedString(@"SHOW_TOOL_PREVIEW", @"Show Tool Preview")];
		return YES;
	}
	else if ([anItem action] == @selector(togglePreviousCelOverlay:))
	{
		[anItem setTitle:([self showsPreviousCelOverlay]) ? NSLocalizedString(@"HIDE_PREVIOUS_CEL_OVERLAY", @"Hide Previous Cel Overlay") :
			NSLocalizedString(@"SHOW_PREVIOUS_CEL_OVERLAY", @"Show Previous Cel Overlay")];
		return YES;
	}
	else {
		return YES;
	}
}

- handleAnimatedGifAtURL:(NSURL *)aURL
{
	BOOL isAnimated = [PXGifImporter fileAtURLIsAnimated:aURL];
	if (isAnimated)
	{
		return [[[PXAnimationDocument alloc] initWithContentsOfFile:[aURL path] ofType:GIFFileType] autorelease];
	}
	return nil;
}

- (id)makeDocumentWithContentsOfURL:(NSURL *)aURL ofType:(NSString *)docType
{
	if ([docType isEqualToString:GIFFileType])
	{
		id potentiallyAnimatedDocument = [self handleAnimatedGifAtURL:aURL];
		if (potentiallyAnimatedDocument)
			return potentiallyAnimatedDocument;
	}
    //FIXME: Handle error.
	return [super makeDocumentWithContentsOfURL:aURL ofType:docType error:NULL];
}

- (id)makeDocumentForURL:(NSURL *)absoluteDocumentURL withContentsOfURL:(NSURL *)absoluteDocumentContentsURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if ([typeName isEqualToString:GIFFileType])
	{
		id potentiallyAnimatedDocument = [self handleAnimatedGifAtURL:absoluteDocumentURL];
		if (potentiallyAnimatedDocument)
			return potentiallyAnimatedDocument;
	}
	return [super makeDocumentForURL:absoluteDocumentURL withContentsOfURL:absoluteDocumentContentsURL ofType:typeName error:nil];
}

- (IBAction)newAnimationDocument:(id)sender
{
	//FIXME: This is deprecated, but I don't know how to use the current API to replicate the functionality.
    [self openUntitledDocumentOfType:PixenAnimationFileType display:YES];
}

- (NSArray *)animationDocuments
{
	NSMutableArray *animationDocuments = [NSMutableArray array];
	for (NSDocument *document in [self documents])
    {
		if ([document isKindOfClass:[PXAnimationDocument class]]) {
			[animationDocuments addObject:document];
		}
	}
	return animationDocuments;
}

- (IBAction)importAnimationFromImageSequence:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setPrompt:@"Import"];
	[openPanel setTitle:@"Import Sequence"];
	
	// Determine the appropriate extensions for the open panel.
	NSArray *longTypes = [PXCanvasDocument readableTypes];
	NSMutableArray *types = [[[NSMutableArray alloc] initWithCapacity:[longTypes count]] autorelease];
	for (NSString *currentType in longTypes)
	{
		[types addObjectsFromArray:[[NSDocumentController sharedDocumentController] fileExtensionsFromType:currentType]];
	}
	[openPanel setAllowsOtherFileTypes:NO];
	[openPanel setCanChooseDirectories:NO];

	NSInteger returnCode = [openPanel runModalForTypes:types];
	if (returnCode == NSFileHandlingPanelCancelButton) { return; }

	PXAnimationDocument *animationDocument = (PXAnimationDocument *)[self makeUntitledDocumentOfType:PixenAnimationFileType error:NULL];
  
	[[animationDocument animation] removeCel:[[animationDocument animation] objectInCelsAtIndex:0]];
	
	NSMutableArray *images = [[[NSMutableArray alloc] initWithCapacity:[[openPanel filenames] count]] autorelease];
    for (NSString *currentFile in [openPanel filenames])
	{
    [images addObject:[PXCanvas canvasWithContentsOfFile:currentFile]];
	}
	
  float defaultDuration = 1.0f;
	for(PXCanvas *current in images)
  {
    [[animationDocument animation] addCel:[[[PXCel alloc] initWithCanvas:current duration:defaultDuration] autorelease]];
  }	
  [self addDocument:animationDocument];
	[animationDocument makeWindowControllers];
	[animationDocument showWindows];
  [animationDocument updateChangeCount:NSChangeReadOtherContents];
}

@end

