//
//  PXEyedropperToolPropertiesView.m
//  Pixen
//
//  Created by Andy Matuschak on 7/8/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXEyedropperToolPropertiesView.h"


@implementation PXEyedropperToolPropertiesView

- init
{
	[super init];
	colorSource = PXMergedLayersColorSource;
	return self;
}

- (void)setButtonType:(PXToolButtonType)tbt
{
	buttonType = tbt;
	if (targetMatrix)
		[targetMatrix selectCellAtRow:tbt column:0];
}

- (void)awakeFromNib
{
	[targetMatrix selectCellAtRow:buttonType column:0];
}

- (NSString *)  nibName
{
    return @"PXEyedropperToolPropertiesView";
}

- (PXEyedropperColorSourceType)colorSource
{
	return colorSource;
}

- (PXToolButtonType)targetToolButton
{
	return buttonType;
}

- (IBAction)colorSourceChanged:sender
{
	colorSource = ([[sender selectedCell] tag]) ? PXActiveLayerColorSource : PXMergedLayersColorSource;
}

- (IBAction)targetChanged:sender
{
	buttonType = ([[sender selectedCell] tag]) ? PXRightButtonTool : PXLeftButtonTool;
}

@end
