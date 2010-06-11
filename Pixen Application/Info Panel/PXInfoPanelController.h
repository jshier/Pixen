//
//  PXInfoPanelController.h
//  Pixen-XCode

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
//  Created by Andy Matuschak on Thu Jul 29 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

#import <AppKit/NSNibDeclarations.h>

@class NSColor;
@class NSPanel;
@class NSTextField;

@interface PXInfoPanelController : NSObject
{
	NSPoint draggingOrigin;
		
	IBOutlet NSPanel *panel;
	
	IBOutlet NSTextField *cursorX;
	IBOutlet NSTextField *cursorY;
	IBOutlet NSTextField *width;
	IBOutlet NSTextField *height;
	IBOutlet NSTextField *red;
	IBOutlet NSTextField *green;
	IBOutlet NSTextField *blue;
	IBOutlet NSTextField *alpha;
	IBOutlet NSTextField *hex;
}

//singleton
+ (id) sharedInfoPanelController;

- (void)setCursorPosition: (NSPoint)point;
- (void)setColorInfo:(NSColor *) color;
- (void)setCanvasSize: (NSSize)size;
- (void)setDraggingOrigin: (NSPoint)point;

	//Accessor
- (NSPanel *) infoPanel;

@end
