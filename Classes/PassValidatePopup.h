//
//  PassValidatePopup.h
//  BlinkHD_ios
//
//  Created by Developer on 28/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassValidatePopup : UIView
@property (nonatomic, assign) IBOutlet UIView *contentView;

- (id)initwithPassword:(NSString *)text andTitle:(NSString *)title;
- (void)show;
- (void)dismiss;
- (void)formatAllTextByFont:(UIFont *)font andTextColor:(UIColor *)color;
@end
