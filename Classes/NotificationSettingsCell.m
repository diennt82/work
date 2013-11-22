//
//  NotificationSettingsCell.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 21/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "NotificationSettingsCell.h"
#import <MonitorCommunication/MonitorCommunication.h>

@implementation NotificationSettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchValueChangedAction:(id)sender
{
    [_notifSettingsDelegate reportSwitchValue:((UISwitch *)sender).isOn andRowIndex:_rowIndex];
}

- (void)dealloc {
    [_settingSwitch release];
    [_settingsLabel release];
    [super dealloc];
}

@end
