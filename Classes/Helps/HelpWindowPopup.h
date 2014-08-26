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

@protocol HelpWindowPopupDelegate <NSObject>
- (void)willDismiss:(id)sender;
@end

@interface HelpWindowPopup : UIView

@property (nonatomic, retain) UIWebView     *webView;
@property (nonatomic, retain) UIView        *contentView;
@property (nonatomic, assign) id <HelpWindowPopupDelegate> delegate;

- (id)initWithTitle:(NSString *)title andHtmlString:(NSString *)htmlString;
- (id)initWithTitle:(NSString *)title andHtmlString:(NSString *)htmlString andHeight:(CGFloat)height;
- (void)show;
- (void)dismiss;
- (BOOL)isShowing;
@end
