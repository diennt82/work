//
//  Step_06_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_06_ViewController.h"
#import "HttpCom.h"
#import "Step_10_ViewController.h"
#import "KISSMetricsAPI.h"
#import "HoldOnCamWifi.h"

#define TIME_INPUT_PASSWORD_AGAIN   60.0
#define RETRY_SETUP_WIFI_TIMES      5
#define GAI_CATEGORY    @"Step 06 view"

@interface Step_06_ViewController () <UITextFieldDelegate>

@property (retain, nonatomic) UITextField *tfSSID;
@property (retain, nonatomic) UITextField *tfPassword;
@property (retain, nonatomic) UITextField *tfConfirmPass;

@end

@implementation Step_06_ViewController

@synthesize securityCell, ssidCell, passwordCell, confPasswordCell;
@synthesize currentStateCamera = _currentStateCamera;
@synthesize inputPasswordTimer = _inputPasswordTimer;
@synthesize deviceConf = _deviceConf;
@synthesize timeOut = _timeOut;

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
    [_tfSSID release];
    [_tfPassword release];
    [_tfConfirmPass release];
    
    [_ssid release];
    [_security release];
    [_password release];
    [_deviceConf release];
    [_progressView release];
    [_infoSelectCameView release];
    [_scrollViewGuide release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(becomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    [self.progressView setHidden:YES];
    
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
    [nextButton release];
    
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
    
    if (self.ssid == nil)
    {
        NSLog(@"empty SSID ");
    }
    if (self.security == nil)
    {
        NSLog(@"empty security ");
    }
    
    UITextField * tfSsid = (UITextField *) [self.ssidCell viewWithTag:202];
    if (tfSsid != nil && (self.isOtherNetwork == FALSE))
    {
        tfSsid.text = self.ssid;
    }
    
    UITextField * _sec = (UITextField *) [self.securityCell viewWithTag:1];
    if (_sec != nil)
    {
        _sec.text = self.security;
    }
    
    self.tfSSID = (UITextField *)[self.ssidCell viewWithTag:202];
    
    if (self.tfSSID.text.length > 0 && ([self.security isEqualToString:@"None"] || [self.security isEqualToString:@"open"]))
    {
        self.navigationItem.rightBarButtonItem .enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }
    
    self.tfPassword = (UITextField *)[self.passwordCell viewWithTag:200];
    self.tfConfirmPass = (UITextField *)[self.confPasswordCell viewWithTag:201];
    
    /* initialize transient object here */
	self.deviceConf = [[[DeviceConfiguration alloc] init] autorelease];
	
    if (![self restoreDataIfPossible] )
	{
		//Try to read the ssid from preference:
        self.deviceConf.ssid = self.ssid;
    }
    else
    {
        /*
         * 1. Check deviceConf.ssid vs self.ssid
         * 2. check sec type : OPEN , WeP, wpa
         * 3. If ( =)  -> prefill pass- deviceConf.key  to  password/conf password text field
         */
        
        NSLog(@"Step_06_ViewController - viewDidLoad - deviceConf.ssid: %@, - self.ssid: %@, - self.security: %@", self.deviceConf.ssid, self.ssid, self.security);
        
        if ([self.deviceConf.ssid isEqualToString:self.ssid] &&
            ([self.security isEqualToString:@"wep"] || [self.security isEqualToString:@"wpa"]))
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
            self.tfPassword.text = self.deviceConf.key;
            self.tfConfirmPass.text = self.deviceConf.key;
        }
    }
    
    //addsubview
    [self.view addSubview:self.infoSelectCameView];
    [self.infoSelectCameView setHidden:YES];
    
    [self.scrollViewGuide setContentSize:CGSizeMake(320, 1181)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    //[self resetAllTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.trackedViewName = GAI_CATEGORY;
    NSLog(@"update security type");
    UITextField * _sec = (UITextField *) [self.securityCell viewWithTag:1];
    if (_sec != nil)
    {
        _sec.text = self.security;
    }
    
    _isUserMakeConnect = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    _task_cancelled = YES;
    [self resetAllTimer];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Actions
- (void)hubbleItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 202) { // SSID
        
        NSInteger ssidTextLength = 0;
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        
        if (isBackSpace == -8)
        {
            ssidTextLength = textField.text.length - 1;
        }
        else {
            ssidTextLength = textField.text.length + string.length;
        }
        if (ssidTextLength > 0 && [self.tfPassword.text isEqualToString:self.tfConfirmPass.text]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.tintColor = nil;
        }
    }
    else if (textField.tag == 200) { // Password
        
        NSString *passString = @"";
        
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        
        if (isBackSpace == -8)
        {
            passString = [textField.text substringToIndex:textField.text.length - 1];
        }
        else {
            passString = [textField.text stringByAppendingString:string];
        }
        if (self.tfSSID.text.length > 0 && passString.length>0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.tintColor = nil;
        }
    }
    else if (textField.tag == 201) { // Confirm Password
        
        NSString *confirmPassString = @"";
        
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        
        if (isBackSpace == -8)
        {
            confirmPassString = [textField.text substringToIndex:textField.text.length - 1];
        }
        else {
            confirmPassString = [textField.text stringByAppendingString:string];
        }
        if (self.tfSSID.text.length > 0 && [self.tfPassword.text isEqualToString:confirmPassString]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.tintColor = nil;
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag !=202 ) // Dont move if it's the SSID name
    {
        [self animateTextField: textField up: YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag !=202 ) // Dont move if it's the SSID name
    {
        [self animateTextField: textField up: NO];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int movementDistance = 80; // tweak as needed
    
    const float movementDuration = 0.3f; // tweak as needed
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    
    if (textField.tag ==201 &&
        (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
         interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        ) //Confirm Password cell
    {
        movementDistance+= 40;
    }
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 200) //password
    {
        self.password = textField.text;
        //[self.tfConfirmPass becomeFirstResponder];
        [textField resignFirstResponder];
        return NO;
    }
    else if (textField.tag ==201) //conf password
    {
        [textField resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

#pragma  mark -
#pragma mark Table View delegate & datasource

#define SSID_SECTION 0
#define SEC_SECTION 1

#define SSID_INDEX 0

#define SEC_INDEX 0
#define PASSWORD_INDEX 1
#define CONFPASSWORD_INDEX 2

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int tag = tableView.tag;
    
    if (tag == 13)
    {
        if (indexPath.section == SSID_SECTION)
        {
            //only one cell in this section
            if (self.isOtherNetwork == TRUE)
            {
                UITextField *tfSsid  = (UITextField*) [ssidCell viewWithTag:202];
                
                [tfSsid setUserInteractionEnabled:TRUE];
            }
            return ssidCell;
        }
        else if (indexPath.section == SEC_SECTION)
        {
            if (indexPath.row == SEC_INDEX) {
                [self.securityCell setAccessoryType:UITableViewCellAccessoryNone];
                if (self.isOtherNetwork) {
                    [self.securityCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
                return securityCell;
            }
            if (indexPath.row == PASSWORD_INDEX)
            {
                return passwordCell;
            }
            if (indexPath.row == CONFPASSWORD_INDEX)
            {
                return confPasswordCell;
            }
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tag = tableView.tag;
    
    if (tag == 13)
    {
        if (section == SSID_SECTION)
            return 1;
        if (section == SEC_SECTION)
        {
            if ([self.security isEqualToString:@"open"] ||
                [self.security isEqualToString:@"none"])
            {
                return 1;
            }
            else
            {
                return 2;
            }
        }
    }
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int tag = tableView.tag;
    
    if (tag == 13)
    {
        return 2;
    }
    
    return 0;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
//    if ([self.ssid isEqualToString:@"Other Network"])
//    {
//        if (indexPath.section == SEC_SECTION)
//        {
//            if (indexPath.row == SEC_INDEX && self.isOtherNetwork)
//            {
//                [self changeSecurityType];
//            }
//        }
//    }
    
    if (indexPath.section == SSID_SECTION)
    {
        //only one cell in this section
        if (self.isOtherNetwork == TRUE)
        {
            UITextField *tfSsid  = (UITextField*) [ssidCell viewWithTag:202];
            [tfSsid setUserInteractionEnabled:TRUE];
            [tfSsid becomeFirstResponder];
        }
    }
    else if (indexPath.section == SEC_SECTION)
    {
        if (indexPath.row == PASSWORD_INDEX)
        {
            UITextField * txtField = (UITextField*) [passwordCell viewWithTag:200];
            [txtField becomeFirstResponder];
        }
        
        if (indexPath.row == CONFPASSWORD_INDEX)
        {
            UITextField * txtField = (UITextField*) [confPasswordCell viewWithTag:201];
            [txtField becomeFirstResponder];
        }
        else if (indexPath.row == SEC_INDEX && self.isOtherNetwork == TRUE)
        {
            [self changeSecurityType];
        }
    }
}

#pragma  mark -


-(void) changeSecurityType
{
    //load step 07
    NSLog(@"Load step 7");
    
    
    //Load the next xib
    Step_07_ViewController *step07ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        
        step07ViewController = [[Step_07_ViewController alloc]
                                initWithNibName:@"Step_07_ViewController_ipad" bundle:nil];
        
    }
    else
    {
        step07ViewController = [[Step_07_ViewController alloc]
                                initWithNibName:@"Step_07_ViewController" bundle:nil];
        
    }
    
    step07ViewController.step06 = self;
    [self.navigationController pushViewController:step07ViewController animated:NO];
    
    [step07ViewController release];
}

-(void) handleNextButton:(id) sender
{
    [[HoldOnCamWifi shareInstance] stopHolder];
    
    [[KISSMetricsAPI sharedAPI] recordEvent:@"Step06 - next button" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Touch Next button"
                                                     withLabel:@"Next"
                                                     withValue:nil];
    //create progressView for process verify network
    self.navigationItem.leftBarButtonItem.enabled = NO; // Disable go back
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.view addSubview:self.progressView];
    [self.progressView setHidden:NO];
    
    //check if password is ok?
    UITextField * my_ssid = (UITextField*) [self.ssidCell viewWithTag:202];
    
    [self.view endEditing:YES];
    
    NSLog(@"%s other: %d, security: %@", __FUNCTION__, self.isOtherNetwork, self.security);
    
    if (self.isOtherNetwork == TRUE)
    {
        if ([my_ssid.text length] == 0)
        {
            //error
            self.navigationItem.leftBarButtonItem.enabled = YES; // enable go back
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self.progressView removeFromSuperview];
            
            //ERROR condition
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:@"SSID cannot be empty"
                                   message:@"Please fill the SSID name and try again"
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [_alert show];
            [_alert release];
            return;
        }
        else
        {
            self.ssid = my_ssid.text;
        }
    }
    
    if ([self.security isEqualToString:@"open"])
    {
        //cont
        self.password = @""; // Purpose nil
        [self sendWifiInfoToCamera];
    }
    else
    {
        UITextField * pass = (UITextField*)[self.passwordCell viewWithTag:200];
        //UITextField * confpass = (UITextField*)[self.confPasswordCell viewWithTag:201];
        
        if ( [pass.text length] == 0 )
        {
            //error
            self.navigationItem.leftBarButtonItem.enabled = YES; // enable go back
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self.progressView removeFromSuperview];
            
           // NSString * msg_fail = NSLocalizedStringWithDefaultValue(@"Confirm_Pass_Fail", nil, [NSBundle mainBundle], @"Le mot de passe ne correspond pas. S'il vous plaît, saisir à nouveau !", nil);
            
            //ERROR condition
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:@"Password Failed"
                                   message:@"Please enter password"
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [_alert show];
            [_alert release];
            return;
        }
        else
        {
            //cont
            self.password = pass.text;
            [self sendWifiInfoToCamera ];
        }
    }
}

-(void) prepareWifiInfo
{
    //NOTE: we can do this because we are connecting to camera now
    NSString * camera_mac= nil;
    NSString *stringUDID = @"";
    

    stringUDID = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_UDID
                                                           withTimeout:5.0];
    //get_udid: 01008344334C32B0A0VFFRBSVA
    NSRange range = [stringUDID rangeOfString:@": "];
    
    if (range.location != NSNotFound)
    {
        //01008344334C32B0A0VFFRBSVA
        stringUDID = [stringUDID substringFromIndex:range.location + 2];
        camera_mac = [stringUDID substringWithRange:NSMakeRange(6, 12)];
        
        camera_mac = [Util add_colon_to_mac:camera_mac];
    }
    else
    {
        NSLog(@"Error - Received UDID wrong format - UDID: %@", stringUDID);
    }
    
    
    self.deviceConf.ssid = self.ssid;
    
    //save mac address for used later
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:camera_mac forKey:@"CameraMacWithQuote"];
    [userDefaults setObject:stringUDID forKey:CAMERA_UDID];
    [userDefaults synchronize];
    
    
    self.deviceConf.addressMode = @"DHCP";
    
    if ([self.security isEqualToString:@"wep"])
    {
        //@"Open",@"WEP", @"WPA-PSK/WPA2-PSK"
        self.deviceConf.securityMode = @"WEP";
        self.deviceConf.wepType = @"OPEN"; //default
        self.deviceConf.keyIndex = @"1"; //default;
    }
    else if( [self.security isEqualToString:@"wpa"])
    {
        self.deviceConf.securityMode = @"WPA-PSK/WPA2-PSK";
        
    }
    else if ([self.security isEqualToString:@"shared"])
    {
        self.deviceConf.securityMode = @"SHARED";
    }
    else {
        self.deviceConf.securityMode= @"OPEN";
    }
    
    NSLog(@"Log - udid: %@, %@", stringUDID, camera_mac);
    
    self.deviceConf.key = self.password;
    
    self.deviceConf.usrName = BASIC_AUTH_DEFAULT_USER;
    
    NSString* camPass = [CameraPassword getPasswordForCam:camera_mac];
    NSLog(@"Log - 02 cam password is : %@", camPass);
    
    if (camPass == nil ) //// default pass
    {
        camPass = @"00000000";
        NSLog(@"Log - 02 cam password is default: %@", camPass);
    }
    
    self.deviceConf.passWd = camPass;
}

-(void)sendWifiInfoToCamera
{
     NSString *response ;
    
    //and then disable user interaction
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION];
    
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    [formatter release];
    [stringFromDate insertString:@"." atIndex:3];
    
    NSLog(@"set auth -set_auth_cmd: %d ", [fwVersion compare:FW_MILESTONE_F66_NEW_FLOW]);
    
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step06 - Add camera fw: %@", fwVersion] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Send Wifi info to Camera-fw:%@", fwVersion]
                                                     withLabel:nil
                                                     withValue:nil];
     // >12.82 we can move on with new flow
    if  ([fwVersion compare:FW_MILESTONE_F66_NEW_FLOW] >= NSOrderedSame) //||
         //([fwVersion compare:FW_MILESTONE_F66_NEW_FLOW] == NSOrderedAscending) )
    {
         /** SEND auth data over first */
        NSString * set_auth_cmd = [NSString stringWithFormat:@"%@%@%@%@%@",
                                   SET_SERVER_AUTH,
                                   SET_SERVER_AUTH_PARAM1, apiKey,
                                   SET_SERVER_AUTH_PARAM2, stringFromDate];
        
      response = [[HttpCom instance].comWithDevice sendCommandAndBlock:set_auth_cmd
                                                                       withTimeout:10.0];
        NSLog(@"set auth -set_auth_cmd: %@, -response: %@ ", set_auth_cmd, response);
        
    }
    
    
    
    [self prepareWifiInfo];
    
    //Save and send
    if ( [_deviceConf isDataReadyForStoring])
    {
        [Util writeDeviceConfigurationData:[_deviceConf getWritableConfiguration]];
    }
    
    [_deviceConf restoreConfigurationData:[Util readDeviceConfiguration]];
    
    
    NSString * device_configuration = [_deviceConf getDeviceEncodedConfString];
    
    
    NSString * setup_cmd = [NSString stringWithFormat:@"%@%@",
                            SETUP_HTTP_CMD, device_configuration];
    
//    response = [[HttpCom instance].comWithDevice sendCommandAndBlock:setup_cmd ];
//    NSLog(@"Step_06VC - send cmd  %@ - response is: %@", setup_cmd, response);
    
     [self loopSetupWifiSending:setup_cmd retryTimes:0];
    
    // >12.82 we can move on with new flow
    if ([fwVersion compare:FW_MILESTONE_F66_NEW_FLOW] >= NSOrderedSame) // fw >= FW_MILESTONE_F66_NEW_FLOW
    {
        //Should check connect to camera here(after send command setup http)
        //Check app is already connected to camera which is setup or not, call once
        [NSTimer scheduledTimerWithTimeInterval: 3.0
                                         target:self
                                       selector:@selector(moveOnToCheckCameraOnlineStatus)
                                       userInfo:nil
                                        repeats:NO];
        response = [[HttpCom instance].comWithDevice sendCommandAndBlock:RESTART_HTTP_CMD];
        
        NSLog(@"%s RESTART_HTTP_CMD: %@", __FUNCTION__, response);
    }
    else
    {
        // popup force waiting..
        [NSTimer scheduledTimerWithTimeInterval: 3.0
                                         target:self
                                       selector:@selector(checkAppConnectToCameraAtStep03)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (BOOL)loopSetupWifiSending:(NSString *)setup_cmd retryTimes:(NSInteger)times
{
    if (times < RETRY_SETUP_WIFI_TIMES)
    {
        NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:setup_cmd];
        
        if (response != nil && [response isEqualToString:@"setup_wireless_save: 0"])
        {
            return TRUE;
        }
        
        NSLog(@"%s send cmd  %@ - response is: %@", __FUNCTION__, setup_cmd, response);//setup_wireless_save: 0
        times++;
        [self loopSetupWifiSending:setup_cmd retryTimes:times];
    }
    
    return FALSE;
}

-(void)moveOnToCheckCameraOnlineStatus
{
    [self resetAllTimer];
    [self nextStepVerifyPassword];
    [self.progressView removeFromSuperview];
    [self.infoSelectCameView removeFromSuperview];
    [self.progressView setHidden:YES];
}

- (void)checkAppConnectToCameraAtStep03
{
    [self.view bringSubviewToFront:self.progressView];
    [self.progressView setHidden:NO];
    NSString *currentSSID = [CameraPassword fetchSSIDInfo];
    NSLog(@"check App Connect To Camera At Step03 after sending wifi info");
    if (currentSSID == nil)
    {
        // check again
       
        if (_task_cancelled)
        {
            //handle when user press back
        }
        else
        {
            [NSTimer scheduledTimerWithTimeInterval: 3//
                                             target:self
                                           selector:@selector(checkAppConnectToCameraAtStep03)
                                           userInfo:nil
                                            repeats:NO];
            
            NSLog(@"Continue to check ssid after 3sec");
        }
        
    }
    else if ([self isAppConnectedToCamera])
    {
        NSLog(@"App connected with camera, start to get WIFI conn status...");
        [self.progressView setHidden:NO];
        [self.view bringSubviewToFront:self.progressView];
        [self getStatusOfCameraToWifi:nil];
        
    }
    else //currentSSID is not camera : this means app is kicked out
    {
        NSLog(@"App connected with %@ not camera, ask user to switch manually. " ,currentSSID );
        // show prompt to user select network camera again and handle next
        [self.progressView setHidden:YES];
        [self.infoSelectCameView setHidden:NO];
        [self.view bringSubviewToFront:self.infoSelectCameView];
    }
    
    
}

-(void) becomeActive
{
    //_task_cancelled = YES; //don't need
    //_isUserMakeConnect = YES; //don't need
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
    
    if (_deviceConf.ssid != nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_deviceConf.ssid  forKey:HOME_SSID];
        [userDefaults synchronize];
    }
    
    //Load the next xib
    
    Step_10_ViewController *step10ViewController = nil;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        
        step10ViewController = [[Step_10_ViewController alloc]
                                initWithNibName:@"Step_10_ViewController_ipad" bundle:nil];
    }
    else
    {
        
        step10ViewController = [[Step_10_ViewController alloc]
                                initWithNibName:@"Step_10_ViewController" bundle:nil];
    }
    
    [self.navigationController pushViewController:step10ViewController animated:NO];
    [step10ViewController release];
    
}



- (void)getStatusOfCameraToWifi:(NSTimer *)info
{
    NSString *commandGetState = GET_STATE_NETWORK_CAMERA;

    NSString *state = [[HttpCom instance].comWithDevice sendCommandAndBlock:commandGetState withTimeout:20.0];
    NSLog(@"getStatusOfCameraToWifi - command %@  response:%@", commandGetState,state);

    if (state != nil && [state length] > 0)
    {
        _currentStateCamera = [[state componentsSeparatedByString:@": "] objectAtIndex:1];
    }
    else
    {
        _currentStateCamera = @"";
    }
    
    if ([_currentStateCamera isEqualToString:@"CONNECTED"])
    {
        [self resetAllTimer];
        [self nextStepVerifyPassword];
        [self.progressView removeFromSuperview];
        [self.infoSelectCameView removeFromSuperview];
        [self.progressView setHidden:YES];
    }
    else
    {
        /*
         * Need to checkout current ssid here!
         */
        
        if (![self isAppConnectedToCamera])
        {
            NSLog(@"Step_06VC - current ssid is not a camera ssid !!!!! This check passed before coming here..");
            [self.infoSelectCameView setHidden:NO];
            [self.view bringSubviewToFront:self.infoSelectCameView];
        }
        else
        {
            // get state network of camera after 4s
            _inputPasswordTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0//
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
    
    if ([currentSSID isEqualToString:cameraSSID])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) restoreDataIfPossible
{
	NSDictionary * saved_data = [Util readDeviceConfiguration];
	
	if ( saved_data != nil)
	{
		[self.deviceConf restoreConfigurationData:saved_data];
		//populate the fields with stored data
		return TRUE;
	}
    
	return FALSE;
}

- (void)showDialogPasswordWrong
{
    NSLog(@"pass is wrong: %@ ", self.password);
    _timeOut = nil;
    [self resetAllTimer];
    [self.progressView setHidden:YES];
    NSString * msg_pw_wrong = @"Password input don't correctly, try again";
    //ERROR condition
    UIAlertView *alertViewPassword = [[UIAlertView alloc]
                           initWithTitle:@"Confirm Password Failed"
                           message:msg_pw_wrong
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"Ok", nil];
    alertViewPassword.tag = 101;
    [alertViewPassword show];
    [alertViewPassword release];
}

- (void)resetAllTimer
{
    if (_timeOut != nil)
    {
        [_timeOut invalidate];
        _timeOut = nil;
    }
    if (_inputPasswordTimer)
    {
        [_inputPasswordTimer invalidate];
        _inputPasswordTimer = nil;
    }
}




#pragma  mark -
#pragma  mark Dummy ota upgrade



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    int tag = alertView.tag;
    
    if (tag == 100)
    {
        ///any button - go back to camera list
        [UIApplication sharedApplication].idleTimerDisabled=  NO;
        
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else if(tag == 101)
    {
        if (buttonIndex == 0)
        {
            NSLog(@"ok");
            [self resetAllTimer];
            [self getStatusOfCameraToWifi:nil];
            _timeOut =  [NSTimer scheduledTimerWithTimeInterval: TIME_INPUT_PASSWORD_AGAIN// after 60s if not get successful
                                                         target:self
                                                       selector:@selector(showDialogPasswordWrong)
                                                       userInfo:nil
                                                        repeats:NO];
        }
        else
        {
            NSLog(@"cancel");
        }
    }
}

-(void) askUserToWaitForUpgrade
{
    [self resetAllTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    [UIApplication sharedApplication].idleTimerDisabled=  YES;
    
    
    [self.progressView removeFromSuperview];
    [self.infoSelectCameView removeFromSuperview];
    [self.progressView setHidden:YES];
    
    [self.view addSubview:self.otaDummyProgress];
    [self.view bringSubviewToFront:self.otaDummyProgress];
    self.otaDummyProgressBar.progress = 0.0;
    
	[self performSelectorInBackground:@selector(upgradeFwReboot_bg)  withObject:nil] ;
    
    
}

-(void) upgradeFwReboot_bg
{
	//percentageProgress.
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	//float totalTime  = 80.0; // 80 sec reboot time
    
	float sleepPeriod = 120.0 / 100; // 100 cycles
	int percentage = 0;
	while (percentage ++ < 100)
	{
        
        
		[self performSelectorOnMainThread:@selector(upgradeFwProgress_ui:)
                               withObject:[NSNumber numberWithInt:percentage]
                            waitUntilDone:YES];
        
		[NSThread sleepForTimeInterval:sleepPeriod];
        
	}
    
	[self performSelectorOnMainThread:@selector(goBackAndReaddCamera) withObject:nil waitUntilDone:NO];
	[pool release];
    
}

-(void) goBackAndReaddCamera
{
    //ERROR condition
    UIAlertView *alertViewBack = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedStringWithDefaultValue(@"Upgrade_done" ,nil, [NSBundle mainBundle],
                                                                          @"Upgrade Done" , nil)
                          message:@"Press OK to retry installing the camera."
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    alertViewBack.tag = 100;
    [alertViewBack show];
    [alertViewBack release];
}

-(void) upgradeFwProgress_ui:(NSNumber *) number
{
	int value =  [number intValue];
	float _value = (float) value;
	_value = _value/100.0;
    
	if (value >=0)
	{
		self.otaDummyProgressBar.progress = _value;
	}
    
}




@end
