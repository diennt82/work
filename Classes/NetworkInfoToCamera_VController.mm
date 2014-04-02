//
//  Step_06_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "NetworkInfoToCamera_VController.h"
#import "Step_10_ViewController_ble.h"
#import "define.h"

@interface NetworkInfoToCamera_VController () <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIView *viewProgress;
@property (retain, nonatomic) UITextField *tfSSID;
@property (retain, nonatomic) UITextField *tfPassword;
@property (retain, nonatomic) UITextField *tfConfirmPass;

@end

@implementation NetworkInfoToCamera_VController

@synthesize securityCell, ssidCell, passwordCell, confPasswordCell;

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
    [_ib_dialogVerifyNetwork release];
    [_viewProgress release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Enter_Network_Information",nil, [NSBundle mainBundle],
                                                                  @"Enter Network Information" , nil);
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                               @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    self.navigationItem.hidesBackButton = NO;
    
    UIImageView *imageView = (UIImageView *)[_viewProgress viewWithTag:595];
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
    
    
    UIBarButtonItem *nextButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Next",nil, [NSBundle mainBundle],
                                                                             @"Next" , nil)
     
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleNextButton:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [nextButton release];
    
    self.tfSSID = (UITextField *)[self.ssidCell viewWithTag:202];
    if (self.tfSSID.text.length > 0)
    {
        self.navigationItem.rightBarButtonItem .enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }
    
    self.tfPassword = (UITextField *)[self.passwordCell viewWithTag:200];
    self.tfPassword.delegate = self;
    
    self.tfConfirmPass = (UITextField *)[self.confPasswordCell viewWithTag:201];
    self.tfConfirmPass.delegate = self;
    
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
        
        NSLog(@"NetworkInfoToCamera_VController - viewDidLoad - deviceConf.ssid: %@, - self.ssid: %@, - self.security: %@", self.deviceConf.ssid, self.ssid, self.security);
        
        if ([self.deviceConf.ssid isEqualToString:self.ssid] &&
            ([self.security isEqualToString:@"wep"] || [self.security isEqualToString:@"wpa"]))
        {
            self.tfPassword.text = self.deviceConf.key;
            self.tfConfirmPass.text = self.deviceConf.key;
        }
    }
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
}

- (void)viewDidUnload
{
    [self setIb_dialogVerifyNetwork:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    //remove delegate
    [BLEConnectionManager getInstanceBLE].delegate = nil;
    
    [super viewWillDisappear:animated];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.viewProgress.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    }
    
    NSLog(@"update security type");
    UITextField * _sec = (UITextField *) [self.securityCell viewWithTag:1];
    if (_sec != nil)
    {
        _sec.text = self.security;
    }
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
        [self.tfConfirmPass becomeFirstResponder];
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

- (void)hideAllKeyboard
{
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
    //    Step_07_ViewController *step07ViewController = nil;
    //
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    //    {
    //
    //
    //        step07ViewController = [[Step_07_ViewController alloc]
    //                                initWithNibName:@"Step_07_ViewController_ipad" bundle:nil];
    //
    //    }
    //    else
    //    {
    //        step07ViewController = [[Step_07_ViewController alloc]
    //                                initWithNibName:@"Step_07_ViewController" bundle:nil];
    //
    //    }
    //
    //    step07ViewController.step06 = self;
    //    [self.navigationController pushViewController:step07ViewController animated:NO];
    //
    //    [step07ViewController release];
    
}



-(void) handleNextButton:(id) sender
{
    //check if password is ok?
    UITextField  * pass = (UITextField*)[self.passwordCell viewWithTag:200];
    UITextField  * confpass = (UITextField*)[self.confPasswordCell viewWithTag:201];
    UITextField * my_ssid = (UITextField*) [self.ssidCell viewWithTag:202];
    
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
        [self sendWifiInfoToCamera];
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
            //NSLog(@"password is : %@", self.password);
            [self sendWifiInfoToCamera ];
        }
    }
}

-(void) prepareWifiInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *camera_mac = [userDefaults objectForKey:@"CameraMacSave"];
    NSLog(@"Check camera_mac is %@", camera_mac);
    self.deviceConf.ssid = self.ssid;
    
    //save mac address for used later
    [userDefaults setObject: [Util add_colon_to_mac:camera_mac] forKey:@"CameraMacWithQuote"];
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
    else
    {
        self.deviceConf.securityMode= @"OPEN";
    }
    
    self.deviceConf.key = self.password;
    
    self.deviceConf.usrName = BASIC_AUTH_DEFAULT_USER;
    NSLog(@"02 cam password is : %@", [CameraPassword getPasswordForCam:camera_mac]);
    NSString* camPass = [CameraPassword getPasswordForCam:camera_mac];
    
    if (camPass == nil ) //// default pass
    {
        camPass = @"00000000";
        NSLog(@"02 cam password is default: %@", camPass);
    }
    
    self.deviceConf.passWd = camPass;
}

#pragma mark - BLEConnectionManagerDelegate

- (void) didReceiveBLEList:(NSMutableArray *)bleLists
{
        NSLog(@"NWINFO : rescan completed ");
   CBPeripheral * ble_uart = (CBPeripheral *)[[BLEConnectionManager getInstanceBLE].listBLEs objectAtIndex:0];
    
    [[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:ble_uart];
}


-(void) bleDisconnected
{
    NSLog(@"NWINFO : BLE device is DISCONNECTED - Reconnect after 2s - state: %d", stage);
    
    NSDate * date;
    date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
//    [NSTimer scheduledTimerWithTimeInterval:TIME_OUT_RECONNECT_BLE target:self selector:@selector(dialogFailConnection:) userInfo:nil repeats:NO];

    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    //[[BLEConnectionManager getInstanceBLE] reinit];
    
    [[BLEConnectionManager getInstanceBLE] reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
}

- (void)dialogFailConnection:(NSTimer *)timer
{
    if ([BLEConnectionManager getInstanceBLE].state == CONNECTED)
    {
        //Check after TIME_OUT_RECONNECT_BLE seconds, if connected retrun
        return;
    }
    //show info
    NSString * msg =  @"Camera (ble) is disconnected abruptly, please retry adding camera again";
    
    
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
    
    
    UIAlertView *_myAlert = nil ;
    _myAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                          message:msg
                                         delegate:self
                                cancelButtonTitle:ok
                                otherButtonTitles:nil];
    
    _myAlert.tag = RETRY_CONNECTION_BLE_FAIL_TAG;
    _myAlert.delegate = self;
    [_myAlert release];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == RETRY_CONNECTION_BLE_FAIL_TAG)
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void) didConnectToBle:(CBUUID*) service_id
{
    NSLog(@"BLE device connected - now, last stage: %d", stage);
    
    switch (stage)
    {
        case SENT_WIFI:
        case CHECKING_WIFI:
            NSLog(@"checking wifi status");
            [self readWifiStatusOfCamera:nil];
            break;
            
        case INIT:
            NSLog(@"start over!!");
            [self sendWifiInfoToCamera];
            break;
    }
}

- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera
{
    NSLog(@"NetworkInfo - onReceiveDataError: %d, cmd: %@", error_code, commandToCamera);
}

- (void)didReceiveData:(NSString *)string
{
    NSLog(@"NetworkInfoToCameraVC - didReceiveData: %@", string);
    
    if ([string hasPrefix:@"setup_wireless_save"])
    {
        stage = SENT_WIFI;
        
        NSLog(@"Finishing SETUP_HTTP_COMMAND");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self readWifiStatusOfCamera:nil];
        });
    }
    else if ([string hasPrefix:GET_STATE_NETWORK_CAMERA])
    {
        stage = CHECKING_WIFI;
        
        NSLog(@"Recv: %@", string);
        NSString *state = string;
        NSString *_currentStateCamera;
     
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
            dispatch_async(dispatch_get_main_queue(), ^{
                //CONNECTED... Move on now..
                [self sendCommandRestartSystem];
                
                [self showNextScreen];
                [self.view setUserInteractionEnabled:YES];
                [self.navigationController.navigationBar setUserInteractionEnabled:YES];
                
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // get state network of camera after 4s
                [NSTimer scheduledTimerWithTimeInterval: 2.0//
                                                 target:self
                                               selector:@selector(readWifiStatusOfCamera:)
                                               userInfo:nil
                                                repeats:NO];
                
            });
            
        }
        
        
    }
    else if ([string hasPrefix:RESTART_HTTP_CMD])
    {
        NSLog(@"Finishing RESTART_HTTP_CMD");
    }
    else
    {
        NSLog(@"Receive un-expected data, Try to findout what to do next?");
        
        switch (stage)
        {
            case SENT_WIFI:
            case CHECKING_WIFI:
                NSLog(@"checking wifi status");
                [self readWifiStatusOfCamera:nil];
                break;
                
            case INIT:
                NSLog(@"start over!!");
                [self sendWifiInfoToCamera];
                break;
        }
        
        
    }
    
}

#pragma mark - Methods

- (void)sendCommandRestartSystem
{
    NSLog(@"Send RESTART Command, now");
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:RESTART_HTTP_CMD withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    NSDate * date;
    
    if ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy  )
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
        if([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy  )
        {
            NSLog(@"BLE still busy, camera may have already rebooted. Moving on..");
        }
    }
}

- (BOOL)sendCommandHTTPSetup
{
    NSLog(@"Send command SETUP HTTP Command, now");
    if ([BLEConnectionManager getInstanceBLE].state != CONNECTED)
    {
        NSLog(@"sendCommandHTTPSetup:  BLE disconnected - stage: %d", stage);
        return FALSE;
    }
    
    //send next command
    DeviceConfiguration * sent_conf = [[DeviceConfiguration alloc] init];
    
    [sent_conf restoreConfigurationData:[Util readDeviceConfiguration]];
    NSString * conf = [sent_conf getDeviceEncodedConfString];
    
    NSString * cmmd = [NSString stringWithFormat:@"%@%@", SETUP_HTTP_CMD, conf];
    
    //send cmd to Device
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:cmmd withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    [sent_conf release];
    NSDate * date;
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    NSLog(@"After sending Save Wireless wait for 3sec, after that - return TRUE");
    date = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    
    return TRUE;
}

- (BOOL)sendCommandCodecSupport
{
    NSLog(@"now, Send command get code support!!!!");
    if ([BLEConnectionManager getInstanceBLE].state != CONNECTED)
    {
        NSLog(@"sendCommandCodecSupport:  BLE disconnected - ");
        return FALSE;
    }
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_CODECS_SUPPORT withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    NSDate * date;
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    return TRUE;
}

-(void)sendWifiInfoToCamera
{
    [self.view endEditing:YES];
    //will hide keyboard
    //[self hideAllKeyboard];
    //should hide back in navigation bar
    self.navigationItem.hidesBackButton = YES;
    // should be show dialog here, make sure user input username and password
    //[self.ib_dialogVerifyNetwork setHidden:NO];
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    //and then disable user interaction
    [self.view setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    [self prepareWifiInfo];
    
    //Save and send
    if ( [_deviceConf isDataReadyForStoring])
    {
        [Util writeDeviceConfigurationData:[_deviceConf getWritableConfiguration]];
    }

    stage = INIT;

    [BLEConnectionManager getInstanceBLE].delegate = self;
    
    if ([self sendCommandHTTPSetup])
    {
        /*
         * Move cmd below to didReceiveData: delegate
         */
        
        //stage = SENT_WIFI;
        
        //[self readWifiStatusOfCamera:nil];
    }
}

-(void) readWifiStatusOfCamera:(NSTimer *) exp
{
    NSLog(@"now,readWifiStatusOfCamera");
    
    if ([BLEConnectionManager getInstanceBLE].state != CONNECTED)
    {
        NSLog(@"NITC_VC - readWifiStatusOfCamera - BLE disconnected - stage: %d", stage);
        return ;
    }
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_STATE_NETWORK_CAMERA withTimeOut:LONG_TIME_OUT_SEND_COMMAND];
    
    NSLog(@"Finished sending: %@",GET_STATE_NETWORK_CAMERA);
    
    
    /*
     * Move cmd below to didReceiveData: delegate
     */
    //stage = CHECKING_WIFI;
    
    NSDate * date;
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
        NSLog(@"NetworkInfo_VC - readWifiStatusOfCamera BLE isBusy");
    }
}

- (void) showNextScreen
{
    
    NSLog(@"NetworkInfo - SSID: %@   - %@", self.ssid, self.deviceConf.ssid );
    
    DeviceConfiguration * sent_conf = [[DeviceConfiguration alloc] init];
    
    [sent_conf restoreConfigurationData:[Util readDeviceConfiguration]];
    
    //load step 10
    
    NSLog(@"Load Step 10");
    //[self.ib_dialogVerifyNetwork setHidden:YES];
    [_viewProgress removeFromSuperview];
    if (sent_conf.ssid != nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:sent_conf.ssid  forKey:HOME_SSID];
        [userDefaults synchronize];
    }
    
    //Load the next xib
    
    Step_10_ViewController_ble *step10ViewController = [[Step_10_ViewController_ble alloc]
                                initWithNibName:@"Step_10_ViewController_ble" bundle:nil];
    
    [self.navigationController pushViewController:step10ViewController animated:NO];
    [step10ViewController release];
    
    [sent_conf release];
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

@end
