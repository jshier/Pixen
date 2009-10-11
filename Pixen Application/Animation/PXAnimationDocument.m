//
//  PXAnimationDocument.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXAnimationDocument.h"
#import "PXAnimation.h"
#import "PXAnimationWindowController.h"
#import "PXCel.h"
#import "PXAnimatedGifExporter.h"
#import "PXCanvas_ImportingExporting.h"
#import "OSProgressPopup.h"

@implementation PXAnimationDocument

- init
{
	[super init];
	animation = [[PXAnimation alloc] init];
	return self;
}

- (void)dealloc
{
	[(PXAnimationWindowController *)windowController setAnimation:nil];
	[animation release];
	[super dealloc];
}

//FIXME: consider removing these three once coupling decreases
- (PXAnimation *)animation
{
	return animation;
}

- canvasController
{
	return [windowController canvasController];
}

- canvas
{
	return [[animation objectInCelsAtIndex:0] canvas];
}

- (void)initWindowController
{
    windowController = [[PXAnimationWindowController alloc] initWithWindowNibName:@"PXAnimationDocument"];
}

- (void)setWindowControllerData
{
	[(PXAnimationWindowController *)windowController setAnimation:animation];
}

- (NSFileWrapper *)fileWrapperRepresentationOfType:(NSString *)aType
{
	if ([aType isEqualToString:PixenAnimationFileType])
	{
		NSMutableDictionary *files = [NSMutableDictionary dictionaryWithCapacity:[animation countOfCels]];
		NSMutableArray *celData = [NSMutableArray arrayWithCapacity:[animation countOfCels]];
		int i;
		for (i = 0; i < [animation countOfCels]; i++)
		{
			PXCel *current = [animation objectInCelsAtIndex:i];
			NSFileWrapper *file = [[[NSFileWrapper alloc] initRegularFileWithContents:[NSKeyedArchiver archivedDataWithRootObject:[current canvas]]] autorelease];
			[files setObject:file forKey:[NSString stringWithFormat:@"%d.%@", i, PXISuffix]];
			[celData addObject:[current info]];
		}
		NSString *error = nil;
		NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList:celData format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
		if(!xmlData)
		{
			NSLog(@"%@", error);
			[error release];
			return nil;
		}
		[files setObject:[[[NSFileWrapper alloc] initRegularFileWithContents:xmlData] autorelease] forKey:@"CelData.plist"];
		return [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:files] autorelease];
	}
	else if ([aType isEqualToString:GIFFileType])
	{
		return [[[NSFileWrapper alloc] initRegularFileWithContents:[self dataRepresentationOfType:GIFFileType]] autorelease];
	}
	return nil;
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
	if ([aType isEqualToString:GIFFileType])
	{
		OSProgressPopup *popup = [OSProgressPopup sharedProgressPopup];
		PXAnimatedGifExporter *exporter = [[[PXAnimatedGifExporter alloc] initWithSize:[animation size] iterations:1] autorelease];
		int i;
		int numberOfCels = [animation countOfCels];
		[popup setMaxProgress:numberOfCels];
		[popup beginOperationWithStatusText:[NSString stringWithFormat:@"Exporting GIF... (1 of %d)", numberOfCels] parentWindow:[windowController window]];
		[popup setProgress:0];
		id exportAnimation = animation;
		exportAnimation = [[animation copy] autorelease];
		[exportAnimation reduceColorsTo:256 withTransparency:YES matteColor:[NSColor whiteColor]];
		NSColor *transparentColor = nil;
		for (i = 0; i < numberOfCels; i++)
		{
			PXCanvas * celCanvas = [[exportAnimation objectInCelsAtIndex:i] canvas];
			transparentColor = [exporter writeCanvas:celCanvas withDuration:[[exportAnimation objectInCelsAtIndex:i] duration] transparentColor:transparentColor];
			[popup setStatusText:[NSString stringWithFormat:@"Exporting GIF... (%d of %d)", i + 1, numberOfCels]];
			[popup setProgress:i + 1];
		}
		
		[exporter finalizeExport];
		[popup endOperation];
		return [exporter data];
	}
	return nil;
}

- (BOOL)loadFileWrapperRepresentation:(NSFileWrapper *)wrapper ofType:(NSString *)docType
{
	if ([docType isEqualToString:PixenAnimationFileType])
	{
		[animation removeCel:[animation objectInCelsAtIndex:0]];
		NSDictionary *files = [wrapper fileWrappers];
		NSString *error = nil;
		NSData *plistData = [[files objectForKey:@"CelData.plist"] regularFileContents];
		NSArray *plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&error];
		if(!plist)
		{
			NSLog(@"%@", error);
			[error release];
			return NO;
		}
		if([plist count] == 0) { return NO; }
		PXGrid *firstGrid = nil;
		int i;
		for (i = 0; i < [plist count]; i++)
		{
			NSFileWrapper *currentFile = [files objectForKey:[NSString stringWithFormat:@"%d.%@", i, PXISuffix]];
			PXCel *cel = [[PXCel alloc] init];
			[cel setCanvas:[NSKeyedUnarchiver unarchiveObjectWithData:[currentFile regularFileContents]]];
			if(firstGrid == nil) {
				firstGrid = [[cel canvas] grid];
			} else {
				[[cel canvas] setGrid:firstGrid];
			}
			[cel setInfo:[plist objectAtIndex:i]];
			[animation addCel:cel];
		}
		[[self undoManager] removeAllActions];
		[self updateChangeCount:NSChangeCleared];
		return (animation != nil) && ([animation countOfCels] > 0);
	}
	else if ([docType isEqualToString:GIFFileType])
	{
		return [self loadDataRepresentation:[wrapper regularFileContents] ofType:docType];
	}
	else
	{
		return NO;
	}
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)docType
{
	if ([docType isEqualToString:GIFFileType])
	{
		[animation removeCel:[animation objectInCelsAtIndex:0]];
		NSImage *tempImage = [[[NSImage alloc] initWithData:data] autorelease];
		NSBitmapImageRep *bitmapRep = [[tempImage representations] objectAtIndex:0];
		int frameCount = [[bitmapRep valueForProperty:NSImageFrameCount] intValue];
		int i;
		for (i = 0; i < frameCount; i++)
		{
			[bitmapRep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithInt:i]];
			PXCel *newCel = [[[PXCel alloc] initWithImage:[tempImage copy] animation:animation] autorelease];
			[newCel retain];
			[newCel setDuration:[[bitmapRep valueForProperty:NSImageCurrentFrameDuration] floatValue]];
		}
		[[self undoManager] removeAllActions];
		[self updateChangeCount:NSChangeCleared];
		return (animation != nil) && ([animation countOfCels] > 0);
	}
	[[self undoManager] removeAllActions];
	[self updateChangeCount:NSChangeCleared];
	return (animation != nil) && ([animation countOfCels] > 0);
}

+ (BOOL)isNativeType:(NSString *)type
{
	if ([type isEqualToString:GIFFileType]) { return YES; }
	return [super isNativeType:type];
}

+ writableTypes
{
	return [[super writableTypes] arrayByAddingObject:GIFFileType];
}

@end
