//
//  MBP_FirstPage.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ConnectionMethodDelegate.h"

#define ACTION_SETUP_BM 100
#define ACTION_LOGIN 101


#define FIRST_TIME_SETUP @"_first_time_setup"

@interface MBP_FirstPage : UIViewController {

	id <ConnectionMethodDelegate> delegate; 

}



- (IBAction) handleButtonPressed:(id) sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) delegate;
@end
