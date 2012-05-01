//
//  MBP_FirstPage.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"

#define DIRECT_MODE_BTN_TAG 100
#define ROUTER_MODE_BTN_TAG 101
#define STOP_AND_EXIT_BTN_TAG 102

@interface MBP_FirstPage : UIViewController {

	id <ConnectionMethodDelegate> delegate; 

}



- (IBAction) handleButtonPressed:(id) sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) delegate;
@end
