//
//  PXPaletteImporter.h
//  Pixen
//
//  Created by Andy Matuschak on 8/22/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXPaletteImporter : NSObject {

}

- (void)importPaletteAtPath:(NSString *)path;
- (void)runInWindow:(NSWindow *)window;

@end
