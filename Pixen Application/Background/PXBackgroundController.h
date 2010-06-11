/* PXBackgroundController */

#import <Cocoa/Cocoa.h>

@class PXBackgroundInfoView, PXBackgroundsTableView, PXBackground, OSStackedView, PXDefaultBackgroundTemplateView;
@interface PXBackgroundController : NSWindowController
{
    IBOutlet PXBackgroundInfoView *alternateBackgroundView;
    IBOutlet PXBackgroundInfoView *mainBackgroundView;
    IBOutlet OSStackedView *mainStack, *defaultsStack;
	id delegate;
	NSMutableArray *mainViews, *defaultsViews;
}
- (void)setDelegate:del;
- (void)reloadData;
- (void)setPreviewImage:(NSImage *)img;
- (NSString *)pathForBackground:(PXBackground *)background;
- (void)saveBackground:(PXBackground *)background atPath:(NSString *)path;

@end

@interface NSObject(PXBackgroundControllerDelegate)
- (void)backgroundChanged:(NSNotification *)changed;

- (PXBackground *)mainBackground;
- (PXBackground *)alternateBackground;
- (void)setMainBackground:(PXBackground *) aBackground;
- (void)setAlternateBackground:(PXBackground *) aBackground;

- (PXBackground *)defaultMainBackground;
- (void)setDefaultMainBackground:(PXBackground *)bg;
- (PXBackground *)defaultAlternateBackground;
- (void)setDefaultAlternateBackground:(PXBackground *)bg;

@end

@interface PXBackgroundTemplateScrollView : NSScrollView
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)info;
- (NSDragOperation)draggingExited:(id <NSDraggingInfo>)info;
@end
