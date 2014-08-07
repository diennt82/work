//
//  Step_10_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MonitorCommunication/MonitorCommunication.h>

#import "Step_02_ViewController.h"
#import "Step_11_ViewController.h"
#import "Step_12_ViewController.h"
#import "ConnectionMethodDelegate.h"
#import "define.h"

@class ScanForCamera;

#define SEND_CONF_SUCCESS 1
#define SEND_CONF_ERROR 2

#define SETUP_CAMERAS_UNCOMPLETE 0
#define SETUP_CAMERAS_COMPLETE 1
#define SETUP_CAMERAS_FAIL 2

//Master_key=BC0B87B2832B67FF58F11749F19C4915D4B876C2505D9CC7D0D06F79653C8B11
#define MASTER_KEY @"Master_key="

@interface Step_10_ViewController : GAITrackedViewController

@property (nonatomic, weak) IBOutlet UIView *ib_viewGuild;
@property (nonatomic, weak) IBOutlet UIScrollView *ib_scollViewGuide;
@property (nonatomic, weak) IBOutlet UIButton *ib_resumeSetup;

@property (nonatomic, weak)  id<ConnectionMethodDelegate> delegate;

@property (nonatomic, copy) NSString *cameraMac;
@property (nonatomic, copy) NSString *master_key;
@property (nonatomic, copy) NSString *errorCode;
@property (nonatomic, copy) NSString *stringUDID;
@property (nonatomic, copy) NSString *stringAuth_token;

- (IBAction)registerCamera:(id)sender;

- (void)wait_for_camera_to_reboot:(NSTimer *)exp;
- (void)setupCompleted;
- (void)setupFailed;

@end
