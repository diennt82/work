//
//  EarlierNavigationController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 28/2/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "EarlierNavigationController.h"
#import "PublicDefine.h"

@interface EarlierNavigationController ()

@end

@implementation EarlierNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isEarlierView = NO;
}

- (BOOL)shouldAutorotate
{
    UIViewController *vc = [self.viewControllers lastObject];
    return [vc shouldAutorotate];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (!_isEarlierView) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
        if ( camInView ) {
            return  UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
