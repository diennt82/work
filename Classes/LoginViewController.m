//
//  LoginViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 2/10/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "StunClient.h"
//#import "Reachability.h"
#import "ForgotPwdViewController.h"
#import "UserAccount.h"
#import "PublicDefine.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "KISSMetricsAPI.h"
#import "TimelineDatabase.h"
#import "RegistrationViewController.h"
#import "MBP_iosViewController.h"
#import "MBP_iosAppDelegate.h"

#define MOVEMENT_DURATION   0.3 //movementDuration
#define _Use3G              @"use3GToConnect"
#define GAI_CATEGORY        @"Login view"

@interface LoginViewController ()  <UITextFieldDelegate, StunClientDelegate, UserAccountDelegate>

@property (retain, nonatomic) IBOutlet UIView *viewProgress;
@property (retain, nonatomic) IBOutlet UITextField *tfEmail;
@property (retain, nonatomic) IBOutlet UITextField *tfPassword;
@property (retain, nonatomic) IBOutlet UIButton *buttonEnter;

@property (nonatomic, assign) id<ConnectionMethodDelegate> delegate;
@property (nonatomic, retain) NSString *stringUsername;
@property (nonatomic, retain) NSString *stringUserEmail;
@property (nonatomic, retain) NSString *stringPassword;
@property (nonatomic) BOOL buttonEnterPressedFlag;
@property (nonatomic,retain) StunClient *client;

@property (retain, nonatomic) IBOutlet UIImageView *imgViewLoading;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate: (id<ConnectionMethodDelegate>) d
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.delegate = d;
    }
    return self;
}

- (id)initWithDelegate: (id<ConnectionMethodDelegate>) d
{
    self = [super init];
    
    if (self) {
        // Custom initialization
        self.delegate = d;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (UIScreen.mainScreen.bounds.size.height < 568)
    {
        [[NSBundle mainBundle] loadNibNamed:@"LoginViewController_35"
                                      owner:self
                                    options:nil];
    }
    
    [self.view addSubview:self.viewProgress];
    self.stringPassword  = @"";
    
    [self.buttonEnter setBackgroundImage:[UIImage imageNamed:@"enter"]
                                forState:UIControlStateNormal];
    [self.buttonEnter setBackgroundImage:[UIImage imageNamed:@"enter_pressed"]
                                forState:UIControlEventTouchDown];
    self.tfEmail.delegate = self;
    self.tfPassword.delegate = self;
    
    self.buttonEnterPressedFlag = NO;
    
    self.imgViewLoading.animationImages =[NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"loader_big_a"],
                                          [UIImage imageNamed:@"loader_big_b"],
                                          [UIImage imageNamed:@"loader_big_c"],
                                          [UIImage imageNamed:@"loader_big_d"],
                                          [UIImage imageNamed:@"loader_big_e"],
                                          //[UIImage imageNamed:@"Logo_220"],
                                          nil];
    self.imgViewLoading.animationDuration = 1.5;
    [self.imgViewLoading startAnimating];
    
    
#if !TARGET_IPHONE_SIMULATOR
    if ([self isConnectingToCameraNetwork])
    {
        NSString * msg = NSLocalizedStringWithDefaultValue(@"phone_is_connected_to_camera" ,nil, [NSBundle mainBundle],
                                                           @"You are connecting to a Camera network which does not have internet access.Please go to wifi settings and switch to another WIFI." ,nil);
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"ok" ,nil, [NSBundle mainBundle],
                                                          @"OK", nil);
        
        //ERROR condition
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:msg
                              delegate:self
                              cancelButtonTitle:ok
                              otherButtonTitles: nil];
        alert.tag = 114;
        [alert show];
        [alert release];
        
    }
    else
#endif
    {
    
        //load user/pass
        [self performSelectorInBackground:@selector(loadUserInfo_bg) withObject:nil];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    self.trackedViewName = GAI_CATEGORY;
    
    MBP_iosViewController *mainVC = (MBP_iosViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    mainVC.app_stage = APP_STAGE_LOGGING_IN;
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Logging_in_to_server" ,nil, [NSBundle mainBundle],
                                                       @"Logging in to server..." , nil);
    UILabel *labelMessage = (UILabel *)[_viewProgress viewWithTag:509];
    [labelMessage setText:msg];
    
    NSString * old_usr = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"PortalUsername"];
    self.tfEmail.text = old_usr;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIButton *btnForgotPassword = (UIButton *)[self.view viewWithTag:955];
        btnForgotPassword.frame = CGRectMake(_buttonEnter.frame.origin.x, btnForgotPassword.frame.origin.y, btnForgotPassword.frame.size.width, btnForgotPassword.frame.size.height);
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[KISSMetricsAPI sharedAPI] recordEvent:@"Login Screen" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"viewDidAppear"
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self performSelector:@selector(crash) withObject:nil];
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)loadUserInfo_bg
{
    [self performSelectorOnMainThread:@selector(loadUserInfo) withObject:nil waitUntilDone:NO];
}

- (void)loadUserInfo
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	//can be user email or user name here --
	NSString * old_usr = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
	NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * old_api_key = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
    
    self.stringUserEmail  = (NSString*) [userDefaults objectForKey:@"PortalUseremail"];
    BOOL shouldAutoLogin = [userDefaults boolForKey:_AutoLogin];
    
    /* Reset SYM NAT status here */
    [userDefaults setInteger:TYPE_UNKNOWN forKey:APP_IS_ON_SYMMETRIC_NAT];
    [userDefaults synchronize];
    
    if (old_usr != nil)
    {
        self.stringUsername = [NSString stringWithString:old_usr];
        self.tfEmail.text = old_usr;
        
        if (shouldAutoLogin &&
            old_api_key != nil && old_pass != nil )
        {
            /* Don't need to go thru the login query again */
            NSLog(@" Use old api key");
            self.stringPassword = [NSString stringWithString:old_pass];
            self.viewProgress.hidden = NO;
            self.tfPassword.text = old_pass;
            
            self.buttonEnterPressedFlag = YES;
            [self moveOnAfterLoginOk:old_api_key];
            
        }
        else if (shouldAutoLogin &&
                 old_pass != nil)
        {
            self.stringPassword = [NSString stringWithString:old_pass];
            self.viewProgress.hidden = NO;
            self.tfPassword.text = old_pass;
            
            self.buttonEnterPressedFlag = YES;
            [self check3GConnectionAndPopup];
        }
        else
        {
            
            
            [userDefaults removeObjectForKey:CAM_IN_VEW];
            [userDefaults synchronize];
            self.viewProgress.hidden = YES;
            self.buttonEnter.enabled = NO;
            
            if ( old_pass != nil)
            {
                self.tfPassword.text = old_pass;
                self.buttonEnterPressedFlag = NO;
                self.buttonEnter.enabled = YES;
            }
            
        }
    }
    else
    {
        [userDefaults removeObjectForKey:CAM_IN_VEW];
        [userDefaults synchronize];
        self.viewProgress.hidden = YES;
        self.buttonEnter.enabled = NO;
        NSLog(@"LoginVC - No login");
    }
    
    //self.viewProgress.hidden = NO;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UserAccount delegate

- (void)finishStoreCameraListData:(NSMutableArray *)arrayCamProfile success:(BOOL)success
{
    if (success)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        if (_delegate)
        {
            [_delegate sendStatus:SHOW_CAMARA_TIMELINE];
        }
    }
    else
    {
        BOOL shouldCancelRegisterApp = FALSE;
        
        if (arrayCamProfile) // Fake data to handle error response!
        {
            if ([[arrayCamProfile objectAtIndex:0] integerValue] == 401 &&
                [[arrayCamProfile objectAtIndex:1] hasPrefix:@"Access Denied."])//Access Denied.
            {
                [self performSelectorInBackground:@selector(logout) withObject:nil];
            }
            else
            {
                shouldCancelRegisterApp = TRUE;
            }
        }
        else
        {
            shouldCancelRegisterApp = TRUE;
            
            NSLog(@"%s", __FUNCTION__);
            
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error",nil, [NSBundle mainBundle],
                                                               @"Get Camera list Error", nil);
            
            NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error_msg1",nil, [NSBundle mainBundle],
                                                                @"Server unreachable", nil);
            
            NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                              @"Ok", nil);
            
            
            //ERROR condition
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:msg
                                  message:msg1
                                  delegate:nil
                                  cancelButtonTitle:ok
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
        if (shouldCancelRegisterApp)
        {
            MBP_iosAppDelegate *appDelegate = (MBP_iosAppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate cancelRegisterApp];
            
            self.buttonEnterPressedFlag = NO;
            self.buttonEnter.enabled = YES;
            self.viewProgress.hidden = YES;
        }
    }
}

#pragma mark - Action

- (IBAction)buttonForgotPasswordTouchUpInsideAction:(id)sender
{
    NSLog(@"Load fpwd");
    //Load the next xib
    ForgotPwdViewController *forgotPwdController = [[ForgotPwdViewController alloc]
                                                    initWithNibName:@"ForgotPwdViewController" bundle:nil];
    
    [self.navigationController pushViewController:forgotPwdController animated:YES];
    [forgotPwdController release];
}

- (IBAction)buttnEnterTouchUpInsideAction:(id)sender
{
    self.buttonEnterPressedFlag = YES;
    [self.view endEditing:YES];
    
    self.stringUsername = [NSString stringWithString:_tfEmail.text];
    self.stringPassword = [NSString stringWithString:_tfPassword.text];
    
    [self check3GConnectionAndPopup];
}

- (IBAction)buttonCreateAccountTouchUpInsideAction:(id)sender
{
    [self.view endEditing:YES];
    NSLog(@"LoginVC - createNewAccount ---");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:TRUE forKey:FIRST_TIME_SETUP];
    [userDefaults synchronize];
    
    RegistrationViewController *registrationVC = [[RegistrationViewController alloc] init];
    registrationVC.delegate = _delegate;
    [self.navigationController pushViewController:registrationVC animated:YES];
    
    MBP_iosViewController *mainVC = (MBP_iosViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    mainVC.app_stage = SETUP_CAMERA;
    
    [registrationVC release];
}

#pragma mark - PJNATH Callbacks

-(void)symmetric_check_result: (BOOL) isBehindSymNat
{
    NSInteger result = (isBehindSymNat == TRUE)?TYPE_SYMMETRIC_NAT:TYPE_NON_SYMMETRIC_NAT;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:result forKey:APP_IS_ON_SYMMETRIC_NAT];
    [userDefaults synchronize];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [_client shutdown];
                       // [self.client release];
                   }
                   );
}

#pragma mark - Methods

- (void)logout
{
    @autoreleasepool
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //REmove password and registration id
        [userDefaults removeObjectForKey:@"PortalPassword"];
        [userDefaults removeObjectForKey:_push_dev_token];
        
#if  !TARGET_IPHONE_SIMULATOR
        
        NSLog(@"De-Register push with both parties: APNs and BMS ");
        
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *appId = [userDefaults objectForKey:@"APP_ID"];
        NSString * userName = [userDefaults objectForKey:@"PortalUsername"];
        
        [userDefaults removeObjectForKey:@"PortalApiKey"];
        [userDefaults removeObjectForKey:@"PortalUseremail"];
        [userDefaults synchronize];
        
        // Let the device know we want to receive push notifications
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        
        /* Drop all timeline for this user */
        [[TimelineDatabase getSharedInstance] clearEventForUserName:userName];
        
        
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                 Selector:nil
                                                                             FailSelector:nil
                                                                                ServerErr:nil];
        
        NSDictionary *responseDict = [jsonComm deleteAppBlockedWithAppId:appId
                                                               andApiKey:apiKey];
        [jsonComm release];
        NSLog(@"logout --> delete app status = %d", [[responseDict objectForKey:@"status"] intValue]);
        
        [NSThread sleepForTimeInterval:0.10];
#endif
        
        
    }
    
    self.buttonEnterPressedFlag = NO;
    self.buttonEnter.enabled = YES;
	self.viewProgress.hidden = YES;
}
/* check if phone is connected to 3g network 
   Also check if phone is connected to camera network (!!#@!#) 
 */
- (void)check3GConnectionAndPopup
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL skip_3g_popup = [userDefaults boolForKey:_Use3G];
    
    if (  (skip_3g_popup ==FALSE)  && [self isCurrentConnection3G])
    {
        //Popup now..
        self.buttonEnter.enabled = YES;
        
        NSLog(@"Wifi is not available ");
        self.viewProgress.hidden = YES;
        
        NSString * msg = NSLocalizedStringWithDefaultValue(@"wifi_not_available" ,nil, [NSBundle mainBundle],
                                                           @"Mobile data is enabled. If you continue to connect, you may incur air time charges. Do you want to proceed?" ,nil);
        
        NSString * no = NSLocalizedStringWithDefaultValue(@"No" ,nil, [NSBundle mainBundle],
                                                          @"No", nil);
        
        NSString * yes = NSLocalizedStringWithDefaultValue(@"Yes" ,nil, [NSBundle mainBundle],
                                                           @"Yes", nil);
        
        NSString * yes1 = NSLocalizedStringWithDefaultValue(@"Yes_n" ,nil, [NSBundle mainBundle],
                                                            @"Yes and don't ask again", nil);
        
        //ERROR condition
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:msg
                              delegate:self
                              cancelButtonTitle:no
                              otherButtonTitles:yes,yes1, nil];
        alert.tag = 113;
        [alert show];
        [alert release];
    }
    
    else
    {
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Logging_in_to_server" ,nil, [NSBundle mainBundle],@"Logging in to server..." , nil);
               
        self.viewProgress.hidden = NO;
        UILabel *labelMessage = (UILabel *)[_viewProgress viewWithTag:509];
        [labelMessage setText:msg];
        self.buttonEnter.enabled = NO;
        
        //Is on WIFI -> proceed
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(doSignIn:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

-(BOOL) isCurrentConnection3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == ReachableViaWWAN)
    {
        //3G
        return TRUE;
    }
    
    return FALSE;
}
-(BOOL) isConnectingToCameraNetwork
{
    NSString * current_ssid = [CameraPassword fetchSSIDInfo] ;

    if ([current_ssid hasPrefix:DEFAULT_SSID_HD_PREFIX] ||
        [current_ssid hasPrefix:DEFAULT_SSID_PREFIX]
        )
    {
        return TRUE;
        
    }
    
    return FALSE;
}

- (void)doSignIn:(NSTimer *) exp
{
    self.navigationController.navigationBarHidden = YES;
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(loginSuccessWithResponse:)
                                                                          FailSelector:@selector(loginFailedWithError:)
                                                                             ServerErr:@selector(loginFailedServerUnreachable)] autorelease];
    
    [jsonComm loginWithLogin:_stringUsername andPassword:_stringPassword];
    
    NSLog(@"start logging");
#if 1
    // Ignore symmetric nath value nat. Force app to it
#else
    if (_client == nil)
    {
        _client = [StunClient alloc]; //init];
    }
    
    //If we have not checked -- then start checking, else just skip this step
    if ( [_client isCheckingForSymmetrictNat]  == FALSE )
    {
        //init
        [_client init];
        [_client test_start_async:self];
    }
#endif
}

#pragma mark TextView  delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _tfEmail) // Username
    {
        [self.tfPassword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _tfPassword)
    {
        if ( ([textField.text length] + [string length] ) >2)
        {
            self.buttonEnter.enabled = YES;
        }
        else
        {
            self.buttonEnter.enabled = NO;
        }
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
    //const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: MOVEMENT_DURATION];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Alertview delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	int tag = alertView.tag;
#if 0
	if (tag == 112) //OFFLINE mode ??
    {
        switch (buttonIndex) {
            case 0:
                break;
                
            case 1://Yes - go offline mode
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:YES forKey:_OfflineMode];
                [userDefaults synchronize];
                
                //Show Camera list
                NSLog(@"LoginVC- didDismissWithButtonIndex: %p", _delegate);

                [self.navigationController popToRootViewControllerAnimated:YES];
                
                if (_delegate)
                {
                    [_delegate sendStatus:SHOW_CAMARA_TIMELINE];
                }
            }
                break;
                
            default:
                break;
        }
    }
    else
#endif
        if (tag == 113) // 3g check
    {
        switch (buttonIndex)
        {
            case 0:
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:NO forKey:_Use3G];
                [userDefaults synchronize];
                
                break;
            }
            case 1: // Yes - go by 3g
            {
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Logging_in_to_server" ,nil, [NSBundle mainBundle],
                                                                   @"Logging in to server..." , nil);
                self.viewProgress.hidden = NO;
                UILabel *labelProgress = (UILabel *)[_viewProgress viewWithTag:509];
                [labelProgress setText:msg];
                self.buttonEnter.enabled = YES;
                
                //signal iosViewController
                [self doSignIn:nil];
                
                break;
            }
            case 2://Yes - DONT ask again
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:YES forKey:_Use3G];
                [userDefaults synchronize];
                
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Logging_in_to_server" ,nil, [NSBundle mainBundle],
                                                                   @"Logging in to server..." , nil);
                self.viewProgress.hidden = NO;
                
                UILabel *labelProgress = (UILabel *)[_viewProgress viewWithTag:509];
                
                [labelProgress setText:msg];
                self.buttonEnter.enabled = NO;
                [self doSignIn:nil];
                
                break;
            }
        }
    }
    else if (tag == 114) // camera network check
    {
        switch (buttonIndex)
        {
            case 0:
            {
                //Stay at this screen.
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:NO forKey:_AutoLogin];
                [userDefaults synchronize];
                

                [self loadUserInfo];
                break;
            }
        }
    }
}

#pragma mark -
#pragma mark Login Callbacks
- (void) loginSuccessWithResponse:(NSDictionary *)responseDict
{
    //reset it here
    self.buttonEnterPressedFlag = NO;
    self.buttonEnter.enabled = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:_OfflineMode];
    [userDefaults synchronize];
    
	if (responseDict) {
        NSInteger statusCode = [[responseDict objectForKey:@"status"] intValue];
        
        if (statusCode == 200) // success
        {
            NSString *apiKey = [[responseDict objectForKey:@"data"] objectForKey:@"authentication_token"];
            
            //Store user/pass for later use
            [userDefaults setObject:_stringUsername forKey:@"PortalUsername"];
            [userDefaults setObject:_stringPassword forKey:@"PortalPassword"];
            [userDefaults setObject:apiKey forKey:@"PortalApiKey"];
            [userDefaults setBool:TRUE forKey:_AutoLogin];
            
            [userDefaults synchronize];
            
            //MOVE on now ..
            
            //Register for push
            NSLog(@"Login success! 1");
            [self moveOnAfterLoginOk:apiKey];
        }
        else
        {
            NSLog(@"Invalid response: %@", responseDict);
            //ERROR condition
            self.viewProgress.hidden = YES;
            
            NSString * title = NSLocalizedStringWithDefaultValue(@"Login_Error" ,nil, [NSBundle mainBundle],
                                                                 @"Login Error", nil);
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Login_Error_msg" ,nil, [NSBundle mainBundle],
                                                               @"Server response invalid, please try again!", nil);
            
            NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok" ,nil, [NSBundle mainBundle],
                                                              @"OK", nil);
            [[KISSMetricsAPI sharedAPI] recordEvent:@"Login Failed" withProperties:nil];
            
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:[NSString stringWithFormat:@"Login succeed-user: %@", _stringUsername]
                                                             withLabel:nil
                                                             withValue:nil];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:msg
                                  delegate:self
                                  cancelButtonTitle:ok
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else
    {
        NSLog(@"Error - loginSuccessWithResponse: reponseDict = nil");
    }
}
-(void)moveOnAfterLoginOk: (NSString * ) apiKey
{
    NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
    NSString * userEmail = (NSString *)[userDefalts objectForKey:@"PortalUseremail"];
    
    if (userEmail == nil)
    {
        
        NSLog(@"No Useremail, query for once now");
        
        // Get user info (email)
        BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:@selector(getUserInfoSuccessWithResponse:)
                                                                              FailSelector:@selector(getUserInfoFailedWithResponse:)
                                                                                 ServerErr:@selector(getUserInfoFailedServerUnreachable)] autorelease];
        [jsonComm getUserInfoWithApiKey:apiKey];
    }
    
    
#if !TARGET_IPHONE_SIMULATOR
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationType) (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    NSLog(@"Login success! 2");
    
    UserAccount *account = [[UserAccount alloc] initWithUser:_stringUsername
                                                    password:_stringPassword
                                                      apiKey:apiKey
                                                    listener:self];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Login successfully - user: %@", _stringUsername] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Login succeeded-user:%@", _stringUsername]
                                                     withLabel:nil
                                                     withValue:nil];
    //BLOCKED method
    [account readCameraListAndUpdate];
    [account release];
    
    NSLog(@"Login success! 3");
    
}

- (void) loginFailedWithError:(NSDictionary *) responseError
{
    //reset it here
    self.buttonEnterPressedFlag = NO;
    self.buttonEnter.enabled = YES;
    
	NSLog(@"%s responseDict: %@", __FUNCTION__, responseError);
	
	self.viewProgress.hidden = YES;
	
    
    NSString * title = NSLocalizedStringWithDefaultValue(@"Login_Error" ,nil, [NSBundle mainBundle],
                                                         @"Login Error", nil);
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Login_Error_msg2" ,nil, [NSBundle mainBundle],
                                                       @"Server error: %@", nil);
    msg = [NSString stringWithFormat:msg, [responseError objectForKey:@"message"]];
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok" ,nil, [NSBundle mainBundle],
                                                      @"OK", nil);
    
    
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:title
                          message:msg
						  delegate:self
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Login failed - user: %@, error: %@", _stringUsername, msg] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Login failed-user:%@, error: %@", _stringUsername, msg]
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)loginFailedServerUnreachable
{
    //reset it here
    self.buttonEnterPressedFlag = NO;
    self.buttonEnter.enabled = YES;
    
	NSLog(@"Loging failed : server unreachable");
	self.viewProgress.hidden = YES;
    
    NSString * title = NSLocalizedStringWithDefaultValue(@"Login_Error" ,nil, [NSBundle mainBundle],
                                                         @"Login Error", nil);
#if 1
    NSString *msg = @"Server is unreachable or The request timed out.";
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok" ,nil, [NSBundle mainBundle],
                                                      @"OK", nil);
    UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:title
						  message:msg
						  delegate:self
						  cancelButtonTitle:nil
						  otherButtonTitles:ok, nil];
	[alert show];
	[alert release];
#else
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Login_Error_msg3" ,nil, [NSBundle mainBundle],
                                                       @"Server is unreachable. Do you want to access your cameras offline?" ,nil);
    
    NSString * no = NSLocalizedStringWithDefaultValue(@"No" ,nil, [NSBundle mainBundle],
                                                      @"No", nil);
    
    NSString * yes = NSLocalizedStringWithDefaultValue(@"Yes" ,nil, [NSBundle mainBundle],
                                                       @"Yes", nil);
    
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:title
						  message:msg
						  delegate:self
						  cancelButtonTitle:no
						  otherButtonTitles:yes, nil];
    alert.tag = 112;
	[alert show];
	[alert release];
    
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Login failed - user: %@, error: Server unreachable", _stringUsername] withProperties:nil];
#endif
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Login failed, Server unreachable-user:%@", _stringUsername]
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)getUserInfoSuccessWithResponse: (NSDictionary *)responseDict
{
    if (responseDict) {
        self.stringUserEmail = [[responseDict objectForKey:@"data"] objectForKey:@"email"];
        
        NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
        [userDefalts setObject:self.stringUserEmail forKey:@"PortalUseremail"];
        [userDefalts synchronize];
    }
}

- (void)getUserInfoFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"%s responseDict: %@", __FUNCTION__, responseDict);
    
    NSString * title = @"Get User info failed!";
    NSString * msg = [responseDict objectForKey:@"message"];
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok" ,nil, [NSBundle mainBundle],
                                                      @"OK", nil);
    
	//ERROR condition
	[[[[UIAlertView alloc] initWithTitle:title
                                 message:msg
                                delegate:nil
                       cancelButtonTitle:ok
                       otherButtonTitles:nil]
      autorelease]
     show];
}

- (void)getUserInfoFailedServerUnreachable
{
    [[[[UIAlertView alloc] initWithTitle:@"Server Unreachable"
                                 message:@"Server Unreachable"
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil]
      autorelease]
     show];
}

- (void)dealloc {
    [_viewProgress release];
    [_tfEmail release];
    [_tfPassword release];
    [_buttonEnter release];
    [super dealloc];
}
@end
