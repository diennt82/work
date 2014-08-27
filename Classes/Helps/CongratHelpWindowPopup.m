//
//  CongratHelpWindowPopup.m
//  BlinkHD_ios
//
//  Created by Developer on 26/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CongratHelpWindowPopup.h"

@interface CongratHelpWindowPopup()
@property (nonatomic, retain) UIView *actionView;
@end

@implementation CongratHelpWindowPopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [_buttonTitles release];
    [_actionView release];
    [super dealloc];
}

- (void)reloadUIComponents
{
    if (self.actionView)
    {
        [self.actionView removeFromSuperview];
        self.actionView = nil;
    }
    _actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 0)];
    [self.contentView addSubview:self.actionView];
    
    CGFloat buttonHeight = 40;
    CGFloat buttonOffsetY = 0;
    for (NSString *key in [self.buttonTitles allKeys])
    {
        NSString *title = [self.buttonTitles objectForKey:key];
        
        CGRect rect = self.actionView.frame;
        rect.size.height += buttonHeight;
        self.actionView.frame = rect;
        
        rect = CGRectMake(0, buttonOffsetY, self.contentView.frame.size.width, buttonHeight - 1);
        UIButton *button = [[UIButton alloc] initWithFrame:rect];
        [button setTitle:title forState:UIControlStateNormal];
        [button.titleLabel setTextColor:[UIColor blackColor]];
        button.tag = (int)key;
        [button addTarget:self action:@selector(handleButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionView addSubview:button];
        
        if (key != [self.buttonTitles.allKeys lastObject])
        {
            rect.size.height = 1;
            rect.origin.y = CGRectGetMaxY(button.frame);
            rect.origin.x = 25;
            rect.size.width -= 50;
            UIView *line = [[UIView alloc] initWithFrame:rect];
            [line setBackgroundColor:[UIColor colorWithRed:189/255.0f green:189/255.0f blue:189/255.0f alpha:1.0f]];
            [self.actionView addSubview:line];
            [line release];
        }
        
        buttonOffsetY += buttonHeight;
        [button release];
    }
    CGRect rect = self.actionView.frame;
    rect.origin.y = self.contentView.frame.size.height - rect.size.height;
    self.actionView.frame = rect;
    
    rect = self.webView.frame;
    rect.size.height = self.contentView.frame.size.height - self.actionView.frame.size.height;
    self.webView.frame = rect;
}

- (void)handleButtonTouchUpInside:(id)sender
{
    UIButton *button = sender;
    [self reloadUIComponents];
}

#pragma mark - Override method
- (void)initUIComponents
{
    [super initUIComponents];
    
//    [self.closeButton removeFromSuperview];
    
    CGRect rect = self.webView.frame;
    rect.size.height -= 100;
    self.webView.frame = rect;
    
    rect = self.contentView.frame;
    rect.size.height += self.closeButton.frame.size.height;
    self.contentView.frame = rect;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
@end
