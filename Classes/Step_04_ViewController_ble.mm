//
//  Setup_04_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_04_ViewController_ble.h"

@interface Step_04_ViewController_ble ()

@end

@implementation Step_04_ViewController_ble


@synthesize cameraMac, cameraName;
@synthesize alertView = _alertView;
@synthesize result_received = _result_received;

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
                                    action:@selector(handleNextBtnTouchAction:)];
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
    _waitingResponse = NO;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    if(_timeout)
//    {
//        [_timeout invalidate];
//        _timeout = nil;
//    }
//    if (_getWifiListTimer)
//    {
//        [_getWifiListTimer invalidate];
//        _getWifiListTimer = nil;
//    }
}
- (void)handleNextBtnTouchAction: (id)sender
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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cameraName_text forKey:@"CameraName"];
    [userDefaults synchronize];
    
    
    comm = [[HttpCommunication alloc]init];
    comm.device_ip = @"192.168.2.1";//here camera is still in directmode
    comm.device_port = 80;
    
    
    /*20121129: phung skip authentication */
    
    [self queryWifiList];
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
    int tag = ((UIButton*)sender).tag;
    
    NSString * cameraName_text = @"";
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        
        cameraName_text =((UITextView *)camName).text  ;
        
    }
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        
        cameraName_text =((UITextField *)camName).text;
    }
    
    
    
    if ([cameraName_text length] < 3 || [cameraName_text length] > 15 )
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
    {       NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
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
    else if (tag == CONF_CAM_BTN_TAG)
    {
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cameraName_text forKey:@"CameraName"];
        [userDefaults synchronize];
        
        
        comm = [[HttpCommunication alloc]init];
        comm.device_ip = @"192.168.2.1";//here camera is still in directmode
        comm.device_port = 80;
        
        
        /*20121129: phung skip authentication */
        [self queryWifiList];
        
    }
}

- (void)sendCommandGetWifiList:(NSTimer *) info
{
    if (_waitingResponse)
        return;
    if (self.result_received != nil && [self.result_received length] > 0)
    {
        if(_timeout)
        {
            [_timeout invalidate];
            _timeout = nil;
        }
        if (_getWifiListTimer)
        {
            [_getWifiListTimer invalidate];
            _getWifiListTimer = nil;
        }
        return;
    }
    //retry sending get wifi
    NSLog(@"Check [BLEManageConnect getInstanceBLE] is %@", [BLEManageConnect getInstanceBLE]);
    [BLEManageConnect getInstanceBLE].delegate = self;
    [[BLEManageConnect getInstanceBLE].uartPeripheral writeString:GET_ROUTER_LIST];
    _waitingResponse = YES;
    NSDate * date;
    while ([BLEManageConnect getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
}

-(void) queryWifiList
{
    //create dialog process
    [self.statusDialog setHidden:NO];


    _timeout = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(showDialog:) userInfo:nil repeats:NO];
    _getWifiListTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                         target:self
                                                       selector:@selector(sendCommandGetWifiList:)
                                                       userInfo:nil
                                                        repeats:YES];



}

- (void) showDialog:(NSTimer *)timer
{
    [self askForRetry];
}
//Double the timeout..
-(void) queryWifiList_2
{
    _waitingResponse = NO;
    _result_received = nil;
    //reset timer
    if (_timeout)
    {
        [_timeout invalidate];
        _timeout = nil;
    }
    if (_getWifiListTimer)
    {
        [_getWifiListTimer invalidate];
        _getWifiListTimer = nil;
    }
    //and create it again
    _timeout = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(showDialog:) userInfo:nil repeats:NO];
    _getWifiListTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                         target:self
                                                       selector:@selector(sendCommandGetWifiList:)
                                                       userInfo:nil
                                                        repeats:YES];
    
#if 0
    NSData * router_list_raw;
    router_list_raw = [comm sendCommandAndBlock_raw:GET_ROUTER_LIST withTimeout:2*DEFAULT_TIME_OUT];
    if (router_list_raw != nil)
    {
        WifiListParser * routerListParser = nil;
        routerListParser = [[WifiListParser alloc]init];
        
        [routerListParser parseData:router_list_raw
                       whenDoneCall:@selector(setWifiResult:)
                             target:self];
    }
    else
    {
        NSLog(@"GOT NULL wifi list from camera");
        [self askForRetry];
    }
#endif
}

#define ALERT_ASK_FOR_RETRY_WIFI 1

- (void) askForRetry
{
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Fail_to_communicate_with_camera",nil, [NSBundle mainBundle],
                                                       @"Fail to communicate with camera. Retry?", nil);
    
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
    NSString * retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
                                                         @"Retry", nil);
    
    
    
    UIAlertView *_myAlert = nil ;
    _myAlert = [[UIAlertView alloc] initWithTitle:msg
                                          message:@""
                                         delegate:self
                                cancelButtonTitle:cancel
                                otherButtonTitles:retry,nil];
    
    _myAlert.tag = ALERT_ASK_FOR_RETRY_WIFI;
    _myAlert.delegate = self;
    
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [_myAlert setTransform:myTransform];
    [_myAlert show];
    [_myAlert release];
    
}

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

- (void)errorCallback: (NSError *)error
{
    NSLog(@"error return is %@", error);
    [self queryWifiList_2];
}
-(void) setWifiResult:(NSArray *) wifiList
{
    [self.statusDialog setHidden:YES];
    NSLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count);
    
    
    
    
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}



- (void) didReceiveData:(NSString *)string
{
    self.result_received = string;
    _waitingResponse = NO;
    NSLog(@"Data Receiving router list is %@", string);
    {
        //processing data receive wifi list
        
        if (string !=nil && [string length] > 0)
        {
            NSData *router_list_raw = [string dataUsingEncoding:NSUTF8StringEncoding];
            
            if (router_list_raw != nil)
            {
                WifiListParser * routerListParser = nil;
                routerListParser = [[WifiListParser alloc]init];
                
//                [routerListParser parseData:router_list_raw
//                               whenDoneCall:@selector(setWifiResult:)
//                                     target:self];
                [routerListParser parseData:router_list_raw
                               whenDoneCall:@selector(setWifiResult:)
                              whenErrorCall:@selector(errorCallback:)
                                     target:self];
            }
            else
            {
                NSLog(@"GOT NULL wifi list from camera");
                [self askForRetry];
            }
        }
        
    }
}

- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera
{
    NSLog(@"error_code is %d and command is %@**************", error_code, commandToCamera);
}
#pragma mark - CBCentralManagerDelegate
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        
    }
}


@end
