//
//  PXCanvas_ApplescriptAdditions.m
//  Pixen
//
//  Created by Ian Henderson on Fri Mar 05 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXCanvas_ApplescriptAdditions.h"
#import "PXLayerController.h"
#import "PXLayer.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "PXNotifications.h"

@implementation PXCanvas(ApplescriptAdditions)

- handleGetColorScriptCommand:command
{
    NSDictionary *arguments = [command evaluatedArguments];
    return [self colorAtPoint:NSMakePoint([[arguments objectForKey:@"atX"] intValue], [[arguments objectForKey:@"atY"] intValue])];
}

- handleSetColorScriptCommand:command
{
    NSDictionary *arguments = [command evaluatedArguments];
    id colorArray = [arguments objectForKey:@"toColor"];
    NSColor *color = [NSColor colorWithDeviceRed:[[colorArray objectAtIndex:0] floatValue]/65535 green:[[colorArray objectAtIndex:1] floatValue]/65535 blue:[[colorArray objectAtIndex:2] floatValue]/65535 alpha:1.0f];
    NSPoint changedPoint = NSMakePoint([[arguments objectForKey:@"atX"] intValue], [[arguments objectForKey:@"atY"] intValue]);
    [self setColor:color atPoint:changedPoint];
    [self changedInRect:NSMakeRect(changedPoint.x, changedPoint.y, 1, 1)];
    return nil;
}

- handleAddLayerScriptCommand:command
{
	[self addLayer:[[PXLayer alloc] initWithName:[[command evaluatedArguments] objectForKey:@"layerName"] size:[self size]]];
	return nil;
}


- layerNamed:aName
{
	for (id current in layers)
	{
		if ([[current name] isEqualToString:aName])
		{
			return current;
		}
	}
	return nil;
}

- handleRemoveLayerScriptCommand:command
{
	id layer = [self layerNamed:[[command evaluatedArguments] objectForKey:@"layerName"]];
	if(layer != nil)
	{
		[self removeLayer:layer];
		[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasLayerSelectionDidChangeName object:self];
	}
	return nil;
}

- handleMoveLayerScriptCommand:command
{
	[self moveLayer:[layers objectAtIndex:[[[command evaluatedArguments] objectForKey:@"atIndex"] intValue]] toIndex:[[[command evaluatedArguments] objectForKey:@"toIndex"] intValue]];
	return nil;
}

- (void)setActiveLayerName:aName
{
	id layer = [self layerNamed:aName];
	if(layer != nil)
	{
		[self activateLayer:layer];
		[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasLayerSelectionDidChangeName object:self];
	}
}

- (int)height
{
    return (int)[self size].height;
}

- (void)setHeight:(int)height
{
    NSSize newSize = [self size];
    newSize.height = height;
    [self setSize:newSize];
}

- (int)width
{
    return (int)[self size].width;
}

- (void)setWidth:(int)width
{
    NSSize newSize = [self size];
    newSize.width = width;
    [self setSize:newSize];
}

@end
