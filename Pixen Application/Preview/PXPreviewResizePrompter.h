//
//  PXPreviewResizePrompter.h
//  Pixen
//
//  Created by Andy Matuschak on 6/11/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXPreviewResizePrompter : NSWindowController {
	IBOutlet NSTextField * zoomPercentage, * width, * height;
	NSSize canvasSize;
	id delegate;
}

- (IBAction)resize:sender;
- (IBAction)cancel:sender;
- (IBAction)updateForm:sender;

- (void)setZoomFactor:(float)zoomFactor;
- (void)setCanvasSize:(NSSize)size;
- (void)setDelegate:delegate;

- (void)promptInWindow:(NSWindow *)window;

@end

@interface NSObject(PXPreviewResizePrompterDelegate)
- (void)prompter:(PXPreviewResizePrompter *)p didFinishWithZoomFactor:(float)fac;
@end
