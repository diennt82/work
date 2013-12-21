//
//  SchedulerCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SchedulerCellDelegate <NSObject>

- (void)reportSchedulerSwitchState: (BOOL)state atRow: (NSInteger)rowIdx;
- (void)reportByDaySwitchState: (BOOL)state atRow: (NSInteger)rowIdx;

@end

@interface SchedulerCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UISwitch *schedulerSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *byDaySwitch;

@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) BOOL schedulerSate;
@property (nonatomic) BOOL byDayState;

@end
