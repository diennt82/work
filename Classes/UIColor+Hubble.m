//
//  UIColor+Hubble.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 23/1/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "UIColor+Hubble.h"
#import "define.h"

@implementation UIColor (Hubble)

// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)holdToTalkTextColor
{
    return Rgb2UIColor(0, 172, 247);
}

+ (UIColor *)listeningTextColor
{
    return Rgb2UIColor(0, 172, 247);
}

+ (UIColor *)recordingTextColor
{
    return Rgb2UIColor(255, 53, 4);
}

+ (UIColor *)temperatureTextColor
{
    return Rgb2UIColor(0, 172, 247);
}

+ (UIColor *)barItemSelectedColor
{
    return Rgb2UIColor(16, 16, 16);
}

+ (UIColor *)timeLineColor
{
    return Rgb2UIColor(16, 16, 16);
}
+ (UIColor *)timeLineLineColor
{
    return Rgb2UIColor(223, 223, 223);
}

+ (UIColor *)cellMelodyColor
{
    return Rgb2UIColor(208, 209, 203);
}

+ (UIColor *)textTimerPlayBackColor
{
    return Rgb2UIColor(217, 217, 217);
}

+ (UIColor *)textForFinishPlayBackColor
{
    return Rgb2UIColor(255, 255, 255);
}

+ (UIColor *)doNotDisturbCellBGColor
{
    return Rgb2UIColor(43, 50, 56);
}

+ (UIColor *)selectButtonBackgroundColor
{
    return Rgb2UIColor(96, 170, 243);
}

+ (UIColor *)deSelectButtonBackgroundColor
{
    return Rgb2UIColor(232, 232, 232);
}

+ (UIColor *)deSelectButtonBackgroundTextColor
{
    return Rgb2UIColor(147, 147, 147);
}

+ (UIColor *)deSelectedAddCameraTextColor
{
    return Rgb2UIColor(128, 203, 235);
}
+ (UIColor *)deSelectedBuyCameraTextColor
{
    return Rgb2UIColor(172, 227, 128);
}
+ (UIColor *)selectCameraItemColor
{
    return Rgb2UIColor(96, 170, 244);
}
@end
