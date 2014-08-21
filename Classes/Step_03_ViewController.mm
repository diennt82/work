//
//  Step_03_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#define TAG_IMAGE_ANIMATION 599
#define TIME_OUT            180

#import "Step_03_ViewController.h"
#import "UIBarButtonItem+Custom.h"
//#import "KISSMetricsAPI.h"
#import "UIFont+Hubble.h"
#import "Camera.h"
#import "define.h"
#import "PublicDefine.h"
#import "UIView+Custom.h"

#define GAI_CATEGORY    @"Step 03 view"

@interface Step_03_ViewController ()

@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewGuide;
@property (retain, nonatomic) IBOutlet UIView *inProgress;
@property (retain, nonatomic) IBOutlet UIView *timoutView;
@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, assign) NSTimer           *timerTimeOut;

- (IBAction)handleCameraButton:(id)sender;
- (IBAction)handlePairYes:(id)sender;
- (IBAction)handlePairNo:(id)sender;
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
    [self xibDefaultLocalization];
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    UIImageView *imageView  = (UIImageView *)[self.inProgress viewWithTag:575];
    imageView.animationImages = @[[UIImage imageNamed:@"setup_camera_c1"],
                                  [UIImage imageNamed:@"setup_camera_c2"],
                                  [UIImage imageNamed:@"setup_camera_c3"],
                                  [UIImage imageNamed:@"setup_camera_c4"]];
    imageView.animationDuration = 1.5f;
    imageView.animationRepeatCount = 0;
    [imageView startAnimating];
    
    

    self.homeWifiSSID = [CameraPassword fetchSSIDInfo];
    
    NSLog(@"homeWifiSSID: %@", self.homeWifiSSID);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.homeWifiSSID forKey:HOME_SSID];
    [userDefaults synchronize];
    
    [self.view addSubview:self.inProgress];
    self.inProgress.hidden = YES;
    
    CAMERA_TAG tag = (CAMERA_TAG)[[userDefaults objectForKey:SET_UP_CAMERA_TAG] intValue];
    UIImage *iconImage = [self convertToCamaraImage:tag];
    [self.cameraButton setBackgroundImage:iconImage forState:UIControlStateNormal];
    
    task_timeOut = NO;
    
    [self.scrollViewGuide setContentSize:CGSizeMake(320, 1370)];
    
    if(isiPhone4)
    {
        [_scrollViewGuide setContentOffset:CGPointMake(0, _scrollViewGuide.contentSize.height-(_scrollViewGuide.frame.size.height-88))];
    }else{
        [_scrollViewGuide setContentOffset:CGPointMake(0, _scrollViewGuide.contentSize.height-_scrollViewGuide.frame.size.height)];        
    }
    [_scrollViewGuide setShowsVerticalScrollIndicator:YES];
    
}

- (void)xibDefaultLocalization
{
    [[self.view viewWithTag:10] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_detect_camera", nil, [NSBundle mainBundle], @"Detect Camera", nil)];
    [[self.view viewWithTag:11] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_to_detect_your_camera", nil, [NSBundle mainBundle], @"To detect your camera simply connect your phone to it via Wi-Fi", nil)];
    [[self.view viewWithTag:12] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_step1", nil, [NSBundle mainBundle], @"1. Press and hold the button marked 'PAIR' for 3 seconds ", nil)];
    [[self.view viewWithTag:13] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_step2", nil, [NSBundle mainBundle], @"2. Connect to your camera via your phone's Wi-Fi", nil)];
    [[self.view viewWithTag:14] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_step3", nil, [NSBundle mainBundle], @"3. Open iPhone settings icon to select Wi-Fi netwowrk", nil)];
    [[self.view viewWithTag:15] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_step4", nil, [NSBundle mainBundle], @"4. Click on Wi-Fi icon and select your camera from the list of networks.", nil)];
    [[self.view viewWithTag:16] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_step5", nil, [NSBundle mainBundle], @"5. Once you have completed these steps return to this app and resume setup", nil)];
    [[self.view viewWithTag:17] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_note", nil, [NSBundle mainBundle], @"(Note that this will disconnect your own Wi-Fi for a short while)", nil)];
    
    [[self.inProgress viewWithTag:10] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_detecting_WIFI", nil, [NSBundle mainBundle], @"Detecting Wi-Fi Camera", nil)];
    [[self.inProgress viewWithTag:11] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_this_may_teke", nil, [NSBundle mainBundle], @"This may take up to 3 minutes", nil)];
    
    [[self.timoutView viewWithTag:10] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_label_hubble_cannot_connect", nil, [NSBundle mainBundle], @"Hubble can't connect to camera wifi, do you want to pair with camera again?", nil)];
    [[self.timoutView viewWithTag:11] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_button_yes", nil, [NSBundle mainBundle], @"Yes", nil)];
    [[self.timoutView viewWithTag:12] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_button_no", nil, [NSBundle mainBundle], @"No", nil)];
}

- (void) viewWillAppear:(BOOL)animated
{
    // Do any additional setup after loading the view.
    
    [super viewWillAppear:animated];
    
    self.trackedViewName = GAI_CATEGORY;
    
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [UIView animateWithDuration:1.0 animations:^{
        [_scrollViewGuide setContentOffset:CGPointMake(0,0)];
    }];
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
    Step_04_ViewController *step04 = [[Step_04_ViewController alloc] init];
    [self.navigationController pushViewController:step04 animated:YES];
    [step04 release];
}

#pragma mark -

-(void) dealloc
{
    [homeWifiSSID release];
    [cameraName release];
    [cameraMac release];
    [_scrollViewGuide release];
    [_inProgress release];
    [_cameraButton release];
    [_timerTimeOut release];
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
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step03 - Enter background" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Enter background"
                                                     withLabel:@"Homekey"
                                                     withValue:nil];
    //showProgressNextTime = TRUE;
    [self showProgress:nil];
}

-(void) becomeActive
{
    if (task_timeOut) {
        return;
    }
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step03 - Enter fore ground" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Become active"
                                                     withLabel:nil
                                                     withValue:nil];
    
    task_cancelled = NO;
    [self checkConnectionToCamera:nil];
}

-(void) showProgress:(NSTimer *) exp
{
    NSLog(@"show progress ");
    
    //if (![Step_09_ViewController isWifiConnectionAvailable])
    {
        if (self.inProgress != nil && task_timeOut == NO)
        {
            NSLog(@"show progress 01 ");
            self.inProgress.hidden = NO;
            [self.view addSubview:self.inProgress];
            [self.view bringSubviewToFront:self.inProgress];
        }
    }
}

- (void) hideProgess
{
    NSLog(@"hide progress");
    if (self.inProgress != nil)
    {
        [self.inProgress removeFromSuperview];
        self.inProgress.hidden = YES;
    }
}

- (void) checkConnectionToCamera:(NSTimer *) expired
{
    if (task_timeOut) {
        [self hideProgess];
        [self.view addSubview:self.timoutView];
        return;
    }
    if (self.timerTimeOut == nil) {
        self.timerTimeOut = [NSTimer scheduledTimerWithTimeInterval:TIME_OUT
                                                             target:self
                                                           selector:@selector(conectionToCameraDidTimeOut:)
                                                           userInfo:nil
                                                            repeats:NO];
    }
    
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
            
            [HttpCom instance].comWithDevice.device_port = DEFAULT_BM_PORT;
            
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
	
	if (task_cancelled == NO)
	{
		//check back later..
		[NSTimer scheduledTimerWithTimeInterval: 3//
										 target:self
									   selector:@selector(checkConnectionToCamera:)
									   userInfo:nil
										repeats:NO];
	}
}

- (void)conectionToCameraDidTimeOut:(NSTimer *)timer {
    [self.timerTimeOut invalidate];
    self.timerTimeOut = nil;
    task_timeOut = YES;
    task_cancelled = YES;
}

-(void) moveToNextStep
{
    NSString * fw_version = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_VERSION];
    NSLog(@"Step_03 - moveToNextStep -->fw_version: %@", fw_version);

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
    
    //step04ViewController.cameraMac =  self.cameraMac;
    step04ViewController.cameraName  =self.cameraName;
    
    [self.navigationController pushViewController:step04ViewController animated:NO];
    
    [step04ViewController release];
    
    
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

- (IBAction)handleCameraButton:(id)sender {
    
      UIButton * buttonView = (UIButton *) sender;
    
    UILabel *labelCrazy = [[UILabel alloc] init];
    CGRect rect;
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
    {
        rect = CGRectMake(SCREEN_WIDTH/2 - 200/2,  buttonView.frame.size.height, 200, 50);
    }
    else
    {
        rect = CGRectMake(SCREEN_HEIGHT/2 - 200/2,  buttonView.frame.size.height, 200, 50);
    }
    
    labelCrazy.frame = rect;
    labelCrazy.backgroundColor = [UIColor grayColor];
    labelCrazy.textColor = [UIColor whiteColor];
    labelCrazy.numberOfLines = 0;
    labelCrazy.font = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:13];
    labelCrazy.textAlignment = NSTextAlignmentCenter;
    labelCrazy.text = NSLocalizedStringWithDefaultValue(@"press_located_on_the_camera", nil, [NSBundle mainBundle], @"Please press the button located on the camera.", nil);
    [self.view addSubview:labelCrazy];
    [self.view bringSubviewToFront:labelCrazy];
    
    [labelCrazy performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3];
    
    [labelCrazy release];
}

- (IBAction)handlePairYes:(id)sender {
    [self hubbleItemAction:nil];
}

- (IBAction)handlePairNo:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
    if ([self.delegate respondsToSelector:@selector(goBackCameralist)]) {
        [self.delegate goBackCameralist];
    }
}

- (UIImage *)convertToCamaraImage:(CAMERA_TAG)cameraTad {
    switch (cameraTad) {
        case FORCUS_66_TAG:
            return [UIImage imageNamed:@"camera_ble3"];
        case SCOUT_73_TAG:
            return [UIImage imageNamed:@"wifisetup_scout85"];
        case MBP_83_TAG:
            return [UIImage imageNamed:@"camera_ble2"];
        case MBP_85_TAG:
            return [UIImage imageNamed:@"blesetup_focus85"];
        default:
            break;
    }
    return nil;
}
@end
