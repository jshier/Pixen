
//
//  PXAnimationWindowController.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvasWindowController.h"
@class PXAnimation, PXCel, PXFilmStripView, PXAnimationPreview, RBSplitSubview;
@interface PXAnimationWindowController : PXCanvasWindowController {
	PXAnimation *animation;
	IBOutlet PXFilmStripView *filmStrip;
	IBOutlet PXAnimationPreview *animationPreview;
	
	IBOutlet RBSplitSubview *topSubview;
	NSUInteger oldMin, oldMax;
	
	IBOutlet NSButton *playPauseButton;
	
	PXCel *activeCel;
	NSUInteger activeIndex;
}
- (void)setAnimation:anim;
- (void)activateCel:(PXCel *)cel;
- (IBAction)newCel:sender;
- (IBAction)deleteCel:sender;
- (IBAction)duplicateCel:sender;
- (void)writeCelsAtIndices:(NSIndexSet *)indices toPasteboard:(NSPasteboard *)pboard;
@end
