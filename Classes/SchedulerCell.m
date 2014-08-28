//
//  SchedulerCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "SchedulerCell.h"

@interface SchedulerCell ()

@property (nonatomic, weak) IBOutlet UILabel *schedulerLabel;
@property (nonatomic, weak) IBOutlet UILabel *byDayLabel;

@end

@implementation SchedulerCell

- (void)layoutSubviews
{
    _schedulerLabel.text = LocStr(@"Scheduler");
    _byDayLabel.text = LocStr(@"By day");
    
    [super layoutSubviews];
}

- (IBAction)schedulerSwitchValueChangedAtion:(id)sender
{
    [_schedulerCellDelegate reportSchedulerSwitchState:_schedulerSwitch.isOn atRow:_rowIndex];
}

- (IBAction)byDaySwitchValueChangedAction:(id)sender
{
    [_schedulerCellDelegate reportByDaySwitchState:_byDaySwitch.isOn atRow:_rowIndex];
}

@end
