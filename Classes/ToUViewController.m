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
    
    self.title = @"Terms of Services";
    self.navigationController.navigationBarHidden = NO;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_logo_back"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(btnBackPressed)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [termOfUse loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL fileURLWithPath:
       [[NSBundle mainBundle] pathForResource:@"MonitorEverywhere_App_ios_Apple" ofType:@"html"] ] ] ];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = YES;
}

@end
