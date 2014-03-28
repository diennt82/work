//
//  Step_03_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#define TAG_IMAGE_ANIMATION 599

#import "Step_03_ViewController.h"
#import "UIBarButtonItem+Custom.h"

@interface Step_03_ViewController ()

@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewGuide;
@property (retain, nonatomic) IBOutlet UIView *inProgress;


@end

@implementation Step_03_ViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
#if 1
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    [self.view viewWithTag:501].transform = transform;
    [_inProgress viewWithTag:501].transform = transform;
    
    UIImageView *imageView  = (UIImageView *)[self.inProgress viewWithTag:575];
    imageView.animationImages = @[[UIImage imageNamed:@"setup_camera_c1"],
                                  [UIImage imageNamed:@"setup_camera_c2"],
                                  [UIImage imageNamed:@"setup_camera_c3"],
                                  [UIImage imageNamed:@"setup_camera_c4"]];
    imageView.animationDuration = 1.5f;
    imageView.animationRepeatCount = 0;
    
    [self.scrollViewGuide setContentSize:CGSizeMake(320, 1181)];
#else
    self.navigationItem.title =  NSLocalizedStringWithDefaultValue(@"Detect_Camera",nil, [NSBundle mainBundle],
                                                                   @"Detect Camera", nil);

    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back", nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];

    [self startAnimationWithOrientation];
#endif
    self.homeWifiSSID = [CameraPassword fetchSSIDInfo];
    
    NSLog(@"homeWifiSSID: %@", self.homeWifiSSID);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.homeWifiSSID forKey:HOME_SSID];
    [userDefaults synchronize];
    
    [self.view addSubview:self.inProgress];
    self.inProgress.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    // Do any additional setup after loading the view.
    
    [super viewWillAppear:animated];
    
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(becomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Actions

- (void)hubbleItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)Step04Action:(id)sender
{
    [self.navigationController pushViewController:[[Step_04_ViewController alloc] init] animated:YES];
}

#pragma mark -

-(void) dealloc
{
    [homeWifiSSID release];
    [cameraName release];
    [cameraMac release];
    [_scrollViewGuide release];
    [_inProgress release];
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
        //[self showProgress:nil];
        [self performSelectorOnMainThread:@selector(showProgress:) withObject:nil waitUntilDone:NO];
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
            UIImageView *imageView  = (UIImageView *)[self.inProgress viewWithTag:575];
            [imageView startAnimating];
            [self.view bringSubviewToFront:self.inProgress];
        }
    }
}

- (void) hideProgess
{
    NSLog(@"hide progress");
    if (self.inProgress != nil)
    {
        UIImageView *imageView  = (UIImageView *)[self.inProgress viewWithTag:575];
        [imageView stopAnimating];
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
		
        NSLog(@"Check mac address is %@ and Ip address is %@", bc, own);
		if ([own hasPrefix:DEFAULT_IP_PREFIX]  || [own hasPrefix:DEFAULT_IP_PREFIX_CAMERA_C89])
		{
			//set default ip first, will use later for all
            if ([own hasPrefix:DEFAULT_IP_PREFIX_CAMERA_C89])
            {
                NSLog(@"Set default ip for camera c89 %@", own);
                [[HttpCom instance].comWithDevice setDevice_ip:DEFAULT_BM_IP_CAMERA_C89];
            }
            else if ([own hasPrefix:DEFAULT_IP_PREFIX])
            {
                NSLog(@"Set default ip for camera %@", own);
                [[HttpCom instance].comWithDevice setDevice_ip:DEFAULT_BM_IP];
            }
            else
            {
                NSLog(@"Set default ip for camera %@", own);
                [[HttpCom instance].comWithDevice setDevice_ip:DEFAULT_BM_IP];
            }
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
    
    NSString * fw_version = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_VERSION];
    
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
            [userDefaults setObject:fwVersion forKey:FW_VERSION];
            [userDefaults setObject:self.cameraName forKey:CAMERA_SSID];
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

@end
