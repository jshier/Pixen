//
// PXNotifications.m
// Pixen
//
// Created by Joe Osborn on 2005.05.09.

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
//


#import "PXNotifications.h"

NSString *PXLayerSelectionDidChangeName = @"PXLayerDidChange";
NSString *PXCanvasLayerSelectionDidChangeName = @"PXCanvasLayerDidChange";
NSString *PXCanvasSizeChangedNotificationName = @"PXCanvasSizeChanged";
NSString *PXCanvasChangedNotificationName = @"PXCanvasChanged";
NSString *PXPatternChangedNotificationName = @"PXPatternChanged";
NSString *PXCanvasSelectionChangedNotificationName = @"PXCanvasSelectionChanged";
NSString *PXCanvasSelectionStatusChangedNotificationName = @"PXCanvasSelectionStatusChanged";
NSString *PXCanvasLayersChangedNotificationName = @"PXCanvasLayersChanged";
NSString *PXToolDidChangeNotificationName = @"PXToolDidChange";
NSString *PXToolColorDidChangeNotificationName = @"PXToolColorDidChange";
NSString *PXSelectionMaskChangedNotificationName = @"PXSelectionMaskChanged";
NSString *PXBackgroundChangedNotificationName = @"PXBackgroundChanged";
NSString *PXBackgroundTemplateInstalledNotificationName = @"PXBackgroundTemplateInstalled";
NSString *PXUserPalettesChangedNotificationName = @"PXUserPalettesChanged";
NSString *PXPatternsChangedNotificationName = @"PXPatternsChanged";

NSString *PXDocumentOpenedNotificationName = @"PXDocumentOpened";
NSString *PXDocumentWillCloseNotificationName = @"PXDocumentWillClose";
NSString *PXDocumentDidCloseNotificationName = @"PXDocumentDidClose";
NSString *PXDocumentChangedDisplayNameNotificationName = @"PXDocumentChangedDisplayName";

NSString *PXToolDoubleClickedNotificationName = @"PXToolDoubleClicked";

NSString *PXPaletteChangedNotificationName = @"PXPaletteChanged";
NSString *PXPaletteRemovedColorNotificationName = @"PXPaletteRemovedColor";
NSString *PXPaletteSwappedColorsNotificationName = @"PXPaletteSwappedColors";
NSString *PXPaletteMovedColorNotificationName = @"PXPaletteMovedColor";
NSString *PXPaletteCycledColorsNotificationName = @"PXPaletteCycledColors";
NSString *PXPaletteChangedColorNotificationName = @"PXPaletteChangedColor";
NSString *PXPaletteAddedColorNotificationName = @"PXPaletteAddedColor";
NSString *PXPaletteResizedNotificationName = @"PXPaletteResized";
NSString *PXPaletteLockedNotificationName = @"PXPaletteLocked";
NSString *PXPaletteUnlockedNotificationName = @"PXPaletteUnlocked";

NSString *PXUnlockToolSwitcherNotificationName = @"PXUnlockToolSwitcher";
NSString *PXLockToolSwitcherNotificationName = @"PXLockToolSwitcher";