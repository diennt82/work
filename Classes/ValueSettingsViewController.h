//
//  ValueSettingsViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraSettingsViewController.h"

@interface ValueSettingsViewController : UITableViewController

@property (nonatomic, strong) NSArray *valueArray;
@property (nonatomic, weak) CameraSettingsViewController *parentVC;
@property (nonatomic) NSInteger selectedValue;
@property (nonatomic) NSInteger parentIndex;

@end
