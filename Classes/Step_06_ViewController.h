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

@property (nonatomic, retain) IBOutlet UIView *otaDummyProgress;
@property (nonatomic, retain) IBOutlet UIProgressView *otaDummyProgressBar;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewGuide;
@property (nonatomic, retain) IBOutlet UIView *infoSelectCameView;

@property (nonatomic, assign) IBOutlet UITableViewCell * ssidCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * securityCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * passwordCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * confPasswordCell;

@property (nonatomic, copy) NSString *security;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, assign) BOOL isOtherNetwork;

- (void)handleNextButton:(id)sender;
- (void)sendWifiInfoToCamera;
- (BOOL)restoreDataIfPossible;
- (void)prepareWifiInfo;

@end
