//
//  PXFillTool.h
//  Pixen-XCode
//
//  Created by Joe Osborn on Tue Nov 18 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXTool.h"
#import "PXLayer.h"


@interface PXFillTool : PXTool 
{
	BOOL commandDown;
}

int CombineAxis(int Xaxis, int Yaxis, int width, int height);

- (void)fillPointsFromPoint:(NSPoint)aPoint forCanvasController:(PXCanvasController *)controller;
- (BOOL)checkSelectionOnCanvas:(PXCanvas *)canvas;
- (void)fillPixelsInBOOLArray:(NSArray *)fillPoints withColor:(NSColor *)newColor withBoundsRect:(NSRect)bounds ofCanvas:(PXCanvas *)canvas;


@end
