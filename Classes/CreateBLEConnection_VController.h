//
//  CreateBLEConnection_VController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosViewController.h"
#import "EditCamera_VController.h"
#import "Step_10_ViewController.h"
#import "BLEConnectionManager.h"

#define OPEN_WIFI_BTN_TAG 1001
#define ALERT_FWCHECK_FAILED 2
#define TAG_TRY_CONNECT_BLE 3

#define TAG_IMAGE_ANIMATION 599

@interface CreateBLEConnection_VController : UIViewController<BLEConnectionManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIView * inProgress;
    
    BOOL task_cancelled;
    NSString * homeWifiSSID;
    BOOL showProgressNextTime;
    
    NSTimer *_getMacAddressTimer;
    NSString *_cameraMac;
    NSString *_cameraName;
    BOOL _isBackPress;
}

@property (retain, nonatomic) IBOutlet UIButton *ib_RefreshBLE;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *ib_Indicator;
@property (retain, nonatomic) IBOutlet UITableView *ib_tableListBLE;
@property (nonatomic, retain) NSMutableArray *currentBLEList;
@property (nonatomic, retain) NSString *cameraMac;
@property (nonatomic, retain) NSString *cameraName;

@property (retain, nonatomic) IBOutlet UILabel *ib_lableStage;
@property (assign, nonatomic) IBOutlet UIImageView *cameraIcon;


@property (nonatomic, retain) UIView * inProgress;
@property (nonatomic, retain) NSString *homeWifiSSID;
@property (nonatomic) NSInteger cameraType;

- (void) hideProgess;
-(void) showProgress:(NSTimer *) exp;
- (void) checkConnectionToCamera:(NSTimer *) expired;
-(void) moveToNextStep;

- (IBAction)refreshCamBLE:(id)sender;

@end