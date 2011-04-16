//
//  PXLayerController.m
//  Pixen-XCode
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

//  Created by Joe Osborn on Thu Feb 05 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXLayerController.h"
#import "PXLayerDetailsView.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"
#import "SubviewTableViewController.h"
#import "PXNotifications.h"
#import "PXCanvasDocument.h"
#import "PXAnimationDocument.h"
#import "RBSplitSubview.h"

@implementation PXLayerController

- init
{
	[super init];
	[NSBundle loadNibNamed:@"PXLayerController" owner:self];
	views = [[NSMutableArray alloc] initWithCapacity:8];
	[self selectRow:-1];
	[tableView registerForDraggedTypes:[NSArray arrayWithObject:PXLayerRowPboardType]];
	return self;
}

-(id) initWithCanvas:(PXCanvas*) aCanvas
{
	if ( ! ( self = [self init] ) ) 
		return nil;	
	[self setCanvas:aCanvas];
	return self;
}

- (void)setCanvas:(PXCanvas *)aCanvas
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc removeObserver:self];
	[aCanvas retain];
	[canvas release];
	canvas = aCanvas;
	
	[nc addObserver:self
		   selector:@selector(reloadData:)
			   name:PXCanvasLayersChangedNotificationName 
			 object:canvas];
	
	[nc addObserver:self
		   selector:@selector(canvasLayerChanged:) 
			   name:PXCanvasLayerSelectionDidChangeName 
			 object:canvas];
	
	[self reloadData:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[views release];
	[canvas release];
	[tableViewController release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[tableView setIntercellSpacing:NSMakeSize(0,1)];
	tableViewController = [[SubviewTableViewController controllerWithViewColumn:[tableView tableColumnWithIdentifier:@"details"]] retain];
	[tableViewController setDelegate:self];
}

- (void)resetViewHiddenStatus
{
	BOOL shouldBeHidden = [subview isCollapsed];
	
	NSEnumerator *enumerator = [views objectEnumerator];
	id current;
	while ( (current = [enumerator nextObject] ) )
	{
		[current setHidden:shouldBeHidden];
	}
}

- (NSView *)view
{
	return view;
}

- document
{
	return document;
}

- (void)setDocument:doc
{
	document = doc;
}

- (NSView *) tableView:(NSTableView *)tableView viewForRow:(NSInteger)row
{
	return [views objectAtIndex:[self invertLayerIndex:row]];	
}

- (void)canvasLayerChanged:(NSNotification *) notification
{
	[self selectRow:[self invertLayerIndex:[[canvas layers] indexOfObject:[canvas activeLayer]]]];
}

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)view
{
	return [[canvas layers] count];
}

- (void)reloadData:(NSNotification *) aNotification
{
	NSUInteger i, selectedRow;
	
	if ([tableView selectedRow] == -1)
	{
		[self selectRow:0]; 
	}
	
	selectedRow = [self invertLayerIndex:[tableView selectedRow]];
	for (i = 0; i < [[canvas layers] count]; i++)
	{
		PXLayer *layer = [[canvas layers] objectAtIndex:i];
		if([views count] > i)
		{
			[(PXLayerDetailsView *)[views objectAtIndex:i] setLayer: layer];
			[[views objectAtIndex:i] updatePreview:nil];
		}
		else
		{
			PXLayerDetailsView *newView = [[[PXLayerDetailsView alloc] initWithLayer:layer] autorelease];
			[newView setLayerController:self];
			[views addObject:newView];
			[newView updatePreview:nil];
		}
	}
	for (i = [[canvas layers] count]; i < [views count]; i++)
	{
		[[views objectAtIndex:i] setLayer:nil];
	}
	[views removeObjectsInRange:NSMakeRange(i, [views count] - i)];
	[self selectRow:[self invertLayerIndex:selectedRow]];
//	[self resetViewHiddenStatus];
	
	if ([[[aNotification userInfo] objectForKey:PXCanvasOldLayersCountKey] intValue] == 1 
		&& [[canvas layers] count] == 2
		&& [subview isCollapsed])
	{
		[self toggle:self];
	}
	[tableViewController reloadTableView];
	[tableView setNeedsDisplay:YES];
	id newLayer = [[aNotification userInfo] objectForKey:PXCanvasNewLayerKey];
	if(newLayer)
	{
		[tableView display];
		for (id current in views)
		{
			if([current layer] == newLayer)
			{
				[current focusOnName];
			}
		}
	}
	//else if ([[canvas layers] count] && [canvas activeLayer])
	//	[self canvasLayerChanged:nil];
}

- (IBAction)nextLayer:(id) sender
{
	[self selectRow:[tableView selectedRow]+1];
	[self selectLayer:[[canvas layers] objectAtIndex:[self invertLayerIndex:[tableView selectedRow]]]];
}

- (IBAction)previousLayer:(id) sender
{
	[self selectRow:[tableView selectedRow]-1];
	[self selectLayer:[[canvas layers] objectAtIndex:[self invertLayerIndex:[tableView selectedRow]]]];
}

- (void)selectRow:(NSUInteger)index
{
	if ([tableView respondsToSelector:@selector(selectRowIndexes:byExtendingSelection:)])
	{
		
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
	}
	else
	{
		[tableView selectRow:index byExtendingSelection:NO];
	}
	[self updateRemoveButtonStatus];
}

- (IBAction)displayHelp:sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"workingwithlayers" inBook:@"Pixen Help"];	
}

- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSUInteger)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"visible"])
	{
		return [NSNumber numberWithBool:[[[canvas layers] objectAtIndex:[self invertLayerIndex:rowIndex]] visible]];
	}
	return nil;
}

/*
 * TableView dataSource
 */

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSUInteger)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"visible"])
	{
		[[[canvas layers] objectAtIndex:[self invertLayerIndex:rowIndex]] setVisible:[anObject boolValue]];
		[canvas changedInRect:NSMakeRect(0,0,[canvas size].width, [canvas size].height)];
	}
}

- (void)setSubview:(RBSplitSubview *)sv
{
	subview = sv;
}

- (void)toggle:(id)sender
{
	if([subview isCollapsed])
	{
		[subview expand];
	}
	else
	{
		[subview collapse];
	}
//	[self resetViewHiddenStatus];
	[[subview window] display];
}

- (IBAction)addLayer:(id)sender
{
	layersCreated++;
	PXLayer *layer =[[PXLayer alloc] initWithName:[NSString stringWithFormat:NSLocalizedString(@"New Layer %d", @"New Layer %d"), layersCreated] size:[canvas size] fillWithColor:[[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]];
	
	//[[[self document] undoManager] beginUndoGrouping];
	[canvas addLayer:layer];
	//[[[self document] undoManager] endUndoGrouping];
	[self selectRow:0];
	[self selectLayer:nil];
}

- (PXCanvas *)canvas
{
	return canvas;
}

- (IBAction)duplicateLayer:(id)sender
{
	[canvas duplicateLayerAtIndex:[self invertLayerIndex:[tableView selectedRow]]];
}

- (void)duplicateLayerObject:(PXLayer *)layer
{
	[canvas duplicateLayerAtIndex:[[canvas layers] indexOfObject:layer]];
}

- (void)removeLayerAtCanvasLayersIndex:(NSUInteger)index
{
	if([[canvas layers] count] <= 1) { return; }
	[canvas removeLayerAtIndex:index];
    NSUInteger newIndex = MAX(index - 1, 0);
	[self selectRow:[self invertLayerIndex:newIndex]];
	[self selectLayer:nil];
}

- (void)removeLayerObject:(PXLayer *)layer
{
	[self removeLayerAtCanvasLayersIndex:[[canvas layers] indexOfObject:layer]];
}

- (IBAction)removeLayer:(id) sender
{
	if ([tableView selectedRow] == -1) 
		return; 
	
	[self removeLayerAtCanvasLayersIndex:[self invertLayerIndex:[tableView selectedRow]]];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self selectLayer:self];
}

- (IBAction)selectLayer:(id)sender
{
	if ([tableView selectedRow] == -1)
	{
		[self selectRow:[self invertLayerIndex:[[canvas layers] indexOfObject:[canvas activeLayer]]]]; 
		return;
	}
	
	NSInteger row = [self invertLayerIndex:[tableView selectedRow]];
	
	[self selectRow:[self invertLayerIndex:row]];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc postNotificationName:PXLayerSelectionDidChangeName
					  object:self
					userInfo:[NSDictionary dictionaryWithObject:[[canvas layers] objectAtIndex:row]
														 forKey:PXLayerKey]];
}

- (void)updateRemoveButtonStatus
{
	if ([[canvas layers] count] == 1)
		[removeButton setEnabled:NO];
	else 
		[removeButton setEnabled:YES];
}

- (NSInteger)invertLayerIndex:(NSInteger)anIndex
{
	return [[canvas layers] count] - anIndex - 1;
}

- (void)mergeDownLayerAtCanvasLayersIndex:(NSUInteger)ind
{
	NSUInteger index = ind;
	if (index >= [[canvas layers] count]) {
		index = 0;
	}
	if (index == 0) 
		return;
	BOOL wasActive = [[canvas layers] objectAtIndex:index] == [canvas activeLayer];
	[canvas mergeDownLayer:[[canvas layers] objectAtIndex:index]];
	if(wasActive)
	{
		[self selectRow:[self invertLayerIndex:index-1]];
		[self selectLayer:[[canvas layers] objectAtIndex:index-1]];
	}
	else
	{
		[self selectRow:[self invertLayerIndex:[canvas indexOfLayer:[canvas activeLayer]]]];
		[self selectLayer:[canvas activeLayer]];
	}
}

- (void)mergeDownLayerObject:(PXLayer *) layer
{
	[self mergeDownLayerAtCanvasLayersIndex:[[canvas layers] indexOfObject:layer]];
}

- (void)mergeDown
{
	[self mergeDownLayerAtCanvasLayersIndex:[self invertLayerIndex:[tableView selectedRow]]];
}

- (BOOL)tableView:(NSTableView *)aTableView
		writeRows:(NSArray *)rows
	 toPasteboard:(NSPasteboard *)pboard
{
	[pboard declareTypes:[NSArray arrayWithObject:PXLayerRowPboardType] owner:self];
	
	[pboard setString:[NSString stringWithFormat:@"%d", [self invertLayerIndex:[[rows objectAtIndex:0] intValue]]] forType:PXLayerRowPboardType];
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView 
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(NSUInteger)row
	   proposedDropOperation:(NSTableViewDropOperation)operation
{
	if (![[[info draggingPasteboard] types] containsObject:PXLayerRowPboardType])
	{
		return NSDragOperationNone; 
	}
	
	NSInteger sourceRow = [self invertLayerIndex:[[[info draggingPasteboard] stringForType:PXLayerRowPboardType] intValue]];
	if ( row == sourceRow + 1 || row == sourceRow)
	{
		return NSDragOperationNone;
	}
		
	if (operation == NSTableViewDropOn) 
	{ 
		if (row == sourceRow - 1)
			return NSDragOperationNone;
		[aTableView setDropRow:row dropOperation:NSTableViewDropAbove]; 
	}
	
	return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)aTableView
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)operation
{
	id layer = [[canvas layers] objectAtIndex:[[[info draggingPasteboard] stringForType:PXLayerRowPboardType] intValue]];
	[canvas moveLayer:layer toIndex:[self invertLayerIndex:row]];
	[self selectRow:[self invertLayerIndex:[[canvas layers] indexOfObject:layer]]];
	return YES;
}

- (void)deleteKeyPressedInTableView:tv
{
	[self removeLayer:self];
}

@end
