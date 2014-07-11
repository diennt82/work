//
//  Step_10_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#define TAG_IMAGE_VIEW_ANIMATION 595

#import "Step_10_ViewController_ble.h"
#import "StartMonitorCallback.h"
#import "UserAccount.h"
#import "BLEConnectionManager.h"
#import "MBP_iosViewController.h"

@interface Step_10_ViewController_ble ()

@property (nonatomic, retain) UserAccount *userAccount;
@property (nonatomic, retain) BMS_JSON_Communication *jsonCommBlocked;

@end

@implementation Step_10_ViewController_ble

@synthesize  userNameLabel, userEmailLabel,progressView ;
@synthesize  cameraMac, master_key;
@synthesize  cameraName;

@synthesize  homeSSID;
@synthesize  shouldStopScanning;
@synthesize  timeOut;



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
    
    //[userNameLabel release];
    //[userEmailLabel release];
    [_jsonCommBlocked release];
    [cameraMac release];
    [master_key release];
    
    
    [_userAccount release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Disconnect BLE
    NSLog(@"Disconnect BLE ");
    [BLEConnectionManager getInstanceBLE].needReconnect = NO;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral didDisconnect];
    [BLEConnectionManager getInstanceBLE].delegate = nil;
    
    //Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //can be user email or user name here --
    self.userNameLabel.text = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
    self.userEmailLabel.text = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    
    self.cameraMac = (NSString *) [userDefaults objectForKey:@"CameraMacWithQuote"];
    self.stringUDID = [userDefaults stringForKey:CAMERA_UDID];
    
    if (self.progressView == nil)
    {
        NSLog(@"progressView = nil!!!!");
    }
    
    
    
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    UIImageView *imageView = (UIImageView *)[self.progressView viewWithTag:595];
    imageView.animationImages =[NSArray arrayWithObjects:
                                [UIImage imageNamed:@"setup_camera_c1"],
                                [UIImage imageNamed:@"setup_camera_c2"],
                                [UIImage imageNamed:@"setup_camera_c3"],
                                [UIImage imageNamed:@"setup_camera_c4"],
                                nil];
    imageView.animationDuration = 1.5;
    imageView.animationRepeatCount = 0;
    
    [self.view addSubview:self.progressView];
    [imageView startAnimating];
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
    
    //CameraTest: try to search for camera now..
    
    [NSTimer scheduledTimerWithTimeInterval: SCAN_CAM_TIMEOUT_BLE
                                     target:self
                                   selector:@selector(setStopScanning:)
                                   userInfo:nil
                                    repeats:NO];
    
    // 2 of 3. no need to schedule timer here
    [self wait_for_camera_to_reboot:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)hubbleItemAction: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startAnimationWithOrientation
{
    UIImageView *animationView =  (UIImageView *)[cameraAddedView viewWithTag:TAG_IMAGE_VIEW_ANIMATION];
    //UIImageView *animationView = [[UIImageView alloc ] initWithFrame:deviceScreen];
    
    [animationView setContentMode:UIViewContentModeScaleAspectFit];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        animationView.animationImages =[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"frame-1_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-2_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-3_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-4-2_update-iOS7_new"],
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
                                        [UIImage imageNamed:@"frame-4-2_update_new"],
                                        [UIImage imageNamed:@"frame-5_update_new"],
                                        [UIImage imageNamed:@"frame-6_update_new"],
                                        nil];
        NSLog(@"ios < 7");
    }
    
    animationView.animationDuration = 18;
    animationView.animationRepeatCount = 0;
    
    [cameraAddedView bringSubviewToFront:animationView];
    
    [animationView startAnimating];
}

#pragma  mark -
#pragma mark Timer callbacks

-(void) silentRetryTimeout:(NSTimer *) expired
{
    
    //TIMEOUT --
    should_retry_silently = FALSE;
    
}


#pragma mark -


-(void) setStopScanning:(NSTimer *) exp
{
    should_stop_scanning = TRUE;
}

- (void) wait_for_camera_to_reboot:(NSTimer *)exp
{
    if (should_stop_scanning == TRUE)
    {
        should_stop_scanning = FALSE;
        NSLog(@" stop scanning now.. should be 4 mins");
        
		[self setupFailed];
		return ;
    }
    else
    {
        NSLog(@"Continue scan...");
    }
    
    
    if ([self checkItOnline])
    {
        //Found it online
        NSLog(@"Found it online");
        [self setupCompleted];
        return;
    }
	
	[NSTimer scheduledTimerWithTimeInterval: 2.0 //
									 target:self
								   selector:@selector(wait_for_camera_to_reboot:)
								   userInfo:nil
									repeats:NO];
}

#pragma mark - MBS_JSON communication

-(BOOL) checkItOnline
{
    NSLog(@"--> Try to search IP online...");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
    
    if (_userAccount == nil)
    {
        UserAccount *user = [[UserAccount alloc] initWithUser:userEmail
                                 password:userPass
                                   apiKey:userApiKey
                                 listener:nil];
        self.userAccount = user;
        [user release];
    }

#if 1
    if ([_userAccount checkCameraIsAvailable:self.cameraMac])
    {
        self.errorCode = @"NoErr";
        return TRUE;
    }
#else
    NSString *localIp = [_userAccount query_cam_ip_online: self.cameraMac];
    
    if ( localIp != nil)
    {
        NSLog(@"Found a local ip: %@", localIp);
        return TRUE;
    }
#endif
    
    self.errorCode =@"NotAvail";
    
    return FALSE;
}

- (void)updatesBasicInfoForCamera
{
    if (!_jsonCommBlocked)
    {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey     = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *hostSSID   = [userDefaults objectForKey:HOST_SSID];
    NSString *deviceName = [userDefaults objectForKey:CAMERA_NAME];
    
    NSDictionary *responseDict = [_jsonCommBlocked updateDeviceBasicInfoBlockedWithRegistrationId:_stringUDID
                                                                                       deviceName:deviceName
                                                                                         timeZone:nil
                                                                                             mode:nil
                                                                                  firmwareVersion:nil
                                                                                         hostSSID:hostSSID
                                                                                       hostRouter:nil
                                                                                        andApiKey:apiKey];
    BOOL updateFailed = TRUE;
    
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            NSString *bodyKey = [[responseDict objectForKey:@"data"] objectForKey:@"host_ssid"];
            
            if (![bodyKey isEqual:[NSNull null]])
            {
                if ([bodyKey isEqualToString:hostSSID])
                {
                    updateFailed = FALSE;
                }
            }
        }
    }
    
    if (updateFailed)
    {
        NSLog(@"Step10VC - updatesBasicInfoForCamera: %@", responseDict);
    }
    else
    {
        NSLog(@"Step10VC - updatesBasicInforForCamera successfully!");
    }
}

- (void)sendToServerTheCommand:(NSString *) command
{
    if (!_jsonCommBlocked)
    {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    }
    
    NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:_stringUDID
                                                                             andCommand:command
                                                                              andApiKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"PortalApiKey"]];
    
    NSInteger errorCode = -1;
    NSString *errorMessage = @"Update failed";
    
    if (responseDict)
    {
        errorCode = [[responseDict objectForKey:@"status"] integerValue];
        
        if (errorCode == 200)
        {
            errorCode = [[[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"device_response_code"] integerValue];
        }
        else
        {
            errorMessage = [responseDict objectForKey:@"message"];
        }
    }
    
    NSLog(@"%s cmd:%@, error: %d", __func__, command, errorCode);
}

- (void) setupCompleted
{
    // Try to update host ssid to server
    [self sendToServerTheCommand:@"set_motion_area&grid=1x1&zone=00"];
    [self sendToServerTheCommand:@"vox_enable"];
    [self sendToServerTheCommand:@"set_temp_lo_enable&value=1"];
    [self sendToServerTheCommand:@"set_temp_hi_enable&value=1"];
    
    [self updatesBasicInfoForCamera];
    
    //Load step 12
    NSLog(@"Load step 12");
    
    //Load the next xib
    Step_12_ViewController *step12ViewController = [[Step_12_ViewController alloc]
                                init];
    
    [self.navigationController pushViewController:step12ViewController animated:NO];
    
    [step12ViewController release];
}

- (void)  setupFailed
{
    NSLog(@"%s", __FUNCTION__);
#if 0
 	NSLog(@"Setup has failed - remove cam on server");
	// send a command to remove camera
	//NSString *mac = [Util strip_colon_fr_mac:self.cameraMac];

    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(removeCamSuccessWithResponse:)
                                                                          FailSelector:@selector(removeCamFailedWithError:)
                                                                             ServerErr:@selector(removeCamFailedServerUnreachable)] autorelease];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [jsonComm deleteDeviceWithRegistrationId:_stringUDID
                                   andApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
#endif
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
    
    step11ViewController.errorCode = self.errorCode;
    [self.navigationController pushViewController:step11ViewController animated:NO];
    
    [step11ViewController release];
}



-(void) removeCamSuccessWithResponse:(NSDictionary *)responseData
{
	NSLog(@"removeCam success");
	
	//[delegate sendStatus:5 ];
	
}

-(void) removeCamFailedWithError:(NSDictionary *)error_response
{
	NSLog(@"removeCam failed Server error: %@", [error_response objectForKey:@"message"]);
}

-(void) removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
}






@end
