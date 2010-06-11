//
//  PXSpriteSheetExporter.m
//  Pixen
//
//  Created by Ian Henderson on 12.08.05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXSpriteSheetExporter.h"
#import "PXDocumentController.h"
#import "PXAnimationDocument.h"
#import "PXAnimation.h"

PXSpriteSheetExporter *sharedSpriteSheetExporter = nil; 

@implementation PXSpriteSheetExporter

- init
{
	if (sharedSpriteSheetExporter) {
		[self dealloc];
		return sharedSpriteSheetExporter;
	}
	if ([super initWithWindowNibName:@"PXSpriteSheetExporter"] == nil) {
		return nil;
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentsChanged:) name:PXDocumentDidCloseNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentsChanged:) name:PXDocumentOpenedNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentsChanged:) name:PXDocumentChangedDisplayNameNotificationName object:nil];
	
	sharedSpriteSheetExporter = self;
	return self;
}

- (void)recacheDocumentRepresentations
{
	NSArray *animationDocuments = [[PXDocumentController sharedDocumentController] animationDocuments];
	NSArray *oldRepresentations = documentRepresentations;
	documentRepresentations = [[NSMutableArray alloc] init];
	for (id doc in animationDocuments)
    {
		BOOL included = NO;
		for (NSDictionary *oldRep in oldRepresentations)
        {
			if ([oldRep objectForKey:@"document"] == doc) {
				included = [[oldRep objectForKey:@"included"] boolValue];
				break;
			}
		}
		[(NSMutableArray *)documentRepresentations addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:doc, @"document", [doc displayName], @"displayName", [NSNumber numberWithBool:included], @"included", nil]];
	}
	[oldRepresentations release];
}

- (void)documentsChanged:(NSNotification *)notification
{
	PXAnimationDocument *doc = [notification object];
	if ([doc isKindOfClass:[PXAnimationDocument class]]) {
		[self willChangeValueForKey:@"documentRepresentations"];
		[self recacheDocumentRepresentations];
		[self didChangeValueForKey:@"documentRepresentations"];
	}
}

+ sharedSpriteSheetExporter
{
	return [[self alloc] init];
}

- (NSArray *)documentRepresentations
{
	if (!documentRepresentations) {
		[self recacheDocumentRepresentations];
	}
	return documentRepresentations;
}

- (NSColor *)backgroundColor
{
	return [NSColor whiteColor];
}

- (NSImage *)spriteSheetImage
{
	int interAnimationMargin = 0;
	int interCelMargin = 0;
	int padding = 0;
	NSMutableArray *animationSheets = [NSMutableArray array];
	NSSize sheetSize = NSMakeSize(padding*2, padding*2);
	for (NSDictionary *docRep in documentRepresentations)
    {
		PXAnimation *animation = [[docRep objectForKey:@"document"] animation];
		if ([[docRep objectForKey:@"included"] boolValue]) {
			NSImage *spriteSheetRow = [animation spriteSheetWithCelMargin:interCelMargin];
			if ([spriteSheetRow size].width > sheetSize.width) {
				sheetSize.width = [spriteSheetRow size].width;
			}
			sheetSize.height += [spriteSheetRow size].height + interAnimationMargin;
			[animationSheets addObject:spriteSheetRow];
		}
	}
	if (NSEqualSizes(sheetSize, NSMakeSize(padding*2, padding*2))) {
		return nil;
	}
	sheetSize.height -= interAnimationMargin;
	
	NSImage *spriteSheet = [[[NSImage alloc] initWithSize:sheetSize] autorelease];
	[spriteSheet lockFocus];
	[[NSColor clearColor] set];
	NSRectFill(NSMakeRect(0,0,sheetSize.width,sheetSize.height));
	NSPoint currentPoint = NSMakePoint(padding, 0);
	for (NSImage *row in animationSheets)
  {
		[row compositeToPoint:currentPoint operation:NSCompositeSourceOver];
    currentPoint.y += [row size].height;
		currentPoint.y += interAnimationMargin;
	}
	[spriteSheet unlockFocus];
	return spriteSheet;
}

- (IBAction)updatePreview:sender
{
  NSImage *img = [self spriteSheetImage];
  if(img)
  {
    [sheetImageView setImage:[self spriteSheetImage]];
  }
  else
  {
    [sheetImageView setImage:[NSImage imageNamed:@"Pixen"]];
  }
}

- (void)windowDidLoad
{
	[self updatePreview:self];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
	if (returnCode == NSCancelButton) {
		closeOnEndSheet = NO;
	} else {
		closeOnEndSheet = YES;
	}
	NSImage *spriteSheet = [self spriteSheetImage];
	NSRect spriteSheetRect = {NSZeroPoint, [spriteSheet size]};
	[spriteSheet lockFocus];
	NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:spriteSheetRect] autorelease];
	[spriteSheet unlockFocus];
	[[bitmap representationUsingType:NSPNGFileType properties:nil] writeToFile:[sheet filename] atomically:YES];
}

- (void)windowDidEndSheet:notification
{
	if (closeOnEndSheet) {
		[self close];
	}
}

- (IBAction)export:sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
  [savePanel setExtensionHidden:false];
  [savePanel setCanSelectHiddenExtension:false];
	[savePanel setTitle:@"Save Spritesheet"];
	[savePanel setRequiredFileType:@"png"];
	[savePanel beginSheetForDirectory:nil file:@"Spritesheet.png" modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

@end
