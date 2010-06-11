//
//  PXSequenceExportPrompter.m
//  Pixen
//
//  Created by Andy Matuschak on 8/10/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXSequenceExportPrompter.h"
#import "PXCanvasDocument.h"

@implementation PXSequenceExportPrompter

- initWithDocument:(NSDocument *)aDocument
{
	[super init];
	fileTemplate = [[NSString stringWithFormat:@"%@ %%f", [[aDocument displayName] stringByDeletingPathExtension]] retain];
	[NSBundle loadNibNamed:@"PXSequenceExportPrompter" owner:self];
	[self setFileType:PixenImageFileType];
	savePanel = [[NSOpenPanel savePanel] retain];
	[savePanel setCanChooseDirectories:YES];
	[savePanel setTitle:@"Choose Target Folder"];
	[savePanel setPrompt:@"Export"];
	[savePanel setCanChooseFiles:NO];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setAllowsMultipleSelection:NO];
	[savePanel setAccessoryView:view];
	return self;
}

- (void)dealloc
{
	[savePanel release];
	[fileType release];
	[super dealloc];
}

- (void)setFileType:(NSString *)newFT
{
	[fileType release];
	fileType = [newFT retain];
	[self setValue:[[[self fileTemplate] stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@".%@", [[[NSDocumentController sharedDocumentController] fileExtensionsFromType:newFT] objectAtIndex:0]]] forKey:@"fileTemplate"];
}

- (NSString *)fileTemplate
{
	return fileTemplate;
}

- (void)panelDidFinish:panel returnCode:(int)code contextInfo:(void *)info
{
	if (code == NSCancelButton) { return; }
	if (NSEqualRanges([fileTemplate rangeOfString:@"%f"], NSMakeRange(NSNotFound, 0)))
		fileTemplate = [fileTemplate stringByAppendingString:@" %f"];
	[_delegate performSelector:_didEndSelector withObject:self];
}

- (void)beginSheetModalForWindow:(NSWindow *)parentWindow modalDelegate:delegate didEndSelector:(SEL)didEndSelector
{
	_delegate = delegate;
	_didEndSelector = didEndSelector;
	[savePanel beginSheetForDirectory:nil file:nil types:nil modalForWindow:parentWindow modalDelegate:self didEndSelector:@selector(panelDidFinish:returnCode:contextInfo:) contextInfo:NULL];
}

- savePanel
{
	return savePanel;
}

- (NSArray *)fileTypes
{
	return [PXCanvasDocument writableTypes];
}

@end
