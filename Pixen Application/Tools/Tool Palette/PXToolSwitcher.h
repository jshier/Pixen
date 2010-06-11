//
//  PXToolSwitcher.h
//  Pixen-XCode

// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  Created by Andy Matuschak on Sat Mar 13 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h>

@class PXTool, PXCanvasController;
@class NSString;
@class NSColor;
@class NSColorWell;
@class NSEvent;
@class NSImage;

typedef enum {
	PXPencilToolTag = 0,
	PXEraserToolTag,
	PXEyedropperToolTag,
	PXZoomToolTag,
	PXFillToolTag,
	PXLineToolTag,
	PXRectangularSelectionToolTag,
	PXMoveToolTag,
	PXRectangleToolTag,
	PXEllipseToolTag,
	PXMagicWandToolTag,
	PXLassoToolTag
} PXToolTag;


@interface PXToolSwitcher : NSObject
{
	id tools;
	IBOutlet NSMatrix *toolsMatrix;
	IBOutlet NSColorWell *colorWell;
@private 
	NSColor *_color;
	PXTool *_tool;
	PXTool *_lastTool;
	BOOL _locked;
}

- (id) init;
- (id) selectedTool;

- (id) toolWithTag:(PXToolTag)tag;
- (PXToolTag)tagForTool:(id) aTool;
- (void)setIcon:(NSImage *) anImage forTool:(id)aTool;
- (void)clearBeziers;

	//Manage color/colorWell
- (NSColor*) color;
- (void)setColor:(NSColor *)aColor;
- (void)activateColorWell;

- (void)lock;
- (void)unlock;

- (void)useTool:aTool;
- (void)useToolTagged:(PXToolTag)tag;

	//Actions methods
- (IBAction)toolClicked:(id)sender;
- (IBAction)colorChanged:(id)sender;

	//Events methods
- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc;
- (void)optionKeyDown;
- (void)optionKeyUp;
- (void)shiftKeyDown;
- (void)shiftKeyUp;
- (void)commandKeyDown;
- (void)commandKeyUp;

- (void)checkUserDefaults;

- (void)requestToolChangeNotification;

@end
