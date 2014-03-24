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
#import "define.h"

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

- (void)drawRect:(CGRect)rect
{
    //get and set Enable do not disturb
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isEnable = [userDefaults objectForKey:@"EnableDoNotDisturb"];
    if (isEnable)
    {
        //enable
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [self.ib_enableDoNotDisturb setImage:[UIImage imageSwitchOn] forState:UIControlStateNormal];
        [self.ib_circleSliderCustom setUserInteractionEnabled:YES];
        self.ib_circleSliderCustom.value = [self updateValueCustomSlider];        
    }
    else
    {
        //disable
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        [self.ib_enableDoNotDisturb setImage:[UIImage imageSwitchOff] forState:UIControlStateNormal];
        [self.ib_circleSliderCustom setUserInteractionEnabled:NO];
        [self.ib_circleSliderCustom startTimerUpdateLabel];
    }
}

- (NSInteger)updateValueCustomSlider
{
    NSInteger nowInterval = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSLog(@"time current is %d", nowInterval);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger timeExpire = [userDefaults integerForKey:TIME_TO_EXPIRED];
    NSLog(@"time expire is %d", timeExpire);
    NSInteger deltaTime = nowInterval - timeExpire;
    if (deltaTime >= 0)
    {
        return 0;
    }
    else
    {
        return round(abs(deltaTime)/60.0);
    }
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
    [userDefaults setBool:_isEnableDoNotDisturb forKey:@"EnableDoNotDisturb"];
    
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
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        [self.ib_enableDoNotDisturb setImage:[UIImage imageSwitchOff] forState:UIControlStateNormal];
        [self.ib_circleSliderCustom setUserInteractionEnabled:NO];
    }
}

@end
