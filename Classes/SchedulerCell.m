//
//  SchedulerCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "SchedulerCell.h"

@implementation SchedulerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //[self.schedulerSwitch setOn:_schedulerSate];
        //[self.byDaySwitch setOn:_byDayState];
    }
    return self;
}
- (IBAction)schedulerSwitchValueChangedAtion:(id)sender
{
    //self.schedulerSate = !_schedulerSate;
    [_schedulerCellDelegate reportSchedulerSwitchState:_schedulerSwitch.isOn atRow:_rowIndex];
}

- (IBAction)byDaySwitchValueChangedAction:(id)sender
{
    //self.byDayState = !_byDayState;
    [_schedulerCellDelegate reportByDaySwitchState:_byDaySwitch.isOn atRow:_rowIndex];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_schedulerSwitch release];
    [_byDaySwitch release];
    [super dealloc];
}
@end
