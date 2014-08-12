//
//  Setup_04_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>
#import <CameraScanner/CameraScanner.h>

#import "EditCamera_VController.h"
#import "WifiEntry.h"
#import "DisplayWifiList_VController.h"
#import "UARTPeripheral.h"
#import "PublicDefine.h"
#import "define.h"

@interface EditCamera_VController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *tfCamName;
@property (nonatomic, weak) IBOutlet UIButton *btnContinue;
@property (nonatomic, weak) IBOutlet UIView *viewProgress;

@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, copy) NSString *homeWifiSSID;

@property (nonatomic) BOOL isShowingProcess;
@property (nonatomic) BOOL shouldCancel;
@property (nonatomic) int stage;

@end

@implementation EditCamera_VController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"logo"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [_btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    
    UIImageView *imageView = (UIImageView *)[_viewProgress viewWithTag:585];
    imageView.animationImages = @[[UIImage imageNamed:@"loader_a"],
                                  [UIImage imageNamed:@"loader_b"],
                                  [UIImage imageNamed:@"loader_c"],
                                  [UIImage imageNamed:@"loader_d"],
                                  [UIImage imageNamed:@"loader_e"],
                                  [UIImage imageNamed:@"loader_f"]];
    imageView.animationRepeatCount = 0;
    imageView.animationDuration = 1.5f;
    
    [imageView startAnimating];
    
    self.tfCamName.delegate = self;
    self.tfCamName.text = _cameraName;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _viewProgress.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove delegate
    [BLEConnectionManager.instanceBLE setDelegate:nil];
}

#pragma mark - Actions

- (IBAction)btnContinueTouchUpInsideAction:(id)sender
{
    NSString *cameraName_text = _tfCamName.text;
    
    if ([cameraName_text length] < MIN_LENGTH_CAMERA_NAME || [cameraName_text length] > MAX_LENGTH_CAMERA_NAME ) {
        NSString *title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                             @"Invalid Camera Name", nil);
        
        NSString *msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg", nil, [NSBundle mainBundle],
                                                           @"Camera Name has to be between 5-30 characters", nil);
        
        NSString *ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:ok
                                               otherButtonTitles:nil];
        [alert show];
    }
    else if (![self isCameraNameValidated:cameraName_text]) {
        NSString *title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                             @"Invalid Camera Name", nil);
        
        NSString *msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg2", nil, [NSBundle mainBundle],
                                                           @"Camera name is invalid. Please enter [0-9],[a-Z], space, dot, hyphen, underscore & single quote only.", nil);
        
        NSString *ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:ok
                                               otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cameraName_text forKey:@"CameraName"];
        [userDefaults synchronize];

        [self.view addSubview:_viewProgress];
        [self.view bringSubviewToFront:_viewProgress];
        [self registerCamera:nil];
    }
}

#pragma mark - Methods

- (void)hubbleItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    self.alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    indicator.center = CGPointMake(_alertView.bounds.size.width/2, _alertView.bounds.size.height-45);
    [indicator startAnimating];
    [_alertView addSubview:indicator];
    
    [_alertView setBackgroundColor:[UIColor blackColor]];
    [_alertView show];
}

#pragma mark - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)animateTextField:(UITextField *)textField up:(BOOL)up
{
    NSInteger movementDistance = 216; // tweak as needed
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        movementDistance = 264;
    }
    
    if (UIScreen.mainScreen.bounds.size.height < 568) {
        movementDistance = 200;
    }
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)isCameraNameValidated:(NSString *)cameraNames
{
    
    NSString *validString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890. '_-";
    
    for (int i = 0; i < cameraNames.length; i ++) {
        NSRange range = [validString rangeOfString:[NSString stringWithFormat:@"%c",[cameraNames characterAtIndex:i]]];
        if (range.location == NSNotFound) {
            return NO;
        }
    }
    
    return YES;
}

// TODO: check to see if this is actually called. May not be used as not wired up in IB.
- (IBAction)handleButtonPress:(id)sender
{
    NSString *cameraName = _tfCamName.text;
    
    if ( cameraName.length < MIN_LENGTH_CAMERA_NAME || cameraName.length > MAX_LENGTH_CAMERA_NAME ) {
        NSString *title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                             @"Invalid Camera Name", nil);
        
        NSString *msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg", nil, [NSBundle mainBundle],
                                                           @"Camera Name has to be between 5-30 characters", nil);
        
        NSString *ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:ok
                                               otherButtonTitles:nil];
        
        [alert show];
    }
    else if ( ![self isCameraNameValidated:cameraName] ) {
        NSString *title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                             @"Invalid Camera Name", nil);
        
        NSString *msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg2", nil, [NSBundle mainBundle],
                                                           @"Camera name is invalid. Please enter [0-9],[a-Z], space, dot, hyphen, underscore & single quote only.", nil);
        
        NSString *ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:ok
                                               otherButtonTitles:nil];
        
        [alert show];
    }
    else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cameraName forKey:@"CameraName"];
        [userDefaults synchronize];
        
        [self registerCamera:nil];
    }
}

- (void)showScreenGetWifiList
{
    NSLog(@"Load screen display wifi list");
    //Load the next xib
    DisplayWifiList_VController *wifiListVController = nil;
    wifiListVController =  [[DisplayWifiList_VController alloc]
                            initWithNibName:@"DisplayWifiList_VController" bundle:nil];
    [self.navigationController pushViewController:wifiListVController animated:NO];
    
}

#pragma mark -   Timer

-(void)timeOutSendingMkey:(NSTimer *)exp
{
    // 60sec has passed since we started, no matter what happen, kill it off now.
    self.shouldCancel = YES;
    
}

- (void)setMasterKeyOnCamera
{
    self.shouldCancel = NO;
    self.timerTimeoutConnectBLE = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                                   target:self
                                                                 selector:@selector(timeOutSendingMkey:)
                                                                 userInfo:nil
                                                                  repeats:NO];
    // Send auto_token to camera.
    // First get mac address of camera.
    self.stage = SENDING_MASTER_KEY;
    
    do {
        [self sendCommandAuthTokenToCamera];
        
        if ( _shouldCancel ) {
            NSLog(@"Cancelling 2 ");
            break ;
        }
    }
    while ( _stage == SENDING_MASTER_KEY );
    
    
    if ( _stage == SENDING_MASTER_KEY_DONE ) {
        if ( _timerTimeoutConnectBLE.isValid ) {
            [_timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_viewProgress removeFromSuperview];
            [self showScreenGetWifiList];
        });
    }
    else {
        //ERROR handling: TODO:
        NSString *msg = NSLocalizedStringWithDefaultValue(@"addcam_error_2" ,nil, [NSBundle mainBundle],
                                                           @"Failed to connect to camera. Please make sure you stay close to the camera and retry", nil);
        NSString *cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                              @"Cancel", nil);
        
        NSString *retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
                                                             @"Retry", nil);
        //ERROR condition
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                                              @"AddCam Error" , nil)
                              message:msg
                              delegate:self
                              cancelButtonTitle:cancel
                              otherButtonTitles:retry, nil];
        alert.delegate = self;
        alert.tag = ALERT_ASK_FOR_RETRY_BLE;
        
        [alert show];
    }
}

- (void)sendCommandAuthTokenToCamera
{
    NSString * set_mkey = SET_MASTER_KEY;
    set_mkey =[set_mkey stringByAppendingString:_authToken];
    NSDate * date;
    
    BOOL debugLog = YES;
    
    while( BLEConnectionManager.instanceBLE.state != CONNECTED && !_shouldCancel ) {
        if (debugLog) {
            NSLog(@"EditCameraVC- BLE disconnected, waiting for it to reconnect..");
            debugLog = NO;
        }

        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
    }
    
    if ( _shouldCancel ) {
        NSLog(@"Cancelling ... now");
        return;
    }
    
    NSLog(@"Now, send command Authentication token");
    
    [BLEConnectionManager.instanceBLE setDelegate:self];
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:set_mkey withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    
    while ( BLEConnectionManager.instanceBLE.uartPeripheral.isBusy ) {
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    //.5 sec to set the stage to correct
    date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
}

#pragma mark - Callbacks

- (void)addCamSuccessWithResponse:(NSDictionary *)responseData
{
    NSLog(@"addcam response: %@", responseData);
    self.authToken = [[responseData objectForKey:@"data"] objectForKey:@"auth_token"];
    [self setMasterKeyOnCamera];
}

- (void)addCamFailedWithError:(NSDictionary *)errorResponse
{
    [_viewProgress removeFromSuperview];

    if ( !errorResponse ) {
        NSLog(@"error_response = nil");
        return;
    }
    
    NSLog(@"addcam failed with error code:%d", [errorResponse[@"status"] intValue]);
    
    NSString *ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                                          @"AddCam Error" , nil)
						  message:errorResponse[@"message"]
						  delegate:nil
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	return;
}

- (void) addCamFailedServerUnreachable
{
    [_viewProgress removeFromSuperview];
	NSLog(@"addcam failed : server unreachable");
    
    NSString *msg = NSLocalizedStringWithDefaultValue(@"addcam_error_1" ,nil, [NSBundle mainBundle],
                                                       @"The device is not able to connect to the server. Please check the WIFI and the internet. Go to WIFI setting to confirm device is connected to intended router", nil);
    NSString *cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
    NSString *retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
                                                         @"Retry", nil);
    //ERROR condition
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                                          @"AddCam Error" , nil)
                          message:msg
                          delegate:self
                          cancelButtonTitle:cancel
                          otherButtonTitles:retry, nil];
    alert.delegate = self;
    alert.tag = ALERT_ASK_FOR_RETRY;
    
    [alert show];
}

- (IBAction)registerCamera:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *fwVersion = [userDefaults objectForKey:FW_VERSION];
    NSString *udid = [userDefaults objectForKey:CAMERA_UDID];
    
    //NSLog(@"-----fwVersion = %@, ,model = %@", fwVersion, model);
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    
    [stringFromDate insertString:@"." atIndex:3];
    
    NSLog(@"%@", stringFromDate);
    
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(addCamSuccessWithResponse:)
                                                                          FailSelector:@selector(addCamFailedWithError:)
                                                                             ServerErr:@selector(addCamFailedServerUnreachable)];
    
    NSString *stringCameraName = (NSString *) [userDefaults objectForKey:@"CameraName"];
    [jsonComm registerDeviceWithDeviceName:stringCameraName
                         andRegistrationID:udid
                                   andMode:@"upnp" // Need somethings more usefully
                              andFwVersion:fwVersion
                               andTimeZone:stringFromDate
                                 andApiKey:apiKey];
}

#pragma mark - BLEConnectionManagerDelegate

- (void)didReceiveData:(NSString *)string
{
    NSLog(@"response set authen token is %@", string);
    
    if ( string.length == 0 ) {
        NSLog(@"can't send master key, garbage data..");
    }
    else {
        if ([string hasPrefix:@"set_master_key: 0"]) {
            // done
            NSLog(@"sending master key done, move on..");
            self.stage = SENDING_MASTER_KEY_DONE;
            
            
        }
        else if ([string hasPrefix:@"set_master_key: -1"]) {
            // dont do anything.. we'll retry in main thread.
            NSLog(@"can't send master key, set_master_key: -1");
        }
    }
}

- (void)onReceiveDataError:(int)errorCode forCommand:(NSString *)commandToCamera
{
    
}

- (void)didConnectToBle:(CBUUID*)serviceId
{
    NSLog(@"BLE device connected again( EditCamera)");
}

- (void)bleDisconnected
{
    NSLog(@"EDITCAM : BLE device is DISCONNECTED - Reconnect after 2s ");
    
    NSDate *date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    [BLEConnectionManager.instanceBLE setDelegate:self];
    [BLEConnectionManager.instanceBLE reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{
    if (alertView.tag == ALERT_ASK_FOR_RETRY_BLE) {
        
        if (buttonIndex == 1) {
            //Retry
            [self setMasterKeyOnCamera];
        }
        else {
            // return to the beginning
            NSLog(@"EDITCAM : return to the beginning.Disconnect BLE ");
            [BLEConnectionManager.instanceBLE setDelegate:nil];
            [BLEConnectionManager.instanceBLE setNeedReconnect:NO];
            [BLEConnectionManager.instanceBLE disconnect];

            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

@end