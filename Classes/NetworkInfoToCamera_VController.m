//
//  Step_06_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>

#import "NetworkInfoToCamera_VController.h"
#import "Step_10_ViewController_ble.h"
#import "PublicDefine.h"
#import "define.h"
#import "Util.h"

#define BTN_CONTINUE_TAG    599
#define BTN_TRY_AGAIN_TAG   559
#define BLE_TIMEOUT_PROCESS 4*60.0

@interface NetworkInfoToCamera_VController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *viewProgress;
@property (nonatomic, weak) IBOutlet UIView *viewError;

@property (nonatomic, strong) UITextField *tfSSID;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UITextField *tfConfirmPass;

@property (nonatomic, strong) NSTimer *timerTimeoutConnectBLE;
@property (nonatomic, strong) UIButton *btnContinue;
@property (nonatomic, strong) UIButton *btnTryAgain;

@property (nonatomic, copy) NSString *statusNetworkCamString;
@property (nonatomic) BOOL shouldTimeoutProcessing;
@property (nonatomic) int stage;

@end

@implementation NetworkInfoToCamera_VController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Enter_Network_Information",nil, [NSBundle mainBundle],
                                                                  @"Enter Network Information" , nil);
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                               @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil];
    self.navigationItem.hidesBackButton = NO;
    
    self.btnContinue = (UIButton *)[_viewError viewWithTag:BTN_CONTINUE_TAG];
    [_btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    [_btnContinue addTarget:self action:@selector(btnContinueTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnTryAgain = (UIButton *)[_viewError viewWithTag:BTN_TRY_AGAIN_TAG];
    [_btnTryAgain setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_btnTryAgain setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    [_btnTryAgain addTarget:self action:@selector(btnTryAgainTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    if ( !_ssid ) {
        NSLog(@"empty SSID ");
    }
    
    if ( !_security ) {
        NSLog(@"empty security ");
    }
    
    UITextField *tfSsid = (UITextField *)[_ssidCell viewWithTag:202];
    if (tfSsid && !_isOtherNetwork ) {
        tfSsid.text = _ssid;
    }
    
    UITextField *_sec = (UITextField *)[_securityCell viewWithTag:1];
    _sec.text = _security;
    
    UIBarButtonItem *nextButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Next",nil, [NSBundle mainBundle],
                                                                             @"Next" , nil)
     
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleNextButton:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.tfSSID = (UITextField *)[_ssidCell viewWithTag:202];
    
    if ( _tfSSID.text.length > 0 && ([_security isEqualToString:@"None"] || [_security isEqualToString:@"open"]) ) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    self.tfPassword = (UITextField *)[_passwordCell viewWithTag:200];
    _tfPassword.delegate = self;
    
    self.tfConfirmPass = (UITextField *)[_confPasswordCell viewWithTag:201];
    _tfConfirmPass.delegate = self;
    
    /* initialize transient object here */
	self.deviceConf = [[DeviceConfiguration alloc] init];
	
    if ( ![self restoreDataIfPossible] ) {
		//Try to read the ssid from preference:
        self.deviceConf.ssid = _ssid;
    }
    else {
        /*
         * 1. Check deviceConf.ssid vs self.ssid
         * 2. check sec type : OPEN , WeP, wpa
         * 3. If ( =)  -> prefill pass- deviceConf.key  to  password/conf password text field
         */
        
        NSLog(@"%s - deviceConf.ssid: %@, - self.ssid: %@, - self.security: %@", __FUNCTION__, self.deviceConf.ssid, self.ssid, self.security);
        
        if ( [_deviceConf.ssid isEqualToString:_ssid] &&
            ([_security isEqualToString:@"wep"] || [_security isEqualToString:@"wpa"]) )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            _tfPassword.text = _deviceConf.key;
            _tfConfirmPass.text = _deviceConf.key;
        }
    }
    
    [BLEConnectionManager.instanceBLE setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _viewProgress.frame = rect;
        _viewError.frame = rect;
    }
    
    NSLog(@"update security type");
    UITextField * _sec = (UITextField *)[self.securityCell viewWithTag:1];
    _sec.text = _security;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setIb_dialogVerifyNetwork:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //remove delegate
    [BLEConnectionManager.instanceBLE setDelegate:nil];
}


#pragma mark - Actions

- (IBAction)btnTryAgainTouchUpInsideAction:(UIButton *)sender
{
    sender.enabled = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 202) {
        // SSID
        NSInteger ssidTextLength = 0;
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        
        if (isBackSpace == -8) {
            ssidTextLength = textField.text.length - 1;
        }
        else {
            ssidTextLength = textField.text.length + string.length;
        }
        if (ssidTextLength > 0 && [self.tfPassword.text isEqualToString:self.tfConfirmPass.text]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else if (textField.tag == 200) {
        // Password
        NSString *passString = @"";
        const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(ch, "\b");
        
        if (isBackSpace == -8) {
            passString = [textField.text substringToIndex:textField.text.length - 1];
        }
        else {
            passString = [textField.text stringByAppendingString:string];
        }
        if (self.tfSSID.text.length > 0 && [passString isEqualToString:self.tfConfirmPass.text]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else if (textField.tag == 201) {
        // Confirm Password
        NSString *confirmPassString = @"";
        
        const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(ch, "\b");
        
        if (isBackSpace == -8) {
            confirmPassString = [textField.text substringToIndex:textField.text.length - 1];
        }
        else {
            confirmPassString = [textField.text stringByAppendingString:string];
        }
        if (self.tfSSID.text.length > 0 && [self.tfPassword.text isEqualToString:confirmPassString]) {
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
    if ( textField.tag != 202 ) {
        // Dont move if it's the SSID name
        [self animateTextField: textField up: YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ( textField.tag != 202 ){
        // Dont move if it's the SSID name
        [self animateTextField: textField up: NO];
    }
}

- (void)animateTextField:(UITextField *)textField up:(BOOL)up
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField.tag == 200 ) {
        // password
        self.password = textField.text;
        [self.tfConfirmPass becomeFirstResponder];
    }
    else if ( textField.tag ==201 ) {
        //conf password
        [textField resignFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)hideAllKeyboard
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:200];
    if ( textField ) {
        [textField resignFirstResponder];
    }
    
    textField = (UITextField *)[self.view viewWithTag:201];
    if( textField ) {
        [textField resignFirstResponder];
    }
    
    textField = (UITextField *)[self.view viewWithTag:202];
    if( textField ) {
        [textField resignFirstResponder];
    }
}

#pragma  mark - Table View delegate & datasource

#define SSID_SECTION 0
#define SEC_SECTION 1

#define SSID_INDEX 0

#define SEC_INDEX 0
#define PASSWORD_INDEX 1
#define CONFPASSWORD_INDEX 2

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    int tag = tableView.tag;
    
    if (tag == 13) {
        if (indexPath.section == SSID_SECTION) {
            // only one cell in this section
            if ( _isOtherNetwork ) {
                UITextField *tfSsid  = (UITextField *)[_ssidCell viewWithTag:202];
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
    
    return cell;
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
                return 3;
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
            UITextField *tfSsid  = (UITextField*)[_ssidCell viewWithTag:202];
            [tfSsid setUserInteractionEnabled:YES];
            [tfSsid becomeFirstResponder];
        }
    }
    else if (indexPath.section == SEC_SECTION)
    {
        if (indexPath.row == PASSWORD_INDEX) {
            UITextField * txtField = (UITextField*)[_passwordCell viewWithTag:200];
            [txtField becomeFirstResponder];
        }
        if (indexPath.row == CONFPASSWORD_INDEX)
        {
            UITextField * txtField = (UITextField*)[_confPasswordCell viewWithTag:201];
            [txtField becomeFirstResponder];
        }
    }
}

#pragma mark -

- (void)changeSecurityType
{
    //load step 07
    NSLog(@"Load step 7");
}

- (void)handleNextButton:(id)sender
{
    //check if password is ok?
    UITextField *my_ssid = (UITextField*)[_ssidCell viewWithTag:202];
    NSLog(@"%s other: %d, security: %@", __FUNCTION__, _isOtherNetwork, _security);
    
    if ( _isOtherNetwork ) {
        if ([my_ssid.text length] == 0) {
            // ERROR condition
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:@"SSID cannot be empty"
                                   message:@"Please fill the SSID name and try again"
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [_alert show];
            
            return;
        }
        else {
            self.ssid = my_ssid.text;
        }
    }
    
    if ([_security isEqualToString:@"open"])
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        /* Start timer to check for camera connection issue */
        self.timerTimeoutConnectBLE  = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                       target:self
                                                     selector:@selector(timeoutBLESetupProcessing:)
                                                     userInfo:nil
                                                      repeats:NO];
        
        /* Blocking call, after this return the camera should be either added or failed setup already */
        self.password = @"";
        [self sendWifiInfoToCamera];
    }
    else {
        UITextField *pass = (UITextField *)[_passwordCell viewWithTag:200];
        UITextField *confpass = (UITextField *)[_confPasswordCell viewWithTag:201];
        
        if ( [pass.text length] == 0 ||
            [confpass.text length] ==0 ||
            ![pass.text isEqualToString:confpass.text] )
        {
            // ERROR condition
            NSString *msg_fail = NSLocalizedStringWithDefaultValue(@"Confirm_Pass_Fail", nil, [NSBundle mainBundle], @"Le mot de passe ne correspond pas. S'il vous plaît, saisir à nouveau !", nil);
            UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Confirm Password Failed"
                                   message:msg_fail
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [alert show];
            return;
        }
        else {
            //cont
            self.password = [NSString stringWithString:[pass text]];
            NSLog(@"NetworkInfo - handleNextButton - Create time out ble setup process");
            
            self.navigationItem.rightBarButtonItem.enabled = NO;

            /* Start timer to check for camera connection issue */
            self.timerTimeoutConnectBLE  = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                           target:self
                                                         selector:@selector(timeoutBLESetupProcessing:)
                                                         userInfo:nil
                                                          repeats:NO];
            
            /* Blocking call, after this return the camera should be either added or failed setup already */
            [self sendWifiInfoToCamera ];
        }
    }
}

- (void)timeoutBLESetupProcessing:(NSTimer *)timer
{
    self.view.userInteractionEnabled = YES;
    self.shouldTimeoutProcessing = YES;
    
    // disconnect to BLE and return to guide screen.
    if (BLEConnectionManager.instanceBLE.state == CONNECTED) {
        BLEConnectionManager.instanceBLE.needReconnect = NO;
        [BLEConnectionManager.instanceBLE stopScanBLE];
        [self disconnectToBLE];
    }
    else {
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:@selector(removeCamSuccessWithResponse:)
                                                                              FailSelector:@selector(removeCamFailedWithError:)
                                                                                 ServerErr:@selector(removeCamFailedServerUnreachable)];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *stringUDID = [userDefaults stringForKey:CAMERA_UDID];
        NSString *apiKey     = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSLog(@"NetworkInfo - timeoutBLESetupProcessing - try to remove camera");
        
        [jsonComm deleteDeviceBlockedWithRegistrationId:stringUDID andApiKey:apiKey];
        
        [_viewProgress removeFromSuperview];
        
        [self.view addSubview:_viewError];
        [self.view bringSubviewToFront:_viewError];
    }
}

- (void)prepareWifiInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *cameraMac = [userDefaults objectForKey:@"CameraMacSave"];
    NSLog(@"Check camera_mac is %@", cameraMac);
    self.deviceConf.ssid = self.ssid;
    
    //save mac address for used later
    [userDefaults setObject: [Util add_colon_to_mac:cameraMac] forKey:@"CameraMacWithQuote"];
    [userDefaults synchronize];
    
    _deviceConf.addressMode = @"DHCP";
    
    if ([_security isEqualToString:@"wep"]) {
        //@"Open",@"WEP", @"WPA-PSK/WPA2-PSK"
        _deviceConf.securityMode = @"WEP";
        _deviceConf.wepType = @"OPEN"; //default
        _deviceConf.keyIndex = @"1"; //default;
    }
    else if ( [_security isEqualToString:@"wpa"] )
    {
        _deviceConf.securityMode = @"WPA-PSK/WPA2-PSK";
    }
    else if ([_security isEqualToString:@"shared"]) {
        _deviceConf.securityMode = @"SHARED";
    }
    else {
        _deviceConf.securityMode= @"OPEN";
    }
    
    _deviceConf.key = _password;
    
    _deviceConf.usrName = BASIC_AUTH_DEFAULT_USER;
    NSLog(@"02 cam password is : %@", [CameraPassword getPasswordForCam:cameraMac]);
    NSString* camPass = [CameraPassword getPasswordForCam:cameraMac];
    
    if ( !camPass ) {
        // default pass
        camPass = @"00000000";
        NSLog(@"02 cam password is default: %@", camPass);
    }
    
    _deviceConf.passWd = camPass;
}

#pragma mark - BLEConnectionManagerDelegate

- (void)didReceiveBLEList:(NSMutableArray *)bleLists
{
    NSLog(@"NWINFO : rescan completed ");
    CBPeripheral *bleUart = (CBPeripheral *)[BLEConnectionManager.instanceBLE.listBLEs firstObject];
    [BLEConnectionManager.instanceBLE connectToBLEWithPeripheral:bleUart];
}

- (void)bleDisconnected
{
    NSLog(@"NWINFO : BLE device is DISCONNECTED - state: %d, - shouldTimeoutProcessing: %d", _stage, _shouldTimeoutProcessing);
    
    if (_shouldTimeoutProcessing) {
        //NSLog(@"NWINFO - bleDisconnected");
        [_viewProgress removeFromSuperview];
        [self.view addSubview:_viewError];
        [self.view bringSubviewToFront:_viewError];
    }
    else {
        [self rescanToConnectToBLE];
    }
}

- (void)disconnectToBLE
{
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE disconnect];
}

- (void)rescanToConnectToBLE
{
    NSLog(@"NetworkInfo - rescanToConnectToBLE - Reconnect after 2s");
    
    NSDate *date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
}

- (void)didConnectToBle:(CBUUID*)serviceId
{
    NSLog(@"BLE device connected - now, latest stage: %d", _stage);
   
#if 0
    switch (stage)
    {
        case SENT_WIFI:
        case CHECKING_WIFI:
            NSLog(@"checking wifi status ... do nothing here");
           // [self readWifiStatusOfCamera:nil];
            break;
            
        case INIT:
            NSLog(@"start over!!");
            //[self sendWifiInfoToCamera];
            break;
    }
#endif
}

- (void)onReceiveDataError:(int)errorCode forCommand:(NSString *)commandToCamera
{
    NSLog(@"NetworkInfo - onReceiveDataError: %d, cmd: %@", errorCode, commandToCamera);
}

- (void)didReceiveData:(NSString *)string
{
    NSLog(@"NetworkInfoToCameraVC - didReceiveData: %@", string);
    
    if ([string hasPrefix:@"set_time_zone"]) {
        // set_time_zone: 0 -> success
        self.stage = SENT_TIME_ZONE;
        NSLog(@"NetworkInfo - Set time done");
    }
    else if ([string hasPrefix:@"setup_wireless_save"])
    {
        self.stage = SENT_WIFI;
        NSLog(@"Finishing SETUP_HTTP_COMMAND");
    }
    else if ([string hasPrefix:GET_STATE_NETWORK_CAMERA])
    {
        self.stage = CHECKING_WIFI;
        
        NSLog(@"Recv: %@", string);
        NSString *state = string;
        NSString *currentStateCamera;
     
        if ( state.length > 0) {
            currentStateCamera = [[state componentsSeparatedByString:@": "] objectAtIndex:1];
        }
        else {
            currentStateCamera = @"";
        }
        
        if ([currentStateCamera isEqualToString:@"CONNECTED"]) {
            self.stage = CHECKING_WIFI_PASSED;
        }
        else {
            self.stage = CHECKING_WIFI;
        }
    }
    else if ([string hasPrefix:RESTART_HTTP_CMD]) {
        NSLog(@"Finishing RESTART_HTTP_CMD");
    }
    else {
        NSLog(@"Receive un-expected data, Try to findout what to do next??? ");
#if 0
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
#endif
    }
}

#pragma mark - Methods

- (void)sendCommandRestartSystem
{
    NSLog(@"Send RESTART Command, now");
    
    NSDate *date;
    while ( BLEConnectionManager.instanceBLE.state != CONNECTED && !_shouldTimeoutProcessing ) {
        NSLog(@"sendCommandRestartSystem:  BLE disconnected - stage: %d, sleep 2s ", _stage);
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( _shouldTimeoutProcessing ) {
        NSLog(@"sendCommandRestartSystem: SETUP PROCESS TIMEOUT -- return");
        return;
    }
    
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:RESTART_HTTP_CMD withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];

    if ( BLEConnectionManager.instanceBLE.uartPeripheral.isBusy ) {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
        if( BLEConnectionManager.instanceBLE.uartPeripheral.isBusy ) {
            NSLog(@"BLE still busy, camera may have already rebooted. Moving on..");
        }
    }
}

- (BOOL)sendCommandHTTPSetup
{
    NSLog(@"Send command SETUP HTTP Command, now");
    NSDate *date;
    while( BLEConnectionManager.instanceBLE.state != CONNECTED && !_shouldTimeoutProcessing ) {
        NSLog(@"sendCommandHTTPSetup:  BLE disconnected - stage: %d, sleep 2s ", _stage);
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( _shouldTimeoutProcessing ) {
        NSLog(@"sendCommandHTTPSetup: SETUP PROCESS TIMEOUT -- return");
        return NO;
    }
    
    //send next command
    DeviceConfiguration *sentConf = [[DeviceConfiguration alloc] init];
    
    [sentConf restoreConfigurationData:[Util readDeviceConfiguration]];
    NSString *conf = [sentConf getDeviceEncodedConfString];
    
    NSString *cmd = [NSString stringWithFormat:@"%@%@", SETUP_HTTP_CMD, conf];
    
    //send cmd to Device
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:cmd withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    
    while (BLEConnectionManager.instanceBLE.uartPeripheral.isBusy) {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    NSLog(@"After sending Save Wireless wait for 3sec, after that - return TRUE");
    date = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    return YES;
}

- (BOOL)sendCommandSetTimeZone
{
    NSLog(@"NetworkInfo - sendCommandSetTimeZone");
    NSDate *date;
    
    BOOL debugLog = YES;
    
    while( BLEConnectionManager.instanceBLE.state != CONNECTED && !_shouldTimeoutProcessing ) {
        if ( debugLog ) {
            NSLog(@"NetworkInfo - sendCommandSetTimeZone:  BLE disconnected - stage: %d, sleep 2s...", _stage);
            debugLog = NO;
        }
        
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( _shouldTimeoutProcessing ) {
        NSLog(@"NetworkInfo - sendCommandSetTimeZone: TIMEOUT -- return");
        return NO;
    }
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    [stringFromDate insertString:@"." atIndex:3];
    NSLog(@"%@", stringFromDate);
    
    NSString *cmd = [NSString stringWithFormat:SET_TIME_ZONE, stringFromDate];
    
    //send cmd to Device
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:cmd withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    
    while (BLEConnectionManager.instanceBLE.uartPeripheral.isBusy) {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    NSLog(@"After sending Set Time Zone wait for 3sec, after that - return TRUE");
    date = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    return YES;
}

- (void)sendWifiInfoToCamera
{
    [self.view endEditing:YES];
    
    //should hide back in navigation bar
    self.navigationItem.hidesBackButton = YES;
    
    // should be show dialog here, make sure user input username and password
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    //and then disable user interaction
    [self.view setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    [self prepareWifiInfo];
    
    //Save and send
    if ( [_deviceConf isDataReadyForStoring]) {
        [Util writeDeviceConfigurationData:[_deviceConf getWritableConfiguration]];
    }

    self.stage = INIT;

    BLEConnectionManager.instanceBLE.delegate = self;
    
    if ([self sendCommandSetTimeZone]) {
        while (_stage != SENT_TIME_ZONE && !_shouldTimeoutProcessing);
        
        if ([self sendCommandHTTPSetup]) {
            while (_stage != SENT_WIFI && !_shouldTimeoutProcessing);
            
            int count = 20;
            NSDate * exp_reading_status = [[NSDate date] dateByAddingTimeInterval:3*60];
            
            do {
                [self readWifiStatusOfCamera:nil];
                
                if ([exp_reading_status compare:[NSDate date]] == NSOrderedAscending ) {
                    NSLog(@"wifi pass check failed -- 3 min passed");
                    break;
                }
            }
            while (_stage != CHECKING_WIFI_PASSED && count-- > 0 && !_shouldTimeoutProcessing);
            
            if (_stage == CHECKING_WIFI) {
                //Failed!!
                if ( _timerTimeoutConnectBLE ) {
                    [_timerTimeoutConnectBLE invalidate];
                    self.timerTimeoutConnectBLE = nil;
                }
                
                [self timeoutBLESetupProcessing:nil];
                NSLog(@"wifi pass check failed!!! call timeout");
            }
            else if (_stage == CHECKING_WIFI_PASSED) {
                //CONNECTED... Move on now..
                [self sendCommandRestartSystem];
                
                [self showNextScreen];
                [self.view setUserInteractionEnabled:YES];
                [self.navigationController.navigationBar setUserInteractionEnabled:YES];
            }
        }
    }
    else {
        NSLog(@"NetworkInfo - sendWifiInfoToCamera - SetTimeZone failed!");
    }
}

- (void)readWifiStatusOfCamera:(NSTimer *)exp
{
    NSLog(@"now,readWifiStatusOfCamera blocking ");
    
    NSDate *date;
    while( BLEConnectionManager.instanceBLE.state != CONNECTED && !_shouldTimeoutProcessing ) {
        NSLog(@"readWifiStatusOfCamera:  BLE disconnected - stage: %d, sleep 2s ", _stage);
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( _shouldTimeoutProcessing ) {
        NSLog(@"readWifiStatusOfCamera: SETUP PROCESS TIMEOUT -- return");
        return;
    }
    
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:GET_STATE_NETWORK_CAMERA withTimeOut:LONG_TIME_OUT_SEND_COMMAND];
    
    NSLog(@"Finished sending: %@",GET_STATE_NETWORK_CAMERA);

    while (BLEConnectionManager.instanceBLE.uartPeripheral.isBusy) {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
}

- (void)showNextScreen
{
    NSLog(@"NetworkInfo - SSID: %@   - %@", self.ssid, self.deviceConf.ssid );
    
    if ( _timerTimeoutConnectBLE ) {
        [_timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    DeviceConfiguration *sentConf = [[DeviceConfiguration alloc] init];
    [sentConf restoreConfigurationData:[Util readDeviceConfiguration]];
    
    //load step 10
    
    NSLog(@"Load Step 10");
    //[self.ib_dialogVerifyNetwork setHidden:YES];
    [_viewProgress removeFromSuperview];
    if ( sentConf.ssid ) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:sentConf.ssid forKey:HOME_SSID];
        [userDefaults synchronize];
    }
    
    //Load the next xib
    Step_10_ViewController_ble *step10ViewController = [[Step_10_ViewController_ble alloc] initWithNibName:@"Step_10_ViewController_ble" bundle:nil];
    [self.navigationController pushViewController:step10ViewController animated:NO];
    
}

- (BOOL)restoreDataIfPossible
{
	NSDictionary *savedData = [Util readDeviceConfiguration];
	
	if ( savedData ) {
		//populate the fields with stored data
		[self.deviceConf restoreConfigurationData:savedData];
		return YES;
	}
    
	return NO;
}

#pragma mark - JSON_Comm call back

- (void)removeCamSuccessWithResponse:(NSDictionary *)responseData
{
	NSLog(@"removeCam success");
}

- (void)removeCamFailedWithError:(NSDictionary *)errorResponse
{
	NSLog(@"removeCam failed Server error: %@", errorResponse[@"message"]);
}

- (void)removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
}

@end
