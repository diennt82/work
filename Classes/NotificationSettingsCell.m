//
//  NotificationSettingsCell.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 21/11/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>
#import "NotificationSettingsCell.h"

@implementation NotificationSettingsCell

- (IBAction)switchValueChangedAction:(id)sender
{
    [_notifSettingsDelegate reportSwitchValue:((UISwitch *)sender).isOn andRowIndex:_rowIndex];
}

@end
