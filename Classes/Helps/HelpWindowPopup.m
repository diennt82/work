//
//  HelpWindowPopup.m
//  BlinkHD_ios
//
//  Created by Developer on 6/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#define POPUP_WIDTH_IPHONE  290
#define POPUP_WIDTH_IPAD    350
#define POPUP_HEIGHT        210

#import "HelpWindowPopup.h"
#import "define.h"
#import "UIFont+Hubble.h"

@interface MBP_PopupOverlayWindow : UIWindow
@property (nonatomic, retain) HelpWindowPopup   *dialog;
@property (nonatomic) BOOL                      shown;
@end


@interface HelpWindowPopup()
@property (nonatomic, retain) MBP_PopupOverlayWindow    *overlayWindow;
@property (nonatomic, retain) NSString                  *title;
@property (nonatomic, retain) NSString                  *content;
@end

@implementation HelpWindowPopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andContent:(NSString *)content
{
    self = [self initWithFrame:[self frame]];
    if (self)
    {
        self.title = title;
        self.content = content;
        [self initUIComponents];
    }
    return self;
}

- (CGRect)frame
{
    CGRect rect = CGRectMake(0, 0, POPUP_WIDTH_IPHONE, POPUP_HEIGHT);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        rect = CGRectMake(0, 0, POPUP_WIDTH_IPAD, POPUP_HEIGHT);
    }
    rect.origin.x = ([[UIScreen mainScreen] bounds].size.width - rect.size.width) / 2;
    rect.origin.y = ([[UIScreen mainScreen] bounds].size.height - rect.size.height) / 2;
    return rect;
}

- (void)dealloc
{
    [_overlayWindow release];
    [_title release];
    [_content release];
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
    
    self.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [overlay addSubview:self];
    [overlay makeKeyAndVisible];
    self.overlayWindow = overlay;
    
    // Animate
    self.transform = CGAffineTransformIdentity;
    overlay.alpha = 1.0;
    [overlay release];
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
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:rect];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:scrollView];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 0)];
    UIFont *font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:17];
    contentLabel.font = font;
    contentLabel.textColor = [UIColor colorWithRed:(128/255.f) green:(128/255.f) blue:(128/255.f) alpha:1];
    contentLabel.numberOfLines = 0;
    rect = contentLabel.frame;
    rect.size.height = ceilf([self calculateHeightForString:self.content withWidthFrame:contentLabel.frame.size.width andFont:font]);
    contentLabel.frame = rect;
    contentLabel.text = self.content;
    [scrollView addSubview:contentLabel];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentLabel.frame.size.height + 10);
    
    [titleLabel release];
    [contentLabel release];
    [headerView release];
    [closeButton release];
    [scrollView release];
}

- (void)handleCloseButton:(id)sender
{
    self.overlayWindow.shown = NO;
    [self.overlayWindow setNeedsDisplay];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self removeFromSuperview];
        self.overlayWindow.dialog = nil;
        
        UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        [window makeKeyAndVisible];
        [window.rootViewController preferredStatusBarStyle];
        [window.rootViewController setNeedsStatusBarAppearanceUpdate];
    });
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