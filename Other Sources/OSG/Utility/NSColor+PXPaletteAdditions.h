//
//  NSColor+PXPaletteAdditions.h
//  Pixen
//
//  Created by Andy Matuschak on 7/2/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor(PXPaletteAdditions)

- (unsigned int)paletteHash;
- (float)distanceTo:(NSColor *)other;

@end
