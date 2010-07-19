//
//  PXCanvasWindowController_Zooming.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvasWindowController_Zooming.h"
#import "PXCanvasView.h"
#import "PXCanvasController.h"

@implementation PXCanvasWindowController(Zooming)

- (void)prepareZoom
{
	NSArray *itemsObjects = [NSArray arrayWithObjects:
		[NSNumber numberWithInt:3000], 
		[NSNumber numberWithInt:2000], 
		[NSNumber numberWithInt:1000], 
		[NSNumber numberWithInt:800], 
		[NSNumber numberWithInt:500], 
		[NSNumber numberWithInt:400],
		[NSNumber numberWithInt:200], 
		[NSNumber numberWithInt:100],
		[NSNumber numberWithInt:50], 
		nil];
	[zoomPercentageBox removeAllItems];
	[zoomPercentageBox addItemsWithObjectValues:itemsObjects];
	// If you're looking for arbitrarily hard-coded percentages, they're right here!
	[zoomPercentageBox selectItemAtIndex:7];
	[zoomStepper setIntValue:7];	
}

- (IBAction)zoomToFit:sender
{
	[self zoomToFit];
}

- (void)zoomToIndex:(float)index
{
	if(index < 0 || index >= [zoomPercentageBox numberOfItems]) { 
		NSBeep();
	}
	
	[zoomPercentageBox selectItemAtIndex:index];
	[zoomStepper setIntValue:index];
	[[canvasController view] setZoomPercentage:[zoomPercentageBox intValue]];
	[canvasController updateMousePosition:[[self window] mouseLocationOutsideOfEventStream]];
}

- (void)zoomToPercentage:(NSNumber *)percentage
{
	if( percentage == nil 
		|| [percentage isEqual:[NSNumber numberWithInt:0]] 
		|| [[[percentage description] lowercaseString] isEqualToString:PXInfinityDescription] 
		|| [[[percentage description] lowercaseString] isEqualToString:PXNanDescription]) 
	{ 
		[self zoomToPercentage:[NSNumber numberWithFloat:100]]; 
		return;
	}
	if([percentage intValue] > 10000)
	{
		[self zoomToIndex:0];
		return;
	}
	// Kind of a HACK, could change if the description changes to display something other than inf or nan on such numbers.
	//Probably not an issue, but I'll mark it so it's easy to find if it breaks later.
	
	if( ! [[zoomPercentageBox objectValues] containsObject:percentage])
	{
		id values = [NSMutableArray arrayWithArray:[zoomPercentageBox objectValues]];
		[values addObject:percentage];
		[values sortUsingSelector:@selector(compare:)];
		[zoomPercentageBox removeAllItems];
		[zoomPercentageBox addItemsWithObjectValues:[[values reverseObjectEnumerator] allObjects]];
	}
	
	[zoomPercentageBox selectItemWithObjectValue:percentage];
	[self zoomToIndex:[zoomPercentageBox indexOfSelectedItem]];
}

- (void)zoomToFit
{
	if([canvas size].width <= 0 ||
	   [canvas size].height <= 0)
	{
		return;
	}
	NSRect contentFrame = [[[canvasController scrollView] contentView] frame];
    float xRatio = NSWidth(contentFrame)/[canvas size].width;
    float yRatio = NSHeight(contentFrame)/[canvas size].height;
	float pct = (NSWidth(contentFrame) > [canvas size].width || NSHeight(contentFrame) > [canvas size].height) ? (floorf(xRatio < yRatio ? xRatio : yRatio))*100 : 100.0;
    [self zoomToPercentage:[NSNumber numberWithFloat:MIN(pct, 10000)]];
}

- (void)canvasController:(PXCanvasController *)controller zoomInOnCanvasPoint:(NSPoint)point
{
	[self zoomIn:self];
}

- (void)canvasController:(PXCanvasController *)controller zoomOutOnCanvasPoint:(NSPoint)point
{
	[self zoomOut:self];
}

- (void)zoomToFitCanvasController:(PXCanvasController *)controller
{
	[self zoomToFit:self];	
}

- (IBAction)zoomIn: (id) sender
{
	[self zoomToIndex:[zoomStepper intValue]-1];
}

- (IBAction)zoomOut: (id) sender
{
	[self zoomToIndex:[zoomStepper intValue]+1];
}

- (IBAction)zoomStandard: (id) sender
{ 
	[self zoomToIndex:[zoomPercentageBox indexOfItemWithObjectValue:[NSNumber numberWithInt:100]]];
}

- (IBAction)zoomPercentageChanged:sender
{
	[self zoomToPercentage:[zoomPercentageBox objectValue]];
}

- (IBAction)zoomStepperStepped:(id) sender
{
	if([zoomStepper intValue] >= [zoomPercentageBox numberOfItems]) 
	{ 
		NSBeep();
		[zoomStepper setIntegerValue:[zoomPercentageBox numberOfItems]-1]; 
		return; 
	}
	[self zoomToIndex:[zoomStepper intValue]];
}


@end
