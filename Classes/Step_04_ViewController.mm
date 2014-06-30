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

@interface Step_04_ViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITextField *tfCamName;
@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@end

@implementation Step_04_ViewController

@synthesize cameraMac, cameraName;
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
    self.tfCamName.text = self.cameraName;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.progressView removeFromSuperview];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

    [self.navigationController pushViewController:step05ViewController animated:NO];
    
    [step05ViewController release];
    
    self.btnContinue.enabled = YES;
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
   [cameraMac release];
    [_progressView release];
    [_btnContinue release];
    [_tfCamName release];
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
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
            
        
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
            
            NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                              @"Ok", nil);
            
            
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

        [self.progressView setHidden:NO];
        [self.view addSubview:self.progressView];
        [self.view bringSubviewToFront:self.progressView];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cameraName_text forKey:@"CameraName"];
        [userDefaults synchronize];
        
        /*20121129: phung skip authentication */
        
        //[self performSelectorInBackground:@selector(queryWifiList) withObject:nil];
        self.btnContinue.enabled = NO;
        [self moveToNextStep];
    }
}

#if 0

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
 
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
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

#endif


@end
