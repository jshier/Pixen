//
//  PXLayerDetailsView.h
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

//  Created by Joe Osborn on Thu Feb 05 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "PXLayer.h"
@interface PXLayerDetailsView : NSView 
{
	IBOutlet id name;
	IBOutlet id thumbnail;
	IBOutlet id opacity;
	IBOutlet id opacityText;
	IBOutlet id view;
	IBOutlet id visibility;

	id layerController;
	
	PXLayer *layer;
	BOOL isHidden; //for backwards compatibility with 10.2
	NSRect changedRect;	
}
- (void)setLayerController:cont;
- layer;
- (void)focusOnName;
- opacityText;
- (NSTextField *)name;
- (id) initWithLayer:(PXLayer *) aLayer;

- (void)setLayer:(PXLayer *)aLayer;

- (void)updatePreview:(NSNotification *) notification;

- (IBAction)opacityDidChange:(id) sender;
- (IBAction)nameDidChange:(id) sender;
- (IBAction)visibilityDidChange:(id)sender;

- (BOOL)isHidden;
- (void)setHidden:(BOOL)shouldHide;
@end
