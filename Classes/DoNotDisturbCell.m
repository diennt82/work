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
#import "MBP_iosAppDelegate.h"
#import "UIView+Custom.h"

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
    if (isiPhone4) {
        CGRect rect = self.ib_circleSliderCustom.frame;
        rect.origin.y -= 25;
        self.ib_circleSliderCustom.frame = rect;
        
        rect = self.descLabel.frame;
        rect.origin.y -= 25;
        self.descLabel.frame = rect;
    }
    
    self.backgroundColor = [UIColor colorWithRed:43/255.f green:50/255.f blue:56/255.f alpha:1];
        
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _isEnableDoNotDisturb = [userDefaults boolForKey:ENABLE_DO_NOT_DISTURB];
    if (_isEnableDoNotDisturb)
    {
        self.imgViewEnableDisable.hidden = YES;
        //enable
        if (self.ib_circleSliderCustom.value > 0)
        {
            MBP_iosAppDelegate *appDelegate = (MBP_iosAppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate unregisterForRemoteNotifications];
        }
        [self.ib_enableDoNotDisturb setImage:[UIImage imageSwitchOn] forState:UIControlStateNormal];
        [self.ib_circleSliderCustom setUserInteractionEnabled:YES];
        self.ib_circleSliderCustom.value = [self updateValueCustomSlider];
        [self.ib_circleSliderCustom startTimerUpdateLabel];
        [self.ib_circleSliderCustom.textField setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
        [self.ib_circleSliderCustom.minuteTField setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    }
    else
    {
        self.imgViewEnableDisable.hidden = NO;

        //disable
        MBP_iosAppDelegate *appDelegate = (MBP_iosAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate registerForRemoteNotification];
        [self.ib_enableDoNotDisturb setImage:[UIImage imageSwitchOff] forState:UIControlStateNormal];
        [self.ib_circleSliderCustom setUserInteractionEnabled:NO];
        [self.ib_circleSliderCustom.textField setTextColor:[UIColor lightGrayColor]];
        [self.ib_circleSliderCustom.minuteTField setTextColor:[UIColor lightGrayColor]];
    }
    
    [self xibDefaultLocalization];
}

- (void)xibDefaultLocalization
{
    [self.ib_enableDoNotDisturb setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_settingpage_cell_donotdisturb_button_on", nil, [NSBundle mainBundle], @"On", nil)];
    [self.descLabel setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_settingpage_cell_donotdisturb_label_des", nil, [NSBundle mainBundle], @"Choose how long you don't want to receive notifications for. Remember you can always edit your notification settings in General Settings", nil)];
}

- (NSInteger)updateValueCustomSlider
{
    NSInteger nowInterval = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger timeExpire = [userDefaults integerForKey:TIME_TO_EXPIRED];
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
    [super dealloc];
}

- (IBAction)didEnableDisturb:(id)sender {
    _isEnableDoNotDisturb = !_isEnableDoNotDisturb;
    
    if(_isEnableDoNotDisturb)
    {
        self.imgViewEnableDisable.hidden = YES;
    }
    else
    {
        self.imgViewEnableDisable.hidden = NO;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_isEnableDoNotDisturb forKey:ENABLE_DO_NOT_DISTURB];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (_isEnableDoNotDisturb)
    {
        //enable
        if (self.ib_circleSliderCustom.value > 0)
        {
            MBP_iosAppDelegate *appDelegate = (MBP_iosAppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate unregisterForRemoteNotifications];
        }
        [self.ib_enableDoNotDisturb setImage:[UIImage imageSwitchOn] forState:UIControlStateNormal];
        [self.ib_circleSliderCustom setUserInteractionEnabled:YES];
        [self.ib_circleSliderCustom.textField setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
        [self.ib_circleSliderCustom.minuteTField setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    }
    else
    {
        //disable
        MBP_iosAppDelegate *appDelegate = (MBP_iosAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate registerForRemoteNotification];
        [self.ib_enableDoNotDisturb setImage:[UIImage imageSwitchOff] forState:UIControlStateNormal];
        [self.ib_circleSliderCustom setUserInteractionEnabled:NO];
        [self.ib_circleSliderCustom.textField setTextColor:[UIColor lightGrayColor]];
        [self.ib_circleSliderCustom.minuteTField setTextColor:[UIColor lightGrayColor]];
    }
}

@end
