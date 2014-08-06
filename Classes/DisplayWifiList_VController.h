//
//  DisplayWifiList_VController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEConnectionManager.h"

@interface DisplayWifiList_VController : UIViewController<UIAlertViewDelegate, BLEConnectionManagerDelegate>

@property (nonatomic, retain) IBOutlet UIView *ib_Indicator;
@property (nonatomic, retain) IBOutlet UILabel *ib_LabelState;
@property (nonatomic, assign) IBOutlet UITableViewCell *cellView;

@property (nonatomic, retain) NSMutableArray * listOfWifi;

@end
