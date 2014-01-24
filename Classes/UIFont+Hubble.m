//
//  UIFont+Hubble.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 23/1/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "UIFont+Hubble.h"

@implementation UIFont (Hubble)

//+ (id)applyHubbleFontDefaultWithSize:(CGFloat)size
//{
//    return [UIFont fontWithName:<#(NSString *)#> size:<#(CGFloat)#>]
//}
+ (id)applyHubbleFontName:(NSString *)font withSize:(CGFloat)size
{
    return [UIFont fontWithName:font size:size];
}

@end
