//
//  PXLayerController.h
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

#import <Foundation/Foundation.h>
#import "SubviewTableViewController.h"
#import "PXCanvas.h"

@class PXLayer, RBSplitSubview;
@interface PXLayerController : NSResponder <SubviewTableViewControllerDataSourceProtocol> 
{
	IBOutlet id view;
	IBOutlet id tableView;
	PXCanvas *canvas;
	IBOutlet RBSplitSubview *subview;
	NSMutableArray *views;
	id tableViewController;
	IBOutlet id removeButton;
	id document;
	NSUInteger layersCreated;
}
-(id) initWithCanvas:(PXCanvas *)aCanvas;
- (void)toggle:(id)sender;
- (NSView *)view;
- (void)setSubview:(RBSplitSubview *)sv;
- (void)reloadData:(NSNotification *) aNotification;
- (void)setCanvas:(PXCanvas *) aCanvas;
- (PXCanvas *)canvas;

- (IBAction)addLayer: (id)sender;
- (IBAction)duplicateLayer: (id)sender;
- (void)duplicateLayerObject: (PXLayer *)layer;
- (IBAction)removeLayer: (id)sender;
- (void)removeLayerObject: (PXLayer *)layer;
- (IBAction)selectLayer: (id)sender;
- (void)selectRow:(NSUInteger)index;

- (IBAction)nextLayer: (id)sender;
- (IBAction)previousLayer: (id)sender;

- (void)mergeDown;

- (void)updateRemoveButtonStatus;

- (void)mergeDownLayerObject:(PXLayer *)layer;

- (NSInteger)invertLayerIndex:(NSInteger)anIndex;

	/*
	 * Table View dateSource
	 */
- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSUInteger)rowIndex;

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(NSUInteger)rowIndex;

	/*
	 * TableView drag & drop 
	 */
- (NSDragOperation)tableView:(NSTableView *)aTableView
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(NSUInteger)row
       proposedDropOperation:(NSTableViewDropOperation)operation;

@end
