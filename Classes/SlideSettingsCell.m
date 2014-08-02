//
//  SlideSettingsCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "SlideSettingsCell.h"

@implementation SlideSettingsCell

- (IBAction)slideValueChangedAction:(id)sender
{
    UISlider *aSlider = (UISlider *)sender;
    [_slideSettingsDelegate reportChangedSliderValue:aSlider.value andRowIndex:_rowIndex];
}

- (void)dealloc
{
    [_slideSettings release];
    [super dealloc];
}

@end
