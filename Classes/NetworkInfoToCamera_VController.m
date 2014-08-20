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

@interface NetworkInfoToCamera_VController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView *viewProgress;
@property (nonatomic, strong) IBOutlet UIView *viewError;
@property (nonatomic, strong) IBOutlet UITableViewCell *ssidCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *securityCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *confPasswordCell;

@property (nonatomic, weak) IBOutlet UILabel *checkingConnectionLabel;
@property (nonatomic, weak) IBOutlet UILabel *makeTakeAMinuteLabel;
@property (nonatomic, weak) IBOutlet UILabel *unableToDetectCameraLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeoutLabel;

@property (nonatomic, strong) UITextField *tfSSID;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UITextField *tfConfirmPass;

@property (nonatomic, strong) NSTimer *timerTimeoutConnectBLE;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIButton *tryAgainButton;

@property (nonatomic, copy) NSString *statusNetworkCamString;
@property (nonatomic) BOOL shouldTimeoutProcessing;
@property (nonatomic) int stage;

@end

@implementation NetworkInfoToCamera_VController

#define PASSWORD_LABEL_TAG      100
#define PASSWORD_TEXTFIELD_TAG  200

#define CONFIRM_LABEL_TAG       101
#define CONFIRM_TEXTFIELD_TAG   201

#define NAME_LABEL_TAG          102
#define NAME_TEXTFIELD_TAG      202

#define SECURITY_LABEL_TAG      103
#define SECURITY_VAL_LABEL_TAG  203

#define BTN_CONTINUE_TAG    599
#define BTN_TRY_AGAIN_TAG   559
#define BLE_TIMEOUT_PROCESS 4*60.0

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LocStr(@"Enter Network Information");
    
    self.continueButton = (UIButton *)[_viewError viewWithTag:BTN_CONTINUE_TAG];
    [_continueButton setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_continueButton setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    [_continueButton addTarget:self action:@selector(btnContinueTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tryAgainButton = (UIButton *)[_viewError viewWithTag:BTN_TRY_AGAIN_TAG];
    [_tryAgainButton setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_tryAgainButton setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    [_tryAgainButton addTarget:self action:@selector(btnTryAgainTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _checkingConnectionLabel.text = LocStr(@"Checking connection to camera");
    _makeTakeAMinuteLabel.text = LocStr(@"This may take up to a minute");
    _unableToDetectCameraLabel.text = LocStr(@"Unable to detect camera");
    _timeoutLabel.text = LocStr(@"Timeout");
    [_continueButton setTitle:LocStr(@"Continue") forState:UIControlStateNormal];
    [_tryAgainButton setTitle:LocStr(@"Try again") forState:UIControlStateNormal];
    
    ((UILabel *)[_ssidCell viewWithTag:NAME_LABEL_TAG]).text = LocStr(@"Name");
    ((UILabel *)[_securityCell viewWithTag:SECURITY_LABEL_TAG]).text = LocStr(@"Security");
    ((UILabel *)[_securityCell viewWithTag:SECURITY_VAL_LABEL_TAG]).text = LocStr(@"None");
    ((UILabel *)[_passwordCell viewWithTag:PASSWORD_LABEL_TAG]).text = LocStr(@"Password");
    ((UITextField *)[_passwordCell viewWithTag:PASSWORD_TEXTFIELD_TAG]).placeholder = LocStr(@"Enter Wi-Fi password");
    ((UILabel *)[_confPasswordCell viewWithTag:CONFIRM_LABEL_TAG]).text = LocStr(@"Confirm");
    ((UITextField *)[_confPasswordCell viewWithTag:CONFIRM_TEXTFIELD_TAG]).placeholder = LocStr(@"Confirm password");
    
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
        DLog(@"empty SSID ");
    }
    
    if ( !_security ) {
        DLog(@"empty security ");
    }
    
    UITextField *tfSsid = (UITextField *)[_ssidCell viewWithTag:NAME_TEXTFIELD_TAG];
    if (tfSsid && !_isOtherNetwork ) {
        tfSsid.text = _ssid;
    }
    
    UITextField *_sec = (UITextField *)[_securityCell viewWithTag:SECURITY_VAL_LABEL_TAG];
    _sec.text = _security;
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:LocStr(@"Next")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(handleNextButton:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.tfSSID = (UITextField *)[_ssidCell viewWithTag:NAME_TEXTFIELD_TAG];
    
    if ( _tfSSID.text.length > 0 && ([_security isEqualToString:LocStr(@"None")] || [_security isEqualToString:@"open"]) ) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    self.tfPassword = (UITextField *)[_passwordCell viewWithTag:PASSWORD_TEXTFIELD_TAG];
    _tfPassword.delegate = self;
    
    self.tfConfirmPass = (UITextField *)[_confPasswordCell viewWithTag:CONFIRM_TEXTFIELD_TAG];
    _tfConfirmPass.delegate = self;
    
    // initialize transient object here
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
        
        DLog(@"%s - deviceConf.ssid: %@, - self.ssid: %@, - self.security: %@", __FUNCTION__, self.deviceConf.ssid, self.ssid, self.security);
        
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
    
    UITextField * _sec = (UITextField *)[_securityCell viewWithTag:SECURITY_VAL_LABEL_TAG];
    _sec.text = _security;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    if (textField.tag == NAME_TEXTFIELD_TAG) {
        // SSID
        NSInteger ssidTextLength = 0;
        const char * ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(ch, "\b");
        
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
    else if (textField.tag == PASSWORD_TEXTFIELD_TAG) {
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
        if (_tfSSID.text.length > 0 && [passString isEqualToString:_tfConfirmPass.text]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else if (textField.tag == CONFIRM_TEXTFIELD_TAG) {
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
    // Dont move if it's the SSID name
    if ( textField.tag != NAME_TEXTFIELD_TAG ) {
        [self animateTextField:textField up:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Dont move if it's the SSID name
    if ( textField.tag != NAME_TEXTFIELD_TAG ){
        [self animateTextField:textField up:NO];
    }
}

- (void)animateTextField:(UITextField *)textField up:(BOOL)up
{
    int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if ( textField.tag == CONFIRM_TEXTFIELD_TAG && UIInterfaceOrientationIsLandscape(interfaceOrientation) ) {
        // Confirm Password cell
        movementDistance+= 40;
    }
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField.tag == PASSWORD_TEXTFIELD_TAG ) {
        // password
        self.password = textField.text;
        [_tfConfirmPass becomeFirstResponder];
    }
    else if ( textField.tag == CONFIRM_TEXTFIELD_TAG ) {
        // conf password
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
    UITextField *textField = (UITextField *)[self.view viewWithTag:PASSWORD_TEXTFIELD_TAG];
    if ( textField ) {
        [textField resignFirstResponder];
    }
    
    textField = (UITextField *)[self.view viewWithTag:CONFIRM_TEXTFIELD_TAG];
    if( textField ) {
        [textField resignFirstResponder];
    }
    
    textField = (UITextField *)[self.view viewWithTag:NAME_TEXTFIELD_TAG];
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
    
    if (indexPath.section == SSID_SECTION) {
        // only one cell in this section
        if ( _isOtherNetwork ) {
            UITextField *tfSsid  = (UITextField *)[_ssidCell viewWithTag:NAME_TEXTFIELD_TAG];
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
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SSID_SECTION) {
        return 1;
    }
    else if (section == SEC_SECTION) {
        if ([_security isEqualToString:@"open"] || [_security isEqualToString:LocStr(@"None")]) {
            return 1;
        }
        else {
            return 3;
        }
    }
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
        // only one cell in this section
        if ( _isOtherNetwork ) {
            UITextField *tfSsid  = (UITextField*)[_ssidCell viewWithTag:NAME_TEXTFIELD_TAG];
            [tfSsid setUserInteractionEnabled:YES];
            [tfSsid becomeFirstResponder];
        }
    }
    else if (indexPath.section == SEC_SECTION)
    {
        if (indexPath.row == PASSWORD_INDEX) {
            UITextField * txtField = (UITextField*)[_passwordCell viewWithTag:PASSWORD_TEXTFIELD_TAG];
            [txtField becomeFirstResponder];
        }
        if (indexPath.row == CONFPASSWORD_INDEX)
        {
            UITextField * txtField = (UITextField*)[_confPasswordCell viewWithTag:CONFIRM_TEXTFIELD_TAG];
            [txtField becomeFirstResponder];
        }
    }
}

#pragma mark -

- (void)changeSecurityType
{
    // ? TODO ?
    DLog(@"Load step 7");
}

- (void)handleNextButton:(id)sender
{
    // check if password is ok
    UITextField *my_ssid = (UITextField*)[_ssidCell viewWithTag:NAME_TEXTFIELD_TAG];
    DLog(@"%s other: %d, security: %@", __FUNCTION__, _isOtherNetwork, _security);
    
    if ( _isOtherNetwork ) {
        if ([my_ssid.text length] == 0) {
            UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:LocStr(@"SSID cannot be empty")
                                                             message:LocStr(@"Enter the SSID name and try again")
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:LocStr(@"Ok"), nil];
            [_alert show];
            
            return;
        }
        else {
            self.ssid = my_ssid.text;
        }
    }
    
    if ([_security isEqualToString:@"open"]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        // Start timer to check for camera connection issue
        self.timerTimeoutConnectBLE  = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                       target:self
                                                     selector:@selector(timeoutBLESetupProcessing:)
                                                     userInfo:nil
                                                      repeats:NO];
        
        // Blocking call, after this return the camera should be either added or failed setup already
        self.password = @"";
        [self sendWifiInfoToCamera];
    }
    else {
        UITextField *pass = (UITextField *)[_passwordCell viewWithTag:PASSWORD_TEXTFIELD_TAG];
        UITextField *confpass = (UITextField *)[_confPasswordCell viewWithTag:CONFIRM_TEXTFIELD_TAG];
        
        if ( [pass.text length] == 0 ||
            [confpass.text length] ==0 ||
            ![pass.text isEqualToString:confpass.text] )
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Confirm password")
                                                            message:LocStr(@"Password does not match, please re-enter!")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:LocStr(@"Ok"), nil];
            [alert show];
            return;
        }
        else {
            //cont
            self.password = [NSString stringWithString:pass.text];
            DLog(@"NetworkInfo - handleNextButton - Create time out ble setup process");
            
            self.navigationItem.rightBarButtonItem.enabled = NO;

            // Start timer to check for camera connection issue
            self.timerTimeoutConnectBLE  = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                           target:self
                                                         selector:@selector(timeoutBLESetupProcessing:)
                                                         userInfo:nil
                                                          repeats:NO];
            
            // Blocking call, after this return the camera should be either added or failed setup already
            [self sendWifiInfoToCamera ];
        }
    }
}

- (void)timeoutBLESetupProcessing:(NSTimer *)timer
{
    self.view.userInteractionEnabled = YES;
    self.shouldTimeoutProcessing = YES;
    
    // disconnect to BLE and return to guide screen.
    if ( BLEConnectionManager.instanceBLE.state == CONNECTED ) {
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
        
        DLog(@"NetworkInfo - timeoutBLESetupProcessing - try to remove camera");
        
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
    DLog(@"Check camera_mac is %@", cameraMac);
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
    else if ( [_security isEqualToString:@"wpa"] ) {
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
    DLog(@"02 cam password is : %@", [CameraPassword getPasswordForCam:cameraMac]);
    NSString* camPass = [CameraPassword getPasswordForCam:cameraMac];
    
    if ( !camPass ) {
        // default pass
        camPass = @"00000000";
        DLog(@"02 cam password is default: %@", camPass);
    }
    
    _deviceConf.passWd = camPass;
}

#pragma mark - BLEConnectionManagerDelegate

- (void)didReceiveBLEList:(NSMutableArray *)bleLists
{
    DLog(@"NWINFO : rescan completed");
    CBPeripheral *bleUart = (CBPeripheral *)[BLEConnectionManager.instanceBLE.listBLEs firstObject];
    [BLEConnectionManager.instanceBLE connectToBLEWithPeripheral:bleUart];
}

- (void)bleDisconnected
{
    DLog(@"NWINFO : BLE device is DISCONNECTED - state: %d, - shouldTimeoutProcessing: %d", _stage, _shouldTimeoutProcessing);
    if (_shouldTimeoutProcessing) {
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
    DLog(@"NetworkInfo - rescanToConnectToBLE - Reconnect after 2s");
    NSDate *date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
}

- (void)didConnectToBle:(CBUUID*)serviceId
{
    DLog(@"BLE device connected - now, latest stage: %d", _stage);
   
    switch (_stage)
    {
        case SENT_WIFI:
        case CHECKING_WIFI:
        {
            DLog(@"checking wifi status ... do nothing here");
            //[self readWifiStatusOfCamera:nil];
            break;
        }
        case INIT:
        {
            DLog(@"start over!!");
            //[self sendWifiInfoToCamera];
            break;
        }
    }
}

- (void)onReceiveDataError:(int)errorCode forCommand:(NSString *)commandToCamera
{
    DLog(@"NetworkInfo - onReceiveDataError: %d, cmd: %@", errorCode, commandToCamera);
}

- (void)didReceiveData:(NSString *)string
{
    DLog(@"NetworkInfoToCameraVC - didReceiveData: %@", string);
    
    if ([string hasPrefix:@"set_time_zone"]) {
        // set_time_zone: 0 -> success
        self.stage = SENT_TIME_ZONE;
        DLog(@"NetworkInfo - Set time done");
    }
    else if ([string hasPrefix:@"setup_wireless_save"])
    {
        self.stage = SENT_WIFI;
        DLog(@"Finishing SETUP_HTTP_COMMAND");
    }
    else if ([string hasPrefix:GET_STATE_NETWORK_CAMERA])
    {
        self.stage = CHECKING_WIFI;
        
        DLog(@"Recv: %@", string);
        NSString *state = string;
        NSString *currentStateCamera;
     
        if ( state.length > 0 ) {
            currentStateCamera = [state componentsSeparatedByString:@": "][1];
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
        DLog(@"Finishing RESTART_HTTP_CMD");
    }
    else {
        DLog(@"Receive un-expected data, Try to findout what to do next??? ");

        switch (_stage)
        {
            case SENT_WIFI:
            case CHECKING_WIFI:
                DLog(@"checking wifi status");
                //[self readWifiStatusOfCamera:nil];
                break;
                
            case INIT:
                DLog(@"start over!!");
                //[self sendWifiInfoToCamera];
                break;
        }
    }
}

#pragma mark - Methods

- (void)sendCommandRestartSystem
{
    DLog(@"Send RESTART Command, now");
    
    NSDate *date;
    while ( BLEConnectionManager.instanceBLE.state != CONNECTED && !_shouldTimeoutProcessing ) {
        DLog(@"sendCommandRestartSystem:  BLE disconnected - stage: %d, sleep 2s ", _stage);
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( _shouldTimeoutProcessing ) {
        DLog(@"sendCommandRestartSystem: SETUP PROCESS TIMEOUT -- return");
        return;
    }
    
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:RESTART_HTTP_CMD withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];

    if ( BLEConnectionManager.instanceBLE.uartPeripheral.isBusy ) {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
        if( BLEConnectionManager.instanceBLE.uartPeripheral.isBusy ) {
            DLog(@"BLE still busy, camera may have already rebooted. Moving on..");
        }
    }
}

- (BOOL)sendCommandHTTPSetup
{
    DLog(@"Send command SETUP HTTP Command, now");
    NSDate *date;
    while( BLEConnectionManager.instanceBLE.state != CONNECTED && !_shouldTimeoutProcessing ) {
        DLog(@"sendCommandHTTPSetup:  BLE disconnected - stage: %d, sleep 2s ", _stage);
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( _shouldTimeoutProcessing ) {
        DLog(@"sendCommandHTTPSetup: SETUP PROCESS TIMEOUT -- return");
        return NO;
    }
    
    // send next command
    DeviceConfiguration *sentConf = [[DeviceConfiguration alloc] init];
    
    [sentConf restoreConfigurationData:[Util readDeviceConfiguration]];
    NSString *conf = [sentConf getDeviceEncodedConfString];
    
    NSString *cmd = [NSString stringWithFormat:@"%@%@", SETUP_HTTP_CMD, conf];
    
    // send cmd to Device
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:cmd withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    
    while (BLEConnectionManager.instanceBLE.uartPeripheral.isBusy) {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    DLog(@"After sending Save Wireless wait for 3sec, after that - return TRUE");
    date = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    return YES;
}

- (BOOL)sendCommandSetTimeZone
{
    DLog(@"NetworkInfo - sendCommandSetTimeZone");
    NSDate *date;
    
    BOOL debugLog = YES;
    
    while( BLEConnectionManager.instanceBLE.state != CONNECTED && !_shouldTimeoutProcessing ) {
        if ( debugLog ) {
            DLog(@"NetworkInfo - sendCommandSetTimeZone:  BLE disconnected - stage: %d, sleep 2s...", _stage);
            debugLog = NO;
        }
        
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( _shouldTimeoutProcessing ) {
        DLog(@"NetworkInfo - sendCommandSetTimeZone: TIMEOUT -- return");
        return NO;
    }
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    [stringFromDate insertString:@"." atIndex:3];
    DLog(@"%@", stringFromDate);
    
    NSString *cmd = [NSString stringWithFormat:SET_TIME_ZONE, stringFromDate];
    
    // send cmd to Device
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:cmd withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    
    while (BLEConnectionManager.instanceBLE.uartPeripheral.isBusy) {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    DLog(@"After sending Set Time Zone wait for 3sec, after that - return TRUE");
    date = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    return YES;
}

- (void)sendWifiInfoToCamera
{
    [self.view endEditing:YES];
    
    // should hide back in navigation bar
    self.navigationItem.hidesBackButton = YES;
    
    // should be show dialog here, make sure user input username and password
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    // and then disable user interaction
    [self.view setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    [self prepareWifiInfo];
    
    // Save and send
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
                // Failed!!
                if ( _timerTimeoutConnectBLE ) {
                    [_timerTimeoutConnectBLE invalidate];
                    self.timerTimeoutConnectBLE = nil;
                }
                
                [self timeoutBLESetupProcessing:nil];
                DLog(@"wifi pass check failed!!! call timeout");
            }
            else if (_stage == CHECKING_WIFI_PASSED) {
                // CONNECTED... Move on now..
                [self sendCommandRestartSystem];
                
                [self showNextScreen];
                [self.view setUserInteractionEnabled:YES];
                [self.navigationController.navigationBar setUserInteractionEnabled:YES];
            }
        }
    }
    else {
        DLog(@"NetworkInfo - sendWifiInfoToCamera - SetTimeZone failed!");
    }
}

- (void)readWifiStatusOfCamera:(NSTimer *)exp
{
    DLog(@"now,readWifiStatusOfCamera blocking ");
    
    NSDate *date;
    while( BLEConnectionManager.instanceBLE.state != CONNECTED && !_shouldTimeoutProcessing ) {
        DLog(@"readWifiStatusOfCamera:  BLE disconnected - stage: %d, sleep 2s ", _stage);
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( _shouldTimeoutProcessing ) {
        DLog(@"readWifiStatusOfCamera: SETUP PROCESS TIMEOUT -- return");
        return;
    }
    
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:GET_STATE_NETWORK_CAMERA withTimeOut:LONG_TIME_OUT_SEND_COMMAND];
    
    DLog(@"Finished sending: %@",GET_STATE_NETWORK_CAMERA);

    while (BLEConnectionManager.instanceBLE.uartPeripheral.isBusy) {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
}

- (void)showNextScreen
{
    DLog(@"NetworkInfo - SSID: %@   - %@", self.ssid, self.deviceConf.ssid );
    
    if ( _timerTimeoutConnectBLE ) {
        [_timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    DeviceConfiguration *sentConf = [[DeviceConfiguration alloc] init];
    [sentConf restoreConfigurationData:[Util readDeviceConfiguration]];
    
    [_viewProgress removeFromSuperview];
    if ( sentConf.ssid ) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:sentConf.ssid forKey:HOME_SSID];
        [userDefaults synchronize];
    }
    
    Step_10_ViewController_ble *step10ViewController = [[Step_10_ViewController_ble alloc] initWithNibName:@"Step_10_ViewController_ble" bundle:nil];
    [self.navigationController pushViewController:step10ViewController animated:NO];
    
}

- (BOOL)restoreDataIfPossible
{
	NSDictionary *savedData = [Util readDeviceConfiguration];
	
	if ( savedData ) {
		// populate the fields with stored data
		[self.deviceConf restoreConfigurationData:savedData];
		return YES;
	}
    
	return NO;
}

#pragma mark - JSON_Comm call back

- (void)removeCamSuccessWithResponse:(NSDictionary *)responseData
{
	DLog(@"removeCam success");
}

- (void)removeCamFailedWithError:(NSDictionary *)errorResponse
{
	DLog(@"removeCam failed Server error: %@", errorResponse[@"message"]);
}

- (void)removeCamFailedServerUnreachable
{
	DLog(@"server unreachable");
}

@end
