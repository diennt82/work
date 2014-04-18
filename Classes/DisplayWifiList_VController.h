//
//  DisplayWifiList_VController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WifiEntry.h"
#import "NetworkInfoToCamera_VController.h"
#import "BLEConnectionManager.h"

@interface DisplayWifiList_VController : UIViewController<UIAlertViewDelegate, BLEConnectionManagerDelegate>
{
    NSMutableArray * _listOfWifi;
    IBOutlet UITableViewCell * cellView;
}

@property (nonatomic, retain) NSMutableArray * listOfWifi;
@property (retain, nonatomic) IBOutlet UIView *ib_Indicator;
@property (retain, nonatomic) IBOutlet UILabel *ib_LabelState;
@property (nonatomic, assign) IBOutlet UITableViewCell *cellView;

@end
