//
//  MenuViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "MenuViewController.h"
#import "SettingsViewController.h"
#import "Account_ViewController.h"

@interface MenuViewController ()

@property (retain, nonatomic) Account_ViewController *accountVC;


@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Menu";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
     withConnDelegate:(id<ConnectionMethodDelegate> ) caller
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.menuDelegate = caller;
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = YES;
    
    UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back.png"];
    
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithImage:hubbleBack
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(menuBackAction:)];
    [backBarBtn setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
    
    self.navigationItem.leftBarButtonItem = backBarBtn;
   // assert(self.navigationController.navigationItem.leftBarButtonItem != nil);
    
    self.camerasVC = [[CamerasViewController alloc] initWithStyle:nil
                                                         delegate:self.menuDelegate
                                                         parentVC:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_camerasVC];
    
    //[self.navigationController initWithRootViewController:camerasVC];
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    //UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    self.accountVC = [[Account_ViewController alloc] init];
    
    NSLog(@"viewDidLoad: %p, %p", self.menuDelegate, self.accountVC.mdelegate);
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:_accountVC];
    
    
    self.viewControllers = [NSArray arrayWithObjects:nav, settingsVC, nav2, nil];
    
    [nav release];
    [nav2 release];
    [settingsVC release];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back.png"];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.accountVC.mdelegate = self.menuDelegate;
    //self.camerasVC.parentVC = self;
    self.camerasVC.camChannels = self.cameras;
    
    NSLog(@"viewDidAppear: %p, %p", self.menuDelegate, _accountVC.mdelegate);
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

- (void)dealloc
{
    [_accountVC release];
    [super dealloc];
}

@end
