//
//  UIBarButtonItem+Custom.m
//  BlinkHD_ios
//
//  Created by Developer on 2/27/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "UIBarButtonItem+Custom.h"

@implementation UIBarButtonItem (Custom)

+ (UIBarButtonItem*)barButtonItemWithImage:(UIImage*)image target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:action  forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[image stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height) ];
    [v addSubview:button];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:v];
    return barButton;
}

@end
