//
//  Step_06_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_06_ViewController.h"
#define TIME_INPUT_PASSWORD_AGAIN   60.0
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
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.progressView setHidden:YES];
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Enter_Network_Information",nil, [NSBundle mainBundle],
                                                                  @"Enter Network Information" , nil);
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                               @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    
    
    
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
    
    
    UIBarButtonItem *nextButton = 
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Next",nil, [NSBundle mainBundle],
                                                                             @"Next" , nil)

                                     style:UIBarButtonItemStylePlain 
                                    target:self 
                                    action:@selector(handleNextButton:)];          
    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [nextButton release];
        
    /* initialize transient object here */
	self.deviceConf = [[[DeviceConfiguration alloc] init] autorelease];
	
	
    if (![self restoreDataIfPossible] )
	{
		//Try to read the ssid from preference: 
        self.deviceConf.ssid = self.ssid; 
    }
    
    self.tfSSID = (UITextField *)[self.ssidCell viewWithTag:202];
    if (self.tfSSID.text.length > 0) {
        self.navigationItem.rightBarButtonItem .enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }
    self.tfPassword = (UITextField *)[self.passwordCell viewWithTag:200];
    self.tfConfirmPass = (UITextField *)[self.confPasswordCell viewWithTag:201];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self resetAllTimer];
}

-(void) viewWillAppear:(BOOL)animated
{
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
    
    NSLog(@"update security type");
    UITextField * _sec = (UITextField *) [self.securityCell viewWithTag:1];
    if (_sec != nil)
    {
        _sec.text = self.security; 
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resetAllTimer];
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
        if (self.tfSSID.text.length > 0 && [passString isEqualToString:self.tfConfirmPass.text]) {
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
#if 0
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        
    }
#endif
    
    
    //Resign all keyboard...
    UITextField * textField = nil;
    
    textField = (UITextField *) [self.view viewWithTag:200];
    if(textField != nil)
    {
        [textField resignFirstResponder]; 
    }
    
    textField = (UITextField *) [self.view viewWithTag:201];
    if(textField != nil)
    {
        [textField resignFirstResponder];
    }
    
    textField = (UITextField *) [self.view viewWithTag:202];
    if(textField != nil)
    {
        [textField resignFirstResponder];
    }
    
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
                return 3; 
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
    
    if ([self.ssid isEqualToString:@"Other Network"])
    {
    
        if (indexPath.section == SEC_SECTION)
        {
            if (indexPath.row == SEC_INDEX) 
            {
                [self changeSecurityType];
                
            }
        }
    }
    
    
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
    //create progressView for process verify network
    [self.view addSubview:self.progressView];
    [self.progressView setHidden:NO];
    //check if password is ok?
    UITextField  * pass = (UITextField*)[self.passwordCell viewWithTag:200];
    UITextField  * confpass = (UITextField*)[self.confPasswordCell viewWithTag:201];
    UITextField * my_ssid = (UITextField*) [self.ssidCell viewWithTag:202];
    
    [pass resignFirstResponder];
    [confpass resignFirstResponder];
    [my_ssid resignFirstResponder];
    NSLog(@"pass : %@ vs %@  ssid: %@", pass.text, confpass.text, my_ssid.text);

    if (self.isOtherNetwork == TRUE)
    {
        
        if ([my_ssid.text length] == 0)
        {
            //error
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
        [self sendWifiInfoToCamera ];
    }
    else 
    {
        
        if ( ([pass.text length] == 0 ) ||
            ( [confpass.text length] ==0 ) ||
            (![pass.text isEqualToString:confpass.text]))
        {
            //error
            
            NSString * msg_fail = NSLocalizedStringWithDefaultValue(@"Confirm_Pass_Fail", nil, [NSBundle mainBundle], @"Le mot de passe ne correspond pas. S'il vous plaît, saisir à nouveau !", nil);
            
            //ERROR condition
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:@"Confirm Password Failed"
                                   message:msg_fail 
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
            self.password = [NSString stringWithString:[pass text]];
            NSLog(@"password is : %@", self.password);
            [self sendWifiInfoToCamera ];
            
        }
    }
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
        [textField resignFirstResponder];
        return NO;
    }
    else if (textField.tag ==201) //conf password
    {
#if 0
        NSString * confpass = textField.text; 
        if (![confpass isEqualToString:self.password])
        {
         
            NSLog(@"pass not match: %@ vs %@", confpass, self.password);

            NSString * msg_fail = NSLocalizedStringWithDefaultValue(@"Confirm_Pass_Fail", nil, [NSBundle mainBundle], @"Le mot de passe ne correspond pas. S'il vous plaît, saisir à nouveau !", nil);
            //ERROR condition
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:@"Confirm Password Failed"
                                   message:msg_fail
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [_alert show];
            [_alert release];
        }
#endif 
        [textField resignFirstResponder];
        
        return NO;
        
    }
    else
    {
        [textField resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

-(void) prepareWifiInfo
{
    //NOTE: we can do this because we are connecting to camera now 
    NSString * camera_mac= nil;
    NSString *stringUDID = @"";

#ifdef CONCURRENT_SETUP
    stringUDID = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_UDID
                                                withTimeout:5.0];
    //01008344334C32B0A0VFFRBSVA
    camera_mac = [stringUDID substringWithRange:NSMakeRange(6, 12)];
    
    camera_mac = [Util add_colon_to_mac:camera_mac];
#else
    camera_mac = [CameraPassword fetchBSSIDInfo];
#endif

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
    else {
        self.deviceConf.securityMode= @"OPEN";
    }
   
    
    self.deviceConf.key = self.password; 
    
    self.deviceConf.usrName = BASIC_AUTH_DEFAULT_USER;
    NSLog(@"02 cam password is : %@", [CameraPassword getPasswordForCam:camera_mac]);
    NSString* camPass = [CameraPassword getPasswordForCam:camera_mac]; 
    
    if (camPass == nil ) //// default pass
    {
        camPass = @"000000";
        NSLog(@"02 cam password is default: %@", camPass);
    }
    
    
    self.deviceConf.passWd = camPass;
    
}

-(void)sendWifiInfoToCamera
{
    [self prepareWifiInfo]; 
    
    //Save and send 
    if ( [_deviceConf isDataReadyForStoring])
    {
        NSLog(@"ok to save ");
        [Util writeDeviceConfigurationData:[_deviceConf getWritableConfiguration]];
    }

    
    NSLog(@"SSID: %@   - %@", self.ssid, self.deviceConf.ssid );
    
//    DeviceConfiguration * sent_conf = [[DeviceConfiguration alloc] init];
    
    [_deviceConf restoreConfigurationData:[Util readDeviceConfiguration]];
    
    
    NSString *deviceCodec = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_CODECS_SUPPORT
                                withTimeout:5.0];
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceCodec  forKey:CODEC_PREFS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
     NSString * device_configuration = [_deviceConf getDeviceEncodedConfString];
    
    
    NSString * setup_cmd = [NSString stringWithFormat:@"%@%@",
                            SETUP_HTTP_CMD,device_configuration];
    
	NSLog(@"Log - before send: %@", setup_cmd);
    
	//NSString * response =
    [[HttpCom instance].comWithDevice sendCommandAndBlock:setup_cmd ];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0//
                                     target:self
                                   selector:@selector(getStatusOfCameraToWifi:)
                                   userInfo:nil
                                    repeats:NO];
//    _timeOut =  [NSTimer scheduledTimerWithTimeInterval: TIME_INPUT_PASSWORD_AGAIN// after 60s if not get successful
//                                                 target:self
//                                               selector:@selector(showDialogPasswordWrong)
//                                               userInfo:nil
//                                                repeats:NO];
    
    NSLog(@"Don't Send & reset done");
}

- (void)nextStepVerifyPassword
{
    BOOL isFirstTimeSetup = [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_TIME_SETUP];
    
    
    if (isFirstTimeSetup   == TRUE)
    {
        
        
        //load step 08
        NSLog(@"Load step 8");
        //Load the next xib
        Step_08_ViewController *step08ViewController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            step08ViewController = [[Step_08_ViewController alloc]
                                    initWithNibName:@"Step_08_ViewController_ipad" bundle:nil];
            
            
            
        }
        else
        {
            step08ViewController = [[Step_08_ViewController alloc]
                                    initWithNibName:@"Step_08_ViewController" bundle:nil];
        }
        step08ViewController.ssid = _deviceConf.ssid;
        [self.navigationController pushViewController:step08ViewController animated:NO];
        
        [step08ViewController release];
        
    }
    else
    {
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
}
- (void)getStatusOfCameraToWifi:(NSTimer *)info
{
//    NSString * currentSSID = [CameraPassword fetchSSIDInfo];
    NSString *commandGetState = GET_STATE_NETWORK_CAMERA;
    NSLog(@"command is %@", commandGetState);
    NSString *state = [[HttpCom instance].comWithDevice sendCommandAndBlock:commandGetState withTimeout:20.0];
    if (state != nil && [state length] > 0)
    {
        _currentStateCamera = [[state componentsSeparatedByString:@": "] objectAtIndex:1];
    }
    else{
        _currentStateCamera = @"";
    }

    NSLog(@"_currentStateCamera is %@", _currentStateCamera);
    
    if ([_currentStateCamera isEqualToString:@"CONNECTED"])
    {
        [self resetAllTimer];
        [self nextStepVerifyPassword];
        [self.progressView removeFromSuperview];
        [self.progressView setHidden:YES];
    }
    else{
        // get state network of camera after 4s
        _inputPasswordTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0//
                                                               target:self
                                                             selector:@selector(getStatusOfCameraToWifi:)
                                                             userInfo:nil
                                                              repeats:NO];
    }

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
    UIAlertView *_alert = [[UIAlertView alloc]
                           initWithTitle:@"Confirm Password Failed"
                           message:msg_pw_wrong
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"Ok", nil];
    [_alert show];
    [_alert release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
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
@end
