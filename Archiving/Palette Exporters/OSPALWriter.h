//
//  OSPALWriter.h
//  PALExport
//
//  Created by Andy Matuschak on 8/15/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"

@interface OSPALWriter : NSObject {

}

+ sharedPALWriter;
- (NSData *)palDataForPalette:(PXPalette *)palette;

@end
