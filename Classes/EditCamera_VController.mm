//
//  Setup_04_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "EditCamera_VController.h"

@interface EditCamera_VController ()

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
	// Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Camera_Detected",nil, [NSBundle mainBundle],
                                                                  @"Camera Detected" , nil);
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    UIBarButtonItem *nextButton =
    [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringWithDefaultValue(@"Next",nil, [NSBundle mainBundle],
                                                                              @"Next", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleButtonPress:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        NSLog(@"Cast to UI TextView");
        ((UITextView *)camName).text = self.cameraName;
        
    }
    
    
    
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        NSLog(@"Cast to UI Textfield");
        ((UITextField *)camName).text = self.cameraName;
        
    }
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

- (void)viewWillDisappear:(BOOL)animated
{
    //remove delegate
    [BLEConnectionManager getInstanceBLE].delegate = nil;
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
    NSString * tempName = @"";
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        
        tempName = ((UITextView *)camName).text;
        
    }
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        
        tempName = ((UITextField *)camName).text ;
        
    }
    
    
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        //        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        //        {
        //            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController_land_ipad" owner:self options:nil];
        //        }
        //        else
        //        {
        //            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController_land" owner:self options:nil];
        //
        //
        //        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        //        {
        //            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController_ipad" owner:self options:nil];
        //        }
        //        else
        //        {
        //            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController" owner:self options:nil];
        //        }
    }
    
    
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        
        
        ((UITextView *)camName).text  = tempName;
        
    }
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        
        ((UITextField *)camName).text = tempName ;
    }
    
    
    
}
#pragma mark -
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

-(void) dealloc
{
    
    [cameraName release];
    [cameraMac release];
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

- (IBAction)handleButtonPress:(id)sender
{
    NSString * cameraName_text = @"";
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        
        cameraName_text =((UITextView *)camName).text  ;
        
    }
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        
        cameraName_text =((UITextField *)camName).text;
    }
    
    
    
    if ([cameraName_text length] < 3 || [cameraName_text length] > CAMERA_NAME_MAX )
    {
        NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                             @"Invalid Camera Name", nil);
        
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg", nil, [NSBundle mainBundle],
                                                           @"Camera Name has to be between 3-15 characters", nil);
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        
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
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        
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
        [userDefaults setObject:cameraName_text forKey:@"CameraName"];
        [userDefaults synchronize];
        
        //
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
    
    [wifiListVController release];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}

#pragma mark -
#pragma mark  Callbacks

- (void) addCamSuccessWithResponse:(NSDictionary *)responseData
{
    NSLog(@"addcam response: %@", responseData);
    _auth_token = [[responseData objectForKey:@"data"] objectForKey:@"auth_token"];
    /*
     TODO:
     - send auto_token to camera
     */
    [self sendCommandAuth_TokenToCamera];
    [self showScreenGetWifiList];

}

- (void)sendCommandAuth_TokenToCamera
{
    NSString * set_mkey = SET_MASTER_KEY;
    set_mkey =[set_mkey stringByAppendingString:_auth_token];
    
    if ([BLEConnectionManager getInstanceBLE].state != CONNECTED)
    {
        return;
    }
    
    NSLog(@"Now, send command Authentication token");
    //first get mac address of camera
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:set_mkey withTimeOut:30.0];
    
    NSDate * date;
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    
}
- (void) addCamFailedWithError:(NSDictionary *) error_response
{
    if (error_response == nil) {
        NSLog(@"error_response = nil");
        return;
    }
    NSLog(@"addcam failed with error code:%d", [[error_response objectForKey:@"status"] intValue]);
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Server_error_" ,nil, [NSBundle mainBundle],
                                                       @"Server error: %@" , nil);
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
	//ERROR condition
    
    //TODO: display alert retry registerCame
    
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                                          @"AddCam Error" , nil)
						  message:[error_response objectForKey:@"message"]
						  delegate:self
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	return;
}

- (void) addCamFailedServerUnreachable
{
	NSLog(@"addcam failed : server unreachable");


        
    NSString * msg = NSLocalizedStringWithDefaultValue(@"addcam_error_1" ,nil, [NSBundle mainBundle],
                                                       @"The device is not able to connect to the server. Please check the WIFI and the internet. Go to WIFI setting to confirm device is connected to intended router", nil);
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
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
    NSString *fwVersion = [userDefaults objectForKey:@"FW_VERSION"];
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
    
    NSString * camName = (NSString *) [userDefaults objectForKey:@"CameraName"];
    [jsonComm registerDeviceWithDeviceName:camName
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
        NSLog(@"can't send master key, camera is not fully up");
    }
    else
    {
        if ([string hasPrefix:@"set_master_key: 0"])
        {
            ///done
            NSLog(@"sending master key done");
        }
        
    }
    

}



#pragma mark -
#pragma mark AlertView delegate



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: // Cancel
            
            break;
        case 1: // Retry
            [self registerCamera:nil];
            break;
        default:
            break;
    }

}

@end
