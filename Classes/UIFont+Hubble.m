//
//  UIFont+Hubble.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 23/1/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "UIFont+Hubble.h"
#import "Define.h"

@implementation UIFont (Hubble)

+ (id)applyHubbleFontName:(NSString *)font withSize:(CGFloat)size
{
    return [UIFont fontWithName:font size:size];
}

+ (UIFont *)lightLarge27Font
{
    return [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:27];
}

+ (UIFont *)lightSmall14Font
{
    return [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:14];
}

+ (UIFont *)lightSmall13Font
{
    return [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:13];
}

+ (UIFont *)regularMediumFont
{
    return [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:16];
}

+ (UIFont *)bold20Font
{
    return [UIFont applyHubbleFontName:PN_BOLD_FONT withSize:20];
}

+ (UIFont *)semiBold12Font
{
    return [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:12];
}

+ (UIFont *)regular11Font
{
    return [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:11];
}
@end
