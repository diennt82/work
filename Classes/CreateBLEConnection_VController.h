//
//  CreateBLEConnection_VController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEConnectionManager.h"

#define OPEN_WIFI_BTN_TAG 1001
#define ALERT_FWCHECK_FAILED 2
#define TAG_TRY_CONNECT_BLE 3
#define TAG_IMAGE_ANIMATION 599

@interface CreateBLEConnection_VController : UIViewController<BLEConnectionManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIButton *ib_RefreshBLE;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *ib_Indicator;
@property (nonatomic, weak) IBOutlet UITableView *ib_tableListBLE;
@property (nonatomic, weak) IBOutlet UILabel *ib_lableStage;
@property (nonatomic, weak) IBOutlet UIView *inProgress;

@property (nonatomic, strong) NSMutableArray *currentBLEList;
@property (nonatomic, copy) NSString *cameraMac;
@property (nonatomic, copy) NSString *cameraName;
@property (nonatomic, copy) NSString *homeWifiSSID;

- (IBAction)refreshCamBLE:(id)sender;

- (void)hideProgess;
- (void)showProgress:(NSTimer *)exp;
- (void)checkConnectionToCamera:(NSTimer *)expired;
- (void)moveToNextStep;

@end