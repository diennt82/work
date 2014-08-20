//
//  Step_10_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScanForCamera;

#define HOME_SSID @"home_ssid"

#define SEND_CONF_SUCCESS 1
#define SEND_CONF_ERROR 2

#define SETUP_CAMERAS_UNCOMPLETE 0
#define SETUP_CAMERAS_COMPLETE 1
#define SETUP_CAMERAS_FAIL 2

#define MASTER_KEY @"Master_key=" // BC0B87B2832B67FF58F11749F19C4915D4B876C2505D9CC7D0D06F79653C8B11
#define ALERT_ADDCAM_SERVER_UNREACH 1

@interface Step_10_ViewController_ble : UIViewController

@property (nonatomic, strong) NSTimer *timeOut;
@property (nonatomic, copy) NSString *cameraMac;
@property (nonatomic, copy) NSString *masterKey;
@property (nonatomic, copy) NSString *errorCode;
@property (nonatomic, copy) NSString *stringUDID;
@property (nonatomic, copy) NSString *stringAuthToken;

@end
