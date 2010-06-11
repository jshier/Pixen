//
//  OSQTExporter.h
//  OSQTExporter
//
//  Created by Andy Matuschak on 8/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuickTime/QuickTime.h>

@class QTMovie;
@interface OSQTExporter : NSObject {
	NSString *tempPath;
	
	QTMovie *qtMovie;
	NSWindow *parentWindow;
	QTAtomContainer	gExportSettings;
}

- (void)addImage:(NSImage *)image forLength:(NSTimeInterval)seconds;
- (void)exportToPath:(NSString *)path parentWindow:(NSWindow *)newParentWindow;
@end
