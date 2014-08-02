//
//  DeviceSettingsCell.h
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 29/11/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeviceSettingsCellDelegate <NSObject>

- (void)reportChangedSliderValue:(CGFloat)value andRowIndex:(NSInteger)rowIndex;

@end

@interface DeviceSettingsCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UISlider *valueSlider;

@property (nonatomic, assign) id<DeviceSettingsCellDelegate> deviceStgsCellDelegate;
@property (nonatomic) NSInteger rowIndex;

@end
