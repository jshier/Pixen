//
//  NSString+Comparison.m
//  Pixen
//
//  Created by Joe Osborn on 2009.12.17.
//  Copyright 2009 God-Bear Productions. All rights reserved.
//

#import "NSString+Comparison.h"



@implementation NSString(CompareNumeric)

- (NSComparisonResult)compareNumeric:other
{
	return [self compare:other options:NSNumericSearch | NSCaseInsensitiveSearch];
}

@end