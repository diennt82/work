//
//  UIColor+Hubble.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 23/1/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "UIColor+Hubble.h"

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
    return [UIColor colorWithRed:0 green:172 blue:247 alpha:1];
}

+ (UIColor *)listeningTextColor
{
    return [UIColor colorWithRed:0 green:172 blue:247 alpha:1];
}

+ (UIColor *)recordingTextColor
{
    return [UIColor colorWithRed:255 green:53 blue:4 alpha:1];
}

+ (UIColor *)temperatureTextColor
{
    return [UIColor colorWithRed:0 green:172 blue:247 alpha:1];
}
@end
