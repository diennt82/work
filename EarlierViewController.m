//
//  EarlierViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "EarlierViewController.h"
#import "TimelineViewController.h"
#import "SavedEventViewController.h"

@interface EarlierViewController ()

@end

@implementation EarlierViewController

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
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TimelineViewController alloc] init]];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:[[SavedEventViewController alloc] init]];
    
    self.viewControllers = [NSArray arrayWithObjects:nav, nav1, nil];
 
    [nav release];
    [nav1 release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
