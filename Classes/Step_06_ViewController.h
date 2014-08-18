//
//  Step_06_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>

#import "Util.h"
#import "Step_08_ViewController.h"
#import "Step_07_ViewController.h"
#import "GAI.h"

@interface Step_06_ViewController : GAITrackedViewController

@property (nonatomic, weak) IBOutlet UIView *otaDummyProgress;
@property (nonatomic, weak) IBOutlet UIProgressView *otaDummyProgressBar;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollViewGuide;
@property (nonatomic, weak) IBOutlet UIView *infoSelectCameView;
@property (nonatomic, weak) IBOutlet UITableViewCell *ssidCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *securityCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *confPasswordCell;

@property (nonatomic, copy) NSString *security;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, assign) BOOL isOtherNetwork;

- (void)handleNextButton:(id)sender;
- (void)sendWifiInfoToCamera;
- (BOOL)restoreDataIfPossible;
- (void)prepareWifiInfo;

@end
