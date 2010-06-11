//
//  PXHotkeyFormatter.m
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

//  Created by Andy Matuschak on Sun Apr 04 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXHotkeyFormatter.h"
#import <Foundation/NSCharacterSet.h>

@implementation PXHotkeyFormatter

-(NSString *) stringForObjectValue:anObject
{
  if (![anObject isKindOfClass:[NSString class]]) 
    return nil; 

  if ([anObject length] > 0)
    {
      unichar theCharacter = [anObject characterAtIndex:([anObject length] - 1)];
      if(![[NSCharacterSet letterCharacterSet] characterIsMember:theCharacter])
	{
	  return nil;
	}
      return [NSString stringWithFormat:@"%c", theCharacter];
    }
  else
    return @"";
}

- (BOOL)isPartialStringValid:(NSString *)partialString 
	    newEditingString:(NSString **)newString
	    errorDescription:(NSString **)error
{
  if ([partialString length] > 0)
    {
      unichar theCharacter = [partialString characterAtIndex:([partialString length] - 1)];
      if(![[NSCharacterSet letterCharacterSet] characterIsMember:theCharacter])
	{
	  *newString = nil;
	  return NO;
	}
      if ([partialString length] > 1) 
	{
	  *newString = [NSString stringWithFormat:@"%c", theCharacter];
	  return NO;
	}
    }
  return YES;
}

- (BOOL)getObjectValue:(id *)anObject
	     forString:(NSString *) string
      errorDescription:(NSString **)error;
{
  *anObject = [[string copy] autorelease];
  return YES;
}

//FIXME: why attributes param is for ? 
//Required argument of this method for NSFormatter subclasses to implement.
- (NSAttributedString *)attributedStringForObjectValue:(id)anObject
				     defaultAttributes:attributes
{
	return [[[NSAttributedString alloc] initWithString:[self stringForObjectValue:anObject]] autorelease];
}

@end
