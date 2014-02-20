//
//  SensitivityTemperatureCell.m
//  BlinkHD_ios
//
//  Created by Developer on 2/18/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#define TEMP_LOW_MIN 10
#define TEMP_LOW_MAX 18
#define TEMP_HIGH_MIN 25
#define TEMP_HIGH_MAX 33

#import "SensitivityTemperatureCell.h"

@interface SensitivityTemperatureCell()

@property (retain, nonatomic) IBOutlet UIButton *btnTypeTemperature;
@property (retain, nonatomic) IBOutlet UILabel *lblTempValueLeft;
@property (retain, nonatomic) IBOutlet UILabel *lblTemperatureValueRight;
@property (retain, nonatomic) IBOutlet UILabel *lblTypeTempLeft;
@property (retain, nonatomic) IBOutlet UILabel *lblTypeTempRight;

@property (retain, nonatomic) IBOutlet UIButton *btnSwitchLeft;
@property (retain, nonatomic) IBOutlet UIButton *btnSwitchRight;
@property (retain, nonatomic) IBOutlet UIButton *btnMinusLeft;
@property (retain, nonatomic) IBOutlet UIButton *btnPlusLeft;
@property (retain, nonatomic) IBOutlet UIButton *btnMinusRight;
@property (retain, nonatomic) IBOutlet UIButton *btnPlusRight;

@property (nonatomic) BOOL isStopTouching;
@property (nonatomic, retain) NSTimer *timerTempLowValueChanged;
@property (nonatomic, retain) NSTimer *timerTempHighValueChanged;

@end

@implementation SensitivityTemperatureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    [self.btnTypeTemperature setImage:[UIImage imageNamed:@"settings_temp_c"] forState:UIControlStateNormal];
    [self.btnTypeTemperature setImage:[UIImage imageNamed:@"settings_temp_f"] forState:UIControlStateSelected];
    [self.btnTypeTemperature setImage:[UIImage imageNamed:@"settings_temp_f"] forState:UIControlStateHighlighted];
    
    self.btnTypeTemperature.selected = _isFahrenheit;
    
    if (_isFahrenheit)
    {
        self.tempValueLeft = ((_tempValueLeft * 9) / 5.f) + 32;
        self.tempValueRight = ((_tempValueRight * 9) / 5.f) + 32;
        
        self.lblTypeTempLeft.text = @"°F";
        self.lblTypeTempRight.text = @"°F";
    }
    else
    {
//        self.tempValueLeft = (_tempValueLeft - 32) * 5/9.f;
//        self.tempValueRight = (_tempValueRight - 32) * 5/9.f;
        
        self.lblTypeTempLeft.text = @"°C";
        self.lblTypeTempRight.text = @"°C";
    }
    
    self.lblTempValueLeft.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueLeft)];
    self.lblTemperatureValueRight.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueRight)];
    
    [self.btnSwitchLeft setImage:[UIImage imageNamed:@"settings_switch_off"] forState:UIControlStateNormal];
    [self.btnSwitchLeft setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateSelected];
    [self.btnSwitchLeft setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateHighlighted];
    
    self.btnSwitchLeft.selected = _isSwitchOnLeft;
    
    self.btnMinusLeft.enabled = _isSwitchOnLeft;
    self.btnPlusLeft.enabled = _isSwitchOnLeft;
    
    [self.btnSwitchRight setImage:[UIImage imageNamed:@"settings_switch_off"] forState:UIControlStateNormal];
    [self.btnSwitchRight setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateSelected];
    [self.btnSwitchRight setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateHighlighted];
    
    self.btnSwitchRight.selected = _isSwitchOnRight;
    
    self.btnMinusRight.enabled = _isSwitchOnRight;
    self.btnPlusRight.enabled = _isSwitchOnRight;
}

- (IBAction)btnTypeTempTouchUpInsideAction:(UIButton *)sender
{
    self.isFahrenheit = !_isFahrenheit;
    sender.selected = _isFahrenheit;
    
    if (_isFahrenheit)
    {
        self.lblTypeTempLeft.text = @"°F";
        self.lblTypeTempRight.text = @"°F";
        
        //fahrenheit = ((Celsius * 9 )/5) + 32;
        self.tempValueLeft = (_tempValueLeft * 9 / 5.f) + 32;
        self.tempValueRight = (_tempValueRight * 9 / 5.f) + 32;
    }
    else
    {
        self.lblTypeTempLeft.text = @"°C";
        self.lblTypeTempRight.text = @"°C";
        
        //celsius = (5/9) * (fahrenheit-32)
        self.tempValueLeft = (_tempValueLeft - 32) * 5/9.f;
        self.tempValueRight = (_tempValueRight - 32) * 5/9.f;
    }
    
    self.lblTempValueLeft.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueLeft)];
    self.lblTemperatureValueRight.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueRight)];
    
    [_sensitivityTempCellDelegate valueChangedTypeTemperaure:_isFahrenheit];
}

- (IBAction)btnMinusLeftTouchUpInsideAction:(id)sender
{
    NSInteger tempLowMin = TEMP_LOW_MIN;
    
    if (_isFahrenheit)
    {
        tempLowMin = (TEMP_LOW_MIN * 9 / 5.f) + 32;
    }
    
    if (_tempValueLeft > tempLowMin)
    {
        self.tempValueLeft--;
        self.lblTempValueLeft.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueLeft)];
    }
    else
    {
        NSLog(@"SensivityTemperature too low, LOW is not supported!");
    }

    if (_timerTempLowValueChanged != nil)
    {
        [_timerTempLowValueChanged invalidate];
        self.timerTempLowValueChanged = nil;
    }
    
    self.timerTempLowValueChanged  =  [NSTimer scheduledTimerWithTimeInterval:3
                                                                       target:self
                                                                     selector:@selector(reportTempLowValueChanged:)
                                                                     userInfo:nil
                                                                      repeats:NO];
}



- (IBAction)btnPlusLeftTouchUpInsideAction:(id)sender
{
    NSInteger tempHighMax = TEMP_LOW_MAX;
    
    if (_isFahrenheit)
    {
        tempHighMax = (TEMP_LOW_MAX * 9 / 5.f) + 32;
    }
    
    if (_tempValueLeft < tempHighMax)
    {
        self.tempValueLeft++;
        self.lblTempValueLeft.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueLeft)];
    }
    else
    {
        NSLog(@"SensivityTemperature too high, LOW is not supported!");
    }
    
    if (_timerTempLowValueChanged != nil)
    {
        [_timerTempLowValueChanged invalidate];
        self.timerTempLowValueChanged = nil;
    }
    
    self.timerTempLowValueChanged  =  [NSTimer scheduledTimerWithTimeInterval:3
                                                                       target:self
                                                                     selector:@selector(reportTempLowValueChanged:)
                                                                     userInfo:nil
                                                                      repeats:NO];
}

- (void)reportTempLowValueChanged: (NSTimer *)timer
{
    [_sensitivityTempCellDelegate valueChangedTempLowValue:_tempValueLeft];
}

- (IBAction)btnMinusRightTouchUpInsideAction:(id)sender
{
    NSInteger temHighMin = TEMP_HIGH_MIN;
    
    if (_isFahrenheit)
    {
        temHighMin = (TEMP_HIGH_MIN * 9 / 5.f) + 32;
    }
    
    if (_tempValueRight > temHighMin)
    {
        self.tempValueRight--;
        self.lblTemperatureValueRight.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueRight)];
    }
    else
    {
        NSLog(@"SensivityTemperature too low, HIGH is not supported!");
    }
    
    if (_timerTempHighValueChanged != nil)
    {
        [_timerTempHighValueChanged invalidate];
        self.timerTempHighValueChanged = nil;
    }
    
    self.timerTempHighValueChanged = [NSTimer scheduledTimerWithTimeInterval:3
                                                                      target:self
                                                                    selector:@selector(reportTempHighValueChanged:)
                                                                    userInfo:nil
                                                                     repeats:NO];
}

- (IBAction)btnPlusRightTouchUpInsideAction:(id)sender
{
    NSInteger temHighMax = TEMP_HIGH_MAX;
    
    if (_isFahrenheit)
    {
        temHighMax = (TEMP_HIGH_MAX * 9 / 5.f) + 32;
    }
    
    if (_tempValueRight < temHighMax)
    {
        self.tempValueRight++;
        self.lblTemperatureValueRight.text = [NSString stringWithFormat:@"%ld", lroundf(_tempValueRight)];
    }
    else
    {
        NSLog(@"SensivityTemperature too high, HIGH is not supported!");
    }
    
    if (_timerTempHighValueChanged != nil)
    {
        [_timerTempHighValueChanged invalidate];
        self.timerTempHighValueChanged = nil;
    }
    
    self.timerTempHighValueChanged = [NSTimer scheduledTimerWithTimeInterval:3
                                                                      target:self
                                                                    selector:@selector(reportTempHighValueChanged:)
                                                                    userInfo:nil
                                                                     repeats:NO];
}

- (void)reportTempHighValueChanged: (NSTimer *)timer
{
    [_sensitivityTempCellDelegate valueChangedTempHighValue:_tempValueRight];
}

- (IBAction)btnSwtichLeftTouchUpInsideAction:(UIButton *)sender
{
    self.isSwitchOnLeft = !_isSwitchOnLeft;
    
    sender.selected = _isSwitchOnLeft;
    
    self.btnMinusLeft.enabled = _isSwitchOnLeft;
    self.btnPlusLeft.enabled = _isSwitchOnLeft;
    
    [_sensitivityTempCellDelegate valueChangedTempLowOn:_isSwitchOnLeft];
}

- (IBAction)btnSwitchRightTouchUpInsideAction:(UIButton *)sender
{
    self.isSwitchOnRight = !_isSwitchOnRight;
    sender.selected = _isSwitchOnRight;
    self.btnMinusRight.enabled = _isSwitchOnRight;
    self.btnPlusRight.enabled = _isSwitchOnRight;
    
    [_sensitivityTempCellDelegate valueChangedTempHighOn:_isSwitchOnRight];
}

- (void)dealloc {
    [_btnTypeTemperature release];
    [_lblTempValueLeft release];
    [_lblTemperatureValueRight release];
    [_lblTypeTempLeft release];
    [_lblTypeTempRight release];
    [_btnSwitchLeft release];
    [_btnSwitchRight release];
    [_btnMinusLeft release];
    [_btnPlusLeft release];
    [_btnMinusRight release];
    [_btnPlusRight release];
    [super dealloc];
}
@end
