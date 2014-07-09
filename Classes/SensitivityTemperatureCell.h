//
//  SensitivityTemperatureCell.h
//  BlinkHD_ios
//
//  Created by Developer on 2/18/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SensitivityTemperaureCellDelegate <NSObject>

- (void)shouldSendServerTheCommandOnBackground;
- (void)valueChangedTypeTemperaure: (BOOL) isFahrenheit;
- (void)valueChangedTempLowValue: (NSInteger) tempValue;
- (void)valueChangedTempHighValue: (NSInteger) tempValue;
- (void)valueChangedTempLowOn: (BOOL)isOn;
- (void)valueChangedTempHighOn: (BOOL)isOn;

@end

@interface SensitivityTemperatureCell : UITableViewCell

@property (nonatomic) BOOL isFahrenheit;
@property (nonatomic) CGFloat tempValueLeft;
@property (nonatomic) CGFloat tempValueRight;

@property (nonatomic) BOOL isSwitchOnLeft;
@property (nonatomic) BOOL isSwitchOnRight;

@property (nonatomic, assign) id<SensitivityTemperaureCellDelegate> sensitivityTempCellDelegate;

- (BOOL)shouldWaitForUpdateSettings;

@end
