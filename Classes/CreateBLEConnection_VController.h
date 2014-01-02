//
//  CreateBLEConnection_VController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosViewController.h"
#import "Step_04_ViewController_ble.h"
#import "Step_10_ViewController.h"
//#import "UARTPeripheral.h"
#import "BLEManageConnect.h"

#define OPEN_WIFI_BTN_TAG 1001
#define ALERT_FWCHECK_FAILED 2
#define TAG_TRY_CONNECT_BLE 3
#define VERSION_18_037 @"get_version: 18_037"
#define TAG_IMAGE_ANIMATION 599

@interface CreateBLEConnection_VController : UIViewController<BLEManageConnectDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIView * inProgress;
    
    BOOL task_cancelled;
    NSString * homeWifiSSID;
    BOOL showProgressNextTime;
    
    BLEManageConnect *_bleManagement;
    NSTimer *_timerUpdateUI;
    NSTimer *_getMacAddressTimer;
    NSString *_cameraMac;
    NSString *_cameraName;
    NSMutableArray *_currentBLEList;
}
@property (retain, nonatomic) IBOutlet UIButton *ib_RefreshBLE;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *ib_Indicator;
@property (retain, nonatomic) IBOutlet UITableView *ib_tableListBLE;
@property (nonatomic, retain) NSMutableArray *currentBLEList;
@property (nonatomic, retain) NSString *cameraMac;
@property (nonatomic, retain) NSString *cameraName;
@property (nonatomic,retain) BLEManageConnect *bleManagement;

@property (retain, nonatomic) IBOutlet UILabel *ib_lableStage;

//next button
@property (retain, nonatomic) IBOutlet UIButton *ib_NextStepAfterReady;

@property (retain, nonatomic) NSTimer *timerUpdateUI;
@property (nonatomic, retain) UIView * inProgress;
@property (nonatomic, retain) NSString *homeWifiSSID;

- (void) hideProgess;
-(void) showProgress:(NSTimer *) exp;
- (void) checkConnectionToCamera:(NSTimer *) expired;
-(void) moveToNextStep;
//action user
- (IBAction)nextStepConnected:(id)sender;
- (IBAction)refreshCamBLE:(id)sender;

@end