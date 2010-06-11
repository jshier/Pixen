//  PXZoomTool.m
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

//  Created by Joe Osborn on Mon Oct 13 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXZoomTool.h"
#import "PXCanvasController.h"
#import "PXToolSwitcher.h"

@implementation PXZoomTool

- (NSString *)name
{
	return NSLocalizedString(@"ZOOM_NAME", @"Zoom Tool");
}

-(id) init
{
	if ( ! ( self = [super init] ) ) 
		return nil;
	
	zoomType = PXZoomIn;
	return self;
}

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *) controller
{
	if(zoomType == PXZoomIn)
    {
		[controller zoomInOnCanvasPoint:aPoint];
    }
	if(zoomType == PXZoomOut)
    {
		[controller zoomOutOnCanvasPoint:aPoint];
    }
}

- (BOOL)optionKeyUp
{
	zoomType = PXZoomIn;
	[switcher setIcon:[NSImage imageNamed:@"zoomIn"] forTool:self];
	return YES;
}

- (BOOL)optionKeyDown
{
	zoomType = PXZoomOut;
	[switcher setIcon:[NSImage imageNamed:@"zoomOut"] forTool:self];
	return YES;
}

@end
