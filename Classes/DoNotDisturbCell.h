//
//  DoNotDisturbCell.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 12/3/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICircularSlider.h"

@interface DoNotDisturbCell : UITableViewCell
{
    BOOL _isEnableDoNotDisturb;
}

@property (retain, nonatomic) IBOutlet UIButton *ib_enableDoNotDisturb;
@property (unsafe_unretained, nonatomic) IBOutlet UICircularSlider *ib_circleSliderCustom;
@property (retain, nonatomic) IBOutlet UIImageView *imgViewEnableDisable;
@property (assign, nonatomic) IBOutlet  UILabel *descLabel;
- (IBAction)didEnableDisturb:(id)sender;

@end
