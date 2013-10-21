//
//  ZoneViewController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 21/10/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "ZoneViewController.h"

@interface ZoneViewController ()

@end

@implementation ZoneViewController
@synthesize  zone1, zone2, zone3, zone4,zone5,zone6,zone7,zone8,zone9;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)shouldAutorotate
{
    return NO;
}



- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
