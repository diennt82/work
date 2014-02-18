//
//  SensitivityCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SensitivityCellDelegate <NSObject>

- (void)reportSwitchValue: (BOOL)value andRowIndex: (NSInteger) rowIndex;
- (void)reportChangedSettingsValue: (NSInteger )value atRow: (NSInteger )rowIndx;

@end

@interface SensitivityCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UISwitch *valueSwitch;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UISlider *valueSlider;

@property (nonatomic) NSInteger rowIndex;
@property (assign, nonatomic) id<SensitivityCellDelegate> sensitivityCellDelegate;
@property (nonatomic) NSInteger settingsValue;
@property (nonatomic) BOOL switchValue;

@end
