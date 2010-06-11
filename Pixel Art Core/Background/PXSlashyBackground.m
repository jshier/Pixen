//  PXSlashyBackground.m
//  Pixen
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
//  Created by Joe Osborn on Thu Sep 18 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXSlashyBackground.h"

@implementation PXSlashyBackground

-(NSString *) defaultName
{
    return NSLocalizedString(@"SLASHED_BACKGROUND", @"Slashed Background");
}

- (void)drawBackgroundLinesInRect:(NSRect)aRect
{
    //rounding off the values in aRect... we can't have them being floating points, can we?
    NSRect rect = NSMakeRect((int)(aRect.origin.x), (int)(aRect.origin.y), (int)(aRect.size.width), (int)(aRect.size.height));
    float oldWidth = [NSBezierPath defaultLineWidth];
    BOOL oldShouldAntialias = [[NSGraphicsContext currentContext] shouldAntialias];
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    [NSBezierPath setDefaultLineWidth:10];
	
    [color set];
    int higherOrigin = (int)((rect.size.width >= rect.size.height) ? rect.origin.x : rect.origin.y);
    int higherDimension = 2*(int)((rect.size.width >= rect.size.height) ? rect.size.width : rect.size.height);
    int i = (int)(higherOrigin-higherDimension);
    while(i < (higherOrigin+higherDimension))
    {
        NSPoint startPoint = NSMakePoint(i-20, rect.origin.y-20);
        NSPoint endPoint = NSMakePoint(i+2*rect.size.width+20, rect.origin.y+2*rect.size.width+20);
        if(rect.size.height > rect.size.width)
        {
            startPoint = NSMakePoint(rect.origin.x-20, i-20);
            endPoint = NSMakePoint(rect.origin.x+2*rect.size.height+20, i+2*rect.size.height+20);
        }
        NSAssert(endPoint.x-startPoint.x == endPoint.y-startPoint.y, @"Bad points!");
        [NSBezierPath strokeLineFromPoint:startPoint toPoint:endPoint];
        i+=33;
    }
    [NSBezierPath setDefaultLineWidth:oldWidth];
    [[NSGraphicsContext currentContext] setShouldAntialias:oldShouldAntialias];
}

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect
{
    [backColor set];
    
    NSRectFill(wholeRect);
    [self drawBackgroundLinesInRect:wholeRect];
}

@end
