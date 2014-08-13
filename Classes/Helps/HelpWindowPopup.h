//
//  HelpWindowPopup.h
//  BlinkHD_ios
//
//  Created by Developer on 6/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "define.h"
#import "UIFont+Hubble.h"

@interface HelpWindowPopup : UIView

@property (nonatomic, retain) UIWebView     *webView;
@property (nonatomic, retain) UIView        *contentView;

- (id)initWithTitle:(NSString *)title andHtmlString:(NSString *)htmlString;
- (void)show;
@end
