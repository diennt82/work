//
//  Step_02_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_02_ViewController.h"


@interface Step_02_ViewController ()

@end

@implementation Step_02_ViewController

@synthesize delegate;


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
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *backButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                                             @"Cancel", nil)
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(handleBackButton:)];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];

    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Switch_On_Camera",nil, [NSBundle mainBundle],
                                                                  @"Switch On Camera", nil);;
    
        
    //Setup now but this button will only be seen when go to the NEXT controller
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back", nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    //Hide back button -- can't go back now..
    self.navigationItem.hidesBackButton = TRUE;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
}

#pragma mark -
#pragma mark Rotating
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationMaskAllButUpsideDown);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustViewsForOrientations:toInterfaceOrientation];
}

-(void) adjustViewsForOrientations: (UIInterfaceOrientation) interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_02_ViewController_land_ipad" owner:self options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_02_ViewController_land" owner:self options:nil];
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_02_ViewController_ipad" owner:self options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_02_ViewController" owner:self options:nil];
        }
    }
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



#pragma mark - 
#pragma mark Actions

-(IBAction)handleBackButton:(id)sender
{
    //simply relogin
    [self.delegate sendStatus:AFTER_DEL_RELOGIN];//rescan
}

- (IBAction)goBackToFirstScreen:(id)sender
{
    [self.delegate sendStatus:FRONT_PAGE];
}

-(void) startMonitorCallBack
{
    NSLog(@"LOGINING... ");
    [self.delegate sendStatus:2];//login];
}


- (IBAction)handleButtonPress:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    
    if (tag == CONTINUE_BTN_TAG)
    {
        
#if 0
        
        NSLog(@"Load step 3");
        //Load the next xib
        Step_03_ViewController *step03ViewController = nil;
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            
            step03ViewController = [[Step_03_ViewController alloc]initWithNibName:@"Step_03_ViewController_ipad" bundle:nil];
            
        }
        else
        {
            step03ViewController = [[Step_03_ViewController alloc]
                                    initWithNibName:@"Step_03_ViewController" bundle:nil];
            
        }
        
        
        
        
        
        [self.navigationController pushViewController:step03ViewController animated:NO];
        
        [step03ViewController release];
        
        
#else // DBG
        
        
        //Load step 11
        NSLog(@"Load step 11");
        
        
        //Load the next xib
        Step_11_ViewController *step11ViewController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            step11ViewController = [[Step_11_ViewController alloc]
                                    initWithNibName:@"Step_11_ViewController_ipad" bundle:nil];
        }
        else
        {
            step11ViewController = [[Step_11_ViewController alloc]
                                    initWithNibName:@"Step_11_ViewController" bundle:nil];
        }
        
        
        [self.navigationController pushViewController:step11ViewController animated:NO];
        
        [step11ViewController release];
#endif
        
    }
    
    
}

#pragma  mark -
#pragma mark Table View delegate & datasource



#define STEP_1 0
#define STEP_2 1
#define STEP_3 2



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int tag = tableView.tag;
    
    //if (tag == 13)
    {
       
        {
            
            if (indexPath.row == STEP_1) {
                return step1_cell;
            }
            if (indexPath.row == STEP_2)
            {
                return step2_cell;
            }
            if (indexPath.row == STEP_3)
            {
                return step3_cell;
            }
            
        }
        
    }
    
    return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
       
}

#pragma  mark -








@end
