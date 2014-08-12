//
//  NotificationSettingsCell.h
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 21/11/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotifSettingsCellDelegate <NSObject>

- (void)reportSwitchValue: (BOOL)value andRowIndex: (NSInteger) rowIndex;

@end

@interface NotificationSettingsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UISwitch *settingSwitch;
@property (nonatomic, weak) IBOutlet UILabel *settingsLabel;

@property (nonatomic, weak) id<NotifSettingsCellDelegate> notifSettingsDelegate;
@property (nonatomic, assign) NSInteger rowIndex;

@end