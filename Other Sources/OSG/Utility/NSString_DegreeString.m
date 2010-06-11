//
//  NSString_DegreeString.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.01.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "NSString_DegreeString.h"


@implementation NSString(DegreeString)
+ (NSString *)degreeString
{
	UniChar degree[] = { 0x00B0 };
	return [self stringWithCharacters:degree length:1];
}
@end
