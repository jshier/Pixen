//
//  PXLineTool.m
//  Pixen-XCode


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

//  Created by Ian Henderson on Wed Dec 10 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXLineTool.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"

@implementation PXLineTool

- (NSString *)name
{
	return NSLocalizedString(@"LINE_NAME", @"Line Tool");
}

-(NSString *) actionName
{
	return NSLocalizedString(@"LINE_ACTION", @"Drawing Line");
}

// Line tool doesn't need center locking, just gets in the way...

- (BOOL)optionKeyDown
{
	return NO;
}

- (BOOL)optionKeyUp
{
	return NO;
}

- (BOOL)supportsAdditionalLocking
{
	return YES;
}


- (BOOL)shouldUseBezierDrawing
{
	return shouldUseBezierDrawing || isClicking;
}

- (void)drawFromPoint:(NSPoint)origin
				   toPoint:(NSPoint)finalPoint
				  inCanvas:(PXCanvas *) canvas
{
	if ([canvas canDrawAtPoint:origin])
		[self drawPixelAtPoint:origin inCanvas:canvas];
	[self drawLineFrom:origin to:finalPoint inCanvas:canvas];
}

- (void)finalDrawFromPoint:(NSPoint)origin
				   toPoint:(NSPoint)finalPoint
				  inCanvas:(PXCanvas *) canvas
{
	shouldUseBezierDrawing = NO;
	[self drawPixelAtPoint:origin inCanvas:canvas];
	[self drawLineFrom:origin to:finalPoint inCanvas:canvas];
}

@end
