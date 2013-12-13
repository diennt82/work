//
//  AddScheduleViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleViewController.h"

@interface AddScheduleViewController : UITableViewController

@property (assign, nonatomic) ScheduleViewController *parentVC;

@property (nonatomic) CGFloat lowerValue;
@property (nonatomic) CGFloat upperValue;
@property (nonatomic) BOOL isOffAllDay;
@property (nonatomic, retain) NSMutableArray *mapDays;

@end
