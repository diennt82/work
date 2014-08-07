//
//  DoNotDisturbCell.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 12/3/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "DoNotDisturbCell.h"
#import "UIColor+Hubble.h"
#import "UIImage+Hubble.h"
#import "define.h"

@interface DoNotDisturbCell ()

@property (nonatomic) BOOL isEnableDoNotDisturb;

@end

@implementation DoNotDisturbCell

- (void)drawRect:(CGRect)rect
{
    //get and set Enable do not disturb
    
    self.backgroundColor = [UIColor colorWithRed:43/255.f green:50/255.f blue:56/255.f alpha:1];
        
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _isEnableDoNotDisturb = [userDefaults boolForKey:@"EnableDoNotDisturb"];
    if (_isEnableDoNotDisturb) {
        _imgViewEnableDisable.hidden = YES;
        //enable
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [_ienableDoNotDisturbButton setImage:[UIImage imageSwitchOn] forState:UIControlStateNormal];
        [_icircleSliderCustom setUserInteractionEnabled:YES];
        _icircleSliderCustom.value = [self updateValueCustomSlider];
        [_icircleSliderCustom startTimerUpdateLabel];
        [_icircleSliderCustom.textField setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
        [_icircleSliderCustom.minuteTField setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    }
    else {
        _imgViewEnableDisable.hidden = NO;

        //disable
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        [_ienableDoNotDisturbButton setImage:[UIImage imageSwitchOff] forState:UIControlStateNormal];
        [_icircleSliderCustom setUserInteractionEnabled:NO];
        [_icircleSliderCustom.textField setTextColor:[UIColor lightGrayColor]];
        [_icircleSliderCustom.minuteTField setTextColor:[UIColor lightGrayColor]];
    }
}

- (NSInteger)updateValueCustomSlider
{
    NSInteger nowInterval = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger timeExpire = [userDefaults integerForKey:TIME_TO_EXPIRED];
    NSInteger deltaTime = nowInterval - timeExpire;
    if (deltaTime >= 0) {
        return 0;
    }
    else {
        return round(abs(deltaTime)/60.0);
    }
}

- (IBAction)didEnableDisturb:(id)sender {
    _isEnableDoNotDisturb = !_isEnableDoNotDisturb;
    
    if (_isEnableDoNotDisturb) {
        _imgViewEnableDisable.hidden = YES;
    }
    else {
        _imgViewEnableDisable.hidden = NO;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_isEnableDoNotDisturb forKey:@"EnableDoNotDisturb"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (_isEnableDoNotDisturb) {
        //enable
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [_ienableDoNotDisturbButton setImage:[UIImage imageSwitchOn] forState:UIControlStateNormal];
        [_icircleSliderCustom setUserInteractionEnabled:YES];
        [_icircleSliderCustom.textField setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
        [_icircleSliderCustom.minuteTField setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    }
    else {
        //disable
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        [_ienableDoNotDisturbButton setImage:[UIImage imageSwitchOff] forState:UIControlStateNormal];
        [_icircleSliderCustom setUserInteractionEnabled:NO];
        [_icircleSliderCustom.textField setTextColor:[UIColor lightGrayColor]];
        [_icircleSliderCustom.minuteTField setTextColor:[UIColor lightGrayColor]];
    }
}

@end
