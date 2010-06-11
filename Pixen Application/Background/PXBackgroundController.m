#import "PXBackgroundController.h"
#import "PXBackgroundInfoView.h"
#import "SubviewTableViewController.h"
#import "PXBackgrounds.h"
#import "PXBackgroundTemplateView.h"
#import "PathUtilities.h"
#import "OSStackedView.h"
#import "PXBackgroundTableHeader.h"
#import "PXBuiltinBackgroundTemplateView.h"
#import "PXDefaultBackgroundTemplateView.h"
#import <Carbon/Carbon.h>

typedef enum _PXStackType
{
	PXTemplatesStackViewType,
	PXDefaultsStackViewType
} PXStackType;

@implementation PXBackgroundController

- builtinTemplates
{
    static id backgrounds = nil;
    if(backgrounds == nil) { backgrounds = [[NSArray alloc] initWithObjects:
		[[[PXSlashyBackground alloc] init] autorelease], 
		[[[PXMonotoneBackground alloc] init] autorelease], 
		[[[PXCheckeredBackground alloc] init] autorelease], 
		[[[PXImageBackground alloc] init] autorelease], 
		nil]; 
	}
    return backgrounds;
}

- presetTemplates
{
	NSMutableArray *results = [NSMutableArray array];
	id enumerator = [[NSFileManager defaultManager] enumeratorAtPath:GetBackgroundPresetsDirectory()], current;
    while((current = [enumerator nextObject]))
    {
        if([[current pathExtension] isEqualToString:PXBackgroundSuffix])
        {
            [results addObject:[NSKeyedUnarchiver unarchiveObjectWithFile:[GetBackgroundPresetsDirectory() stringByAppendingPathComponent:current]]];
        }
    }
	return results;
}

- defaultTemplates
{
	NSMutableArray *results = [NSMutableArray arrayWithObject:[delegate defaultMainBackground]];
	PXBackground *alt = [delegate defaultAlternateBackground];
	if(alt)
	{
		[results addObject:alt];
	}
	else
	{
		[results addObject:[NSNull null]];
	}
	return results;
}

- init
{
	self = [self initWithWindowNibName:@"PXBackgroundController"];
	if(self)
	{
		mainViews = [[NSMutableArray alloc] initWithCapacity:16];
		defaultsViews = [[NSMutableArray alloc] initWithCapacity:3];
	}
	return self;
}

- (void)dealloc
{
	[mainStack clearStack];
	[mainViews release];
	[defaultsStack clearStack];
	[defaultsViews release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)backgroundInstalled:(NSNotification *)note
{
	[self reloadData];
}

- (void)stackedViewDoubleClicked:sender
{
	NSView *view = [sender selectedView];
	if(![view isKindOfClass:[PXBackgroundTemplateView class]]) { return; }
	[mainBackgroundView setBackground:[(PXBackgroundTemplateView *)view background]];
	[delegate setMainBackground:[(PXBackgroundTemplateView *)view background]];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundInstalled:) name:PXBackgroundTemplateInstalledNotificationName object:nil];
	[mainStack registerForDraggedTypes:[NSArray arrayWithObject:PXBackgroundTemplatePboardType]];
	[mainStack setTag:PXTemplatesStackViewType];
	[defaultsStack setTag:PXDefaultsStackViewType];
	[[mainStack enclosingScrollView] registerForDraggedTypes:[NSArray arrayWithObject:PXBackgroundTemplatePboardType]];
	[defaultsStack registerForDraggedTypes:[NSArray arrayWithObject:PXBackgroundTemplatePboardType]];
	[[defaultsStack enclosingScrollView] registerForDraggedTypes:[NSArray arrayWithObject:PXBackgroundTemplatePboardType]];
	[mainStack setTarget:self];
	[mainStack setDoubleAction:@selector(stackedViewDoubleClicked:)];
	[defaultsStack setTarget:self];
	[defaultsStack setDoubleAction:@selector(stackedViewDoubleClicked:)];
}

- (void)backgroundChanged:(NSNotification *)note
{
	[delegate backgroundChanged:[note object]];
}

- (void)setPreviewImage:(NSImage *)img
{
	[mainBackgroundView setPreviewImage:img];
	[alternateBackgroundView setPreviewImage:img];
}

- (void)populateViews:(NSMutableArray *)views forStackedView:(OSStackedView *)stack withSectionNamed:(NSString *)headerName withTemplates:(NSArray *)templates viewClass:(Class)class
{
//FIXME: minor leak?  not autoreleasing this fixes the open/close-background-config-repeatedly crasher.
	PXBackgroundTableHeader *header = [[PXBackgroundTableHeader alloc] initWithFrame:NSMakeRect(0, 0, NSWidth([stack frame]), 18)];
	[header setStringValue:headerName];
	[views addObject:header];
	[stack stackSubview:header];
	[header setFrame:NSMakeRect(-1, -1, NSWidth([header frame]) + 2, NSHeight([header frame]) + 2)];
	int i;
	for (i = 0; i < [templates count]; i++)
	{
		id template = [templates objectAtIndex:i];
		id newView = [[[class alloc] init] autorelease];
		if (template == [NSNull null])
			[newView setBackground:nil];
		else
			[newView setBackground:template];
		[views addObject:newView];
		[stack stackSubview:newView];
	}
}

- (void)populateViews
{
	[mainViews removeAllObjects];
	[mainStack clearStack];
	[defaultsViews removeAllObjects];
	[defaultsStack clearStack];
	[self populateViews:mainViews forStackedView:mainStack withSectionNamed:NSLocalizedString(@"Built-in Templates", @"Built-in Templates") withTemplates:[self builtinTemplates] viewClass:[PXBuiltinBackgroundTemplateView class]];
	PXBackgroundTableHeader *head = [mainViews objectAtIndex:0];
	[head setFrameSize:NSMakeSize(NSWidth([head frame]), NSHeight([head frame]) + 1)];
	[self populateViews:mainViews forStackedView:mainStack withSectionNamed:NSLocalizedString(@"User Templates", @"User Templates") withTemplates:[self presetTemplates] viewClass:[PXBackgroundTemplateView class]];
	[self populateViews:defaultsViews forStackedView:defaultsStack withSectionNamed:NSLocalizedString(@"Default Templates", @"Default Templates") withTemplates:[self defaultTemplates] viewClass:[PXDefaultBackgroundTemplateView class]];
	head = [defaultsViews objectAtIndex:0];
	[head setFrameSize:NSMakeSize(NSWidth([head frame]), NSHeight([head frame]) + 1)];
	
	[[defaultsViews objectAtIndex:1] setBackgroundTypeText:PXMainBackgroundType];
	[[defaultsViews objectAtIndex:2] setBackgroundTypeText:PXAlternateBackgroundType];
}

- (void)reloadData
{
	[self window];
	[self populateViews];
	[mainStack display];
	[defaultsStack display];

	PXBackground *mainBG = [delegate mainBackground], *alternateBG = [delegate alternateBackground];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundChanged:) name:PXBackgroundChangedNotificationName object:mainBG];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundChanged:) name:PXBackgroundChangedNotificationName object:alternateBG];

	[mainBackgroundView setBackground:mainBG];
	[alternateBackgroundView setBackground:alternateBG];
}

- (void)setDelegate:del
{
	delegate = del;
}

- (IBAction)displayHelp:sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"workingwithbackgrounds" inBook:@"Pixen Help"];
}

- (void)dragFailedForInfoView:(PXBackgroundInfoView *)infoView
{
	if(infoView == alternateBackgroundView)
	{
		[alternateBackgroundView setBackground:nil];
		[delegate setAlternateBackground:nil];
	}
	else
	{
		NSBeep();		
	}
}

- (void)backgroundInfoView:(PXBackgroundInfoView *)infoView receivedBackground:(PXBackground *)bg
{
	[[self window] makeFirstResponder:[infoView nameField]];
	if(infoView == mainBackgroundView)
	{
		[delegate setMainBackground:bg];
	}
	else if(infoView == alternateBackgroundView)
	{
		[delegate setAlternateBackground:bg];
	}
}

- (void)deleteSheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
	{
		int tag;
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                 source:GetBackgroundPresetsDirectory()
                                            destination:nil 
                                                  files:[NSArray arrayWithObject:[[contextInfo objectForKey:PXBackgroundPathKey] lastPathComponent]] 
                                                    tag:&tag];
		NSPoint poofPoint = NSPointFromString([contextInfo objectForKey:PXPoofLocationKey]);
		if (!NSEqualPoints(poofPoint, NSZeroPoint))
			NSShowAnimationEffect(NSAnimationEffectPoof, poofPoint, NSZeroSize, nil, NULL, nil);
		[self reloadData];
	}
	[contextInfo release];
}

- (void)tryToDeleteBackgroundAtPath:(NSString *)backgroundPath displayingPoofAtPoint:(NSPoint)point
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:backgroundPath]) { NSBeep(); return; }
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"DELETE")] setKeyEquivalent:@""];
	NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
	[button setKeyEquivalent:@"\r"];
	[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Really delete background template %@?", @"BACKGROUND_DELETE_PROMPT"), [[backgroundPath lastPathComponent] stringByDeletingPathExtension]]];
	[alert setInformativeText:NSLocalizedString(@"This operation cannot be undone.", @"BACKGROUND_DELETE_INFORMATIVE_TEXT")];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(deleteSheetDidEnd:returnCode:contextInfo:)
						contextInfo:[[NSDictionary dictionaryWithObjectsAndKeys:backgroundPath, PXBackgroundPathKey, NSStringFromPoint(point), PXPoofLocationKey, nil] retain]];
}

- (NSString *)pathForBackground:(PXBackground *)background
{
	return [[GetBackgroundPresetsDirectory() stringByAppendingPathComponent:[background name]] stringByAppendingPathExtension:PXBackgroundSuffix];
}

- (void)saveBackground:(PXBackground *)background atPath:(NSString *)path
{
	if(![NSKeyedArchiver archiveRootObject:background toFile:path])
  {
    [NSException raise:@"PXBackgroundSaveFailure" format:@"couldn't save background %@ to %@", background, path];
  }
}

- (void)overwriteSheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
	{
		[self saveBackground:contextInfo atPath:[self pathForBackground:contextInfo]];
	}
	[contextInfo release];
	[self reloadData];
}

- (void)tryToSaveBackground:(PXBackground *)bg
{
	NSString *path = [self pathForBackground:bg];
	id manager = [NSFileManager defaultManager];
	if([manager fileExistsAtPath:path])
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[[alert addButtonWithTitle:NSLocalizedString(@"Overwrite", @"OVERWRITE")] setKeyEquivalent:@""];
		NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
		[button setKeyEquivalent:@"\r"];
		[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"A background with the name %@ already exists.", @"BACKGROUND_OVERWRITE_PROMPT"), [bg name]]];
		[alert setInformativeText:NSLocalizedString(@"Would you like to overwrite it?", @"BACKGROUND_OVERWRITE_INFORMATIVE_TEXT")];
		//need to retain the context info
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(overwriteSheetDidEnd:returnCode:contextInfo:) contextInfo:[bg retain]];
	}
	else
	{
		[self saveBackground:bg atPath:path];
		[self reloadData];
	}
}

- (NSString *)newBackgroundNameForTemplateView:(PXBackgroundTemplateView *)templateView
{
	if ([templateView isKindOfClass:[PXBuiltinBackgroundTemplateView class]])
	{
		return [@"New " stringByAppendingString:[[templateView background] defaultName]];
	}
	else
	{
		return [@"Copy of " stringByAppendingString:[[templateView background] name]];
	}
}

- (BOOL)stackedView:(OSStackedView *)aStackedView
		  writeRows:(NSArray *)rows
	   toPasteboard:(NSPasteboard *)pboard
{
	// get the correct view
	NSView *view = (aStackedView == mainStack) ? [mainViews objectAtIndex:[[rows lastObject] intValue]] :
												 [defaultsViews objectAtIndex:[[rows lastObject] intValue]];
	if(![view isKindOfClass:[PXBackgroundTemplateView class]]) { return NO; }
	if ([(PXBackgroundTemplateView *)view background] == nil) { return NO;}
	PXBackground *bg = [(PXBackgroundTemplateView *)view background];
	
	// figure out what types are applicable and set them up
	NSArray *types = [NSArray arrayWithObjects:PXBackgroundTemplatePboardType, PXBackgroundNamePboardType, PXBackgroundNewTemplatePboardType, nil];
	if([[NSFileManager defaultManager] fileExistsAtPath:[self pathForBackground:bg]])
	{
		types = [types arrayByAddingObject:NSFilenamesPboardType];
	}
	if (aStackedView == defaultsStack)
	{
		types = [types arrayByAddingObject:PXBackgroundTypePboardType];
	}
	if ([view isKindOfClass:[PXBuiltinBackgroundTemplateView class]])
	{
		types = [types arrayByAddingObject:PXBackgroundNoDeletePboardType];
	}
	
	[pboard declareTypes:types owner:self];
	
	// set the default type if we're a defaults stack
	if (aStackedView == defaultsStack)
	{
		[pboard setString:[(PXDefaultBackgroundTemplateView *)view backgroundTypeText] forType:PXBackgroundTypePboardType];
	}
	
	// set the "no delete" flag if we're a built-in template
	if ([view isKindOfClass:[PXBuiltinBackgroundTemplateView class]])
	{
		[pboard setString:[NSString stringWithFormat:@"%d", 1] forType:PXBackgroundNoDeletePboardType];
	}
	
	if ([view isKindOfClass:[PXDefaultBackgroundTemplateView class]])
	{
		if ([[(PXDefaultBackgroundTemplateView *)view backgroundTypeText] isEqualToString:PXMainBackgroundType])
		{
			[pboard setString:[NSString stringWithFormat:@"%d", 1] forType:PXBackgroundNoDeletePboardType];
		}
	}
	
	[pboard setData:[NSKeyedArchiver archivedDataWithRootObject:bg] forType:PXBackgroundTemplatePboardType];
	[pboard setString:[self newBackgroundNameForTemplateView:(PXBackgroundTemplateView *)view] forType:PXBackgroundNewTemplatePboardType];
	
	// set the data for file-based drags
	id path = [self pathForBackground:bg];
	[pboard setString:path forType:PXBackgroundNamePboardType];
	if([[NSFileManager defaultManager] fileExistsAtPath:[self pathForBackground:bg]])
	{
		[pboard setPropertyList:[NSArray arrayWithObject:path] forType:NSFilenamesPboardType];
	}
	return YES;
}

- (NSDragOperation)stackedView:(OSStackedView *)aStackedView 
				  validateDrop:(id <NSDraggingInfo>)info
{
	if(([[info draggingSource] tag] == PXTemplatesStackViewType && [aStackedView tag] == PXTemplatesStackViewType) ||
	   ([[info draggingSource] tag] == PXDefaultsStackViewType && [aStackedView tag] == PXDefaultsStackViewType))
	{
		[[NSCursor arrowCursor] set];
		return NSDragOperationNone;
	}
	return NSDragOperationCopy;
}

- (BOOL)windowPoint:(NSPoint)point inView:(NSView *)view
{
	return NSPointInRect([view convertPoint:point fromView:nil], [view bounds]);
}

- (void)stackedView:(OSStackedView *)aStackedView dragMovedToScreenPoint:(NSPoint)point
{
/*	NSPoint location = [[self window] convertScreenToBase:point];
	// set up poof and not allowed cursors
	if (![self windowPoint:location inView:[mainStack enclosingScrollView]] &&
		![self windowPoint:location inView:[defaultsStack enclosingScrollView]] &&
		![self windowPoint:location inView:mainBackgroundView] &&
		![self windowPoint:location inView:alternateBackgroundView])
	{
		if ([[[NSPasteboard pasteboardWithName:NSDragPboard] stringForType:PXBackgroundNoDeletePboardType] intValue])
		{
			SetThemeCursor(kThemeNotAllowedCursor);
			return;
		}
		
		if (aStackedView == mainStack)
		{
			[[NSCursor disappearingItemCursor] set];
		}
		else
		{
			id typeData = [[NSPasteboard pasteboardWithName:NSDragPboard] stringForType:PXBackgroundTypePboardType];
			if ([typeData isEqualToString:PXMainBackgroundType])
			{
				SetThemeCursor(kThemeNotAllowedCursor);
			}
		}
	}*/
}	

- (NSDragOperation)stackedView:(OSStackedView *)aStackedView
					updateDrag:(id <NSDraggingInfo>)info
{
	NSPoint location = [info draggingLocation];
	PXDefaultBackgroundTemplateView *mainBackgroundTemplate = [defaultsViews objectAtIndex:1];
	PXDefaultBackgroundTemplateView *alternateBackgroundTemplate = [defaultsViews objectAtIndex:2];
	[mainBackgroundTemplate setActiveDragTarget:NO];
	[alternateBackgroundTemplate setActiveDragTarget:NO];
	NSDragOperation dragOperation;
	
	// only do this stuff for the defaults stack
	if (aStackedView == defaultsStack)
	{
		if ([self windowPoint:location inView:mainBackgroundTemplate])
		{
			id typeData = [[NSPasteboard pasteboardWithName:NSDragPboard] stringForType:PXBackgroundTypePboardType];
			if (![typeData isEqualToString:PXMainBackgroundType])
				[mainBackgroundTemplate setActiveDragTarget:YES];
		}
		if ([self windowPoint:location inView:alternateBackgroundTemplate])
		{
			id typeData = [[NSPasteboard pasteboardWithName:NSDragPboard] stringForType:PXBackgroundTypePboardType];
			if (![typeData isEqualToString:PXAlternateBackgroundType])
				[alternateBackgroundTemplate setActiveDragTarget:YES];
		}
		dragOperation = NSDragOperationCopy;
	}
	else
	{
		dragOperation = [self stackedView:aStackedView validateDrop:info];
	}
		
	return dragOperation;
}

- (BOOL)stackedView:(OSStackedView *)aStackedView
		 acceptDrop:(id <NSDraggingInfo>)info
{
	id data = [[info draggingPasteboard] dataForType:PXBackgroundTemplatePboardType];
	id background = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if(aStackedView == mainStack)
	{
		[self tryToSaveBackground:background];
	}
	else
	{
		PXBackgroundTableHeader *defaultsHeader = [defaultsViews objectAtIndex:0];
		PXDefaultBackgroundTemplateView *mainBackgroundTemplate = [defaultsViews objectAtIndex:1];
		PXDefaultBackgroundTemplateView *alternateBackgroundTemplate = [defaultsViews objectAtIndex:2];
		NSPoint location = [info draggingLocation];
		if ([self windowPoint:location inView:mainBackgroundTemplate] || [self windowPoint:location inView:defaultsHeader])
		{
			[delegate setDefaultMainBackground:background];
			[mainBackgroundTemplate setBackground:background];
		}
		else if ([self windowPoint:location inView:alternateBackgroundTemplate])
		{
			[delegate setDefaultAlternateBackground:background];
			[alternateBackgroundTemplate setBackground:background];
		}
		
		[mainBackgroundTemplate setActiveDragTarget:NO];
		[alternateBackgroundTemplate setActiveDragTarget:NO];
	}
	return YES;
}

- (void)stackedView:(OSStackedView *)aStackedView
 dragOperationEnded:(NSDragOperation)drag
		 insideView:(BOOL)inside
	insideSuperview:(BOOL)inSuper
{
	if((drag == NSDragOperationNone) && !inSuper)
	{
		if(aStackedView == mainStack)
		{
			NSString *backgroundPath = [[NSPasteboard pasteboardWithName:NSDragPboard] stringForType:PXBackgroundNamePboardType];
			[self tryToDeleteBackgroundAtPath:backgroundPath displayingPoofAtPoint:[[self window] convertBaseToScreen:[[self window] mouseLocationOutsideOfEventStream]]];
		}
		else
		{
			id typeData = [[NSPasteboard pasteboardWithName:NSDragPboard] stringForType:PXBackgroundTypePboardType];
			if ([typeData isEqualToString:PXMainBackgroundType])
			{
				NSBeep();
			}
			else
			{
				[delegate setDefaultAlternateBackground:nil];
				[(PXBackgroundTemplateView *)[aStackedView selectedView] setBackground:nil];
			}
		}
	}
}

- (void)deleteKeyPressedInStackedView:aStackedView
{
	PXBackground *template = [(PXBackgroundTemplateView *)[aStackedView selectedView] background];
	if(aStackedView == mainStack)
	{
		[self tryToDeleteBackgroundAtPath:[self pathForBackground:template] displayingPoofAtPoint:NSZeroPoint];
	}
	else
	{
		NSString *backgroundType = [(PXDefaultBackgroundTemplateView *)[aStackedView selectedView] backgroundTypeText];
		if ([backgroundType isEqualToString:PXMainBackgroundType])
		{
			NSBeep();
		}
		else
		{
			[delegate setDefaultAlternateBackground:nil];
			[(PXBackgroundTemplateView *)[aStackedView selectedView] setBackground:nil];
		}
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
	[[delegate mainBackground] windowWillClose:notification];
	[[delegate alternateBackground] windowWillClose:notification];
}

@end

@implementation PXBackgroundTemplateScrollView

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)info
{
	if(([[info draggingSource] tag] == PXTemplatesStackViewType && [[self documentView] tag] == PXTemplatesStackViewType) ||
	   ([[info draggingSource] tag] == PXDefaultsStackViewType && [[self documentView] tag] == PXDefaultsStackViewType))
	{
		[[NSCursor arrowCursor] set];
		return NSDragOperationNone;
	}
	return NSDragOperationNone;
}

- (NSDragOperation)draggingExited:(id <NSDraggingInfo>)info
{		
	if (NSPointInRect([[self documentView] convertPoint:[info draggingLocation] fromView:nil], [[self documentView] bounds])) { return NSDragOperationNone; }
	
	if ([[self documentView] tag] == PXDefaultsStackViewType)
	{
		PXDefaultBackgroundTemplateView *mainBackgroundTemplate = (PXDefaultBackgroundTemplateView *)[[[[self documentView] valueForKey:@"views"] objectAtIndex:1] view];
		PXDefaultBackgroundTemplateView *alternateBackgroundTemplate = (PXDefaultBackgroundTemplateView *)[[[[self documentView] valueForKey:@"views"] objectAtIndex:2] view];
		[mainBackgroundTemplate setActiveDragTarget:NO];
		[alternateBackgroundTemplate setActiveDragTarget:NO];
	}
	
	// If the template that's being dragged isn't built-in, update it for deletion.
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSPasteboard pasteboardWithName:NSDragPboard] stringForType:PXBackgroundNamePboardType]])
	{
		[[NSCursor disappearingItemCursor] set];
		return NSDragOperationNone;
	}
	else
		return NSDragOperationNone;	
}

@end
