//
//  DayViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddScheduleViewController.h"

@interface DayViewController : UITableViewController

@property (retain, nonatomic) NSMutableArray *mapDays;
@property (assign, nonatomic) AddScheduleViewController *parentVC;

@end
