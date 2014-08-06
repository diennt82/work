//
//  Step_06_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>

#import "BLEConnectionManager.h"

#define INIT 0
#define SENT_TIME_ZONE  1
#define SENT_WIFI  2
#define CHECKING_WIFI   3
#define CHECKING_WIFI_PASSED  4

@interface NetworkInfoToCamera_VController : UIViewController<UIAlertViewDelegate, BLEConnectionManagerDelegate>

@property (nonatomic, retain) IBOutlet UIView *ib_dialogVerifyNetwork;
@property (nonatomic, assign) IBOutlet UITableViewCell *ssidCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *securityCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *confPasswordCell;

@property (nonatomic, retain) DeviceConfiguration *deviceConf;
@property (nonatomic, copy) NSString *ssid, *security, *password;
@property (nonatomic, assign) BOOL isOtherNetwork;

- (void)handleNextButton:(id)sender;
- (void)sendWifiInfoToCamera;
- (BOOL)restoreDataIfPossible;
- (void)prepareWifiInfo;

@end
