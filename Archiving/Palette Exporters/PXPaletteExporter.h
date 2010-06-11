//
//  PXPaletteExporter.h
//  Pixen
//
//  Created by Andy Matuschak on 8/21/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"

@interface PXPaletteExporter : NSObject {
	NSSavePanel *savePanel;
	PXPalette *palette;
}

- (void)runWithPalette:(PXPalette *)palette inWindow:(NSWindow *)window;

@end
