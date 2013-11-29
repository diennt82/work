//
//  DeviceSettingsCell.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 29/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "DeviceSettingsCell.h"

@implementation DeviceSettingsCell

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

- (IBAction)sliderValueChaned:(id)sender
{
    UISlider *aSlider = (UISlider *)sender;
    
    [_deviceStgsCellDelegate reportChangedSliderValue: aSlider.value andRowIndex: self.rowIndex];
}

- (void)dealloc {
    [_nameLabel release];
    [_valueSlider release];
    [super dealloc];
}
@end
