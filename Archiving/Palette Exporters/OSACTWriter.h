//
//  OSACTWriter.h
//  PALExport
//
//  Created by Andy Matuschak on 8/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"

@interface OSACTWriter : NSObject {

}

+ sharedACTWriter;
- (NSData *)palDataForPalette:(PXPalette *)palette;

@end
