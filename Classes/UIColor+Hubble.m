//
//  UIColor+Hubble.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 23/1/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
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
@end
