//
//  Step_03_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosViewController.h"
#import "Step_04_ViewController.h"
#import "Step_10_ViewController.h"
#import "HttpCom.h"


#define OPEN_WIFI_BTN_TAG 1001
#define ALERT_FWCHECK_FAILED 2

#define VERSION_18_037 @"get_version: 18_037"

@interface Step_03_ViewController : UIViewController
{
    IBOutlet UIView * inProgress; 
    
    BOOL task_cancelled;
    NSString * homeWifiSSID; 
	NSString * cameraMac; 
	NSString * cameraName;
    
    BOOL showProgressNextTime;
    

}

@property (nonatomic, retain) UIView * inProgress; 
@property (nonatomic, retain) NSString * cameraMac, * cameraName, * homeWifiSSID;

- (IBAction)handleButtonPress:(id)sender;
- (void) hideProgess;
-(void) showProgress:(NSTimer *) exp;
- (void) checkConnectionToCamera:(NSTimer *) expired;
-(void) moveToNextStep;

@end
