//
//  MBPNavController.m
//  MBP_ios
//
//  Created by NxComm on 12/5/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import "MBPNavController.h"

@interface MBPNavController ()

@end

@implementation MBPNavController

- (BOOL)shouldAutorotate
{
    UIViewController *vc = self.viewControllers[(self.viewControllers.count -1)];
    return [vc shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
