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
#import "GAI.h"


#define OPEN_WIFI_BTN_TAG 1001
#define ALERT_FWCHECK_FAILED 2

#define VERSION_18_037 @"get_version: 18_037"

@protocol Step_03Delegate <NSObject>
- (void)goBackCameralist;
@end

@interface Step_03_ViewController : GAITrackedViewController
{
    BOOL task_cancelled;
    BOOL task_timeOut;
    NSString * homeWifiSSID; 
	NSString * cameraMac; 
	NSString * cameraName;
    
    BOOL showProgressNextTime;
    

}

@property (nonatomic, retain) NSString * cameraMac, * cameraName, * homeWifiSSID;
@property (nonatomic, assign) id<Step_03Delegate> delegate;

#if 0
- (IBAction)handleButtonPress:(id)sender;
- (void) hideProgess;
#endif
-(void) showProgress:(NSTimer *) exp;
- (void) checkConnectionToCamera:(NSTimer *) expired;
-(void) moveToNextStep;

@end
