//
//  ScheduleViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleViewController : UITableViewController

@property (nonatomic) BOOL scheduleIsOn;
@property (nonatomic, retain) NSString *selectedDayString;
@property (nonatomic) CGFloat lowerValue;
@property (nonatomic) CGFloat upperValue;
@property (nonatomic) BOOL isOffAllDay;

@end
