//
//  SubviewTableViewCell.h
//  SubviewTableViewRuleEditor
//
//  Created by Joar Wingfors on Sat Feb 15 2003.
//  Copyright (c) 2003 joar.com. All rights reserved.
// http://www.joar.com/code/body.html

#import <AppKit/AppKit.h>

/*****************************************************************************

SubviewTableViewCell

Overview:

This is a very simple cell subclass used as the table data cell in the column
where the custom view will be used. It is responsible for ensuring that the
custom view is inserted into the table view, and of proper size and position.

*****************************************************************************/

@interface SubviewTableViewCell : NSCell <NSCopying>
{
    NSView *subview;
}

// The view is not retained by the cell!
- (void) addSubview:(NSView *) view;
- (NSView *)view;

@end

