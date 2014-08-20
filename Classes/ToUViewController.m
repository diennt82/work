//
//  ToUViewController.m
//  MBP_ios
//
//  Created by NxComm on 1/11/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import "ToUViewController.h"

@interface ToUViewController ()

@end

@implementation ToUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LocStr(@"Terms of Services");
    
    [termOfUse loadRequest:[NSURLRequest requestWithURL:
                            [NSURL fileURLWithPath:
                             [[NSBundle mainBundle] pathForResource:@"MonitorEverywhere_App_ios_Apple" ofType:@"html"]]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
