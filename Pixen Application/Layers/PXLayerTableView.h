//
//  PXLayerTableView.h
//  Pixen
//
//  Created by Andy Matuschak on 6/19/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXLayerTableView : NSTableView {

}

@end

@interface NSObject(PXLayerTableViewDelegate)
- (void)deleteKeyPressedInTableView:tableView;
@end
