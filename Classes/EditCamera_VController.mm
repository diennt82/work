//
//  Setup_04_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "EditCamera_VController.h"
#import "define.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface EditCamera_VController () <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *tfCamName;
@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;

@property (nonatomic) BOOL shouldCancel;
@property (retain, nonatomic) NSString *authToken;
@property (nonatomic) BOOL isBack;

@end



@implementation EditCamera_VController

@synthesize cameraMac, cameraName;
@synthesize alertView = _alertView;

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
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    
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
    
    self.tfCamName.text = self.cameraName;
}

- (void)xibDefaultLocalization
{
    UILabel *lable = (UILabel *)[self.view viewWithTag:1];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_EditCameraPage_label_camera_detected", nil, [NSBundle mainBundle], @"Camera Detected", nil);
    lable = (UILabel *)[self.view viewWithTag:2];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_EditCameraPage_label_make_your_notifcation", nil, [NSBundle mainBundle], @"Please name the location of your camera. This will help make your notification more relevant.", nil);
    
    self.tfCamName.placeholder = NSLocalizedStringWithDefaultValue(@"xib_EditCameraPage_textfield_camname", nil, [NSBundle mainBundle], @"Eg. Living Room, Nursery", nil);
    [self.btnContinue setTitle:NSLocalizedStringWithDefaultValue(@"xib_EditCameraPage_button_continue", nil, [NSBundle mainBundle], @"Continue", nil) forState:UIControlStateNormal];
    
    lable = (UILabel *)[self.viewProgress viewWithTag:1];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_EditCameraPage_label_searching", nil, [NSBundle mainBundle], @"Searching for Wi-Fi Networks", nil);
    lable = (UILabel *)[self.viewProgress viewWithTag:2];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_EditCameraPage_label_waitfor", nil, [NSBundle mainBundle], @"Please wait", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.viewProgress.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    //remove delegate
    [BLEConnectionManager getInstanceBLE].delegate = nil;
}

#pragma mark - Actions

- (IBAction)btnContinueTouchUpInsideAction:(id)sender
{
    NSString * cameraName_text = _tfCamName.text;
    
    if ([cameraName_text length] < MIN_LENGTH_CAMERA_NAME || [cameraName_text length] > MAX_LENGTH_CAMERA_NAME )
    {
        NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                             @"Invalid Camera Name", nil);
        
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg", nil, [NSBundle mainBundle],
                                                           @"Camera Name has to be between 5-30 characters", nil);
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
        
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:ok
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else if (![self isCameraNameValidated:cameraName_text])
    {
        NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                             @"Invalid Camera Name", nil);
        
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg2", nil, [NSBundle mainBundle],
                                                           @"Camera name is invalid. Please enter [0-9],[a-Z], space, dot, hyphen, underscore & single quote only.", nil);
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
        
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:ok
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cameraName_text forKey:CAMERA_NAME];
        [userDefaults synchronize];

        [self.view addSubview:_viewProgress];
        [self.view bringSubviewToFront:_viewProgress];
        
#if 1
        //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
        //NSString *fwVersion = [userDefaults stringForKey:FW_VERSION];
        
        
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"ZZZ"];
        
        NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
        [formatter release];
        [stringFromDate insertString:@"." atIndex:3];
        
        NSString * set_auth_cmd = [NSString stringWithFormat:@"%@%@%@%@%@",
                                   SET_SERVER_AUTH,
                                   SET_SERVER_AUTH_PARAM1, apiKey,
                                   SET_SERVER_AUTH_PARAM2, stringFromDate];
        self.authToken = set_auth_cmd;
        
        [self setMasterKeyOnCamera];
#else
        [self registerCamera:nil];
#endif
    }
}

#pragma mark - Methods

- (void)hubbleItemAction:(id)sender
{
    if (_timerTimeoutConnectBLE != nil)
    {
        [_timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    self.shouldCancel = TRUE;
    self.isBack = TRUE;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    
    _alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [_alertView show];
    [self.alertView setBackgroundColor:[UIColor blackColor]];
    
    if(_alertView != nil) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        indicator.center = CGPointMake(_alertView.bounds.size.width/2, _alertView.bounds.size.height-45);
        [indicator startAnimating];
        [_alertView addSubview:indicator];
        [indicator release];
    }
}

#pragma mark - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
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

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    NSInteger movementDistance = 216; // tweak as needed
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        movementDistance = 264;
    }
    
    if (UIScreen.mainScreen.bounds.size.height < 568)
    {
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}

-(void) dealloc
{
    NSLog(@"%s", __FUNCTION__);
    
    [cameraName release];
    [cameraMac release];
    [_tfCamName release];
    [_btnContinue release];
    [_viewProgress release];
    [super dealloc];
}


-(BOOL) isCameraNameValidated:(NSString *) cameraNames
{
    
    NSString * validString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890. '_-";
    
    
    
    for (int i = 0; i < cameraNames.length; i ++)
    {
        NSRange range = [validString rangeOfString:[NSString stringWithFormat:@"%c",[cameraNames characterAtIndex:i]]];
        if (range.location == NSNotFound) {
            return NO;
        }
    }
    
    
    return YES;
    
}

- (void)showScreenGetWifiList
{
    NSLog(@"Load screen display wifi list");
    //Load the next xib
    DisplayWifiList_VController *wifiListVController = nil;
    wifiListVController =  [[DisplayWifiList_VController alloc]
                            initWithNibName:@"DisplayWifiList_VController" bundle:nil];
    [self.navigationController pushViewController:wifiListVController animated:NO];
    
    [wifiListVController release];
}

#pragma mark -
#pragma mark  Timer

-(void)timeOutSendingMkey:(NSTimer * )exp
{
    // 60sec has passed since we started, no matter what happen, kill it off now.
    self.shouldCancel = TRUE;
}

-(void) setMasterKeyOnCamera
{
    self.shouldCancel = FALSE;
    
    if (_timerTimeoutConnectBLE)
    {
        [_timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    self.timerTimeoutConnectBLE = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                              target:self
                                                            selector:@selector(timeOutSendingMkey:)
                                                            userInfo:nil
                                                             repeats:NO];
    
    
    /*
     - send auto_token to camera
     */
    //first get mac address of camera

    stage = SENDING_SERVER_AUTH;
    
    do
    {
        [self sendCommandAuth_TokenToCamera];
        
        if (_isBack)
        {
            NSLog(@"Canceling 3!. Going back.");
            return;
        }
        
        if (_shouldCancel == TRUE)
        {
            NSLog(@"Cancelling 2 ");
            break;
        }
    }
    while (stage == SENDING_SERVER_AUTH);
    
    if (stage == SENDING_SERVER_AUTH_DONE)
    {
        if (_timerTimeoutConnectBLE != nil)
        {
            [_timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [_viewProgress removeFromSuperview];
                           [self showScreenGetWifiList];
                       });
    }
    else
    {
        //ERROR handling: TODO:
        NSString * msg = NSLocalizedStringWithDefaultValue(@"addcam_error_2" ,nil, [NSBundle mainBundle],
                                                           @"Failed to connect to camera. Please make sure you stay close to the camera and retry", nil);
        NSString * cancel = NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil);
        
        NSString * retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
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
        [alert release];
    }
}

- (void)sendCommandAuth_TokenToCamera
{
    NSDate * date;
    
    BOOL debugLog = TRUE;
    
    while( ([BLEConnectionManager getInstanceBLE].state != CONNECTED) &&
          (_shouldCancel == FALSE))
    {
        if (debugLog)
        {
            NSLog(@"EditCameraVC- BLE disconnected, waiting for it to reconnect..");
            debugLog = FALSE;
        }

        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
    }
    
    if (_shouldCancel == TRUE)
    {
        NSLog(@"Cancelling ... now");
        return;
    }
    
    NSLog(@"Now, send command Authentication token");
    
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:_authToken
                                                          withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    //.5 sec to set the stage to correct
    date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
    
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
}

#pragma mark -
#pragma mark  Callbacks

- (void) addCamSuccessWithResponse:(NSDictionary *)responseData
{
    NSLog(@"addcam response: %@", responseData);
    self.authToken = [[responseData objectForKey:@"data"] objectForKey:@"auth_token"];
    [self setMasterKeyOnCamera];
}

- (void) addCamFailedWithError:(NSDictionary *) error_response
{
    [_viewProgress removeFromSuperview];
    if (error_response == nil) {
        NSLog(@"error_response = nil");
        return;
    }
    NSLog(@"addcam failed with error code:%d", [[error_response objectForKey:@"status"] intValue]);
    
    //    NSString * msg = NSLocalizedStringWithDefaultValue(@"Server_error_" ,nil, [NSBundle mainBundle],
    //                                                       @"Server error: %@" , nil);
    NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
    
	//ERROR condition
    
    //TODO: display alert retry registerCame
    
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                                          @"AddCam Error" , nil)
						  message:[error_response objectForKey:@"message"]
						  delegate:nil
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	return;
}

- (void) addCamFailedServerUnreachable
{
    [_viewProgress removeFromSuperview];
	NSLog(@"addcam failed : server unreachable");
    
    
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"addcam_error_1" ,nil, [NSBundle mainBundle],
                                                       @"The device is not able to connect to the server. Please check the WIFI and the internet. Go to WIFI setting to confirm device is connected to intended router", nil);
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil);
    
    NSString * retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
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
    [alert release];
    
    //Todo: handle retry
	
}



- (IBAction)registerCamera:(id)sender
{
    //    self.progressView.hidden = NO;
    //    [self.view bringSubviewToFront:self.progressView];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *fwVersion = [userDefaults objectForKey:FW_VERSION];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
    
    //NSLog(@"-----fwVersion = %@, ,model = %@", fwVersion, model);
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    
    [stringFromDate insertString:@"." atIndex:3];
    
    NSLog(@"%@", stringFromDate);
    
    [formatter release];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(addCamSuccessWithResponse:)
                                                                          FailSelector:@selector(addCamFailedWithError:)
                                                                             ServerErr:@selector(addCamFailedServerUnreachable)] autorelease];
    
    NSString *stringCameraName = (NSString *) [userDefaults objectForKey:CAMERA_NAME];
    [jsonComm registerDeviceWithDeviceName:stringCameraName
                         andRegistrationID:udid
                                   andMode:@"upnp" // Need somethings more usefully
                              andFwVersion:fwVersion
                               andTimeZone:stringFromDate
                                 andApiKey:apiKey];
}

#pragma mark - BLEConnectionManagerDelegate

- (void) didReceiveData:(NSString *)string
{
    NSLog(@"response set authen token is %@", string);
    
    if (string == nil || [string length] == 0)
    {
        NSLog(@"can't send master key, garbage data..");
    }
    else
    {
        //set_server_auth: 0
        if ([string hasPrefix:@"set_server_auth: 0"])
        {
            ///done
            NSLog(@"sending server auth done, move on..");
            stage = SENDING_SERVER_AUTH_DONE;
        }
        else if ([string hasPrefix:@"set_server_auth: -1"])
        {
            // dont do anything.. we'll retry in main thread.
            NSLog(@"can't send server auth, set_server_auth: -1");
        }
    }
}

- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera
{
    
}
- (void) didConnectToBle:(CBUUID*) service_id
{
    NSLog(@"BLE device connected again( EditCamera)");
}

-(void) bleDisconnected
{
    NSLog(@"EDITCAM : BLE device is DISCONNECTED - Reconnect after 2s ");
    
    NSDate * date;
    date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    //    [NSTimer scheduledTimerWithTimeInterval:TIME_OUT_RECONNECT_BLE target:self selector:@selector(dialogFailConnection:) userInfo:nil repeats:NO];
    
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE] reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{
    if (alertView.tag == ALERT_ASK_FOR_RETRY_BLE)
    {
        if (buttonIndex == 1) //Retry
        {
            [self setMasterKeyOnCamera];
        }
        else
        {
            // return to the beginning
            NSLog(@"EDITCAM : return to the beginning.Disconnect BLE ");
            [BLEConnectionManager getInstanceBLE].delegate =  nil;
            [[BLEConnectionManager getInstanceBLE] stopScanBLE];
            [BLEConnectionManager getInstanceBLE].needReconnect = NO;
            [[BLEConnectionManager getInstanceBLE] disconnect];

            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

@end
