//
//  Step_12_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Step_12_ViewController.h"

@interface Step_12_ViewController()
@property (retain, nonatomic) IBOutlet UIButton *btnWatchLiveCamera;

@end

@implementation Step_12_ViewController

@synthesize cameraName;

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
#if 1
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    [self.view viewWithTag:501].transform = transform;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [self.btnWatchLiveCamera setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnWatchLiveCamera setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.cameraName.text =  (NSString *) [userDefaults objectForKey:@"CameraName"];
#else
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.cameraName.text =  (NSString *) [userDefaults objectForKey:@"CameraName"];
    self.navigationItem.title = NSLocalizedStringWithDefaultValue( @"Setup_Complete",
                                                                  nil,
                                                                  [NSBundle mainBundle],
                                                                  @"Setup Complete" , nil);
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
#endif
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem.enabled = NO;
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
    //get registrationID
    NSString *registrationID = [[NSUserDefaults standardUserDefaults] objectForKey:CAMERA_UDID];
    
    NSLog(@"registrationID is %@  bLEEEEEEEEEEEEEEEE&&&&&&&&&&", registrationID);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:registrationID forKey:@"REG_ID"];
    [userDefaults synchronize];
    
    // Disable Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled=  NO;
    
    id<StartMonitorDelegate> delegate = (id<StartMonitorDelegate>) [[self.navigationController viewControllers] objectAtIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //[initSetupController startMonitorCallBack];
    [delegate startMonitorCallBack];
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Add Cameras"
                                                       withAction:@"Add Camera Success"
                                                       withLabel:@"Add Camera Success"
                                                       withValue:nil];
}

- (void)dealloc {
    [_btnWatchLiveCamera release];
    [super dealloc];
}
@end
