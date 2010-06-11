//
//  UKFeedbackProvider.h
//  NiftyFeatures
//
//  Created by Uli Kusterer on Mon Nov 24 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface UKFeedbackProvider : NSObject
{
	IBOutlet NSWindow*		feedbackWindow;
	IBOutlet NSComboBox*	subjectField;
	IBOutlet NSTextView*	messageText;
}

// Action for the "send feedback" menu item:
-(IBAction) orderFrontFeedbackWindow: (id)sender;   // Recommended menu item action method.
-(IBAction) sendFeedback: (id)sender;				// Old name, just for compatibility.

// Actions for the three buttons in the window:
-(IBAction) sendFeedbackButtonAction: (id)sender;
-(IBAction) closeFeedbackWindow: (id)sender;
-(IBAction) openURL: (id)sender;



@end
