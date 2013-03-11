//
//  Setup_04_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_04_ViewController.h"

@interface Step_04_ViewController ()

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
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Camera_Detected",nil, [NSBundle mainBundle],
                                                                  @"Camera Detected" , nil);
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    camName.text = self.cameraName;
    
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
    
    NSString * tempName = camName.text;
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController_land_ipad" owner:self options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController_land" owner:self options:nil];
            
            
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController_ipad" owner:self options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController" owner:self options:nil];
        }
    }
    
    
    camName.text = tempName;
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

-(BOOL) checkValidateString: (NSString *) string with: (NSRegularExpression *) regex
{
    NSTextCheckingResult * matchs = [regex firstMatchInString:string
                                                     options:0
                                                       range:NSMakeRange(0,[string length])];
    
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0,[matchs length])];
    if (NSEqualRanges(rangeOfFirstMatch,NSMakeRange(NSNotFound,0)))
    {
        NSString *substringForFirstMatch = [string substringWithRange:rangeOfFirstMatch];
        NSLog(@"WTF ??? ------------------> %@",substringForFirstMatch);
        
        return NO;
    }
    
    return YES;
}

-(BOOL) isCameraNameValidated:(NSString *) cameraNames
{
    
    NSString * validString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.'_-";


    
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
    
    if ([camName.text length] < 3 || [camName.text length] > 15 )
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
    else if (![self isCameraNameValidated:camName.text])
    {       NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                                 @"Invalid Camera Name", nil);
            
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg2", nil, [NSBundle mainBundle],
                                                               @"Camera Name has some invalid characters", nil);
            
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
//        NSString * string = [NSString stringWithString:camName.text];
//        NSError * error = nil;
        
//        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9' \\._-]+$" options:0 error:&error];
        
//        [self checkValidateString:string with:regex];
        
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:camName.text forKey:@"CameraName"];
        [userDefaults synchronize];
        
        
        comm = [[HttpCommunication alloc]init];
        comm.device_ip = @"192.168.2.1";//here camera is still in directmode
        comm.device_port = 80;
        
        
        /*20121129: phung skip authentication */
        
        [self queryWifiList];
        
#if 0
        //Authenticate first
        [comm babymonitorAuthentication];
        
        
        [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04 
                                         target:self
                                       selector:@selector(isAuthenticationDone:)
                                       userInfo:nil
                                        repeats:NO];
#endif 
        

    }
}


#if 0
- (void) isAuthenticationDone:(NSTimer *) expired
{
	if (comm.authInProgress == FALSE)
	{
		NSLog(@"bm auth passed!");
		[self queryWifiList];
		
	}
	else 
	{
		[NSTimer scheduledTimerWithTimeInterval:1//0.04 
										 target:self
									   selector:@selector(isAuthenticationDone:)
									   userInfo:nil
										repeats:NO];
	}
	
}
#endif 


-(void) queryWifiList
{
    NSData * router_list_raw; 
       
    
    router_list_raw = [comm sendCommandAndBlock_raw:GET_ROUTER_LIST];
    
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
}


//Double the timeout.. 
-(void) queryWifiList_2
{
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


-(void) setWifiResult:(NSArray *) wifiList
{
    NSLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count); 
    
   
    
    
#if 0
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
    
    
    
    step05ViewController.listOfWifi = [[NSMutableArray alloc]initWithArray:wifiList];
    
    [self.navigationController pushViewController:step05ViewController animated:NO];
    
    [step05ViewController release];
    
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}



@end
