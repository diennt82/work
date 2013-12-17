//
//  MenuViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "MenuViewController.h"
#import "CamerasViewController.h"
#import "SettingsViewController.h"
#import "Account_ViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

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
    
    CamerasViewController *camerasVC = [[CamerasViewController alloc] init];
    //camerasVC.cameras = self.cameras;
     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:camerasVC];
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    Account_ViewController *accountVC = [[Account_ViewController alloc] init];
    
    
    
    self.viewControllers = [NSArray arrayWithObjects:nav, settingsVC, accountVC, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
