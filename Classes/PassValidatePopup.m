//
//  PassValidatePopup.m
//  BlinkHD_ios
//
//  Created by Developer on 28/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//



#define POPUP_WIDTH_IPAD    320

#import "PassValidatePopup.h"

@interface MBP_ValidatePopupOverlayWindow : UIWindow
@property (nonatomic, retain) PassValidatePopup         *dialog;
@property (nonatomic) BOOL                              shown;
@end

@interface PassValidatePopup()
@property (nonatomic, retain) MBP_ValidatePopupOverlayWindow    *overlayWindow;
@property (nonatomic, assign) IBOutlet UILabel          *titleLabel;
@property (nonatomic, assign) IBOutlet UIButton         *closeButon;
@property (nonatomic, assign) IBOutlet UIImageView      *imv1Number;
@property (nonatomic, assign) IBOutlet UIImageView      *imv1Leter;
@property (nonatomic, assign) IBOutlet UIImageView      *imv8CharsLength;
@property (nonatomic, assign) IBOutlet UIImageView      *imv12CharsLength;
@property (nonatomic, retain) NSString                  *password;
@end

@implementation PassValidatePopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
    }
    return self;
}

- (id)initwithPassword:(NSString *)text
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PassValidatePopup" owner:nil options:nil];
    if (objects.count > 0)
    {
        self = [[objects objectAtIndex:0] retain];
        self.password = text;
        if (self.password == nil)
        {
            self.password = @"";
        }
        [self initUIComponents];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)dealloc
{
    [_overlayWindow release];
    [_password release];
    [super dealloc];
}

- (void)initUIComponents
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MBP_ValidatePopupOverlayWindow *overlay = [[MBP_ValidatePopupOverlayWindow alloc] init];
    overlay.opaque = NO;
    overlay.windowLevel = UIWindowLevelStatusBar + 1;
    overlay.frame = window.bounds;
    overlay.alpha = 0.0;
    overlay.dialog = self;
    [overlay addSubview:self];
    [overlay makeKeyAndVisible];
    self.overlayWindow = overlay;
    [overlay release];
    
    self.layer.cornerRadius = 10;
    
    CGRect rect = self.frame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        rect.size.width = POPUP_WIDTH_IPAD;
        self.frame = rect;
        
        CGRect ctRect = self.closeButon.frame;
        ctRect.origin.x = (self.frame.size.width - self.closeButon.frame.size.width) / 2;
        self.closeButon.frame = ctRect;
        ctRect = self.titleLabel.frame;
        ctRect.origin.x = (self.frame.size.width - self.titleLabel.frame.size.width) / 2;
        self.titleLabel.frame = ctRect;
    }
    rect.origin.x = (self.overlayWindow.frame.size.width - self.frame.size.width) / 2;
    rect.origin.y = (self.overlayWindow.frame.size.height - self.frame.size.height) / 2;
    self.frame = rect;
    
    [self checkAtLeast1Degit];
    [self checkAtLeast1Letter];
    [self checkAtLeast8Charecters];
    [self checkAtMost12Charecters];
}

- (void)checkAtLeast1Degit
{
    NSString *pattern = @"(?=.*\\d)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray *matches = [regex matchesInString:self.password options:0 range:NSMakeRange(0, self.password.length)];
    if (matches.count == 0)
    {
        [self.imv1Number setImage:[UIImage imageNamed:@"password_fail.png"]];
    }
}

- (void)checkAtLeast1Letter
{
    NSString *pattern = @"(?=.*[a-zA-Z])";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray *matches = [regex matchesInString:self.password options:0 range:NSMakeRange(0, self.password.length)];
    if (matches.count == 0)
    {
        [self.imv1Leter setImage:[UIImage imageNamed:@"password_fail.png"]];
    }
}

- (void)checkAtLeast8Charecters
{
    if (self.password.length < 8)
    {
        [self.imv8CharsLength setImage:[UIImage imageNamed:@"password_fail.png"]];
    }
}

- (void)checkAtMost12Charecters
{
    if (self.password.length > 12)
    {
        [self.imv12CharsLength setImage:[UIImage imageNamed:@"password_fail.png"]];
    }
}

- (void)show
{
    self.overlayWindow.alpha = 1.0;
    
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
}

- (void)dismiss
{
    self.layer.transform = CATransform3DMakeScale(1, 1, 1);
    [self removeFromSuperview];
    self.overlayWindow.dialog = nil;
    
    self.overlayWindow.shown = NO;
    [self.overlayWindow setNeedsDisplay];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        [window makeKeyAndVisible];
        [window.rootViewController preferredStatusBarStyle];
        [window.rootViewController setNeedsStatusBarAppearanceUpdate];
    });
}

- (IBAction)handleCloseButton:(id)sender
{
    [self dismiss];
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

@implementation MBP_ValidatePopupOverlayWindow

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