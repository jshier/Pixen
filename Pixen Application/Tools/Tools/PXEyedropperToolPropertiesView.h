//
//  PXEyedropperToolPropertiesView.h
//  Pixen
//
//  Created by Andy Matuschak on 7/8/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXToolPropertiesView.h"

typedef enum _PXEyedropperColorSourceType
{
	PXMergedLayersColorSource,
	PXActiveLayerColorSource
} PXEyedropperColorSourceType;

typedef enum _PXToolButtonType
{
	PXLeftButtonTool,
	PXRightButtonTool
} PXToolButtonType;

@interface PXEyedropperToolPropertiesView : PXToolPropertiesView {
	PXEyedropperColorSourceType colorSource;
	PXToolButtonType buttonType;
	
	NSMatrix *targetMatrix;
}

- (PXEyedropperColorSourceType)colorSource;
- (PXToolButtonType)targetToolButton;

- (void)setButtonType:(PXToolButtonType)buttonType;
- (IBAction)colorSourceChanged:sender;
- (IBAction)targetChanged:sender;

@end
