//
//  SchedulerCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "SchedulerCell.h"

@implementation SchedulerCell

- (IBAction)schedulerSwitchValueChangedAtion:(id)sender
{
    [_schedulerCellDelegate reportSchedulerSwitchState:_schedulerSwitch.isOn atRow:_rowIndex];
}

- (IBAction)byDaySwitchValueChangedAction:(id)sender
{
    [_schedulerCellDelegate reportByDaySwitchState:_byDaySwitch.isOn atRow:_rowIndex];
}

- (void)dealloc
{
    [_schedulerSwitch release];
    [_byDaySwitch release];
    [super dealloc];
}

@end
