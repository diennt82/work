//
//  UIFont+Hubble.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 23/1/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Hubble)
+ (id)applyHubbleFontName:(NSString *)font withSize:(CGFloat)size;

+ (UIFont *)lightLarge27Font;
+ (UIFont *)lightSmall14Font;
+ (UIFont *)lightSmall13Font;
+ (UIFont *)regularMediumFont;
+ (UIFont *)bold20Font;
+ (UIFont *)semiBold12Font;
+ (UIFont *)regular11Font;
@end
