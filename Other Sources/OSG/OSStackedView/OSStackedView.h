//
//  OSStackedView.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.04.

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

#import <Cocoa/Cocoa.h>


@interface OSStackedView : NSView {
	id delegate;
	id views;
	NSInteger tag;
	id selectedElement;
	id target;
	SEL singleAction, doubleAction;
	
	NSPoint dragOffset;
}
- (NSView *)selectedView;
- (NSUInteger)selectedRow;
- (void)stackSubview:(NSView *)sub;
- (void)unstackSubview:(NSView *)sub;
- (void)clearStack;
- (void)restackViews;

- (void)setTarget:tar;
- (void)setAction:(SEL)act;
- (void)setDoubleAction:(SEL)act;

- (void)setTag:(NSInteger)newTag;
- (NSInteger)tag;
@end

@interface NSObject(OSStackedViewDelegate)

- (void)stackedView:(OSStackedView *)aStackedView
	dragMovedToScreenPoint:(NSPoint)point;

- (BOOL)stackedView:(OSStackedView *)aStackedView
		  writeRows:(NSArray *)rows
	   toPasteboard:(NSPasteboard *)pboard;

- (NSDragOperation)stackedView:(OSStackedView *)aStackedView 
				  validateDrop:(id <NSDraggingInfo>)info;

- (NSDragOperation)stackedView:(OSStackedView *)aStackedView
					updateDrag:(id <NSDraggingInfo>)info;

- (BOOL)stackedView:(OSStackedView *)aStackedView
	 draggingExited:(id <NSDraggingInfo>)info;

- (BOOL)stackedView:(OSStackedView *)aStackedView
		 acceptDrop:(id <NSDraggingInfo>)info;

- (void)stackedView:(OSStackedView *)aStackedView 
	   concludeDrag:(id <NSDraggingInfo>)info;

- (void)stackedView:(OSStackedView *)aStackedView
 dragOperationEnded:(NSDragOperation)drag
		 insideView:(BOOL)inside
	insideSuperview:(BOOL)inSuper;


- (void)deleteKeyPressedInStackedView:(OSStackedView *)aStackedView;

@end
