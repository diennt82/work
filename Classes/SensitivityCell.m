//
//  SensitivityCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "SensitivityCell.h"

@implementation SensitivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)valueChangedSwitchAction:(id)sender
{
    [_sensitivityCellDelegate reportSwitchValue:((UISwitch *)sender).isOn andRowIndex:_rowIndex];
    
    if (((UISwitch *)sender).isOn)
    {
        self.valueSlider.enabled = YES;
    }
    else
    {
        self.valueSlider.enabled = NO;
    }
}

- (IBAction)valueChangedSlideAction:(id)sender
{
    UISlider *aSlider = (UISlider *)sender;
    
    [_sensitivityCellDelegate reportChangedSliderValue: aSlider.value andRowIndex: self.rowIndex];
}

- (void)dealloc {
    [_nameLabel release];
    [_valueSlider release];
    [_valueSwitch release];
    [super dealloc];
}
@end
