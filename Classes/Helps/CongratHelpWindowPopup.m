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
@property (nonatomic, assign) id <CongratHelpDelegate> congratDelegate;
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

- (id)initWithTarget:(id)target
{
    self = [super initWithTitle:@"" andHtmlString:@""];
    if (self) {
        self.congratDelegate = target;
        self.title = @"Congratulations!";
        self.htmlString = [self htmlString:@"Congratulations – you have qualified for a free two week trial of our optional motion-triggered Cloud Video Recording service."];
        
        NSMutableDictionary *buttonTitles = [NSMutableDictionary dictionaryWithObjects:kCongratValues forKeys:kCongratKeys];
        [buttonTitles removeObjectForKey:@(SOUND_GREAT)];
        self.buttonTitles = buttonTitles;
        
        [self reloadUIComponents];
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
    self.titleLabel.text = self.title;
    
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
        [button setTitleColor:button.tintColor forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        button.tag = [key intValue];
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
    switch (button.tag) {
        case START_FREE_TRIAL:
        {
            NSMutableDictionary *buttonTitles = [NSMutableDictionary dictionaryWithObjects:kCongratValues forKeys:kCongratKeys];
            [buttonTitles removeObjectForKey:@(START_FREE_TRIAL)];
            [buttonTitles removeObjectForKey:@(FIND_OUT_MORE)];
            self.buttonTitles = buttonTitles;
            self.title = @"Free Trial!";
            [self reloadUIComponents];
            
            self.htmlString = [self htmlString:@"With our motion-triggered video recording, you’ll never miss a moment again. Any time movement is detected by your camera you’ll receive a video of the whole event. The free trial will last for two weeks and you can turn this feature on/off at any time by going to ‘Settings’."];
            [self loadHtml];
            break;
        }
        case FIND_OUT_MORE:
        {
            NSMutableDictionary *buttonTitles = [NSMutableDictionary dictionaryWithObjects:kCongratValues forKeys:kCongratKeys];
            [buttonTitles removeObjectForKey:@(START_FREE_TRIAL)];
            [buttonTitles removeObjectForKey:@(FIND_OUT_MORE)];
            self.buttonTitles = buttonTitles;
            self.title = @"Free Trial!";
            [self reloadUIComponents];
            
            self.htmlString = [self htmlString:@"With our optional motion-triggered video recording service, you’ll never miss a moment again. Any time movement is detected by your camera you’ll receive a video of the whole event. Click to view immediately or scroll back through your timeline to see all of the day’s events.<P/>Your free trial will last for two weeks and you can turn this feature on/off at any time by going to ‘Settings’.<P/>If you’d like even more detailed information, please <a href=\"http://hubbleconnected.com/free-trial/\">click here</a>."];
            [self loadHtml];
            break;
        }
        case SOUND_GREAT:
        {
            if ([self.congratDelegate respondsToSelector:@selector(triggerSoundsGreat)])
            {
                [self.congratDelegate triggerSoundsGreat];
            }
            [self dismiss];
            break;
        }
        case MAYBE_LATER:
        {
            [self dismiss];
            break;
        }
        default:
            break;
    }
}

- (NSString *)htmlString:(NSString *)content
{
    NSMutableString *html = [[NSMutableString alloc] init];
    [html appendString:@"<html>"];
    [html appendString:@"   <body>"];
    [html appendString:@"       <div style='margin-left:5px;'>"];
    [html appendString:content];
    [html appendString:@"       </div>"];
    [html appendString:@"   </body>"];
    [html appendString:@"</html>"];
    return [html autorelease];
}

#pragma mark - Override method
- (void)initUIComponents
{
    [super initUIComponents];
    
    [self.closeButton removeFromSuperview];
    
    CGRect rect = self.webView.frame;
    rect.size.height -= 100;
    self.webView.frame = rect;
    
    rect = self.contentView.frame;
    rect.size.height += self.closeButton.frame.size.height;
    self.contentView.frame = rect;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [request.URL absoluteString];
    if ([url hasPrefix:@"file:"])
    {
        return YES;
    }
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
}
@end
