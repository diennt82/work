//
//  CongratHelpWindowPopup.m
//  BlinkHD_ios
//
//  Created by Developer on 26/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CongratHelpWindowPopup.h"

@implementation CongratHelpWindowPopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Override method
- (void)initUIComponents
{
    [super initUIComponents];
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return NO;
}
@end
