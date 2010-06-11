//
//  PXSpriteSheetExporter.h
//  Pixen
//
//  Created by Ian Henderson on 12.08.05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXSpriteSheetExporter : NSWindowController {
	IBOutlet NSTableView *animationsTable;
	IBOutlet NSImageView *sheetImageView;
	NSArray *documentRepresentations;
	BOOL closeOnEndSheet;
}

+ sharedSpriteSheetExporter;

- (IBAction)export:sender;

- (NSArray *)documentRepresentations;
- (IBAction)updatePreview:sender;

- (void)recacheDocumentRepresentations;

@end
