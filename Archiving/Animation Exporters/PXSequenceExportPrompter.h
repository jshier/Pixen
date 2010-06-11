//
//  PXSequenceExportPrompter.h
//  Pixen
//
//  Created by Andy Matuschak on 8/10/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXSequenceExportPrompter : NSObject {
	NSOpenPanel *savePanel;
	NSString *fileTemplate;
	NSString *fileType;
	IBOutlet NSView *view;
	
	id _delegate;
	SEL _didEndSelector;
}

- initWithDocument:(NSDocument *)document;
- (void)beginSheetModalForWindow:(NSWindow *)parentWindow modalDelegate:delegate didEndSelector:(SEL)didEndSelector;
- savePanel;
- (NSString *)fileTemplate;
- (void)setFileType:(NSString *)type;

@end
