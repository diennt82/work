//
//  NotificationSettingsCell.h
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 21/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotifSettingsCellDelegate <NSObject>

- (void)reportSwitchValue: (BOOL)value andRowIndex: (NSInteger) rowIndex;

@end

@interface NotificationSettingsCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (retain, nonatomic) IBOutlet UILabel *settingsLabel;

@property (nonatomic) NSInteger rowIndex;
@property (nonatomic, assign) id<NotifSettingsCellDelegate> notifSettingsDelegate;

@end
