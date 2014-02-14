//
//  GeneralCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "GeneralCell.h"

@implementation GeneralCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnClockTouchUpInsideAction:(id)sender
{
    self.is12hr = !_is12hr;
    
    if (_is12hr)
    {
        [self.btnClock setImage:[UIImage imageNamed:@"settings_hr_12"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnClock setImage:[UIImage imageNamed:@"settings_hr_24"] forState:UIControlStateNormal];
    }
    
    //[_generalCellDelegate clockValueChanged:_is12hr];
}

- (IBAction)btnTemperatureTouchUpInsideAction:(id)sender
{
    self.isFahrenheit = !_isFahrenheit;
    
    if (_isFahrenheit)
    {
        [self.btnTemperature setImage:[UIImage imageNamed:@"settings_temp_f"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnTemperature setImage:[UIImage imageNamed:@"settings_temp_c"] forState:UIControlStateNormal];
    }
    
    //[_generalCellDelegate temperatureValueChanged:_isFahrenheit];
}

- (void)dealloc {
    [_labelClock release];
    [_btnClock release];
    [_labelTemperature release];
    [_btnTemperature release];
    [super dealloc];
}
@end
