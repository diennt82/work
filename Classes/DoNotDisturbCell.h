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

@property (nonatomic, retain) IBOutlet UIButton *ienableDoNotDisturbButton;
@property (nonatomic, retain) IBOutlet UICircularSlider *icircleSliderCustom;
@property (nonatomic, retain) IBOutlet UIImageView *imgViewEnableDisable;

- (IBAction)didEnableDisturb:(id)sender;

@end
