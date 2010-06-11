//
//  PXPatternEditorController.h
//  Pixen
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

//  Created by Ian Henderson on 02.07.05.
//  Copyright (c) 2005 Open Sword Group. All rights reserved.

#import <AppKit/AppKit.h>

@class PXPattern, PXPatternEditorView, PXSavedPatternMatrix;

@interface PXPatternEditorController : NSWindowController {
	PXPattern *pattern;
	PXPattern *oldPattern;
	id toolName;
	IBOutlet PXPatternEditorView *view;
	IBOutlet NSDrawer *drawer;
	IBOutlet NSScrollView *scrollView;
	PXSavedPatternMatrix *matrix;
	id delegate;
}

- (void)setToolName:name;

- (void)setDelegate:del;
- (void)setPattern:(PXPattern *)pattern;

- (IBAction)save:sender;
- (IBAction)load:sender;
- (IBAction)deleteSelected:sender;
- (IBAction)newPattern:sender;

@end

@interface NSObject(PXPatternEditorControllerDelegate)
- (void)patternEditor:(PXPatternEditorController *)ed finishedWithPattern:(PXPattern *)pat;
@end
