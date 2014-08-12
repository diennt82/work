//
//  Step_06_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import "Step_06_ViewController.h"
#import "Step_10_ViewController.h"
#import "HttpCom.h"

@interface Step_06_ViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *tfSSID;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UITextField *tfConfirmPass;

// timeout input password
@property (nonatomic, strong) NSTimer *inputPasswordTimer;
@property (nonatomic, strong) NSTimer *timeOut;

@property (nonatomic, strong) DeviceConfiguration * deviceConf;
@property (nonatomic, copy) NSString *currentStateCamera;
@property (nonatomic, copy) NSString *password;

// current state of camera
@property (nonatomic, assign) BOOL isUserMakeConnect;
@property (nonatomic, assign) BOOL task_cancelled;

@end

@implementation Step_06_ViewController

#define TIME_INPUT_PASSWORD_AGAIN 60.0
#define RETRY_SETUP_WIFI_TIMES 5
#define GAI_CATEGORY @"Step 06 view"

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    [_progressView setHidden:YES];
    
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    UIBarButtonItem *nextButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Next",nil, [NSBundle mainBundle],
                                                                             @"Next" , nil)
     
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleNextButton:)];
    
    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UIImageView *imageView = (UIImageView *)[_progressView viewWithTag:595];
    imageView.animationImages =[NSArray arrayWithObjects:
                                [UIImage imageNamed:@"setup_camera_c1"],
                                [UIImage imageNamed:@"setup_camera_c2"],
                                [UIImage imageNamed:@"setup_camera_c3"],
                                [UIImage imageNamed:@"setup_camera_c4"],
                                nil];
    imageView.animationDuration = 1.5;
    imageView.animationRepeatCount = 0;
    [imageView startAnimating];
    
    if ( !_ssid ) {
        NSLog(@"empty SSID ");
    }
    if ( !_security ) {
        NSLog(@"empty security ");
    }
    
    UITextField *tfSsid = (UITextField *)[_ssidCell viewWithTag:202];
    if ( tfSsid && !_isOtherNetwork ) {
        tfSsid.text = _ssid;
    }
    
    UITextField *sec = (UITextField *)[_securityCell viewWithTag:1];
    if ( sec ) {
        sec.text = _security;
    }
    
    self.tfSSID = (UITextField *)[_ssidCell viewWithTag:202];
    
    if ( _tfSSID.text.length > 0 && ([_security isEqualToString:@"None"] || [_security isEqualToString:@"open"]) ) {
        self.navigationItem.rightBarButtonItem .enabled = YES;
    }
    
    self.tfPassword = (UITextField *)[_passwordCell viewWithTag:200];
    self.tfConfirmPass = (UITextField *)[_confPasswordCell viewWithTag:201];
    
    // Initialize transient object here
	self.deviceConf = [[DeviceConfiguration alloc] init];
	
    if ( ![self restoreDataIfPossible] ) {
		// Try to read the ssid from preference:
        self.deviceConf.ssid = _ssid;
    }
    else {
        /*
         * 1. Check deviceConf.ssid vs self.ssid
         * 2. check sec type : OPEN , WeP, wpa
         * 3. If ( =)  -> prefill pass- deviceConf.key  to  password/conf password text field
         */
        NSLog(@"Step_06_ViewController - viewDidLoad - deviceConf.ssid: %@, - self.ssid: %@, - self.security: %@", _deviceConf.ssid, _ssid, _security);
        
        if ( [_deviceConf.ssid isEqualToString:_ssid] &&
            ([_security isEqualToString:@"wep"] || [_security isEqualToString:@"wpa"]) )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.tfPassword.text = _deviceConf.key;
            self.tfConfirmPass.text = _deviceConf.key;
        }
    }
    
    //addsubview
    [self.view addSubview:_infoSelectCameView];
    
    _infoSelectCameView.hidden = YES;
    _scrollViewGuide.contentSize = CGSizeMake(320, 1181);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.trackedViewName = GAI_CATEGORY;
    NSLog(@"update security type");
    UITextField *sec = (UITextField *)[_securityCell viewWithTag:1];
    if ( sec ) {
        sec.text = _security;
    }
    
    _isUserMakeConnect = NO;
    
    // Don't know why but on iOS 7.1 the tintColor was getting unset somehow
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7+
        self.navigationItem.rightBarButtonItem.tintColor = [UIApplication sharedApplication].keyWindow.tintColor;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _task_cancelled = YES;
    [self resetAllTimer];
}


#pragma mark - Actions

- (void)hubbleItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 202) {
        // SSID
        NSInteger ssidTextLength = 0;
        const char *c = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(c, "\b");
        
        if (isBackSpace == -8) {
            ssidTextLength = textField.text.length - 1;
        }
        else {
            ssidTextLength = textField.text.length + string.length;
        }
        
        if (ssidTextLength > 0 && [_tfPassword.text isEqualToString:_tfConfirmPass.text]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else if (textField.tag == 200) {
        // Password
        NSString *passString = @"";
        
        const char *c = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(c, "\b");
        
        if (isBackSpace == -8) {
            passString = [textField.text substringToIndex:textField.text.length - 1];
        }
        else {
            passString = [textField.text stringByAppendingString:string];
        }
        
        if (_tfSSID.text.length > 0 && passString.length>0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else if (textField.tag == 201) {
        // Confirm Password
        NSString *confirmPassString = @"";
        
        const char *c = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(c, "\b");
        
        if (isBackSpace == -8)
        {
            confirmPassString = [textField.text substringToIndex:textField.text.length - 1];
        }
        else {
            confirmPassString = [textField.text stringByAppendingString:string];
        }
        
        if (_tfSSID.text.length > 0 && [_tfPassword.text isEqualToString:confirmPassString]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ( textField.tag !=202 ) {
        // Dont move if it's the SSID name
        [self animateTextField:textField up:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ( textField.tag !=202 ) {
        // Dont move if it's the SSID name
        [self animateTextField:textField up:NO];
    }
}

- (void)animateTextField:(UITextField *)textField up:(BOOL)up
{
    int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if ( textField.tag ==201 && UIInterfaceOrientationIsLandscape(interfaceOrientation) ) {
        //Confirm Password cell
        movementDistance+= 40;
    }
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 200) {
        //password
        self.password = textField.text;
        //[self.tfConfirmPass becomeFirstResponder];
        [textField resignFirstResponder];
        return NO;
    }
    else if (textField.tag ==201) {
        //conf password
        [textField resignFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma  mark -  Table View delegate & datasource

#define SSID_SECTION 0
#define SEC_SECTION 1
#define SSID_INDEX 0
#define SEC_INDEX 0
#define PASSWORD_INDEX 1
#define CONFPASSWORD_INDEX 2

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tag = tableView.tag;
    
    if (tag == 13) {
        if (indexPath.section == SSID_SECTION) {
            //only one cell in this section
            if ( _isOtherNetwork ) {
                UITextField *tfSsid  = (UITextField* )[_ssidCell viewWithTag:202];
                [tfSsid setUserInteractionEnabled:YES];
            }
            return _ssidCell;
        }
        else if (indexPath.section == SEC_SECTION) {
            if (indexPath.row == SEC_INDEX) {
                return _securityCell;
            }
            if (indexPath.row == PASSWORD_INDEX) {
                return _passwordCell;
            }
            if (indexPath.row == CONFPASSWORD_INDEX) {
                return _confPasswordCell;
            }
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tag = tableView.tag;
    
    if (tag == 13) {
        if (section == SSID_SECTION) {
            return 1;
        }
        else if (section == SEC_SECTION) {
            if ([_security isEqualToString:@"open"] || [_security isEqualToString:@"none"]) {
                return 1;
            }
            else {
                return 2;
            }
        }
    }
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int tag = tableView.tag;
    if (tag == 13) {
        return 2;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    if ([_ssid isEqualToString:@"Other Network"]) {
        if (indexPath.section == SEC_SECTION) {
            if (indexPath.row == SEC_INDEX) {
                [self changeSecurityType];
            }
        }
    }
    
    if (indexPath.section == SSID_SECTION) {
        //only one cell in this section
        if ( _isOtherNetwork ) {
            UITextField *tfSsid = (UITextField *)[_ssidCell viewWithTag:202];
            [tfSsid setUserInteractionEnabled:YES];
            [tfSsid becomeFirstResponder];
        }
    }
    else if (indexPath.section == SEC_SECTION) {
        if (indexPath.row == PASSWORD_INDEX) {
            UITextField *txtField = (UITextField *)[_passwordCell viewWithTag:200];
            [txtField becomeFirstResponder];
        }
        
        if (indexPath.row == CONFPASSWORD_INDEX) {
            UITextField *txtField = (UITextField *)[_confPasswordCell viewWithTag:201];
            [txtField becomeFirstResponder];
        }
        else if (indexPath.row == SEC_INDEX) {
            [self changeSecurityType];
        }
    }
}

#pragma mark - Private methods

- (void)changeSecurityType
{
    //load step 07
    NSLog(@"Load step 7");
    
    //Load the next xib
    Step_07_ViewController *step07ViewController = [[Step_07_ViewController alloc] initWithNibName:@"Step_07_ViewController" bundle:nil];
    step07ViewController.step06 = self;
    [self.navigationController pushViewController:step07ViewController animated:NO];
}

- (void)handleNextButton:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step06 - next button" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Touch Next button"
                                                     withLabel:@"Next"
                                                     withValue:nil];
    
    // Create progressView for process verify network
    self.navigationItem.leftBarButtonItem.enabled = NO; // Disable go back
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.view addSubview:_progressView];
    _progressView.hidden = NO;
    
    //check if password is ok?
    UITextField *mySsid = (UITextField*)[_ssidCell viewWithTag:202];
    
    [self.view endEditing:YES];
    
    NSLog(@"%s other: %d, security: %@", __FUNCTION__, _isOtherNetwork, _security);
    
    if ( _isOtherNetwork ) {
        if ( mySsid.text.length == 0) {
            //error
            self.navigationItem.leftBarButtonItem.enabled = YES; // enable go back
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self.progressView removeFromSuperview];
            
            //ERROR condition
            UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:@"SSID cannot be empty"
                                                             message:@"Please fill the SSID name and try again"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [_alert show];
            return;
        }
        else {
            self.ssid = mySsid.text;
        }
    }
    
    if ( [_security isEqualToString:@"open"] ) {
        //cont
        self.password = @""; // Purpose nil
        [self sendWifiInfoToCamera];
    }
    else {
        UITextField *pass = (UITextField*)[self.passwordCell viewWithTag:200];
        //UITextField * confpass = (UITextField*)[self.confPasswordCell viewWithTag:201];
        
        if ( pass.text.length == 0 ) {
            // error
            self.navigationItem.leftBarButtonItem.enabled = YES; // enable go back
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self.progressView removeFromSuperview];
            
            //ERROR condition
            UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:@"Password Failed"
                                                             message:@"Please enter password"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [_alert show];
            return;
        }
        else {
            //cont
            self.password = pass.text;
            [self sendWifiInfoToCamera ];
        }
    }
}

- (void)prepareWifiInfo
{
    // NOTE: we can do this because we are connecting to camera now
    NSString *cameraMac = nil;
    NSString *stringUDID = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_UDID withTimeout:5.0];
    // get_udid: 01008344334C32B0A0VFFRBSVA
    NSRange range = [stringUDID rangeOfString:@": "];
    
    if (range.location != NSNotFound) {
        //01008344334C32B0A0VFFRBSVA
        stringUDID = [stringUDID substringFromIndex:range.location + 2];
        cameraMac = [stringUDID substringWithRange:NSMakeRange(6, 12)];
        cameraMac = [Util add_colon_to_mac:cameraMac];
    }
    else {
        NSLog(@"Error - Received UDID wrong format - UDID: %@", stringUDID);
    }
    
    self.deviceConf.ssid = _ssid;
    
    // Save mac address for used later
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cameraMac forKey:@"CameraMacWithQuote"];
    [userDefaults setObject:stringUDID forKey:CAMERA_UDID];
    [userDefaults synchronize];
    
    self.deviceConf.addressMode = @"DHCP";
    
    if ( [_security isEqualToString:@"wep"] ) {
        //@"Open",@"WEP", @"WPA-PSK/WPA2-PSK"
        _deviceConf.securityMode = @"WEP";
        _deviceConf.wepType = @"OPEN"; //default
        _deviceConf.keyIndex = @"1"; //default;
    }
    else if ( [_security isEqualToString:@"wpa"] ) {
        _deviceConf.securityMode = @"WPA-PSK/WPA2-PSK";
        
    }
    else if ([_security isEqualToString:@"shared"]) {
        _deviceConf.securityMode = @"SHARED";
    }
    else {
        _deviceConf.securityMode= @"OPEN";
    }
    
    NSLog(@"Log - udid: %@, %@", stringUDID, cameraMac);
    _deviceConf.key = _password;
    _deviceConf.usrName = BASIC_AUTH_DEFAULT_USER;
    
    NSString *camPass = [CameraPassword getPasswordForCam:cameraMac];
    NSLog(@"Log - 02 cam password is : %@", camPass);
    
    if ( !camPass ) {
        // default pass
        camPass = @"00000000";
        NSLog(@"Log - 02 cam password is default: %@", camPass);
    }
    
    _deviceConf.passWd = camPass;
}

-(void)sendWifiInfoToCamera
{
    // Disable user interaction
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    [stringFromDate insertString:@"." atIndex:3];
    
    NSLog(@"set auth -set_auth_cmd: %d ", [fwVersion compare:FW_MILESTONE_F66_NEW_FLOW]);
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step06 - Add camera fw: %@", fwVersion] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Send Wifi info to Camera-fw:%@", fwVersion]
                                                     withLabel:nil
                                                     withValue:nil];
    NSString *response = nil;
    
     // >12.82 we can move on with new flow
    if  ([fwVersion compare:FW_MILESTONE_F66_NEW_FLOW] >= NSOrderedSame) //||
         //([fwVersion compare:FW_MILESTONE_F66_NEW_FLOW] == NSOrderedAscending) )
    {
        // SEND auth data over first
        NSString * set_auth_cmd = [NSString stringWithFormat:@"%@%@%@%@%@",
                                   SET_SERVER_AUTH,
                                   SET_SERVER_AUTH_PARAM1, apiKey,
                                   SET_SERVER_AUTH_PARAM2, stringFromDate];
        
        response = [[HttpCom instance].comWithDevice sendCommandAndBlock:set_auth_cmd withTimeout:10.0];
        NSLog(@"set auth -set_auth_cmd: %@, -response: %@ ", set_auth_cmd, response);
    }
    
    [self prepareWifiInfo];
    
    // Save and send
    if ( [_deviceConf isDataReadyForStoring] ) {
        [Util writeDeviceConfigurationData:[_deviceConf getWritableConfiguration]];
    }
    
    [_deviceConf restoreConfigurationData:[Util readDeviceConfiguration]];
    
    NSString *deviceConfiguration = [_deviceConf getDeviceEncodedConfString];
    NSString *setupCmd = [NSString stringWithFormat:@"%@%@", SETUP_HTTP_CMD, deviceConfiguration];
    
    [self loopSetupWifiSending:setupCmd retryTimes:0];
    
    // >12.82 we can move on with new flow
    if ([fwVersion compare:FW_MILESTONE_F66_NEW_FLOW] >= NSOrderedSame) {
        // fw >= FW_MILESTONE_F66_NEW_FLOW
        // Should check connect to camera here(after send command setup http)
        // Check app is already connected to camera which is setup or not, call once
        [NSTimer scheduledTimerWithTimeInterval: 3.0
                                         target:self
                                       selector:@selector(moveOnToCheckCameraOnlineStatus)
                                       userInfo:nil
                                        repeats:NO];
        response = [[HttpCom instance].comWithDevice sendCommandAndBlock:RESTART_HTTP_CMD];
        
        NSLog(@"%s RESTART_HTTP_CMD: %@", __FUNCTION__, response);
    }
    else {
        // popup force waiting..
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:self
                                       selector:@selector(checkAppConnectToCameraAtStep03)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (BOOL)loopSetupWifiSending:(NSString *)setupCmd retryTimes:(NSInteger)times
{
    if ( times < RETRY_SETUP_WIFI_TIMES ) {
        NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:setupCmd];
        if ( [response isEqualToString:@"setup_wireless_save: 0"] ) {
            return YES;
        }
        
        NSLog(@"%s send cmd  %@ - response is: %@", __FUNCTION__, setupCmd, response); //setup_wireless_save: 0
        times++;
        
        [self loopSetupWifiSending:setupCmd retryTimes:times];
    }
    
    return NO;
}

-(void)moveOnToCheckCameraOnlineStatus
{
    [self resetAllTimer];
    [self nextStepVerifyPassword];
    [_progressView removeFromSuperview];
    [_infoSelectCameView removeFromSuperview];
    _progressView.hidden = YES;
}

- (void)checkAppConnectToCameraAtStep03
{
    [self.view bringSubviewToFront:_progressView];
    _progressView.hidden = NO;
    
    NSString *currentSSID = [CameraPassword fetchSSIDInfo];
    NSLog(@"check App Connect To Camera At Step03 after sending wifi info");
    if ( !currentSSID ) {
        // check again
        if ( _task_cancelled ) {
            // handle when user press back
        }
        else {
            [NSTimer scheduledTimerWithTimeInterval:3
                                             target:self
                                           selector:@selector(checkAppConnectToCameraAtStep03)
                                           userInfo:nil
                                            repeats:NO];
            
            NSLog(@"Continue to check ssid after 3sec");
        }
    }
    else if ([self isAppConnectedToCamera]) {
        NSLog(@"App connected with camera, start to get WIFI conn status...");
        [self.view bringSubviewToFront:_progressView];
        [self getStatusOfCameraToWifi:nil];
    }
    else {
        // currentSSID is not camera : this means app is kicked out
        NSLog(@"App connected with %@ not camera, ask user to switch manually. " ,currentSSID );

        // show prompt to user select network camera again and handle next
        _progressView.hidden = YES;
        _infoSelectCameView.hidden = NO;
        [self.view bringSubviewToFront:_infoSelectCameView];
    }
}

-(void) becomeActive
{
    NSLog(@"getstatusOfCamera again");
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(checkAppConnectToCameraAtStep03)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)nextStepVerifyPassword
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //load step 10
    NSLog(@"Add cam... ");
    NSLog(@"Load Step 10");
    
    if ( _deviceConf.ssid ) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_deviceConf.ssid forKey:HOME_SSID];
        [userDefaults synchronize];
    }
    
    //Load the next xib
    Step_10_ViewController *step10ViewController = [[Step_10_ViewController alloc] initWithNibName:@"Step_10_ViewController" bundle:nil];
    [self.navigationController pushViewController:step10ViewController animated:NO];
}

- (void)getStatusOfCameraToWifi:(NSTimer *)info
{
    NSString *commandGetState = GET_STATE_NETWORK_CAMERA;
    NSString *state = [[HttpCom instance].comWithDevice sendCommandAndBlock:commandGetState withTimeout:20.0];
    NSLog(@"getStatusOfCameraToWifi - command %@  response:%@", commandGetState,state);

    if ( state.length > 0 ) {
        _currentStateCamera = [[state componentsSeparatedByString:@": "] objectAtIndex:1];
    }
    else {
        _currentStateCamera = @"";
    }
    
    if ([_currentStateCamera isEqualToString:@"CONNECTED"]) {
        [self resetAllTimer];
        [self nextStepVerifyPassword];
        [_progressView removeFromSuperview];
        [_infoSelectCameView removeFromSuperview];
        _progressView.hidden = YES;
    }
    else {
        // Need to checkout current ssid here!
        if ( ![self isAppConnectedToCamera] ) {
            NSLog(@"Step_06VC - current ssid is not a camera ssid !!!!! This check passed before coming here..");
            _infoSelectCameView.hidden = NO;
            [self.view bringSubviewToFront:_infoSelectCameView];
        }
        else {
            // get state network of camera after 4s
            _inputPasswordTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                   target:self
                                                                 selector:@selector(getStatusOfCameraToWifi:)
                                                                 userInfo:nil
                                                                  repeats:NO];
        }
    }
}

- (BOOL)isAppConnectedToCamera
{
    NSString *currentSSID = [CameraPassword fetchSSIDInfo];
    NSString *cameraSSID = [[NSUserDefaults standardUserDefaults] stringForKey:CAMERA_SSID]; //CameraHD-00667fa037
    NSLog(@"Step_06_VC - currentSSID: %@, - cameraWiFi: %@", currentSSID, cameraSSID);
    
    if ([currentSSID isEqualToString:cameraSSID]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)restoreDataIfPossible
{
	NSDictionary *savedData = [Util readDeviceConfiguration];
	if ( savedData ) {
		[_deviceConf restoreConfigurationData:savedData];
        
		// Populate the fields with stored data
		return YES;
	}
    
	return NO;
}

- (void)showPasswordDialog
{
    NSLog(@"pass is wrong: %@ ", _password);
    _timeOut = nil;
    [self resetAllTimer];
    _progressView.hidden = YES;
    
    //ERROR condition
    UIAlertView *alertViewPassword = [[UIAlertView alloc] initWithTitle:@"Confirm Password"
                           message:@"Input password again."
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"Ok", nil];
    
    alertViewPassword.tag = 101;
    [alertViewPassword show];
}

- (void)resetAllTimer
{
    if ( _timeOut ) {
        [_timeOut invalidate];
        _timeOut = nil;
    }
    if ( _inputPasswordTimer ) {
        [_inputPasswordTimer invalidate];
        _inputPasswordTimer = nil;
    }
}

#pragma mark - Dummy ota upgrade

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int tag = alertView.tag;
    
    if (tag == 100) {
        // any button - go back to camera list
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else if (tag == 101) {
        if (buttonIndex == 0) {
            NSLog(@"ok");
            [self resetAllTimer];
            [self getStatusOfCameraToWifi:nil];
            _timeOut =  [NSTimer scheduledTimerWithTimeInterval:TIME_INPUT_PASSWORD_AGAIN // after 60s if not get successful
                                                         target:self
                                                       selector:@selector(showPasswordDialog)
                                                       userInfo:nil
                                                        repeats:NO];
        }
        else {
            NSLog(@"cancel");
        }
    }
}

- (void)askUserToWaitForUpgrade
{
    [self resetAllTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [_progressView removeFromSuperview];
    [_infoSelectCameView removeFromSuperview];
    _progressView.hidden = YES;
    
    [self.view addSubview:_otaDummyProgress];
    [self.view bringSubviewToFront:_otaDummyProgress];
    _otaDummyProgressBar.progress = 0.0;
    
	[self performSelectorInBackground:@selector(upgradeFwReboot) withObject:nil];
}

- (void)upgradeFwReboot
{
	//percentageProgress.
	@autoreleasepool {
    
		float sleepPeriod = 120.0 / 100; // 100 cycles
		int percentage = 0;
		while (percentage++ < 100) {
			[self performSelectorOnMainThread:@selector(upgradeFwProgress:)
                               withObject:[NSNumber numberWithInt:percentage]
                            waitUntilDone:YES];
        
			[NSThread sleepForTimeInterval:sleepPeriod];
		}
    
		[self performSelectorOnMainThread:@selector(goBackAndReaddCamera) withObject:nil waitUntilDone:NO];
	}
}

- (void)goBackAndReaddCamera
{
    //ERROR condition
    UIAlertView *alertViewBack = [[UIAlertView alloc] initWithTitle:LocStr(@"Upgrade_done")
                                                            message:@"Press OK to retry installing the camera."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
    alertViewBack.tag = 100;
    [alertViewBack show];
}

- (void)upgradeFwProgress:(NSNumber *)number
{
	float value = [number intValue]/100.0f;
	if ( value >= 0 ) {
		_otaDummyProgressBar.progress = value;
	}
}

@end
