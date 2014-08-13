//
//  CreateBLEConnection_VController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditCamera_VController.h"
#import "BLEConnectionManager.h"

@interface CreateBLEConnection_VController : UIViewController<BLEConnectionManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL task_cancelled;
    NSString * homeWifiSSID;
}

@property (retain, nonatomic) IBOutlet UITableView *ib_tableListBLE;
@property (nonatomic, retain) NSMutableArray *currentBLEList;
@property (nonatomic, retain) NSString *cameraMac;
@property (nonatomic, retain) NSString *cameraName;

@property (retain, nonatomic) IBOutlet UILabel *ib_lableStage;
@property (assign, nonatomic) IBOutlet UIImageView *cameraIcon;

@property (nonatomic, retain) NSString *homeWifiSSID;
@property (nonatomic) NSInteger cameraType;

-(void) moveToNextStep;

- (IBAction)refreshCamBLE:(id)sender;

@end