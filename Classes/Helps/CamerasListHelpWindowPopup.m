//
//  CamerasListHelpWindowPopup.m
//  BlinkHD_ios
//
//  Created by Developer on 13/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CamerasListHelpWindowPopup.h"

@implementation CamerasListHelpWindowPopup

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
    
    CGRect rect = self.webView.frame;
    rect.origin.y += 85;
    rect.size.height -= 85;
    self.webView.frame = rect;
    
    rect = CGRectMake(5, 5, 120, 80);
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:rect];
    [iconImageView setBackgroundColor:[UIColor lightGrayColor]];
    [iconImageView setImage:[UIImage imageNamed:@"camera_focus_66"]];
    iconImageView.alpha = 0.25;
    [self.contentView addSubview:iconImageView];
    
    rect = CGRectMake(CGRectGetMaxX(iconImageView.frame) + 7, 5, self.frame.size.width - CGRectGetMaxX(iconImageView.frame) - 5, 20);
    UILabel *lable = [[UILabel alloc] initWithFrame:rect];
    [lable setText:@"Camera Name"];
    lable.alpha = 0.25;
    lable.font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:17];
    [self.contentView addSubview:lable];
    
    rect = CGRectMake(CGRectGetMaxX(iconImageView.frame) + 7, 40, 7, 7);
    UIImageView *statusImageView = [[UIImageView alloc] initWithFrame:rect];
    [statusImageView setImage:[UIImage imageNamed:@"online.png"]];
    [self.contentView addSubview:statusImageView];
    
    rect = CGRectMake(CGRectGetMaxX(iconImageView.frame) + 20, 33, 100, 20);
    UILabel *statusLable = [[UILabel alloc] initWithFrame:rect];
    [statusLable setText:@"Online"];
    statusLable.font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:13];
    [self.contentView addSubview:statusLable];
    
    rect = CGRectMake(CGRectGetMaxX(iconImageView.frame) + 7, 60, 20, 20);
    UIImageView *gearImageView = [[UIImageView alloc] initWithFrame:rect];
    [gearImageView setImage:[UIImage imageNamed:@"camera_settings_pressed.png"]];
    gearImageView.alpha = 0.25;
    [self.contentView addSubview:gearImageView];
    
    
    [statusImageView release];
    [statusLable release];
    [gearImageView release];
    [lable release];
    [iconImageView release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
@end
