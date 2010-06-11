//
//  PXCanvasResizePrompter.h
//  Pixen-XCode
//
// Copyright (c) 2003,2004,2005 Open Sword Group

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
//
//  Created by Ian Henderson on Wed Jun 09 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <AppKit/AppKit.h>


@class PXCanvasResizeView;

@interface NSObject(PXCanvasResizePrompterDelegate)

- (void)prompter:aPrompter 
didFinishWithSize:(NSSize)size
		position:(NSPoint)position
 backgroundColor:(NSColor *)color;

@end

@interface PXCanvasResizePrompter : NSWindowController 
{
	IBOutlet NSTextField *heightField, *widthField;
	IBOutlet PXCanvasResizeView *resizeView;
	IBOutlet NSColorWell *bgColorWell;
	NSImage *cachedImage;
	id delegate;
}

-(id) init;
- (void)setDelegate:(id)newDelegate;
- (void)promptInWindow:(NSWindow *)window;

- (IBAction)cancel:(id) sender;
- (IBAction)updateBgColor:(id) sender;
- (IBAction)updateSize:(id) sender;
- (IBAction)useEnteredFrame:(id) sender;
- (void)setCurrentSize:(NSSize)size;
- (void)setCachedImage:(NSImage *)image;
- widthField;
- heightField;
- resizeView;
- backgroundColor;
- (void)setBackgroundColor:(NSColor *)c;

@end
