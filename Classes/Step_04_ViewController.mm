//
//  Setup_04_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_04_ViewController.h"
#import "define.h"
#import "HttpCom.h"
#import "HoldOnCamWifi.h"
#import "Step_05_ViewController.h"
#import "MBProgressHUD.h"
#import "Step_10_ViewController.h"
#import "PublicDefine.h"

@interface Step_04_ViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITextField *tfCamName;
@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UIButton *btnSkipWIFISetup;
@property (assign, nonatomic) IBOutlet UIImageView *lineImageView;

//@property (retain, nonatomic) CustomIOS7AlertView *alertView;

@end

@implementation Step_04_ViewController

@synthesize cameraName;
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
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    [barBtnHubble release];
    
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    
    self.tfCamName.delegate = self;
    
    if (_camProfile) // Focus73
    {
        self.cameraName = _camProfile.name;
#if 0
        // Need not to show anymore, as far as, the flow will be teminated!
        self.btnSkipWIFISetup.hidden = NO;
#endif
        
        [[HttpCom instance].comWithDevice setDevice_ip:_camProfile.ip_address];
        [[HttpCom instance].comWithDevice setDevice_port:_camProfile.port];
    }
    
    self.tfCamName.text = self.cameraName;
    
    if (isiPhone4)
    {
        self.tfCamName.frame = CGRectOffset(self.tfCamName.frame, 0, -75);
        self.lineImageView.frame = CGRectOffset(self.lineImageView.frame, 0, -75);
        self.btnSkipWIFISetup.frame = CGRectOffset(self.btnSkipWIFISetup.frame, 0, -75);
        self.btnContinue.frame = CGRectOffset(self.btnContinue.frame, 0, -80);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.progressView removeFromSuperview];
    [super viewWillDisappear:animated];
}

#pragma mark - Actions

- (void)hubbleItemAction:(id)sender
{
    [[HoldOnCamWifi shareInstance] stopHolder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Method

- (void)moveToNextStep
{
    NSLog(@"Load step 5");
    //Load the next xib
    Step_05_ViewController *step05ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        step05ViewController =  [[Step_05_ViewController alloc]
                                 initWithNibName:@"Step_05_ViewController_ipad" bundle:nil];
    }
    else
    {
        step05ViewController =  [[Step_05_ViewController alloc]
                                 initWithNibName:@"Step_05_ViewController" bundle:nil];
    }
    
    step05ViewController.camProfile = _camProfile;

    [self.navigationController pushViewController:step05ViewController animated:NO];
    
    [step05ViewController release];
    
    self.btnContinue.enabled = YES;
    
    //[self customIOS7dialogButtonTouchUpInside:_alertView clickedButtonAtIndex:0];
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

    [cameraName release];
    [_progressView release];
    [_btnContinue release];
    [_tfCamName release];
    [_btnSkipWIFISetup release];
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
    int tag = ((UIButton*)sender).tag; 
    
    NSString * cameraName_text = _tfCamName.text;
    
    [_tfCamName resignFirstResponder];
    
    if ([cameraName_text length] < MIN_LENGTH_CAMERA_NAME || [cameraName_text length] > MAX_LENGTH_CAMERA_NAME )
    {
        NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                             @"Invalid Camera Name", nil);
        
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg", nil, [NSBundle mainBundle],
                                                           @"Camera Name has to be between 5-30 characters", nil);
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
            
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                    delegate:nil
                                                    cancelButtonTitle:ok
                                                    otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else if (![self isCameraNameValidated:cameraName_text])
    {       NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                                 @"Invalid Camera Name", nil);
            
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg2", nil, [NSBundle mainBundle],
                                                               @"Camera name is invalid. Please enter [0-9],[a-Z], space, dot, hyphen, underscore & single quote only.", nil);
            
            NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
            
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                             message:msg
                                                            delegate:nil
                                                   cancelButtonTitle:ok
                                                   otherButtonTitles:nil];
            
            [alert show];
            [alert release];
    }
    else if (tag == CONF_CAM_BTN_TAG)
    {
        //show progress view
#if 0
        [self createHubbleAlertView];
#else
        [self.progressView setHidden:NO];
        [self.view addSubview:self.progressView];
        [self.view bringSubviewToFront:self.progressView];
#endif
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cameraName_text forKey:CAMERA_NAME];
        [userDefaults synchronize];
        
        /*20121129: phung skip authentication */
        
        //[self performSelectorInBackground:@selector(queryWifiList) withObject:nil];
        self.btnContinue.enabled = NO;
#if 1
        
        if (_camProfile) // This is a Focus73 model!
        {
            NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_VERSION];
            NSLog(@"%s response: %@", __FUNCTION__, response);
            
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^get_version: \\d{2}.\\d{2}.\\d{2}$"
                                                                                   options:NSRegularExpressionAnchorsMatchLines
                                                                                     error:&error];
            if (!regex)
            {
                NSLog(@"%s error:%@", __FUNCTION__, error.description);
            }
            else
            {
                if (response)
                {
                    //NSString *string = @"get_version: 01.56.78";
                    //NSString *string = nil; Exception!
                    NSUInteger numberOfMatches = [regex numberOfMatchesInString:response
                                                                        options:0
                                                                          range:NSMakeRange(0, [response length])];
                    NSLog(@"%s numberOfMatches:%d", __FUNCTION__, numberOfMatches);
                    
                    if (numberOfMatches == 1)
                    {
                        NSString *fwVersion = [[response componentsSeparatedByString:@": "] objectAtIndex:1];
                        
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:fwVersion forKey:FW_VERSION];
                        [userDefaults synchronize];
                    }
                }
            }
        }
        
        [self moveToNextStep];
#else
        if (_camProfile) // This is a Focus73 model!
        {
            [self performSelectorInBackground:@selector(configureCameraAndMoveToFinalStep) withObject:NO];
        }
        else
        {
            [self moveToNextStep];
        }
#endif
    }
#if 0
    // As far as,this flow will be terminated!
    else if (tag == TAG_BTN_SKIP)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cameraName_text forKey:CAMERA_NAME];
        [userDefaults synchronize];
        
        //MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        //hub.labelText = @"Waiting for configure camera...";
        [self createHubbleAlertView];
        
        [self performSelectorInBackground:@selector(configureCameraAndMoveToFinalStep) withObject:NO];
    }
#endif
}

#pragma mark - Hubble alert view & delegate

#if 0
- (void)configureCameraAndMoveToFinalStep
{
    [self configureCamera];
    
    [[NSUserDefaults standardUserDefaults] setObject:[CameraPassword fetchSSIDInfo] forKey:HOST_SSID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSelectorOnMainThread:@selector(moveToFinalStep) withObject:nil waitUntilDone:NO];
}

- (void)moveToFinalStep
{
    //[MBProgressHUD hideHUDForView:self.view animated:NO];
    //[self customIOS7dialogButtonTouchUpInside:_alertView clickedButtonAtIndex:0];
    
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

- (void)configureCamera
{
    /*
     * 1. Set Auth.
     * 2. Default on all of PN.
     * 3. Get UDID
     * 4. Restart systems.
     */
    
    // 1.
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    [formatter release];
    [stringFromDate insertString:@"." atIndex:3];
    
    NSString * set_auth_cmd = [NSString stringWithFormat:@"%@%@%@%@%@",
                               SET_SERVER_AUTH,
                               SET_SERVER_AUTH_PARAM1, [[NSUserDefaults standardUserDefaults] stringForKey:@"PortalApiKey"],
                               SET_SERVER_AUTH_PARAM2, stringFromDate];
    
    NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:set_auth_cmd
                                                                   withTimeout:10.0];
    NSLog(@"set auth -set_auth_cmd: %@, -response: %@ ", set_auth_cmd, response);
    
    // 2.
    [self defaultOnAllPNToCamera];
    
    // 3.
#if 1
    NSString *stringUDID = @"";
    NSString *stringMac = @"00:00:00:00:00";
    
    response = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_UDID
                                                         withTimeout:5.0];
    
    NSString *pattern = [NSString stringWithFormat:@"^%@: [0-9A-Z]{26}$", GET_UDID];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    if (!regex)
    {
        NSLog(@"%s error:%@", __FUNCTION__, error.description);
    }
    else
    {
        NSLog(@"%s respone:%@", __FUNCTION__, response);
        
        if (response)
        {
            //get_udid: 01008344334C32B0A0VFFRBSVA
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:response
                                                                options:0
                                                                  range:NSMakeRange(0, [response length])];
            NSLog(@"%s numberOfMatches:%lu", __FUNCTION__, (unsigned long)numberOfMatches);
            
            if (numberOfMatches == 1)
            {
                stringUDID = [response substringFromIndex:GET_UDID.length + 2];
                stringMac = [Util add_colon_to_mac:[stringUDID substringWithRange:NSMakeRange(6, 12)]];
            }
        }
    }
    //save mac address for used later
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:stringMac forKey:@"CameraMacWithQuote"];
    [userDefaults setObject:stringUDID forKey:CAMERA_UDID];
    [userDefaults synchronize];
#else
    NSString *stringUDID = @"";
    
    stringUDID = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_UDID
                                                           withTimeout:5.0];
    NSLog(@"%s stringUDID:%@", __FUNCTION__, stringUDID);
    
    //get_udid: 01008344334C32B0A0VFFRBSVA
    NSRange range = [stringUDID rangeOfString:@": "];
    
    if (range.location != NSNotFound)
    {
        //01008344334C32B0A0VFFRBSVA
        stringUDID = [stringUDID substringFromIndex:range.location + 2];
    }
    else
    {
        NSLog(@"Error - Received UDID wrong format - UDID: %@", stringUDID);
    }
    
    //save mac address for used later
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_camProfile.mac_address forKey:@"CameraMacWithQuote"];
    [userDefaults setObject:stringUDID forKey:CAMERA_UDID];
    [userDefaults synchronize];
#endif
    
    // 4.
    response = [[HttpCom instance].comWithDevice sendCommandAndBlock:RESTART_HTTP_CMD];
    
    NSLog(@"%s RESTART_HTTP_CMD: %@", __FUNCTION__, response);
}

- (void)defaultOnAllPNToCamera
{
    NSString *result = @"";
    
    NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"set_motion_area&grid=1x1&zone=00"];
    result = [result stringByAppendingString:response];
    
    if (!_camProfile) // Meaning this is not a Focus73 model!
    {
        response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"vox_enable"];
        result = [result stringByAppendingFormat:@", %@", response];
        
        response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"set_temp_lo_enable&value=1"];
        result = [result stringByAppendingFormat:@", %@", response];
        
        response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"set_temp_hi_enable&value=1"];
        result = [result stringByAppendingFormat:@", %@", response];
    }
    
    NSLog(@"%s respnse:%@", __FUNCTION__, result);
}

- (void)createHubbleAlertView
{
    // Here we need to pass a full frame
    
    if (_alertView == nil)
    {
        self.alertView = [[CustomIOS7AlertView alloc] init];
        // Add some custom content to the alert view
        [_alertView setContainerView:[self createDemoView]];
        
        // Modify the parameters
        //[alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Close1", @"Close2", @"Close3", nil]];
        [_alertView setButtonTitles:NULL];
        [_alertView setDelegate:self];
        
        // You may use a Block, rather than a delegate.
        [_alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
            [alertView close];
        }];
        
        [_alertView setUseMotionEffects:true];
    }
    
    // And launch the dialog
    [_alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    [alertView close];
}

- (UIView *)createDemoView
{
    UIView *demoView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 140)] autorelease];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 35, 30, 30)];// autorelease];
    [imageView setImage:[UIImage imageNamed:@"loader_a"]];
    
    imageView.animationImages = @[[UIImage imageNamed:@"loader_a"],
                                  [UIImage imageNamed:@"loader_b"],
                                  [UIImage imageNamed:@"loader_c"],
                                  [UIImage imageNamed:@"loader_d"],
                                  [UIImage imageNamed:@"loader_e"],
                                  [UIImage imageNamed:@"loader_f"]];
    imageView.animationRepeatCount = 0;
    imageView.animationDuration = 1.5f;
    [imageView startAnimating];
    
    [demoView addSubview:imageView];
    
    [imageView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 200, 41)];// autorelease];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.text = @"Waiting for configure camera...";
    [demoView addSubview:label];
    [label release];
    
    return demoView;
}

//#if 0
{
-(void) queryWifiList
{
    NSData * router_list_raw;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION]; // 01.12.58
    
    BOOL newCmdFlag = TRUE;
    
    if ([fwVersion compare:FW_MILESTONE] >= NSOrderedSame) // fw >= FW_MILESTONE
    {
        router_list_raw = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:GET_ROUTER_LIST2
                                                                        withTimeout:2*DEFAULT_TIME_OUT];
    }
    else
    {
        newCmdFlag = FALSE;
        router_list_raw = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:GET_ROUTER_LIST
                                                                        withTimeout:2*DEFAULT_TIME_OUT];
    }
    
    if (router_list_raw != nil)
    {
        WifiListParser * routerListParser = nil;
        routerListParser = [[WifiListParser alloc]initWithNewCmdFlag:newCmdFlag];
        
        [routerListParser parseData:router_list_raw
                       whenDoneCall:@selector(setWifiResult:)
                             target:self];
    }
    else
    {
        NSLog(@"GOT NULL wifi list from camera");
        [self askForRetry]; 
    }
}


//Double the timeout.. 
-(void) queryWifiList_2
{
    NSData * router_list_raw;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION]; // 01.12.58
    
    BOOL newCmdFlag = TRUE;
    
    if ([fwVersion compare:FW_MILESTONE] >= NSOrderedSame) // fw >= FW_MILESTONE
    {
        router_list_raw = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:GET_ROUTER_LIST2
                                                                        withTimeout:2*DEFAULT_TIME_OUT];
    }
    else
    {
        newCmdFlag = FALSE;
        router_list_raw = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:GET_ROUTER_LIST
                                                                        withTimeout:2*DEFAULT_TIME_OUT];
    }
    
    if (router_list_raw != nil)
    {
        WifiListParser * routerListParser = nil;
        routerListParser = [[WifiListParser alloc]initWithNewCmdFlag:newCmdFlag];
        
        [routerListParser parseData:router_list_raw
                       whenDoneCall:@selector(setWifiResult:)
                             target:self];
    }
    else
    {
        NSLog(@"GOT NULL wifi list from camera");
        [self askForRetry];
    }
}

#define ALERT_ASK_FOR_RETRY_WIFI 1

- (void) askForRetry
{
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Fail_to_communicate_with_camera",nil, [NSBundle mainBundle],
                                                       @"Fail to communicate with camera. Retry?", nil);
 
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil);
    
    NSString * retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
                                                      @"Retry", nil);
    

    
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:msg
                                          message:@""
                                         delegate:self
                                cancelButtonTitle:cancel
                                otherButtonTitles:retry,nil];
    
    myAlert.tag = ALERT_ASK_FOR_RETRY_WIFI;
    myAlert.delegate = self;
    
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [myAlert setTransform:myTransform];
    [myAlert show];
    [myAlert release];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == ALERT_ASK_FOR_RETRY_WIFI)
    {
        switch(buttonIndex) {
            case 0:
                
                //TODO: Go back to camera detection screen
                
                break;
            case 1:
                NSLog(@"OK button pressed");
                
                //retry ..
                [self queryWifiList_2];
                
                break;
        }
    }
}


-(void) setWifiResult:(NSArray *) wifiList
{
    NSLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count); 
    //hide progressView
    [self.progressView removeFromSuperview];
    [self.progressView setHidden:YES];
   
    
    
#if 1
     WifiEntry * entry; 
    
    
    for (int i =0; i< wifiList.count; i++)
    {
        entry = [wifiList objectAtIndex:i]; 
        
        
        NSLog(@"entry %d : %@",i, entry.ssid_w_quote);
        NSLog(@"entry %d : %@",i, entry.bssid);
        NSLog(@"entry %d : %@",i, entry.auth_mode);
        NSLog(@"entry %d : %@",i, entry.quality);
    }
#endif 
    
    
    
    NSLog(@"Load step 5"); 
    //Load the next xib
    Step_05_ViewController *step05ViewController = nil; 
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        step05ViewController =  [[Step_05_ViewController alloc]
                                 initWithNibName:@"Step_05_ViewController_ipad" bundle:nil];
    }
    else
    {
        step05ViewController =  [[Step_05_ViewController alloc]
                                 initWithNibName:@"Step_05_ViewController" bundle:nil];
    }
    
    step05ViewController.listOfWifi = [[[NSMutableArray alloc]initWithArray:wifiList] autorelease];
    
    [self.navigationController pushViewController:step05ViewController animated:NO];
    
    [step05ViewController release];
}
}
#endif


@end
