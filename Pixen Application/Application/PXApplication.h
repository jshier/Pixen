/*----------------------------------------------------------------------------

NAME

	PXApplication.h -- Header file, adds Proximity events to the App.
                    This is a subclass of NSApplication. It's purpose is to
                    catch Proximity events and Post a kProximityNotification
                    to any object that is listening for them. This is
                    preferable than sending a proximity event, because more
                    than one object may need to know about each proximity
                    event. Furthermore, if an object is not in the current
                    event chain, it would also miss the proximity event.
	

COPYRIGHT

	Copyright WACOM Technologies, Inc. 2001
	All rights reserved.

-----------------------------------------------------------------------------*/

#import <AppKit/NSApplication.h>

@interface PXApplication : NSApplication {
	BOOL	_needToWatchMouseEvents;
}
- (void) handleMouseEvent:(NSEvent *)theEvent;
- (void) handleProximityEvent:(NSEvent *)theEvent;

- (BOOL) checkIfNeedToWatchMouseEvents;
@end
