//
//  EarlierNavigationController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 28/2/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "EarlierNavigationController.h"

@interface EarlierNavigationController ()

@end

@implementation EarlierNavigationController

@synthesize isEarlierView = _isEarlierView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isEarlierView = NO;
}

- (BOOL) shouldAutorotate
{
    UIViewController *vc = [self.viewControllers lastObject];
    return [vc shouldAutorotate];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return YES;
}

@end
