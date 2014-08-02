//
//  Step_03_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
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

@interface Step_03_ViewController : GAITrackedViewController

@property (nonatomic, copy) NSString *cameraMac;
@property (nonatomic, copy) NSString *cameraName;
@property (nonatomic, copy) NSString *homeWifiSSID;

- (IBAction)handleButtonPress:(id)sender;

- (void)hideProgess;
- (void)showProgress:(NSTimer *)exp;
- (void)checkConnectionToCamera:(NSTimer *)expired;
- (void)moveToNextStep;

@end
