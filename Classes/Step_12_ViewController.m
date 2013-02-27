//
//  Step_12_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Step_12_ViewController.h"

@implementation Step_12_ViewController

@synthesize cameraName;

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.cameraName.text =  (NSString *) [userDefaults objectForKey:@"CameraName"];
    self.navigationItem.title = NSLocalizedStringWithDefaultValue( @"Setup_Complete",
                                                                  nil,
                                                                  [NSBundle mainBundle],
                                                                  @"Setup Complete" , nil);
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Rotating
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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

            [[NSBundle mainBundle] loadNibNamed:@"Step_12_ViewController_land_ipad" owner:self options:nil];
            
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_12_ViewController_land" owner:self options:nil];


            
            
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {

            [[NSBundle mainBundle] loadNibNamed:@"Step_12_ViewController_ipad" owner:self options:nil];
        }
        else
        {            
     
            [[NSBundle mainBundle] loadNibNamed:@"Step_12_ViewController" owner:self options:nil];
            

            
        }
    }
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.cameraName.text =  (NSString *) [userDefaults objectForKey:@"CameraName"];

}
#pragma mark -
#pragma mark Btn handling 

-(IBAction)startMonitor:(id)sender
{
    NSLog(@"STEP12 START MONITOR");
    
    // Disable Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled=  NO;
    
    id<StartMonitorDelegate> delegate = (id<StartMonitorDelegate>) [[self.navigationController viewControllers] objectAtIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //[initSetupController startMonitorCallBack];
    [delegate startMonitorCallBack];
}

@end
