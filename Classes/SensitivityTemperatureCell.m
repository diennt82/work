//
//  SensitivityTemperatureCell.m
//  BlinkHD_ios
//
//  Created by Developer on 2/18/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#define TEMP_LOW_MIN 10
#define TEMP_LOW_MAX 18
#define TEMP_HIGH_MIN 25
#define TEMP_HIGH_MAX 33

#import "SensitivityTemperatureCell.h"

@interface SensitivityTemperatureCell()

@property (nonatomic, weak) IBOutlet UIButton *btnTypeTemperature;
@property (nonatomic, weak) IBOutlet UILabel *lblTempValueLeft;
@property (nonatomic, weak) IBOutlet UILabel *lblTemperatureValueRight;
@property (nonatomic, weak) IBOutlet UILabel *lblTypeTempLeft;
@property (nonatomic, weak) IBOutlet UILabel *lblTypeTempRight;
@property (nonatomic, weak) IBOutlet UIButton *btnSwitchLeft;
@property (nonatomic, weak) IBOutlet UIButton *btnSwitchRight;
@property (nonatomic, weak) IBOutlet UIButton *btnMinusLeft;
@property (nonatomic, weak) IBOutlet UIButton *btnPlusLeft;
@property (nonatomic, weak) IBOutlet UIButton *btnMinusRight;
@property (nonatomic, weak) IBOutlet UIButton *btnPlusRight;
@property (nonatomic, weak) IBOutlet UIImageView *imgViewLeft;
@property (nonatomic, weak) IBOutlet UIImageView *imgViewRight;

@property (nonatomic, strong) NSTimer *timerTempLowValueChanged;
@property (nonatomic, strong) NSTimer *timerTempHighValueChanged;
@property (nonatomic) BOOL isStopTouching;

@end

@implementation SensitivityTemperatureCell

- (void)drawRect:(CGRect)rect
{
    [_btnTypeTemperature setImage:[UIImage imageNamed:@"settings_temp_c"] forState:UIControlStateNormal];
    [_btnTypeTemperature setImage:[UIImage imageNamed:@"settings_temp_f"] forState:UIControlStateSelected];
    [_btnTypeTemperature setImage:[UIImage imageNamed:@"settings_temp_f"] forState:UIControlStateHighlighted];
    
    _btnTypeTemperature.selected = _isFahrenheit;
    
    if (_isFahrenheit)
    {
        self.tempValueLeft = ((_tempValueLeft * 9) / 5.f) + 32;
        self.tempValueRight = ((_tempValueRight * 9) / 5.f) + 32;
        
        _lblTypeTempLeft.text = @"°F";
        _lblTypeTempRight.text = @"°F";
    }
    else
    {
//        self.tempValueLeft = (_tempValueLeft - 32) * 5/9.f;
//        self.tempValueRight = (_tempValueRight - 32) * 5/9.f;
        
        _lblTypeTempLeft.text = @"°C";
        _lblTypeTempRight.text = @"°C";
    }
    
    _lblTempValueLeft.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueLeft)];
    _lblTemperatureValueRight.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueRight)];
    
    [_btnSwitchLeft setImage:[UIImage imageNamed:@"settings_switch_off"] forState:UIControlStateNormal];
    [_btnSwitchLeft setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateSelected];
    [_btnSwitchLeft setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateHighlighted];
    
    _btnSwitchLeft.selected = _isSwitchOnLeft;
    
    _btnMinusLeft.enabled = _isSwitchOnLeft;
    _btnPlusLeft.enabled = _isSwitchOnLeft;
    
    [_btnSwitchRight setImage:[UIImage imageNamed:@"settings_switch_off"] forState:UIControlStateNormal];
    [_btnSwitchRight setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateSelected];
    [_btnSwitchRight setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateHighlighted];
    
    _btnSwitchRight.selected = _isSwitchOnRight;
    
    _btnMinusRight.enabled = _isSwitchOnRight;
    _btnPlusRight.enabled = _isSwitchOnRight;
    
    _imgViewRight.layer.cornerRadius = 40;
    _imgViewLeft.layer.cornerRadius = 40;
    
    if (_isSwitchOnLeft) {
        NSInteger tempValueInCel = _tempValueLeft;
        if (_isFahrenheit){
            tempValueInCel = (tempValueInCel  -  32)  * 5/9 ;
        }
        [_imgViewLeft setBackgroundColor:COLOR_RGB((tempValueInCel-9)*15,(tempValueInCel-9)*15,255-((tempValueInCel-9)*20))];
    }
    else {
        [_imgViewLeft setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    if (_isSwitchOnRight) {
        NSInteger tempValueInCel = _tempValueRight;
        if (_isFahrenheit) {
            tempValueInCel = (tempValueInCel  -  32)  * 5/9 ;
        }
        [_imgViewRight setBackgroundColor:COLOR_RGB(255.0,(33-tempValueInCel)*20,(33-tempValueInCel)*10)];
    }
    else {
        [_imgViewRight setBackgroundColor:[UIColor lightGrayColor]];
    }    
}

- (IBAction)btnTypeTempTouchUpInsideAction:(UIButton *)sender
{
    self.isFahrenheit = !_isFahrenheit;
    sender.selected = _isFahrenheit;
    
    if (_isFahrenheit) {
        _lblTypeTempLeft.text = @"°F";
        _lblTypeTempRight.text = @"°F";
        
        //fahrenheit = ((Celsius * 9 )/5) + 32;
        self.tempValueLeft = (round(_tempValueLeft * 9.f / 5.f)) + 32;
        self.tempValueRight = (round(_tempValueRight * 9.f / 5.f)) + 32;
    }
    else {
        _lblTypeTempLeft.text = @"°C";
        _lblTypeTempRight.text = @"°C";
        
        //celsius = (5/9) * (fahrenheit-32)
        self.tempValueLeft = round((_tempValueLeft - 32) * 5/9.f);
        self.tempValueRight = round((_tempValueRight - 32) * 5/9.f);
    }
    
    _lblTempValueLeft.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueLeft)];
    _lblTemperatureValueRight.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueRight)];
    
    [_sensitivityTempCellDelegate valueChangedTypeTemperaure:_isFahrenheit];
}

- (IBAction)btnMinusLeftTouchUpInsideAction:(id)sender
{
    NSInteger tempLowMin = TEMP_LOW_MIN;
    NSInteger tempValueInCel = _tempValueLeft;
    
    if (_isFahrenheit) {
        tempLowMin = (round(TEMP_LOW_MIN * 9.f / 5.f)) + 32;
        tempValueInCel = (tempValueInCel  -  32)  * 5/9 ;
    }
    
    if (_tempValueLeft > tempLowMin) {
        _tempValueLeft--;
        _lblTempValueLeft.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueLeft)];
        [_imgViewLeft setBackgroundColor:COLOR_RGB((tempValueInCel-9)*15,(tempValueInCel-9)*15,255-((tempValueInCel-9)*20))];
    }
    else {
        NSLog(@"SensivityTemperature too low, LOW is not supported!");
    }

    [_timerTempLowValueChanged invalidate];
    self.timerTempLowValueChanged = nil;
    
    self.timerTempLowValueChanged = [NSTimer scheduledTimerWithTimeInterval:3
                                                                     target:self
                                                                   selector:@selector(reportTempLowValueChanged:)
                                                                   userInfo:nil
                                                                    repeats:NO];
}

- (IBAction)btnPlusLeftTouchUpInsideAction:(id)sender
{
    NSInteger tempHighMax = TEMP_LOW_MAX;
    NSInteger tempValueInCel = _tempValueLeft;
    
    if (_isFahrenheit) {
        tempHighMax = (round(TEMP_LOW_MAX * 9.f / 5.f)) + 32;
        tempValueInCel = (tempValueInCel  -  32)  * 5/9 ;
    }
    
    if (_tempValueLeft < tempHighMax) {
        _tempValueLeft++;
        _lblTempValueLeft.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueLeft)];
         [_imgViewLeft setBackgroundColor:COLOR_RGB((tempValueInCel-9)*15,(tempValueInCel-9)*15,255-((tempValueInCel-9)*20))];
    }
    else {
        NSLog(@"SensivityTemperature too high, LOW is not supported!");
    }
    
    [_timerTempLowValueChanged invalidate];
    self.timerTempLowValueChanged = nil;
    
    self.timerTempLowValueChanged = [NSTimer scheduledTimerWithTimeInterval:3
                                                                     target:self
                                                                   selector:@selector(reportTempLowValueChanged:)
                                                                   userInfo:nil
                                                                    repeats:NO];
}

- (void)reportTempLowValueChanged: (NSTimer *)timer
{
    NSInteger tempLowValue = _tempValueLeft;
    
    if (_isFahrenheit) {
        tempLowValue = round((tempLowValue - 32) * 5.f/9.f); // Convert to °C
    }
    
    [_sensitivityTempCellDelegate valueChangedTempLowValue:tempLowValue];
}

- (IBAction)btnMinusRightTouchUpInsideAction:(id)sender
{
    NSInteger temHighMin = TEMP_HIGH_MIN;
    NSInteger tempValueInCel = _tempValueRight;
    
    if (_isFahrenheit) {
        temHighMin = (round(TEMP_HIGH_MIN * 9 / 5.f)) + 32;
        tempValueInCel = (tempValueInCel  -  32)  * 5/9 ;
    }
    
    if (_tempValueRight > temHighMin) {
        self.tempValueRight--;
        _lblTemperatureValueRight.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueRight)];
        [_imgViewRight setBackgroundColor:COLOR_RGB(255.0,(33-tempValueInCel)*20,(33-tempValueInCel)*10)];
    }
    else {
        NSLog(@"SensivityTemperature too low, HIGH is not supported!");
    }
    
    [_timerTempHighValueChanged invalidate];
    self.timerTempHighValueChanged = nil;
    
    self.timerTempHighValueChanged = [NSTimer scheduledTimerWithTimeInterval:3
                                                                      target:self
                                                                    selector:@selector(reportTempHighValueChanged:)
                                                                    userInfo:nil
                                                                     repeats:NO];
}

- (IBAction)btnPlusRightTouchUpInsideAction:(id)sender
{
    NSInteger temHighMax = TEMP_HIGH_MAX;
    NSInteger tempValueInCel = _tempValueRight;
    
    if (_isFahrenheit) {
        temHighMax = (round(TEMP_HIGH_MAX * 9.f / 5.f)) + 32;
        tempValueInCel = (tempValueInCel  -  32)  * 5/9 ;
    }
    
    if (_tempValueRight < temHighMax) {
        self.tempValueRight++;
        _lblTemperatureValueRight.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueRight)];
        [_imgViewRight setBackgroundColor:COLOR_RGB(255.0,(33-tempValueInCel)*20,(33-tempValueInCel)*10)];
    }
    else {
        NSLog(@"SensivityTemperature too high, HIGH is not supported!");
    }
    
    [_timerTempHighValueChanged invalidate];
    self.timerTempHighValueChanged = nil;
    
    self.timerTempHighValueChanged = [NSTimer scheduledTimerWithTimeInterval:3
                                                                      target:self
                                                                    selector:@selector(reportTempHighValueChanged:)
                                                                    userInfo:nil
                                                                     repeats:NO];
}

- (void)reportTempHighValueChanged: (NSTimer *)timer
{
    NSInteger tempHiValue = _tempValueRight;
    
    if (_isFahrenheit) {
        tempHiValue = round((tempHiValue - 32) * 5.f/9.f); // Convert to °C
    }
    
    [_sensitivityTempCellDelegate valueChangedTempHighValue:tempHiValue];
}

- (IBAction)btnSwtichLeftTouchUpInsideAction:(UIButton *)sender
{
    self.isSwitchOnLeft = !_isSwitchOnLeft;
    
    sender.selected = _isSwitchOnLeft;
    
    _btnMinusLeft.enabled = _isSwitchOnLeft;
    _btnPlusLeft.enabled = _isSwitchOnLeft;
    
    if (_isSwitchOnLeft) {
        //[_imgViewLeft setBackgroundColor:COLOR_RGB(19.0, 154.0, 245.0)];
        NSInteger tempValueInCel = _tempValueLeft;
        if (_isFahrenheit) {
            tempValueInCel = (tempValueInCel  -  32)  * 5/9 ;
        }
        [_imgViewLeft setBackgroundColor:COLOR_RGB((tempValueInCel-9)*15,(tempValueInCel-9)*15,255-((tempValueInCel-9)*20))];
    } else {
        [_imgViewLeft setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    [_sensitivityTempCellDelegate valueChangedTempLowOn:_isSwitchOnLeft];
}

- (IBAction)btnSwitchRightTouchUpInsideAction:(UIButton *)sender
{
    self.isSwitchOnRight = !_isSwitchOnRight;
    sender.selected = _isSwitchOnRight;
    _btnMinusRight.enabled = _isSwitchOnRight;
    _btnPlusRight.enabled = _isSwitchOnRight;
    
    if (_isSwitchOnRight) {
        NSInteger tempValueInCel = _tempValueRight;
        if (_isFahrenheit) {
            tempValueInCel = (tempValueInCel  -  32)  * 5/9 ;
        }
        [_imgViewRight setBackgroundColor:COLOR_RGB(255.0,(33-tempValueInCel)*20,(33-tempValueInCel)*10)];
        //[_imgViewRight setBackgroundColor:COLOR_RGB(19.0, 154.0, 245.0)];
    }
    else {
        [_imgViewRight setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    [_sensitivityTempCellDelegate valueChangedTempHighOn:_isSwitchOnRight];
}

@end
