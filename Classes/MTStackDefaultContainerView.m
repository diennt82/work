//
//  MTStackDefaultContainerView.m
//  MTStackViewControllerExample
//
//  Created by Jeff Ward on 6/20/13.
//  Copyright (c) 2013 WillowTree Apps. All rights reserved.
//

#import "MTStackDefaultContainerView.h"

#import <QuartzCore/QuartzCore.h>

@interface MTStackDefaultContainerView ()

@property (nonatomic, readonly) UIView *overlayView;
@property (nonatomic) BOOL parallaxEnabled;

@end

@implementation MTStackDefaultContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        
        self.parallaxEnabled = YES;
        
        _overlayView = [[UIView alloc] initWithFrame:[self bounds]];
        [[self overlayView] setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [[self overlayView] setAlpha:1.0f];
        self.overlayView.backgroundColor = [UIColor blackColor];
        [self addSubview:_overlayView];
        
        [self.layer setRasterizationScale:[UIScreen mainScreen].scale];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self bringSubviewToFront:[self overlayView]];
}

-(void)stackViewController:(MTStackViewController *)stackViewController show:(BOOL)show
                      side:(MTStackViewControllerPosition)side toFrame:(CGRect)rect
              withDuration:(CGFloat)duration
{
    
    float x = CGRectGetMinX(rect);
    if(!show && self.parallaxEnabled)
    {
        float parallaxOffset = (stackViewController.slideOffset / 4.0f);
        switch(side)
        {
            case MTStackViewControllerPositionLeft:
                x = x - parallaxOffset;
                break;
            case MTStackViewControllerPositionRight:
                x = x + parallaxOffset;
                break;
        }
    }
    CGRect realRect = CGRectMake(x, CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect));
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.overlayView.alpha = show ? 0.0f : 0.7f;
                         self.frame = realRect;
                     }
                     completion:^(BOOL finished) {
         
                     }];
}

-(void)stackViewController:(MTStackViewController *)stackViewController anmimateToFame:(CGRect)rect side:(MTStackViewControllerPosition)side withOffset:(CGFloat)offset
{
    float x = CGRectGetMinX(rect);
    if(self.parallaxEnabled)
    {
        float parallaxOffset = (stackViewController.slideOffset / 4.0f);
        switch(side)
        {
            case MTStackViewControllerPositionLeft:
            {
                x = x - parallaxOffset + (offset * parallaxOffset);
                break;
            }
            case MTStackViewControllerPositionRight:
            {
                x = x + parallaxOffset - (offset * parallaxOffset);
                break;
            }
        }
        
    }

    self.frame = CGRectMake(x, CGRectGetMinY(rect),
                            CGRectGetWidth(rect), CGRectGetHeight(rect));
    
    [self.overlayView setAlpha:0.7f - (1.0f * fminf(offset, 0.7f))];
}

@end
