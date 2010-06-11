/*----------------------------------------------------------------------------

NAME

PXApplication.m -- Header file, adds Proximity events to the App.
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

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "PXApplication.h"
#import "TabletEvents.h"
#import "Wacom.h"
#import "TAEHelpers.h"
#import "PXCanvasDocument.h"
#import "PXCanvasWindowController.h"

typedef struct UPoint32
{
	UInt32 y;
	UInt32 x;
} UPoint32;

@implementation PXApplication
/////////////////////////////////////////////////////////////////////////////
- (id)init
{
    if (!(self = [super init]))
        return nil;
    //_needToWatchMouseEvents = [self checkIfNeedToWatchMouseEvents];
    //ignore that checkIfNeedToWatch junk - it's pretty ancient.
    _needToWatchMouseEvents = true;
	return self;
}

/////////////////////////////////////////////////////////////////////////////
- (void)sendEvent:(NSEvent *)theEvent
{
	EventRef inEvent;
	UInt32	eventClass;
	
	inEvent = (EventRef)[theEvent eventRef];
	eventClass = GetEventClass(inEvent);
	
	switch (eventClass)
	{
		case kEventClassTablet:
		{	
			if ( [theEvent isTabletProximityEvent] )
			{
				[self handleProximityEvent:theEvent];
			}
			else
			{
				// Pure tablet event? Probably from a second concurrent device.
				//
				// If you wish to use dual inputs, email rledet@wacom.com,
				// and I will help you.
			}
			break;
		}	
		case kEventClassMouse:
		{
			if(_needToWatchMouseEvents)
			{
				[self handleMouseEvent:theEvent];
			}
			else
			{
				[super sendEvent:theEvent];
			}
			break;
		}
		default:
			[super sendEvent:theEvent];
			break;
	}
}

//////////////////////////////////////////////////////////////////////////////
- (void) handleMouseEvent:(NSEvent *)theEvent
{
	OSStatus		result;
	EventRef inEvent;
	UInt32	eventType;
	
	switch( [theEvent type] )
	{
		case kEventMouseDown:
		case kEventMouseUp:
		case kEventMouseMoved:
		case kEventMouseDragged:
			//we need this hack to prevent the normal color picker from being used when the modal picker is out.
			inEvent = (EventRef)[theEvent eventRef];
			result = GetEventParameter(inEvent, kEventParamTabletEventType, 
									   typeUInt32, NULL, 
									   sizeof( eventType ), NULL, 
									   &eventType	);
			
			if ( result == noErr )
			{
				if ( eventType == kEventTabletProximity )
				{
					[self handleProximityEvent:theEvent];
				}
			}
				
				[super sendEvent:theEvent];
			break;
			
		default:
			[super sendEvent:theEvent];
			break;
	}
}



//////////////////////////////////////////////////////////////////////////////
- (void) handleProximityEvent:(NSEvent *)theEvent
{
	OSStatus		result;
	EventRef inEvent;
	TabletProximityRec	proximityEventRecord;
	
	inEvent = (EventRef)[theEvent eventRef];
	result = GetEventParameter(inEvent,
							   kEventParamTabletProximityRec, 
							   typeTabletProximityRec,	NULL, 
							   sizeof( TabletProximityRec ), NULL,
							   &proximityEventRecord );
	
	if ( result == noErr )
	{
		// Set up the keys that are used to extract the data from the
		// Dictionary we provided with the Proximity Notification
		NSArray *keys = [NSArray arrayWithObjects:kPointerType,
			kEnterProximity, nil];
		
		// Setup the data aligned with the keys above to easily create
		// the Dictionary
		NSArray *values = [NSArray arrayWithObjects:
			[NSValue valueWithBytes: &proximityEventRecord.pointerType
						   objCType:@encode(UInt8)],
			[NSValue valueWithBytes: &proximityEventRecord.enterProximity
						   objCType:@encode(UInt8)],
			nil];
		
		// Create the dictionary
		NSDictionary* proximityDict = [NSDictionary dictionaryWithObjects:values
																  forKeys:keys];
		
		// Send the Procimity Notification
		[[NSNotificationCenter defaultCenter]
               postNotificationName: kProximityNotification
							 object: self
						   userInfo: proximityDict];
	}
}



//////////////////////////////////////////////////////////////////////////////
- (BOOL) checkIfNeedToWatchMouseEvents
{
	OSErr			err = noErr;
	TAEObject	theTabletDriverObject;
	NumVersion 	theVerData;
	
	// If the user is running tablet driver version 4.7.5 or higher, then all
	// proximity events are sent as pure proximity event. However, if the
	// user is using an older version of the tablet driver, then you will need
	// to inspect all mouse events for embedded prximty events.
	
	
	// Use Apple Events to ask the Tablet Driver what it's version is.
	theTabletDriverObject.objectType = cWTDDriver;
	err = GetData_ofSize_ofType_ofTabletObject_ForAttribute(&theVerData,
															sizeof(theVerData),
															typeVersion,
															&theTabletDriverObject,
															pVersion);
	if(err == noErr)
	{
		if ( ( theVerData.majorRev > 4 ) ||
			 ((theVerData.majorRev >= 4) && (theVerData.minorAndBugRev >= 75)) )
		{
			// Set a global flag so that we know we can use 4.7.5 features.
			return NO;
		}
		else
		{
			// of coase, if we get an answer via AE then we must be running
			// tablet driver ver 4.7.5 or higher, so this else block should
			// never run.
			return YES;
		}
	}
	else
	{
		// Dang, this means that you are running a pre 4.7.5 driver, or
		// running on pre 10.2. That's a bummer.
		return YES;
	}
	
	return YES;
}

@end
