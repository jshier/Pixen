//
//  PXMagicWandTool.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on Sat Jun 12 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXFillTool.h"
#import "PXCanvas.h"

@interface PXMagicWandTool : PXFillTool
{
	BOOL isMoving, isAdding, isSubtracting;
	NSPoint origin;
	NSRect selectedRect, lastSelectedRect;
	int oldLayerIndex, oldLastLayerIndex;
	
	PXSelectionMask oldMask;
}

@end

