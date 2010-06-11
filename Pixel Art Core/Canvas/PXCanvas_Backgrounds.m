//
//  PXCanvas_Backgrounds.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvas_Backgrounds.h"
#import "PXBackgrounds.h"
#import "PXBackgroundConfig.h"
#import "PXLayer.h"

@implementation PXCanvas(Backgrounds)

- mainBackground
{
	return [bgConfig mainBackground];   
}

- (void)setMainBackground:bg
{
	[bgConfig setMainBackground:bg];
}

- alternateBackground
{
	return [bgConfig alternateBackground];
}

- (void)setAlternateBackground:bg
{
	[bgConfig setAlternateBackground:bg];
}

- mainPreviewBackground
{
	return [bgConfig mainPreviewBackground];
}

- (void)setMainPreviewBackground:bg
{
	[bgConfig setMainPreviewBackground:bg];
}

- alternatePreviewBackground
{
	return [bgConfig alternatePreviewBackground];
}

- (void)setAlternatePreviewBackground:bg
{
	[bgConfig setAlternatePreviewBackground:bg];
}

@end
