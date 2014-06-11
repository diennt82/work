//
//  Step_06_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>

#import "Util.h"
#import "Step_08_ViewController.h"
#import "Step_07_ViewController.h"
#import "GAI.h"

@interface Step_06_ViewController : GAITrackedViewController

@property (nonatomic, retain) IBOutlet UIView *otaDummyProgress;
@property (nonatomic, retain) IBOutlet UIProgressView *otaDummyProgressBar;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewGuide;
@property (nonatomic, retain) IBOutlet UIView *infoSelectCameView;

@property (nonatomic, assign) IBOutlet UITableViewCell * ssidCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * securityCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * passwordCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * confPasswordCell;

//timeout input password
@property (nonatomic, retain) NSTimer *inputPasswordTimer;
@property (nonatomic, retain) NSTimer *timeOut;

@property (nonatomic, copy) NSString *currentStateCamera;
@property (nonatomic, copy) NSString* ssid, * security, *password;
@property (nonatomic, retain) DeviceConfiguration * deviceConf;
@property (nonatomic, assign) BOOL isOtherNetwork;

//current state of camera
@property (nonatomic, assign) BOOL isUserMakeConnect;
@property (nonatomic, assign) BOOL task_cancelled;

- (void)handleNextButton:(id)sender;
- (void)sendWifiInfoToCamera;
- (BOOL)restoreDataIfPossible;
- (void)prepareWifiInfo;

\
@end
