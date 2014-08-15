//
//  Step_08_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_08_ViewController.h"
#import "Step_11_ViewController.h"
#import "RegistrationViewController.h"

@interface Step_08_ViewController ()

@end

@implementation Step_08_ViewController
@synthesize  ssid;

@synthesize timeOut;
@synthesize shouldStopScanning; 


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
    [self xibDefaultLocalization];
    //Hide back button -- can't go back now..
    self.navigationItem.hidesBackButton = TRUE;
    
    
	// Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Camera_Configured",nil, [NSBundle mainBundle],
                                                                  @"Camera Configured" , nil);
    ssidView.text = self.ssid;
    ssidView_1.text = self.ssid;
    self.navigationItem.hidesBackButton = YES;    self.navigationItem.backBarButtonItem =
    

    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"back",nil, [NSBundle mainBundle],
                                                                              @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    
    //check back later..
    [NSTimer scheduledTimerWithTimeInterval: 2.0//
                                     target:self
                                   selector:@selector(checkConnectionToHomeWifi:)
                                   userInfo:nil
                                    repeats:NO];

    
    
    shouldStopScanning = FALSE;
    
    timeOut = [NSTimer scheduledTimerWithTimeInterval:2*60.0
                                 target:self
                                   selector:@selector(homeWifiScanTimeout:)
                                   userInfo:nil
                                    repeats:NO];
    
    
    
}

- (void)xibDefaultLocalization
{
    UITextView *textView = (UITextView *)[self.view viewWithTag:1];
    textView.text = NSLocalizedStringWithDefaultValue(@"xib_step08_textview_reach_wifi_network", nil, [NSBundle mainBundle], @"How to reach Wi-Fi Network? Select settings in iphone home screen and then select Wi-Fi.", nil);
    textView = (UITextView *)[self.view viewWithTag:2];
    textView.text = NSLocalizedStringWithDefaultValue(@"xib_step08_textview_switch_wifi_network", nil, [NSBundle mainBundle], @"Please switch to Wi-Fi network :", nil);
    textView = (UITextView *)[self.view viewWithTag:3];
    textView.text = NSLocalizedStringWithDefaultValue(@"xib_step08_textview_switch_back_to_wifi_network", nil, [NSBundle mainBundle], @"Please switch back to the Wi-Fi network ", nil);
    textView = (UITextView *)[self.view viewWithTag:4];
    textView.text = NSLocalizedStringWithDefaultValue(@"xib_step08_textview_once_the_above_step_is_done", nil, [NSBundle mainBundle], @"Once the above step is done, return here to create an account", nil);
    textView = (UITextView *)[self.view viewWithTag:5];
    textView.text = NSLocalizedStringWithDefaultValue(@"xib_step08_textview_camera_configured_to_wifi", nil, [NSBundle mainBundle], @"Your camera is configured to WiFi ", nil);
    
    UILabel *lable = (UILabel *)[self.view viewWithTag:6];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_step08_label_home_ssid", nil, [NSBundle mainBundle], @"Home ssid", nil);
}

-(void) dealloc
{
    [ssid release];
    [timeOut release];
    
    [super dealloc];
    
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
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"Step_08_ViewController_land_ipad" owner:self options:nil];
        } else {
            [[NSBundle mainBundle] loadNibNamed:@"Step_08_ViewController_land" owner:self options:nil];
        }
    } else if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"Step_08_ViewController_ipad" owner:self options:nil];
        } else {
            [[NSBundle mainBundle] loadNibNamed:@"Step_08_ViewController" owner:self options:nil];
        }
    }
}

-(IBAction)handleButtonPress:(id)sender
{    
    NSLog(@"Step_08 - Load RegistrationVC");
    
    if (timeOut != nil && [timeOut isValid])
    {
        [timeOut invalidate];
    }
    
    // Load RegistrationVC
    
    RegistrationViewController *registrationVC = [[RegistrationViewController alloc] init];
    [self.navigationController pushViewController:registrationVC animated:NO];
    [registrationVC release];
    
    //Load the next xib
//    Step09ViewController *step09VC = [[Step09ViewController alloc] init];
//
//    [self.navigationController pushViewController:step09VC animated:NO];
//    
//    [step09VC release];
}




- (void)  setupFailed
{
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
    
    step11ViewController.errorCode = @"Time Out";
    [self.navigationController pushViewController:step11ViewController animated:NO];
    
    [step11ViewController release];
    
    
}



#pragma  mark -
#pragma mark Timer callbacks

-(void) homeWifiScanTimeout: (NSTimer *) expired
{
    NSLog(@" Timeout while trying to search for Home Wifi: %@", self.ssid);
    
    shouldStopScanning = TRUE;
    
}

- (void) checkConnectionToHomeWifi:(NSTimer *) expired
{
    if (shouldStopScanning == TRUE)
    {
        [self setupFailed];
        return;   
    }
    
    NSString * currentSSID = [CameraPassword fetchSSIDInfo];
    
    
    
    NSLog(@"checkConnectionToHomeWifi 03: %@", currentSSID);
	if ([currentSSID isEqualToString:self.ssid])
	{
		//yeah we're connected ... check for ip??
		
		NSString * bc = @"";
		NSString * own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
		
		if (![own isEqualToString:@""])
		{
			
            //20121130: phung: save it here.. so that we can automatically check later on.
            if (self.ssid != nil)
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                //[userDefaults setObject:self.ssid forKey:HOME_SSID];
                [userDefaults synchronize];
            }
            
            //create account now... 
            [self handleButtonPress:nil];
            
			return;
		}
		
	}
    
    //check back later..
    [NSTimer scheduledTimerWithTimeInterval: 3.0//
                                     target:self
                                   selector:@selector(checkConnectionToHomeWifi:)
                                   userInfo:nil
                                    repeats:NO];
	
}


#pragma mark -


@end
