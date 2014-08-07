//
//  DoNotDisturbCell.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 12/3/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICircularSlider.h"

@interface DoNotDisturbCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *ienableDoNotDisturbButton;
@property (nonatomic, weak) IBOutlet UICircularSlider *icircleSliderCustom;
@property (nonatomic, weak) IBOutlet UIImageView *imgViewEnableDisable;

- (IBAction)didEnableDisturb:(id)sender;

@end
