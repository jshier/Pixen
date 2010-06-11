//
//  SubviewTableViewCell.m
//  SubviewTableViewRuleEditor
//
//  Created by Joar Wingfors on Sat Feb 15 2003.
//  Copyright (c) 2003 joar.com. All rights reserved.
// http://www.joar.com/code/body.html

#import "SubviewTableViewCell.h"

#import "SubviewTableViewController.h"
#import "PXLayerDetailsView.h"

@implementation SubviewTableViewCell

- (void) addSubview:(NSView *) view
{
    // Weak reference
    subview = view;
}

- (void) dealloc
{
    subview = nil;
    [super dealloc];
}

- (NSView *) view
{
    return subview;
}

- (void) drawWithFrame:(NSRect) cellFrame inView:(NSView *) controlView
{
	//ugly hack
	if ([[self view] isKindOfClass:[PXLayerDetailsView class]])
	{
		id v = (PXLayerDetailsView *)[self view];
		if ([self isHighlighted])
		{
			[[v opacityText] setTextColor:[NSColor whiteColor]];
			[(NSTextField *)[v name] setTextColor:[NSColor whiteColor]];
		}
		else
		{
			[[v opacityText] setTextColor:[NSColor disabledControlTextColor]];
			[(NSTextField *)[v name] setTextColor:[NSColor blackColor]];
		}
	}
    [super drawWithFrame: cellFrame inView: controlView];
    [[self view] setFrame: cellFrame];
    if([[self view] superview] != controlView)
    {
		[controlView addSubview:[self view]];
    }
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSImage *gradient;
    /* Determine whether we should draw a blue or grey gradient. */
    /* We will automatically redraw when our parent view loses/gains focus, 
	or when our parent window loses/gains main/key status. */
    if (([[controlView window] firstResponder] == controlView) && 
		[[controlView window] isMainWindow] &&
		[[controlView window] isKeyWindow]) {
		if ([NSColor currentControlTint] == NSGraphiteControlTint)
			gradient = [NSImage imageNamed:@"highlight_graphite.tiff"];
		else
			gradient = [NSImage imageNamed:@"highlight_blue.tiff"];
    } else {
        gradient = [NSImage imageNamed:@"highlight_grey.tiff"];
    }
    
    /* Make sure we draw the gradient the correct way up. */
    [gradient setFlipped:YES];
    if ([self isHighlighted]) {
        [controlView lockFocus];
        
        /* We're selected, so draw the gradient background. */
        NSSize gradientSize = [gradient size];
		[gradient drawInRect:cellFrame
					fromRect:NSMakeRect(0, 0, gradientSize.width, gradientSize.height)
				   operation:NSCompositeSourceOver
					fraction:1.0];
		 [controlView unlockFocus];
    } else {
        /* We're not selected, so ask our superclass to draw our content normally. */
		cellFrame.origin.y -= 4;
		cellFrame.origin.y += 8;
        [super drawInteriorWithFrame:cellFrame inView:controlView];
    }	
}

-(id) copyWithZone:(NSZone *)zone
{
	id new = [[[self class] allocWithZone:zone] init];
	[new addSubview:([subview conformsToProtocol:@protocol(NSCopying)] ? [[subview copy] autorelease] : subview)];
	return new;
}

@end
