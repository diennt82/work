//
//  MBP_InitialSetupViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/23/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_InitialSetupViewController.h"

@interface MBP_InitialSetupViewController ()

@end

@implementation MBP_InitialSetupViewController

@synthesize  delegate; 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

-(void) dealloc
{

    [super dealloc];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // rootViewController can't be an instance of UITabBarController
    // remember to include RootViewController in your class!
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Baby_Monitor_Setup",nil, [NSBundle mainBundle],
                                                                  @"Baby Monitor Setup", nil);

    
   self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                             @"Back", nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    

    //If not first time setup.. show the back key 
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isFirstTimeSetup = [userDefaults boolForKey:FIRST_TIME_SETUP];
    if (isFirstTimeSetup)
    {
  

        UIBarButtonItem *backButton = 
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                                                 @"Cancel", nil)
                                         style:UIBarButtonItemStyleBordered 
                                        target:self 
                                        action:@selector(goBackToFirstScreen:)];          
        self.navigationItem.leftBarButtonItem = backButton;
        [backButton release];
    }
   
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

-(void)viewWillAppear:(BOOL)animated
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isFirstTimeSetup = [userDefaults boolForKey:FIRST_TIME_SETUP];
    if (isFirstTimeSetup ==FALSE)
    {
        NSLog(@"jump here");
        NSLog(@"load step 2:");
        
        UIBarButtonItem *backButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                                                 @"Cancel", nil)
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(handleBackButton:)];
        self.navigationItem.leftBarButtonItem = backButton;
        [backButton release];
        
        //Load the next xib
        Step_02_ViewController *step02ViewController = nil;
        
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            step02ViewController = [[Step_02_ViewController alloc]
                                    initWithNibName:@"Step_02_ViewController_ipad" bundle:nil];
        }
        else
        {
            
            step02ViewController = [[Step_02_ViewController alloc]
                                    initWithNibName:@"Step_02_ViewController" bundle:nil];
        }
        
        
        
        
        [self.navigationController pushViewController:step02ViewController animated:NO];
        
        [step02ViewController release];
    }
    else
    {
        //Do nothing let the normal load..
    }
}

//Support portrait only mode for now
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}


- (BOOL) shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
    
}


- (void)presentModallyOn:(UIViewController *)parent
{
    
    MBPNavController *    navController;
    
    //setup nav controller
    navController= [[[MBPNavController alloc]initWithRootViewController:self] autorelease];
        
    
    // Create a navigation controller with us as its root.
    assert(navController != nil);

    
   
    // Present the navigation controller on the specified parent 
    // view controller.
    
    [parent presentModalViewController:navController animated:NO];
}




-(IBAction)handleBackButton:(id)sender
{
    //simply relogin
    [self.delegate sendStatus:AFTER_DEL_RELOGIN];//rescan 
}




- (IBAction)goBackToFirstScreen:(id)sender
{
    [self.delegate sendStatus:FRONT_PAGE];
}

- (IBAction)handleButtonPress:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    

    
    if (tag == CONTINUE_BTN_TAG)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL isFirstTimeSetup = [userDefaults boolForKey:FIRST_TIME_SETUP];
        if (isFirstTimeSetup ==FALSE)
        {
            NSLog(@"load step 2:");
            
            
            //Load the next xib
            Step_02_ViewController *step02ViewController = nil;
            
            
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                step02ViewController = [[Step_02_ViewController alloc]
                                        initWithNibName:@"Step_02_ViewController_ipad" bundle:nil];
            }
            else
            {
                
                step02ViewController = [[Step_02_ViewController alloc]
                                        initWithNibName:@"Step_02_ViewController" bundle:nil];
            }
            
            
            
            
            [self.navigationController pushViewController:step02ViewController animated:NO];
            
            [step02ViewController release];
        }
        else
        {  
            //20130219- app flow changed : Create account first
            
            NSLog(@"Load step 09");
            
            
            //Load the next xib
            Step_09_ViewController *step09ViewController = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                
                step09ViewController = [[Step_09_ViewController alloc]
                                        initWithNibName:@"Step_09_ViewController_ipad" bundle:nil]; 
            }
            else
            {
                step09ViewController = [[Step_09_ViewController alloc]
                                        initWithNibName:@"Step_09_ViewController" bundle:nil];
            }
            
            
            [self.navigationController pushViewController:step09ViewController animated:NO];
            
            [step09ViewController release];
        }
        
        
    }
    
    
}




-(void) startMonitorCallBack
{
    NSLog(@"LOGINING... "); 
    [self.delegate sendStatus:2];//login];
}

@end
