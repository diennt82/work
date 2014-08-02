//
//  GeneralCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "GeneralCell.h"

@implementation GeneralCell

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor colorWithRed:43/255.f green:50/255.f blue:56/255.f alpha:1];
    
    [self.btnClock setImage:[UIImage imageNamed:@"settings_hr_24"] forState:UIControlStateNormal];
    [self.btnClock setImage:[UIImage imageNamed:@"settings_hr_12"] forState:UIControlStateSelected];
    [self.btnClock setImage:[UIImage imageNamed:@"settings_hr_12"] forState:UIControlStateHighlighted];
    self.btnClock.selected = _is12hr;
    
    [self.btnTemperature setImage:[UIImage imageNamed:@"settings_temp_c"] forState:UIControlStateNormal];
    [self.btnTemperature setImage:[UIImage imageNamed:@"settings_temp_f"] forState:UIControlStateSelected];
    [self.btnTemperature setImage:[UIImage imageNamed:@"settings_temp_f"] forState:UIControlStateHighlighted];
    self.btnTemperature.selected = _isFahrenheit;
}

- (IBAction)btnClockTouchUpInsideAction:(UIButton *)sender
{
    self.is12hr = !_is12hr;
    sender.selected = _is12hr;
    [_generalCellDelegate clockValueChanged:_is12hr];
}

- (IBAction)btnTemperatureTouchUpInsideAction:(UIButton *)sender
{
    self.isFahrenheit = !_isFahrenheit;
    sender.selected = _isFahrenheit;
    [_generalCellDelegate temperatureValueChanged:_isFahrenheit];
}

- (void)dealloc
{
    [_labelClock release];
    [_btnClock release];
    [_labelTemperature release];
    [_btnTemperature release];
    [super dealloc];
}

@end
