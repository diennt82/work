//
//  SchedulerCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "SchedulerCell.h"
#import "UIView+Custom.h"

@implementation SchedulerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //[self.schedulerSwitch setOn:_schedulerSate];
        //[self.byDaySwitch setOn:_byDayState];
        [self xibDefaultLocalization];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self xibDefaultLocalization];
}

- (void)xibDefaultLocalization
{
    [[self.contentView viewWithTag:1] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_scheluler_cell_scheduler", nil, [NSBundle mainBundle], @"Scheduler", nil)];
    [[self.contentView viewWithTag:2] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_scheluler_cell_by_day", nil, [NSBundle mainBundle], @"By Day", nil)];
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
