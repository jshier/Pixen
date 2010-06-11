//
//  PXLayerTextField.h
//  Pixen
//
//  Created by Andy Matuschak on 6/28/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXLayerTextField : NSTextField {
	BOOL isEditing;
	BOOL isFirstEnd;
	BOOL reachedByClicking;
}
- (void)useEditAppearance;
@end
