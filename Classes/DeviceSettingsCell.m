//
//  DeviceSettingsCell.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 29/11/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "DeviceSettingsCell.h"

@implementation DeviceSettingsCell

- (IBAction)sliderValueChaned:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    [_deviceStgsCellDelegate reportChangedSliderValue:slider.value andRowIndex:_rowIndex];
}

@end
