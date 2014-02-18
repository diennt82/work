//
//  SensitivityTemperatureCell.h
//  BlinkHD_ios
//
//  Created by Developer on 2/18/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SensitivityTemperatureCell : UITableViewCell

@property (nonatomic) BOOL isFahrenheit;
@property (nonatomic) CGFloat tempValueLeft;
@property (nonatomic) CGFloat tempValueRight;

@property (nonatomic) BOOL isSwitchOnLeft;
@property (nonatomic) BOOL isSwitchOnRight;

@end
