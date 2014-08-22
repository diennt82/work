//
//  LoginViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 2/10/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>

#import "LoginViewController.h"
#import "StunClient.h"
#import "ForgotPwdViewController.h"
#import "UserAccount.h"
#import "PublicDefine.h"
#import "TimelineDatabase.h"
#import "RegistrationViewController.h"
#import "MBP_iosViewController.h"

@interface LoginViewController ()  <UITextFieldDelegate, StunClientDelegate, UserAccountDelegate>

@property (nonatomic, strong) IBOutlet UIView *viewProgress;
@property (nonatomic, weak) IBOutlet UITextField *usernameEmailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordButton;
@property (nonatomic, weak) IBOutlet UIButton *enterButton;
@property (nonatomic, weak) IBOutlet UIButton *createAccountButton;
@property (nonatomic, weak) IBOutlet UIImageView *imgViewLoading;

@property (nonatomic, strong) StunClient *client;
@property (nonatomic, weak) id<ConnectionMethodDelegate> delegate;
@property (nonatomic, copy) NSString *stringUsername;
@property (nonatomic, copy) NSString *stringUserEmail;
@property (nonatomic, copy) NSString *stringPassword;
@property (nonatomic) BOOL buttonEnterPressedFlag;

@end

@implementation LoginViewController

#define MOVEMENT_DURATION           0.3
#define GAI_CATEGORY                @"Login view"
#define USE_3G_TO_CONNECT_KEY       @"use3GToConnect"
#define USE_OFFLINE_MODE_TAG        112
#define CHECK_3G_NETWORK_TAG        113
#define CHECK_CAMERA_NETWORK_TAG    114

#pragma mark - Initialization methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<ConnectionMethodDelegate>)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UIScreen.mainScreen.bounds.size.height < 568) {
        [[NSBundle mainBundle] loadNibNamed:@"LoginViewController_35" owner:self options:nil];
    }
    
    [self.view addSubview:_viewProgress];
    self.stringPassword  = @"";
    
    _usernameEmailTextField.placeholder = LocStr(@"Username/Email");
    _passwordTextField.placeholder = LocStr(@"Password");
    [_forgotPasswordButton setTitle:LocStr(@"Forgot password?") forState:UIControlStateNormal];
    [_enterButton setTitle:LocStr(@"Enter") forState:UIControlStateNormal];
    [_createAccountButton setTitle:LocStr(@"Create account") forState:UIControlStateNormal];
    
    [_enterButton setBackgroundImage:[UIImage imageNamed:@"enter"] forState:UIControlStateNormal];
    [_enterButton setBackgroundImage:[UIImage imageNamed:@"enter_pressed"] forState:UIControlEventTouchDown];
    
    _usernameEmailTextField.delegate = self;
    _passwordTextField.delegate = self;
    self.buttonEnterPressedFlag = NO;
    
    _imgViewLoading.animationImages = @[
                                        [UIImage imageNamed:@"loader_big_a"],
                                        [UIImage imageNamed:@"loader_big_b"],
                                        [UIImage imageNamed:@"loader_big_c"],
                                        [UIImage imageNamed:@"loader_big_d"],
                                        [UIImage imageNamed:@"loader_big_e"]
                                        ];
    
    _imgViewLoading.animationDuration = 1.5;
    [_imgViewLoading startAnimating];
    
#if !TARGET_IPHONE_SIMULATOR
    if ([self isConnectingToCameraNetwork]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:LocStr(@"You are connecting to a camera network that does not have Internet access. Go to Wi-Fi settings and switch to another Wi-Fi.")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:LocStr(@"Ok"), nil];
        alert.tag = CHECK_CAMERA_NETWORK_TAG;
        [alert show];
    }
    else
#endif
    {
        // load user/pass
        [self performSelectorOnMainThread:@selector(loadUserInfo) withObject:nil waitUntilDone:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    self.trackedViewName = GAI_CATEGORY;
    
    MBP_iosViewController *mainVC = (MBP_iosViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    mainVC.app_stage = APP_STAGE_LOGGING_IN;
    
    UILabel *labelMessage = (UILabel *)[_viewProgress viewWithTag:509];
    [labelMessage setText:LocStr(@"Logging in to server...")];
    
    _usernameEmailTextField.text = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"PortalUsername"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIButton *btnForgotPassword = (UIButton *)[self.view viewWithTag:955];
        btnForgotPassword.frame = CGRectMake(_enterButton.frame.origin.x, btnForgotPassword.frame.origin.y, btnForgotPassword.frame.size.width, btnForgotPassword.frame.size.height);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Login Screen" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"viewDidAppear"
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Private methods

- (void)loadUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	NSString *username = (NSString *)[userDefaults objectForKey:@"PortalUsername"];
	NSString *password = (NSString *)[userDefaults objectForKey:@"PortalPassword"];
    NSString *apiKey = (NSString *)[userDefaults objectForKey:@"PortalApiKey"];
    
    self.stringUserEmail  = (NSString*)[userDefaults objectForKey:@"PortalUseremail"];
    BOOL shouldAutoLogin = [userDefaults boolForKey:AUTO_LOGIN_KEY];
    
    // Reset SYM NAT status here
    [userDefaults setInteger:TYPE_UNKNOWN forKey:APP_IS_ON_SYMMETRIC_NAT];
    [userDefaults synchronize];
    
    if ( username ) {
        self.stringUsername = username;
        _usernameEmailTextField.text = username;
        
        if ( shouldAutoLogin && apiKey && password ) {
            // Don't need to go thru the login query again
            DLog(@"Use old api key");
            self.stringPassword = password;
            _viewProgress.hidden = NO;
            _passwordTextField.text = password;
            
            self.buttonEnterPressedFlag = YES;
            [self moveOnAfterLoginOk:apiKey];
            
        }
        else if ( shouldAutoLogin && password ) {
            self.stringPassword = password;
            _viewProgress.hidden = NO;
            _passwordTextField.text = password;
            
            self.buttonEnterPressedFlag = YES;
            [self check3GConnectionAndPopup];
        }
        else {
            [userDefaults removeObjectForKey:CAM_IN_VEW];
            [userDefaults synchronize];
            self.viewProgress.hidden = YES;
            self.enterButton.enabled = NO;
            
            if ( password ) {
                self.passwordTextField.text = password;
                self.buttonEnterPressedFlag = NO;
                _enterButton.enabled = YES;
            }
        }
    }
    else {
        [userDefaults removeObjectForKey:CAM_IN_VEW];
        [userDefaults synchronize];
        _viewProgress.hidden = YES;
        _enterButton.enabled = NO;
        DLog(@"LoginVC - No login");
    }
}

#pragma mark - UserAccount delegate

- (void)finishStoreCameraListData:(NSMutableArray *)arrayCamProfile success:(BOOL)success
{
    if (success) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        if (_delegate) {
            [_delegate sendStatus:SHOW_CAMERA_LIST];
        }
    }
    else {
        [self performSelectorInBackground:@selector(logout) withObject:nil];
    }
}

#pragma mark - Action

- (IBAction)buttonForgotPasswordTouchUpInsideAction:(id)sender
{
    ForgotPwdViewController *forgotPwdController = [[ForgotPwdViewController alloc] initWithNibName:@"ForgotPwdViewController" bundle:nil];
    [self.navigationController pushViewController:forgotPwdController animated:YES];
}

- (IBAction)buttnEnterTouchUpInsideAction:(id)sender
{
    self.buttonEnterPressedFlag = YES;
    [self.view endEditing:YES];
    
    self.stringUsername = _usernameEmailTextField.text;
    self.stringPassword = _passwordTextField.text;
    
    [self check3GConnectionAndPopup];
}

- (IBAction)buttonCreateAccountTouchUpInsideAction:(id)sender
{
    [self.view endEditing:YES];
    
    DLog(@"LoginVC - createNewAccount ---");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:TRUE forKey:FIRST_TIME_SETUP];
    [userDefaults synchronize];
    
    RegistrationViewController *registrationVC = [[RegistrationViewController alloc] initWithNibName:@"RegistrationViewController" bundle:nil];
    registrationVC.delegate = _delegate;
    [self.navigationController pushViewController:registrationVC animated:YES];
    
    MBP_iosViewController *mainVC = (MBP_iosViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    mainVC.app_stage = SETUP_CAMERA;
    
}

#pragma mark - PJNATH Callbacks

-(void)symmetric_check_result: (BOOL) isBehindSymNat
{
    NSInteger result = (isBehindSymNat == TRUE)?TYPE_SYMMETRIC_NAT:TYPE_NON_SYMMETRIC_NAT;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:result forKey:APP_IS_ON_SYMMETRIC_NAT];
    [userDefaults synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_client shutdown];
    });
}

#pragma mark - Methods

- (void)logout
{
    @autoreleasepool
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // Remove password and registration id
        [userDefaults removeObjectForKey:@"PortalPassword"];
        [userDefaults removeObjectForKey:_push_dev_token];
        
#if  !TARGET_IPHONE_SIMULATOR
        DLog(@"De-Register push with both parties: APNs and BMS ");
        
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *appId = [userDefaults objectForKey:@"APP_ID"];
        NSString *userName = [userDefaults objectForKey:@"PortalUsername"];
        
        [userDefaults removeObjectForKey:@"PortalApiKey"];
        [userDefaults removeObjectForKey:@"PortalUseremail"];
        [userDefaults synchronize];
        
        // Let the device know we want to receive push notifications
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        
        // Drop all timeline for this user
        [[TimelineDatabase getSharedInstance] clearEventForUserName:userName];
        
        
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                 Selector:nil
                                                                             FailSelector:nil
                                                                                ServerErr:nil];
        
        NSDictionary *responseDict = [jsonComm deleteAppBlockedWithAppId:appId
                                                               andApiKey:apiKey];

        DLog(@"logout --> delete app status = %d", [[responseDict objectForKey:@"status"] intValue]);
        
        [NSThread sleepForTimeInterval:0.10];
#endif
    }
    
    self.buttonEnterPressedFlag = NO;
    _enterButton.enabled = YES;
	_viewProgress.hidden = YES;
}

/**
 * Check if phone is connected to 3g network
 * Also check if phone is connected to camera network (!!#@!#)
 */
- (void)check3GConnectionAndPopup
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL skip3GPopup = [userDefaults boolForKey:USE_3G_TO_CONNECT_KEY];
    
    if ( !skip3GPopup && [self isCurrentConnection3G] ) {
        // Popup now..
        _enterButton.enabled = YES;
        
        DLog(@"Wifi is not available ");
        _viewProgress.hidden = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:LocStr(@"Mobile data is enabled. If you continue to connect, you may incur air time charges. Do you want to proceed?")
                                                       delegate:self
                                              cancelButtonTitle:LocStr(@"No")
                                              otherButtonTitles:LocStr(@"Yes"), LocStr(@"Yes and don't ask again"), nil];
        alert.tag = 113;
        [alert show];
    }
    else {
        self.viewProgress.hidden = NO;

        NSString *msg = LocStr(@"Logging in to server...");
        UILabel *labelMessage = (UILabel *)[_viewProgress viewWithTag:509];
        [labelMessage setText:msg];
        
        self.enterButton.enabled = NO;
        
        // Is on WIFI -> proceed
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(doSignIn:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (BOOL)isCurrentConnection3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == ReachableViaWWAN) {
        // 3G
        return YES;
    }
    
    return NO;
}

- (BOOL)isConnectingToCameraNetwork
{
    NSString *ssid = [CameraPassword fetchSSIDInfo] ;
    if ([ssid hasPrefix:DEFAULT_SSID_HD_PREFIX] || [ssid hasPrefix:DEFAULT_SSID_PREFIX] ) {
        return YES;
    }
    
    return NO;
}

- (void)doSignIn:(NSTimer *)exp
{
    self.navigationController.navigationBarHidden = YES;
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(loginSuccessWithResponse:)
                                                                          FailSelector:@selector(loginFailedWithError:)
                                                                             ServerErr:@selector(loginFailedServerUnreachable)];
    
    [jsonComm loginWithLogin:_stringUsername andPassword:_stringPassword];
}

#pragma mark TextView  delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _usernameEmailTextField) {
        // Username
        [_passwordTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _passwordTextField) {
        if ( (textField.text.length + string.length) > 2 ) {
            _enterButton.enabled = YES;
        }
        else {
            _enterButton.enabled = NO;
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
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
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration: MOVEMENT_DURATION];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	int tag = alertView.tag;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	if (tag == USE_OFFLINE_MODE_TAG) {
        switch (buttonIndex) {
            case 0:
                break;
                
            case 1:// Yes - go offline mode
            {
                [userDefaults setBool:YES forKey:OFFLINE_MODE_KEY];
                [userDefaults synchronize];
                
                // Show Camera list
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                if (_delegate) {
                    [_delegate sendStatus:SHOW_CAMERA_LIST];
                }
                break;
            }
                
            default:
                break;
        }
    }
    else if (tag == CHECK_3G_NETWORK_TAG) {
        switch (buttonIndex)
        {
            case 0:
            {
                [userDefaults setBool:NO forKey:USE_3G_TO_CONNECT_KEY];
                [userDefaults synchronize];
                break;
            }
            case 1: // Yes - go by 3g
            {
                self.viewProgress.hidden = NO;
                UILabel *labelProgress = (UILabel *)[_viewProgress viewWithTag:509];
                [labelProgress setText:LocStr(@"Logging in to server..." )];
                _enterButton.enabled = YES;
                
                // signal iosViewController
                [self doSignIn:nil];
                break;
            }
            case 2:// Yes - Don't ask again
            {
                [userDefaults setBool:YES forKey:USE_3G_TO_CONNECT_KEY];
                [userDefaults synchronize];
                _viewProgress.hidden = NO;
                
                UILabel *labelProgress = (UILabel *)[_viewProgress viewWithTag:509];
                [labelProgress setText:@"Logging in to server..."];
                _enterButton.enabled = NO;
                [self doSignIn:nil];
                break;
            }
        }
    }
    else if (tag == CHECK_CAMERA_NETWORK_TAG) {
        // Stay on this view.
        [userDefaults setBool:NO forKey:AUTO_LOGIN_KEY];
        [userDefaults synchronize];
        [self loadUserInfo];
    }
}

#pragma mark -  Login Callbacks

- (void) loginSuccessWithResponse:(NSDictionary *)responseDict
{
    // reset it here
    self.buttonEnterPressedFlag = NO;
    _enterButton.enabled = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:OFFLINE_MODE_KEY];
    [userDefaults synchronize];
    
	if (responseDict) {
        NSInteger statusCode = [responseDict[@"status"] intValue];
        
        if (statusCode == 200) {
            // success
            NSString *apiKey = [responseDict[@"data"] objectForKey:@"authentication_token"];
            
            //Store user/pass for later use
            [userDefaults setObject:_stringUsername forKey:@"PortalUsername"];
            [userDefaults setObject:_stringPassword forKey:@"PortalPassword"];
            [userDefaults setObject:apiKey forKey:@"PortalApiKey"];
            [userDefaults setBool:YES forKey:AUTO_LOGIN_KEY];
            [userDefaults synchronize];
            
            // Register for push
            DLog(@"Login success! 1");
            [self moveOnAfterLoginOk:apiKey];
        }
        else {
            DLog(@"Invalid response: %@", responseDict);
            _viewProgress.hidden = YES;
            
            //[[KISSMetricsAPI sharedAPI] recordEvent:@"Login Failed" withProperties:nil];
            
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:[NSString stringWithFormat:@"Login succeed-user: %@", _stringUsername]
                                                             withLabel:nil
                                                             withValue:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Login Error")
                                                            message:LocStr(@"Server response invalid, please try again!")
                                                           delegate:self
                                                  cancelButtonTitle:LocStr(@"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        DLog(@"Error - loginSuccessWithResponse: reponseDict = nil");
    }
}
-(void)moveOnAfterLoginOk: (NSString * ) apiKey
{
    NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
    NSString *userEmail = (NSString *)[userDefalts objectForKey:@"PortalUseremail"];
    
    if ( !userEmail ) {
        DLog(@"No Useremail, query for once now");
        
        // Get user info (email)
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:@selector(getUserInfoSuccessWithResponse:)
                                                                              FailSelector:@selector(getUserInfoFailedWithResponse:)
                                                                                 ServerErr:@selector(getUserInfoFailedServerUnreachable)];
        [jsonComm getUserInfoWithApiKey:apiKey];
    }
    
#if !TARGET_IPHONE_SIMULATOR && __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // Let the device know we want to receive push notifications
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        // use registerForRemoteNotifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    
    DLog(@"Login success! 2");
    
    UserAccount *account = [[UserAccount alloc] initWithUser:_stringUsername
                                                    password:_stringPassword
                                                      apiKey:apiKey
                                             accountDelegate:self];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Login successfully - user: %@", _stringUsername] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Login succeeded-user:%@", _stringUsername]
                                                     withLabel:nil
                                                     withValue:nil];
    // BLOCKED method
    [account readCameraListAndUpdate];
    
    DLog(@"Login success! 3");
}

- (void) loginFailedWithError:(NSDictionary *)responseError
{
    // reset it here
    self.buttonEnterPressedFlag = NO;
    _enterButton.enabled = YES;
    
	DLog(@"%s responseDict: %@", __FUNCTION__, responseError);
	
	_viewProgress.hidden = YES;
	
    NSString *msg = [NSString stringWithFormat:LocStr(@"Server error: %@"), [responseError objectForKey:@"message"]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Login Error")
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:LocStr(@"Ok")
                                          otherButtonTitles:nil];
	[alert show];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Login failed - user: %@, error: %@", _stringUsername, msg] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Login failed-user:%@, error: %@", _stringUsername, msg]
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)loginFailedServerUnreachable
{
    // reset it here
    self.buttonEnterPressedFlag = NO;
    _enterButton.enabled = YES;
    
	DLog(@"Loging failed : server unreachable");
	_viewProgress.hidden = YES;
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Login Error")
                                                    message:LocStr(@"Server is unreachable. Do you want to access your cameras offline?")
                                                   delegate:self
                                          cancelButtonTitle:LocStr(@"No")
                                          otherButtonTitles:LocStr(@"Yes"), nil];
    alert.tag = USE_OFFLINE_MODE_TAG;
	[alert show];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Login failed - user: %@, error: Server unreachable", _stringUsername] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Login failed, Server unreachable-user:%@", _stringUsername]
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)getUserInfoSuccessWithResponse: (NSDictionary *)responseDict
{
    if (responseDict) {
        self.stringUserEmail = [responseDict[@"data"] objectForKey:@"email"];
        
        NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
        [userDefalts setObject:_stringUserEmail forKey:@"PortalUseremail"];
        [userDefalts synchronize];
    }
}

- (void)getUserInfoFailedWithResponse: (NSDictionary *)responseDict
{
    DLog(@"%s responseDict: %@", __FUNCTION__, responseDict);
    
	[[[UIAlertView alloc] initWithTitle:LocStr(@"Get User info failed!")
                                 message:responseDict[@"message"]
                                delegate:nil
                       cancelButtonTitle:LocStr(@"Ok")
                       otherButtonTitles:nil]
     show];
}

- (void)getUserInfoFailedServerUnreachable
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:LocStr(@"Server unreachable")
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:LocStr(@"Ok"), nil];
    [alert show];
}

@end
