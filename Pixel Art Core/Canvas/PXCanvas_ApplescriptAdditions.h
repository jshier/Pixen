//
//  PXCanvas_ApplescriptAdditions.h
//  Pixen
//
//  Created by Ian Henderson on Fri Mar 05 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXCanvas.h"


@interface PXCanvas(ApplescriptAdditions)

- handleGetColorScriptCommand:command;
- handleSetColorScriptCommand:command;

- (int)height;
- (void)setHeight:(int)height;
- (int)width;
- (void)setWidth:(int)width;

@end
