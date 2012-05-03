//
//  MBP_AddCamController.h
//  MBP_ios
//
//  Created by NxComm on 5/2/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
#import "MBP_DeviceConfigureViewController.h"
#import "BMS_Communication.h"
#define STEP_1_NEXT_BTN 100
#define STEP_2_NEXT_BTN 101


@interface MBP_AddCamController : UIViewController {

	IBOutlet UIScrollView * step_1View; 
	IBOutlet UIScrollView * step_2View; 
	IBOutlet UITextField * device_mac;

	id <ConnectionMethodDelegate> delegate;
	
}
@property (nonatomic, retain) IBOutlet UITextField * device_mac; 
@property (nonatomic, retain) IBOutlet UIScrollView * step_1View; 
@property (nonatomic, retain) IBOutlet UIScrollView * step_2View; 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) delegate;

- (IBAction) handleButtonPressed:(id) sender;

- (void) addCamSuccessWithResponse:(NSData*) responseData;
- (void) addCamFailedWithError:(NSHTTPURLResponse*) error_response;
- (void) addCamFailedServerUnreachable;

@end
