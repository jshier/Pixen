//
//  PXFillToolPropertiesView.h
//  Pixen
//
//  Created by Andy Matuschak on 7/2/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXToolPropertiesView.h"

@interface PXFillToolPropertiesView : PXToolPropertiesView
{
	int tolerance;
	BOOL contiguous;
}

- (IBAction)toleranceChanged:sender;
- (int)tolerance;
- (BOOL)contiguous;

@end
