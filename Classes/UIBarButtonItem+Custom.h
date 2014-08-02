//
//  UIBarButtonItem+Custom.h
//  BlinkHD_ios
//
//  Created by Developer on 2/27/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Custom)

+ (UIBarButtonItem*)barButtonItemWithImage:(UIImage*)image
                                   target:(id)target
                                   action:(SEL)action;

@end
