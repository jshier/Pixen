//
//  PXImageSizePrompter.h
//  Pixel Editor
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

//  Created by Joe Osborn on Tue Oct 28 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

//
//  Created by Open Sword Group on Thu May 01 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSObject(PXImageSizePrompterDelegate)

- (void)prompter:aPrompter didFinishWithSize:(NSSize)aSize backgroundColor:(NSColor *)bg;
- (void)prompterDidCancel:aPrompter;

@end

@class PXNSImageView;
@interface PXImageSizePrompter : NSWindowController 
{
	IBOutlet NSTextField *widthField;
	IBOutlet NSTextField *heightField;
	IBOutlet PXNSImageView *preview;
	IBOutlet NSView *widthIndicator, *heightIndicator;
	NSColor *backgroundColor;
	NSImage *image;
	NSTimer *animationTimer;
	NSSize initialSize;
	NSSize targetSize;
	float animationFraction;
	id delegate;
	NSRect initialHeightIndicatorFrame;
	NSRect initialWidthIndicatorFrame;
}
- (id) init;
- (void)setDelegate:(id) newDelegate;
- (void)promptInWindow:(NSWindow *) window;
- (IBAction)useEnteredSize:(id) sender;
- (IBAction)cancel:(id)sender;
- backgroundColor;
- (void)setBackgroundColor:(NSColor *)c;
@end
