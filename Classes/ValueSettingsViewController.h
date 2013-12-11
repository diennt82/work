//
//  ValueSettingsViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraSettingsViewController.h"

@interface ValueSettingsViewController : UITableViewController

@property (retain, nonatomic) NSArray *valueArray;
@property (nonatomic) NSInteger selectedValue;
@property (nonatomic) NSInteger parentIndex;
@property (assign, nonatomic) CameraSettingsViewController *parentVC;

@end
