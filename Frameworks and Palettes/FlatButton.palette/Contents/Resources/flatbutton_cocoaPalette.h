//
//  membrane_cocoaPalette.h
//  membrane-cocoa
//
//  Created by Tim Mityok on 2004-10-06.
//  Copyright ExitToShell() Software 2004 . All rights reserved.
//

#import <InterfaceBuilder/InterfaceBuilder.h>
#import "FlatButtonCocoa.h"
#import "flat_popup_cocoa.h"

@interface FlatButtonControlPalette : IBPalette
{
}
@end

@interface FlatButtonControl (FlatButtonControlPaletteInspector)
- (NSString *)inspectorClassName;
@end

@interface FlatButtonCell (FlatButtonControlPaletteInspector)
- (NSString *)inspectorClassName;
@end

@interface FlatButtonPopupControl (FlatButtonControlPaletteInspector)
- (NSString *)inspectorClassName;
@end

@interface FlatButtonPopupCell (FlatButtonControlPaletteInspector)
- (NSString *)inspectorClassName;
@end