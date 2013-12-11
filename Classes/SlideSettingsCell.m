//
//  SlideSettingsCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "SlideSettingsCell.h"

@implementation SlideSettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.slideSettings.minimumValueImage = aImage;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)slideValueChangedAction:(id)sender
{
    UISlider *aSlider = (UISlider *)sender;
    
    [_slideSettingsDelegate reportChangedSliderValue: aSlider.value andRowIndex: self.rowIndex];
}

- (void)dealloc {
    [_slideSettings release];
    [super dealloc];
}
@end
