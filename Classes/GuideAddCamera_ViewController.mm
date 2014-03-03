//
//  GuideAddCamera_ViewController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "GuideAddCamera_ViewController.h"

@interface GuideAddCamera_ViewController ()

@end

@implementation GuideAddCamera_ViewController
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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    }
    UIBarButtonItem *backButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                                             @"Cancel", nil)
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(handleBackButton:)];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
    UIBarButtonItem *nextButton =
    [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringWithDefaultValue(@"Next",nil, [NSBundle mainBundle],
                                                                              @"Next", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleNextButtonAction:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
    
    
    //    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Switch_On_Camera",nil, [NSBundle mainBundle],
    //                                                                  @"Switch On Camera", nil);;
    
    self.navigationItem.title = @"Direction to connect";
    
//    //Setup now but this button will only be seen when go to the NEXT controller
//    self.navigationItem.backBarButtonItem =
//    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
//                                                                              @"Back", nil)
//                                      style:UIBarButtonItemStyleBordered
//                                     target:nil
//                                     action:nil] autorelease];
    
    //Hide back button -- can't go back now..
    self.navigationItem.hidesBackButton = TRUE;
    self.navigationController.navigationBarHidden = NO;

    
    
    
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
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
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

    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {

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
    
    //[parent presentModalViewController:navController animated:NO];
    [parent presentViewController:navController animated:NO completion:^{}];
}



#pragma mark -
#pragma mark Actions

- (void)handleNextButtonAction: (id) sender
{
    NSLog(@"Load step Create BLE Connection");
    //Load the next xib
    CreateBLEConnection_VController *step03ViewController=nil;
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        step03ViewController = [[CreateBLEConnection_VController alloc]initWithNibName:@"CreateBLEConnection_VController_ipad" bundle:nil];
//    } else
    {
        step03ViewController =
        [[CreateBLEConnection_VController alloc] initWithNibName:@"CreateBLEConnection_VController"
                                                 bundle:nil];
    }
    
    [self.navigationController pushViewController:step03ViewController animated:NO];
    
    [step03ViewController release];
}

-(IBAction)handleBackButton:(id)sender
{
    //simply relogin
    //[self.delegate sendStatus:AFTER_DEL_RELOGIN];//rescan
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate sendStatus:AFTER_DEL_RELOGIN];
    }];
}

- (IBAction)goBackToFirstScreen:(id)sender
{
    [self.delegate sendStatus:FRONT_PAGE];
}

-(void) startMonitorCallBack
{
#if 1 // New flow: Show Camera list after Add a new Camera
    [self.delegate sendStatus:SHOW_CAMERA_LIST];
#else // Old flow: Re-login after Add a new Camera
    NSLog(@"LOGINING... ");
    [self.delegate sendStatus:2];//login];
#endif
}


- (IBAction)handleButtonPress:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    
    if (tag == CONTINUE_BTN_TAG)
    {
        
#if 1
        
        NSLog(@"Load step 3");
        //Load the next xib
        CreateBLEConnection_VController *step03ViewController = nil;
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            
//            
//            step03ViewController = [[CreateBLEConnection_VController alloc]initWithNibName:@"CreateBLEConnection_VController_iPad" bundle:nil];
//            
//        }
//        else
        {
            step03ViewController = [[CreateBLEConnection_VController alloc]
                                    initWithNibName:@"CreateBLEConnection_VController" bundle:nil];
            
        }

        
        [self.navigationController pushViewController:step03ViewController animated:NO];
        
        [step03ViewController release];
        
        
#else // DBG - TEST view layout ..
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        
        [userDefaults setObject:@"11:22:33:44:55:66" forKey:@"CameraMacWithQuote"];
        [userDefaults synchronize];
        
        
        
        //Load step 10
        NSLog(@"Load Step 10");
        //Load the next xib
        Step_10_ViewController *step10ViewController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            step10ViewController = [[Step_10_ViewController alloc]
                                    initWithNibName:@"Step_10_ViewController_ipad" bundle:nil];
            
        }
        else
        {
            
            step10ViewController = [[Step_10_ViewController alloc]
                                    initWithNibName:@"Step_10_ViewController" bundle:nil];
            
        }
        
        
        
        
        [self.navigationController pushViewController:step10ViewController animated:NO];
        [step10ViewController release];
        
#endif
        
    }
    
    
}

#pragma  mark -
#pragma mark Table View delegate & datasource



#define STEP_1 0
#define STEP_2 1
#define STEP_3 2



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSString *nameImage = [NSString stringWithFormat:@"bb_setup_icon_step_%d.png", indexPath.row + 1];
    CGSize newSize = CGSizeMake(64, 64);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        newSize = CGSizeMake(100, 100);
    }
    
    cell.imageView.image = [self imageWithNameString:nameImage scaledToSize:newSize];
    
    NSString *textInstruction = @"";
    
    switch (indexPath.row)
    {
        case STEP_1:
            textInstruction = @"Switch on the camera";
            break;
            
        case STEP_2:
            textInstruction = @"Wait for 10 seconds while camera warms";
            cell.textLabel.numberOfLines = 2;
            break;
            
        case STEP_3:
            textInstruction = @"When it starts beeping, proceed";
            cell.textLabel.numberOfLines = 2;
            break;
            
        default:
            break;
    }
    
    cell.textLabel.text = textInstruction;
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    return 1;
}



- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
    
}

#pragma  mark -
- (UIImage *)imageWithNameString:(NSString *)nameString scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
    [[UIImage imageNamed:nameString] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

@end