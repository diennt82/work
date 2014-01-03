//
//  Step_03_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#define TAG_IMAGE_ANIMATION 599

#import "Step_03_ViewController.h"

@interface Step_03_ViewController ()

@end

@implementation Step_03_ViewController

@synthesize  inProgress;
@synthesize   cameraMac,  cameraName, homeWifiSSID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        showProgressNextTime= FALSE;
    }
    return self;
}


- (void)viewWillDisappear:(BOOL)animated {
	NSArray *viewControllers = self.navigationController.viewControllers;
	if ([viewControllers indexOfObject:self] == NSNotFound) {
		// View is disappearing because it was popped from the stack
		NSLog(@"View controller was popped --- We are closing down..task_cancelled = YES");
        
		task_cancelled = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title =  NSLocalizedStringWithDefaultValue(@"Detect_Camera",nil, [NSBundle mainBundle],
                                                                   @"Detect Camera", nil);
    
    
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back", nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    [self startAnimationWithOrientation];
    
    self.homeWifiSSID = [CameraPassword fetchSSIDInfo];
    
    
    NSLog(@"homeWifiSSID: %@", self.homeWifiSSID);
    
    
    
	
    
    [self.view addSubview:self.inProgress];
    self.inProgress.hidden = YES;
    
    
    // NSLog(@"Open wifi aaaaaaa");
    //Open wifi
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (void) viewWillAppear:(BOOL)animated
{
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(becomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:orientation];
}

#pragma mark _ Method Animation

- (void)startAnimationWithOrientation
{
    UIImageView *animationView =  (UIImageView *)[self.view viewWithTag:TAG_IMAGE_ANIMATION];
    
    [animationView setContentMode:UIViewContentModeScaleAspectFit];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        animationView.animationImages =[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"frame-1_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-2_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-3_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-4-1_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-5_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-6_update-iOS7_new2"],
                                        nil];
        NSLog(@"ios 7");
    }
    
    else
    {
        animationView.animationImages =[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"frame-1_update_new"],
                                        [UIImage imageNamed:@"frame-2_update_new"],
                                        [UIImage imageNamed:@"frame-3_update_new"],
                                        [UIImage imageNamed:@"frame-4-1_update_new"],
                                        [UIImage imageNamed:@"frame-5_update_new"],
                                        [UIImage imageNamed:@"frame-6_update_new"],
                                        nil];
        NSLog(@"ios < 7");
    }
    
    animationView.animationDuration = 18;
    animationView.animationRepeatCount = 0;
    
    [self.view bringSubviewToFront:animationView];
    
    [animationView startAnimating];
}

#pragma mark -
#pragma mark Rotating
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));}

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
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        // Load resources for iOS 7 or later
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                //[[NSBundle mainBundle] loadNibNamed:@"Step_03_ViewController_land_ipad" owner:self options:nil];
            }
            else
            {
                BOOL hidden = self.inProgress.hidden;
                [self.inProgress removeFromSuperview];
                
                
                //[[NSBundle mainBundle] loadNibNamed:@"Step_03_ViewController_land" owner:self options:nil];
                
                [self.view addSubview:self.inProgress];
                self.inProgress.hidden = hidden;
                
            }
        }
        else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
                 interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                //[[NSBundle mainBundle] loadNibNamed:@"Step_03_ViewController_ipad" owner:self options:nil];
            }
            else
            {
                BOOL hidden = self.inProgress.hidden;
                [self.inProgress removeFromSuperview];
                
                
                //[[NSBundle mainBundle] loadNibNamed:@"Step_03_ViewController" owner:self options:nil];
                [self.view addSubview:self.inProgress];
                self.inProgress.hidden = hidden;
                
                
            }
        }
        
//    }
}
#pragma mark -

-(void) dealloc
{
    [homeWifiSSID release];
    [inProgress release];
    [cameraName release];
    [cameraMac release];
    [super dealloc];
}



- (IBAction)handleButtonPress:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    
    if (tag == OPEN_WIFI_BTN_TAG)
    {
        
        NSLog(@"Can't Open wifi");
        //Open wifi
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
    
}

-(void) handleEnteredBackground
{
    showProgressNextTime = TRUE;
}

-(void) becomeActive
{
    if (showProgressNextTime)
    {
        NSLog(@"cshow progress 03");
        [self showProgress:nil];
    }
    
    task_cancelled = NO;
    [self checkConnectionToCamera:nil];
}

-(void) showProgress:(NSTimer *) exp
{
    NSLog(@"show progress ");
    
    //if (![Step_09_ViewController isWifiConnectionAvailable])
    {
        if (self.inProgress != nil)
        {
            NSLog(@"show progress 01 ");
            self.inProgress.hidden = NO;
            [self.view bringSubviewToFront:self.inProgress];
            
            
        }
        
        
    }
    
    
    
}

- (void) hideProgess
{
    NSLog(@"hide progress");
    if (self.inProgress != nil)
    {
        self.inProgress.hidden = YES;
    }
    
}


- (void) checkConnectionToCamera:(NSTimer *) expired
{
	
	
#if TARGET_IPHONE_SIMULATOR != 1
    
    NSLog(@"checkConnectionToCamera");
    
	NSString * bc1 = @"";
	NSString * own1 = @"";
	[MBP_iosViewController getBroadcastAddress:&bc1 AndOwnIp:&own1];
	//check for ip available before check for SSID to avoid crashing ..
	if ([own1 isEqualToString:@""])
	{
		NSLog(@"IP is not available.. comeback later..");
		//check back later..
        if (task_cancelled == YES) // was poped by its parent
        {
            return;
        }
        
		[NSTimer scheduledTimerWithTimeInterval: 3//
										 target:self
									   selector:@selector(checkConnectionToCamera:)
									   userInfo:nil
										repeats:NO];
		return;
	}
    
    NSLog(@"checkConnectionToCamera 01");
#endif
	
    
    
    
	NSString * currentSSID = [CameraPassword fetchSSIDInfo];
    
#if 0 //Dont show any progress
    {
        NSLog(@"cshow progress 02");
        [self showProgress:nil];
        
    }
#endif
    
    
    
    NSLog(@"checkConnectionToCamera 03: %@", currentSSID);
	if ([currentSSID hasPrefix:DEFAULT_SSID_PREFIX] || [currentSSID hasPrefix:DEFAULT_SSID_HD_PREFIX])
	{
		//yeah we're connected ... check for ip??
		
		NSString * bc = @"";
		NSString * own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
		
		if ([own hasPrefix:DEFAULT_IP_PREFIX])
		{
			
            
			//remember the mac address .. very important
			self.cameraMac = [CameraPassword fetchBSSIDInfo];
			self.cameraName = currentSSID;
			
			NSLog(@"camera mac: %@ ip:%@", self.cameraMac, own );
			
			//dont reschedule another wake up
            [self hideProgess];
			[self moveToNextStep];
			return;
		}
		
	}
	
	
	if (task_cancelled == YES)
	{
		//Don't do any thing here
		
	}
	else {
        
		//check back later..
		[NSTimer scheduledTimerWithTimeInterval: 3//
										 target:self
									   selector:@selector(checkConnectionToCamera:)
									   userInfo:nil
										repeats:NO];
	}
}

-(void) moveToNextStep
{
    HttpCommunication * comm = [[HttpCommunication alloc] init];
    
    NSString * fw_version = [comm sendCommandAndBlock:GET_VERSION];
    [comm release];
    
    NSLog(@"Step_03 - moveToNextStep -->fw_version: %@", fw_version);
    
//    NSString *model = [comm sendCommandAndBlock:GET_MODEL];
//    
//    model = [[model componentsSeparatedByString:@": "] objectAtIndex:1];
//    if ([model isEqualToString:@"-1"]) { // tmp ceamera
//        model = @"blink1_hd";
//    }
//    
//    if ([model isEqualToString:@"blinkhd"]) { // real blinkhd camera
//        model = @"blink1_hd";
//    }
//    
//    NSLog(@"model = %@", model);
    
    if ( fw_version != nil                   &&
        [fw_version isEqualToString:VERSION_18_037]
        )
    {
        //Fatality!!!
        NSLog(@"Failed validity check -- go back");
        
        
        NSString * msg = nil;
        NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        UIAlertView *alert;
        
        
        msg =NSLocalizedStringWithDefaultValue(@"Server_error_maccheck" ,nil, [NSBundle mainBundle],
                                               @"This camera is not registered. Setup camera failed." , nil);
        
        alert = [[UIAlertView alloc]
                 initWithTitle:NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                                 @"AddCam Error" , nil)
                 message:msg
                 delegate:self
                 cancelButtonTitle:ok
                 otherButtonTitles:nil];
        
        alert.tag = ALERT_FWCHECK_FAILED;
        
        [alert show];
        [alert release];
    }
    else
    {
        NSRange colonRange = [fw_version rangeOfString:@": "];
        
        if (colonRange.location != NSNotFound)
        {
            NSString *fwVersion = [[fw_version componentsSeparatedByString:@": "] objectAtIndex:1];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:fwVersion forKey:@"FW_VERSION"];
            //[userDefaults setObject:model forKey:@"MODEL"];
            [userDefaults synchronize];
        }
        
        NSLog(@"Load step 4");
        //Load the next xib
        Step_04_ViewController *step04ViewController = nil;
        
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            step04ViewController = [[Step_04_ViewController alloc]
                                    initWithNibName:@"Step_04_ViewController_ipad" bundle:nil];
            
        }
        else
        {
            step04ViewController = [[Step_04_ViewController alloc]
                                    initWithNibName:@"Step_04_ViewController" bundle:nil];
        }
        
        step04ViewController.cameraMac =  self.cameraMac;
        step04ViewController.cameraName  =self.cameraName;
        
        [self.navigationController pushViewController:step04ViewController animated:NO];
        
        [step04ViewController release];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) setupFailedFWCheck
{
    NSLog(@"setupFailedFWCheck has failed ");
    //Go back to the beginning
    [UIApplication sharedApplication].idleTimerDisabled=  NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark AlertView delegate



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
	int tag = alertView.tag;
    
    if (tag == ALERT_FWCHECK_FAILED)
    {
        ///go back
        
        [self setupFailedFWCheck];
    }
    
}


#pragma mark -


@end
