//
//  DoNotDisturbCell.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 12/3/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "DoNotDisturbCell.h"
#import "UIColor+Hubble.h"
#import "UIImage+Hubble.h"

@implementation DoNotDisturbCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //Create the Circular Slider

    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)dealloc {
    [_ib_enableDoNotDisturb release];
    [_ib_circleSliderCustom release];
    [super dealloc];
}
BOOL _isEnableDoNotDisturb = NO;
- (IBAction)didEnableDisturb:(id)sender {
    _isEnableDoNotDisturb = !_isEnableDoNotDisturb;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_isEnableDoNotDisturb forKey:@"DoNotDisturb"];
    
    if (_isEnableDoNotDisturb)
    {
        //enable
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [self.ib_enableDoNotDisturb setImage:[UIImage imageSwitchOn] forState:UIControlStateNormal];
        [self.ib_circleSliderCustom setUserInteractionEnabled:YES];
    }
    else
    {
        //disable
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
        [self.ib_enableDoNotDisturb setImage:[UIImage imageSwitchOff] forState:UIControlStateNormal];
        [self.ib_circleSliderCustom setUserInteractionEnabled:NO];
    }
}

@end
