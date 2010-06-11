//
//  PXCanvas_Archiving.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(Archiving) <NSCoding>

- (void)encodeWithCoder:(NSCoder *)coder;
- initWithCoder:(NSCoder *)coder;

@end
