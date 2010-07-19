//  PXCanvas.h
//  Pixen

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  Created by Joe Osborn on Sat Sep 13 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "PXPalette.h"
#import "PXLayer.h"
#import "PXGrid.h"

typedef BOOL * PXSelectionMask;

@class PXBackgroundConfig, PXBackground;

@interface PXCanvas : NSObject <NSCopying>
{
	NSMutableArray *layers;
	
//I want to move these to the document somehow, eventually.
//Maybe for Pixen 5... but it would require a huge overhaul
//of mostly everything to allow for moving around responsibilities
//at this point.  is it worth it?  yeah, probably.  but do I have time
//for it now?  well...  --joe
	PXLayer *activeLayer;
	
	PXSelectionMask selectionMask;
	BOOL hasSelection;
	NSPoint selectionOrigin;
	
	NSRect canvasRect;  //Cached because [self size] and NSMakeRect slow things down when containsPoint is called a bunch
	NSRect selectedRect;
	NSUndoManager *undoManager; // Cached from PXCanvasDocument
	NSMutableArray *drawnPoints, *oldColors, *newColors;

//these are slightly easier to move, but will still suck to move.
	PXBackgroundConfig *bgConfig;
	PXGrid *grid;
	BOOL wraps;
	NSSize previewSize;
  
  BOOL frequencyPaletteDirty;
  NSCountedSet *minusColors;
  NSCountedSet *plusColors;
}

- (void)refreshWholePalette;
- (void)refreshPaletteDecreaseColorCount:(NSColor *)down increaseColorCount:(NSColor *)up;

- (void)setUndoManager:(NSUndoManager *)manager;
- (NSUndoManager *)undoManager;

- (id)duplicateWithinAnimation;
- (void)recacheSize;

- (NSSize)size;
- (void)setSize:(NSSize)newSize 
 	withOrigin:(NSPoint)origin
backgroundColor:(NSColor *)color;
- (void)setSize:(NSSize)aSize;

- (PXGrid *)grid;
- (void)setGrid:(PXGrid *)g;

- (NSSize)previewSize;
- (void)setPreviewSize:(NSSize)size;

- (void)beginUndoGrouping;
- (void)endUndoGrouping;
- (void)endUndoGrouping:(NSString *)action;
- (void)updatePreviewSize;
- (NSColor *)eraseColor;

- (PXPalette *)createFrequencyPalette;

@end
