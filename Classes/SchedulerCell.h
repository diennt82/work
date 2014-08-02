//
//  SchedulerCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SchedulerCellDelegate <NSObject>

- (void)reportSchedulerSwitchState:(BOOL)state atRow:(NSInteger)rowIdx;
- (void)reportByDaySwitchState:(BOOL)state atRow:(NSInteger)rowIdx;

@end

@interface SchedulerCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UISwitch *schedulerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *byDaySwitch;

@property (nonatomic, assign) id<SchedulerCellDelegate> schedulerCellDelegate;
@property (nonatomic) NSInteger rowIndex;

@end
