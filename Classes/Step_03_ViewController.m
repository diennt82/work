//
//  Step_03_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import "Step_03_ViewController.h"
#import "UIBarButtonItem+Custom.h"

@interface Step_03_ViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollViewGuide;
@property (nonatomic, weak) IBOutlet UIView *inProgress;

@property (nonatomic) BOOL taskCancelled;
@property (nonatomic) BOOL showProgressNextTime;

@end

@implementation Step_03_ViewController

#define TAG_IMAGE_ANIMATION 599
#define GAI_CATEGORY @"Step 03 view"

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showProgressNextTime = NO;
    
    UIImageView *imageView  = (UIImageView *)[self.inProgress viewWithTag:575];
    imageView.animationImages = @[[UIImage imageNamed:@"setup_camera_c1"],
                                  [UIImage imageNamed:@"setup_camera_c2"],
                                  [UIImage imageNamed:@"setup_camera_c3"],
                                  [UIImage imageNamed:@"setup_camera_c4"]];
    imageView.animationDuration = 1.5f;
    imageView.animationRepeatCount = 0;
    [imageView startAnimating];
    
    [_scrollViewGuide setContentSize:CGSizeMake(320, 1370)];

    self.homeWifiSSID = [CameraPassword fetchSSIDInfo];
    
    NSLog(@"homeWifiSSID: %@", _homeWifiSSID);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_homeWifiSSID forKey:HOME_SSID];
    [userDefaults synchronize];
    
    [self.view addSubview:_inProgress];
    _inProgress.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.trackedViewName = GAI_CATEGORY;
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnteredBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	NSArray *viewControllers = self.navigationController.viewControllers;
	if ( [viewControllers indexOfObject:self] == NSNotFound ) {
		// View is disappearing because it was popped from the stack
		NSLog(@"View controller was popped --- We are closing down..task_cancelled = YES");
		self.taskCancelled = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}

#pragma mark - Actions

- (void)Step04Action:(id)sender
{
    Step_04_ViewController *controller = [[Step_04_ViewController alloc] initWithNibName:@"Step_04_ViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -

- (IBAction)handleButtonPress:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    if (tag == OPEN_WIFI_BTN_TAG) {
        NSLog(@"Can't Open wifi");
        //Open wifi
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
}

- (void)handleEnteredBackground
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step03 - Enter background" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Enter background"
                                                     withLabel:@"Homekey"
                                                     withValue:nil];
    [self showProgress:nil];
}

- (void)becomeActive
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step03 - Enter fore ground" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Become active"
                                                     withLabel:nil
                                                     withValue:nil];
    
    self.taskCancelled = NO;
    [self checkConnectionToCamera:nil];
}

- (void)showProgress:(NSTimer *)exp
{
    NSLog(@"show progress ");
    
    if ( _inProgress )
    {
        NSLog(@"show progress 01 ");
        _inProgress.hidden = NO;
        [self.view addSubview:_inProgress];
        [self.view bringSubviewToFront:_inProgress];
    }
}

- (void)hideProgess
{
    NSLog(@"hide progress");
    if ( _inProgress ) {
        [_inProgress removeFromSuperview];
        _inProgress.hidden = YES;
    }
}

- (void)checkConnectionToCamera:(NSTimer *)expired
{
#if TARGET_IPHONE_SIMULATOR != 1
    NSLog(@"checkConnectionToCamera");
    
	NSString *bc1 = @"";
	NSString *own1 = @"";
	[MBP_iosViewController getBroadcastAddress:&bc1 AndOwnIp:&own1];
    
	// Check for ip available before check for SSID to avoid crashing.
	if ([own1 isEqualToString:@""]) {
		NSLog(@"IP is not available.. comeback later..");
		// check back later..
        if ( _taskCancelled ) {
            // was popped by its parent
            return;
        }
        
		[NSTimer scheduledTimerWithTimeInterval:3
										 target:self
									   selector:@selector(checkConnectionToCamera:)
									   userInfo:nil
										repeats:NO];
		return;
	}
    
    NSLog(@"checkConnectionToCamera 01");
#endif
    
	NSString *currentSSID = [CameraPassword fetchSSIDInfo];
    NSLog(@"checkConnectionToCamera 03: %@", currentSSID);
	if ([currentSSID hasPrefix:DEFAULT_SSID_PREFIX] || [currentSSID hasPrefix:DEFAULT_SSID_HD_PREFIX]) {
		// Yeah we're connected ... check for ip??
		NSString * bc = @"";
		NSString * own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
		
        NSLog(@"Check mac address is %@ and Ip address is %@", bc, own);
		if ([own hasPrefix:DEFAULT_IP_PREFIX]  || [own hasPrefix:DEFAULT_IP_PREFIX_CAMERA_C89]) {
			//set default ip first, will use later for all
            if ([own hasPrefix:DEFAULT_IP_PREFIX_CAMERA_C89]) {
                NSLog(@"Set default ip for camera c89 %@", own);
                [[HttpCom instance].comWithDevice setDevice_ip:DEFAULT_BM_IP_CAMERA_C89];
            }
            else if ([own hasPrefix:DEFAULT_IP_PREFIX]) {
                NSLog(@"Set default ip for camera %@", own);
                [[HttpCom instance].comWithDevice setDevice_ip:DEFAULT_BM_IP];
            }
            else {
                NSLog(@"Set default ip for camera %@", own);
                [[HttpCom instance].comWithDevice setDevice_ip:DEFAULT_BM_IP];
            }
            
            [HttpCom instance].comWithDevice.device_port = DEFAULT_BM_PORT;
            
			//remember the mac address .. very important
			self.cameraMac = [CameraPassword fetchBSSIDInfo];
			self.cameraName = currentSSID;
			
			NSLog(@"camera mac: %@ ip:%@", _cameraMac, own );
			
			//dont reschedule another wake up
            [self hideProgess];
			[self moveToNextStep];
			return;
		}
	}
	
	if ( !_taskCancelled ) {
		// Check back later..
		[NSTimer scheduledTimerWithTimeInterval:3
										 target:self
									   selector:@selector(checkConnectionToCamera:)
									   userInfo:nil
										repeats:NO];
	}
}

- (void)moveToNextStep
{
    NSString *fw_version = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_VERSION];
    NSLog(@"Step_03 - moveToNextStep -->fw_version: %@", fw_version);

    NSRange colonRange = [fw_version rangeOfString:@": "];
    
    if (colonRange.location != NSNotFound) {
        NSString *fwVersion = [[fw_version componentsSeparatedByString:@": "] objectAtIndex:1];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:fwVersion forKey:FW_VERSION];
        [userDefaults setObject:_cameraName forKey:CAMERA_SSID];
        [userDefaults synchronize];
    }
    
    NSLog(@"Load step 4");
    
    //Load the next xib
    Step_04_ViewController *step04ViewController = [[Step_04_ViewController alloc] initWithNibName:@"Step_04_ViewController" bundle:nil];
    step04ViewController.cameraMac = _cameraMac;
    step04ViewController.cameraName = _cameraName;
    [self.navigationController pushViewController:step04ViewController animated:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupFailedFWCheck
{
    NSLog(@"setupFailedFWCheck has failed ");
    //Go back to the beginning
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	int tag = alertView.tag;
    if (tag == ALERT_FWCHECK_FAILED) {
        ///go back
        [self setupFailedFWCheck];
    }
}

@end
