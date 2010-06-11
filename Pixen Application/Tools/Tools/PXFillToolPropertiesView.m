//
//  PXFillToolPropertiesView.m
//  Pixen
//
//  Created by Andy Matuschak on 7/2/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXFillToolPropertiesView.h"


@implementation PXFillToolPropertiesView

- (NSString *)nibName
{
	return @"PXFillToolPropertiesView";
}

- init
{
	[super init];
	tolerance = 0;
	[self willChangeValueForKey:@"contiguous"];
	contiguous = YES;
	[self didChangeValueForKey:@"contiguous"];
	return self;
}

- (IBAction)toleranceChanged:sender
{
	tolerance = [sender intValue];
}

- (int)tolerance
{
	return tolerance;
}

- (BOOL)contiguous
{
	return contiguous;
}

@end
