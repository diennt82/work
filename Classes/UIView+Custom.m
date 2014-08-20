//
//  UIView+Custom.m
//  BlinkHD_ios
//
//  Created by Developer on 15/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "UIView+Custom.h"

@implementation UIView (Custom)
- (void)setLocalizationText:(NSString *)text
{
    if (self)
    {
        if ([self isKindOfClass:[UILabel class]])
        {
            UILabel *lable = (UILabel *)self;
            lable.text = text;
        }
        else if ([self isKindOfClass:[UITextView class]])
        {
            UITextView *textView = (UITextView *)self;
            textView.text = text;
        }
        else if ([self isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *)self;
            textField.placeholder = text;
        }
        else if ([self isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *)self;
            [button setTitle:text forState:UIControlStateNormal];
        }
    }
}
@end
