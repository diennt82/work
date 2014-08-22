//
//  HelpWindowPopup.m
//  BlinkHD_ios
//
//  Created by Developer on 6/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#define POPUP_WIDTH_IPHONE  290
#define POPUP_WIDTH_IPAD    350

#import "HelpWindowPopup.h"

@interface MBP_PopupOverlayWindow : UIWindow
@property (nonatomic, retain) HelpWindowPopup   *dialog;
@property (nonatomic) BOOL                      shown;
@end


@interface HelpWindowPopup() <UIWebViewDelegate>
@property (nonatomic, retain) MBP_PopupOverlayWindow    *overlayWindow;
@property (nonatomic, retain) NSString                  *title;
@property (nonatomic, retain) NSString                  *htmlString;
@end

@implementation HelpWindowPopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.title = @"";
        self.htmlString = @"";
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andHtmlString:(NSString *)htmlString;
{
    self = [self initWithFrame:[self frame:420]];
    if (self)
    {
        self.title = title;
        self.htmlString = htmlString;
        [self initUIComponents];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andHtmlString:(NSString *)htmlString andHeight:(CGFloat)height;
{
    self = [self initWithFrame:[self frame:height]];
    if (self)
    {
        self.title = title;
        self.htmlString = htmlString;
        [self initUIComponents];
    }
    return self;
}

- (CGRect)frame:(CGFloat)height
{
    CGRect rect = CGRectMake(0, 0, POPUP_WIDTH_IPHONE, height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        rect = CGRectMake(0, 0, POPUP_WIDTH_IPAD, height);
    }
    rect.origin.x = ([[UIScreen mainScreen] bounds].size.width - rect.size.width) / 2;
    rect.origin.y = ([[UIScreen mainScreen] bounds].size.height - rect.size.height) / 2;
    return rect;
}

- (void)dealloc
{
    [_overlayWindow release];
    [_title release];
    [_htmlString release];
    [_webView release];
    [_contentView release];
    [super dealloc];
}

- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MBP_PopupOverlayWindow *overlay = [[MBP_PopupOverlayWindow alloc] init];
    overlay.opaque = NO;
    overlay.windowLevel = UIWindowLevelStatusBar + 1;
    overlay.frame = window.bounds;
    overlay.alpha = 0.0;
    overlay.dialog = self;
    
//    self.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [overlay addSubview:self];
    [overlay makeKeyAndVisible];
    self.overlayWindow = overlay;
    
    // Animate
//    self.transform = CGAffineTransformIdentity;
    overlay.alpha = 1.0;
    [overlay release];
    
    CGAffineTransform transform = self.transform;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIDeviceOrientationLandscapeRight)
    {
        CGPoint point = CGPointMake(self.overlayWindow.frame.size.width / 2, self.overlayWindow.frame.size.height / 2);
        self.center = point;
        transform = CGAffineTransformRotate(transform, (3 * M_PI / 2.0));
    }
    else if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        CGPoint point = CGPointMake(self.overlayWindow.frame.size.width / 2, self.overlayWindow.frame.size.height / 2);        self.center = point;
        transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
    }
    self.transform = transform;
    
    NSData *htmlData = [self.htmlString dataUsingEncoding:NSUTF8StringEncoding];
    [self.webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
    
//    
//    self.layer.opacity = 0.5f;
//    self.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0f);
//    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//					 animations:^{
//                         self.layer.opacity = 1.0f;
//                         self.layer.transform = CATransform3DMakeScale(1, 1, 1);
//					 }
//					 completion:^(BOOL finished) {
//                         self.transform = transform;
//					 }
//    ];
}

- (void)dismiss
{
    if ([self.delegate respondsToSelector:@selector(willDismiss:)])
    {
        [self.delegate willDismiss:self];
    }
    
    self.layer.transform = CATransform3DMakeScale(1, 1, 1);
//    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
//					 animations:^{
//                         self.layer.transform = CATransform3DMakeScale(0.0f, 0.0f, 1.0f);
//                         self.layer.opacity = 0.0f;
//					 }
//					 completion:^(BOOL finished) {
//                         self.overlayWindow.shown = NO;
//                         [self.overlayWindow setNeedsDisplay];
//                         dispatch_async(dispatch_get_main_queue(), ^(void) {
    [self removeFromSuperview];
    self.overlayWindow.dialog = nil;
    
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    [window makeKeyAndVisible];
    [window.rootViewController preferredStatusBarStyle];
    [window.rootViewController setNeedsStatusBarAppearanceUpdate];
//                         });
//					 }
//    ];
}

- (BOOL)isShowing
{
    return self.overlayWindow.shown;
}

#pragma mark - Private
- (void)initUIComponents
{
    self.layer.cornerRadius = 10;

    float headerHeight = 45;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, headerHeight + 10)];
    [headerView setBackgroundColor:[UIColor colorWithRed:0 green:171/255.f blue:245/255.f alpha:1.0]];
    headerView.layer.cornerRadius = 10;
    [self addSubview:headerView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 25)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:20];
    titleLabel.text = self.title;
    [headerView addSubview:titleLabel];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 45, self.frame.size.height - 40, 35, 35)];
    [closeButton setImage:[UIImage imageNamed:@"video_fullscreen_close.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    
    CGRect rect = CGRectMake(0, headerHeight, self.frame.size.width, self.frame.size.height - headerHeight - 45);
    _contentView = [[UIView alloc] initWithFrame:rect];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.contentView];
    
    rect = self.contentView.frame;
    rect.origin.y = 0;
    _webView = [[UIWebView alloc] initWithFrame:rect];
    [self.webView setBackgroundColor:[UIColor whiteColor]];
    self.webView.delegate = self;
    [self.contentView addSubview:self.webView];
    
    [titleLabel release];
    [headerView release];
    [closeButton release];
}

- (void)handleCloseButton:(id)sender
{
    [self dismiss];
}

- (CGFloat)calculateHeightForString:(NSString *)desc withWidthFrame:(CGFloat)width andFont:(UIFont *)font {
    CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
    CGSize theSize = [desc sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return theSize.height;
}

- (void)drawDimmedBackgroundInRect:(CGRect)rect {
    // General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color Declarations
    UIColor *greyInner = [UIColor colorWithWhite:0.0 alpha:0.70];
    UIColor *greyOuter = [UIColor colorWithWhite:0.0 alpha:0.2];
    
    // Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)greyOuter.CGColor,
                               (id)greyInner.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    // Rectangle Drawing
    CGPoint mid = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rect];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawRadialGradient(context,
                                gradient,
                                mid, 10,
                                mid, CGRectGetMidY(rect),
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    // Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)clearDimmedBackgroundInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
}

#pragma mark - UIWebviewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end

@implementation MBP_PopupOverlayWindow

- (id)init
{
    if (self == [super init])
    {
        _shown = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_shown)
    {
        [self.dialog drawDimmedBackgroundInRect:rect];
    }
    else
    {
        [self.dialog clearDimmedBackgroundInRect:rect];
    }
}

- (void)dealloc
{
    [_dialog release];
    [super dealloc];
}
@end
