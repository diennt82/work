//
//  DisplayWifiList_VController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WifiEntry.h"
#import "NetworkInfoToCamera_VController.h"
#import "BLEConnectionManager.h"

@interface DisplayWifiList_VController : UIViewController<UIAlertViewDelegate, BLEConnectionManagerDelegate>

@property (nonatomic, retain) NSMutableArray * listOfWifi;
@property (nonatomic, retain) IBOutlet UIView *ib_Indicator;
@property (nonatomic, retain) IBOutlet UILabel *ib_LabelState;
@property (nonatomic, assign) IBOutlet UITableViewCell *cellView;

@end
