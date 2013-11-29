//
//  DeviceSettingsCell.h
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 29/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeviceSettingsCellDelegate <NSObject>

- (void)reportChangedSliderValue: (CGFloat)value andRowIndex: (NSInteger) rowIndex;

@end

@interface DeviceSettingsCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UISlider *valueSlider;

@property (nonatomic) NSInteger rowIndex;
@property (nonatomic, assign) id<DeviceSettingsCellDelegate> deviceStgsCellDelegate;

@end
