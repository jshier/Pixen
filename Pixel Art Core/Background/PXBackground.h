//
//  PXBackground.h
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
//
//  Created by Joe Osborn on Mon Oct 27 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

#import <AppKit/NSNibDeclarations.h>

@class PXCanvas;
@class NSString;
@class NSAffineTransform;
@class NSView;
@class NSImage;

@interface PXBackground : NSObject <NSCoding, NSCopying> 
{
	IBOutlet NSView * configurator;
	id name;
	
	NSSize cachedImageSize;
	NSImage *cachedImage;
}

- (NSImage *)previewImageOfSize:(NSSize)size;

- (NSString *) defaultName;
- (NSString *)name;
- (void)setName:(NSString *) aName;

- (void)setConfiguratorEnabled:(BOOL)enabled;
- (NSView *)configurator;

- (NSString *)nibName;

- (void)changed;

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect;

- (void)drawRect:(NSRect)rect 
      withinRect:(NSRect)wholeRect
   withTransform:(NSAffineTransform *)aTransform
		onCanvas:(PXCanvas *)aCanvas;
@end
