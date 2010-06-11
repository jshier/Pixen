//
//  NSMutableArray+ReorderingAdditions.m
//  Pixen
//
//  Created by Ian Henderson on 10.08.05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "NSMutableArray+ReorderingAdditions.h"


@implementation NSMutableArray(ReorderingAdditions)

- (void)moveObjectAtIndex:(int)initialIndex toIndex:(int)targetIndex
{
	if(targetIndex == initialIndex) { return; }
	id object = [[[self objectAtIndex:initialIndex] retain] autorelease];
	[self removeObjectAtIndex:initialIndex];
	int finalIndex = targetIndex;
	if (finalIndex > initialIndex) {
		finalIndex--;
	}
	[self insertObject:object atIndex:finalIndex];
}

@end
