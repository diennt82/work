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
    
    self.navigationController.navigationBarHidden = NO;

    UIImage *tmpImg = [UIImage imageNamed:@"Hubble_logo_back.png"];
    
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithImage:tmpImg
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(menuBackAction:)];
    
    self.navigationItem.leftBarButtonItem = backBarBtn;
   // assert(self.navigationController.navigationItem.leftBarButtonItem != nil);
    
    CamerasViewController *camerasVC = [[CamerasViewController alloc] init];
    camerasVC.parentVC = self;
     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:camerasVC];
    
    
    
    //[self.navigationController initWithRootViewController:camerasVC];
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    Account_ViewController *accountVC = [[Account_ViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:accountVC];
    
    
    self.viewControllers = [NSArray arrayWithObjects:nav, nav1, nav2, nil];
}

- (void)menuBackAction: (id)sender
{
    // Back to Player view. What is camera selected? 0?
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
