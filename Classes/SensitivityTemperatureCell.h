//
//  SensitivityTemperatureCell.h
//  BlinkHD_ios
//
//  Created by Developer on 2/18/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SensitivityTemperaureCellDelegate <NSObject>

- (void)valueChangedTypeTemperaure:(BOOL)isFahrenheit;
- (void)valueChangedTempLowValue:(NSInteger)tempValue;
- (void)valueChangedTempHighValue:(NSInteger)tempValue;
- (void)valueChangedTempLowOn:(BOOL)isOn;
- (void)valueChangedTempHighOn:(BOOL)isOn;

@end

@interface SensitivityTemperatureCell : UITableViewCell

@property (nonatomic, weak) id<SensitivityTemperaureCellDelegate> sensitivityTempCellDelegate;

@property (nonatomic) BOOL isSwitchOnLeft;
@property (nonatomic) BOOL isSwitchOnRight;
@property (nonatomic) BOOL isFahrenheit;
@property (nonatomic) CGFloat tempValueLeft;
@property (nonatomic) CGFloat tempValueRight;

@end
