//
//  Step_08_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import "Step_08_ViewController.h"
#import "Step_11_ViewController.h"
#import "RegistrationViewController.h"

@interface Step_08_ViewController ()

@property (nonatomic, strong) NSTimer *timeOut;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic) BOOL shouldStopScanning;

@end

@implementation Step_08_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Hide back button -- can't go back now..
    self.navigationItem.hidesBackButton = TRUE;
    
    
	// Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Camera_Configured",nil, [NSBundle mainBundle],
                                                                  @"Camera Configured" , nil);
    _ssidView.text = _ssid;
    _ssidView_1.text = _ssid;
    self.navigationItem.hidesBackButton = YES;
    
    NSString *title = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle], @"Back" , nil);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:nil
                                                                   action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    //check back later..
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(checkConnectionToHomeWifi:)
                                   userInfo:nil
                                    repeats:NO];
    
    self.shouldStopScanning = FALSE;
    
    self.timeOut = [NSTimer scheduledTimerWithTimeInterval:2*60.0
                                                    target:self
                                                  selector:@selector(homeWifiScanTimeout:)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustViewsForOrientations:toInterfaceOrientation];
}

- (void)adjustViewsForOrientations:(UIInterfaceOrientation)interfaceOrientation
{
    if ( UIInterfaceOrientationIsLandscape(interfaceOrientation) ) {
        [[NSBundle mainBundle] loadNibNamed:@"Step_08_ViewController_land" owner:self options:nil];
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        [[NSBundle mainBundle] loadNibNamed:@"Step_08_ViewController" owner:self options:nil];
    }
}

#pragma mark - Custom Action methods

- (IBAction)handleButtonPress:(id)sender
{    
    NSLog(@"Step_08 - Load RegistrationVC");
    
    if ( _timeOut.isValid ) {
        [_timeOut invalidate];
    }
    
    // Load RegistrationVC
    RegistrationViewController *controller = [[RegistrationViewController alloc] initWithNibName:@"RegistrationViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:NO];
}

#pragma mark - Private methods

- (void)setupFailed
{
    //Load step 11
    NSLog(@"Load step 11");
    
    //Load the next xib
    Step_11_ViewController *step11ViewController = [[Step_11_ViewController alloc] initWithNibName:@"Step_11_ViewController" bundle:nil];
    step11ViewController.errorCode = @"Time Out";
    [self.navigationController pushViewController:step11ViewController animated:NO];
}

#pragma mark - Timer callbacks

- (void)homeWifiScanTimeout:(NSTimer *)expired
{
    NSLog(@" Timeout while trying to search for Home Wifi: %@", _ssid);
    self.shouldStopScanning = YES;
}

- (void)checkConnectionToHomeWifi:(NSTimer *)expired
{
    if ( _shouldStopScanning ) {
        [self setupFailed];
        return;   
    }
    
    NSString *currentSSID = [CameraPassword fetchSSIDInfo];

    NSLog(@"checkConnectionToHomeWifi 03: %@", currentSSID);
	if ([currentSSID isEqualToString:_ssid]) {
		//yeah we're connected ... check for ip??
		
		NSString *bc = @"";
		NSString *own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
		
		if (![own isEqualToString:@""]) {
            //20121130: phung: save it here.. so that we can automatically check later on.
            if ( _ssid) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:_ssid forKey:HOME_SSID];
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

@end
