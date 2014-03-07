//
//  LoginViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 2/10/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#define MOVEMENT_DURATION 0.3 //movementDuration

#define _AutoLogin @"shouldAutoLoginIfPossible"
#define _Use3G @"use3GToConnect"
#define _OfflineMode @"offlineMode"

#import "LoginViewController.h"
#import "StunClient.h"
#import "Reachability.h"
#import "ForgotPwdViewController.h"
#import "UserAccount.h"
#import "PublicDefine.h"
#import <MonitorCommunication/MonitorCommunication.h>


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
    self.stringUserEmail = @"";
    self.stringPassword  = @"";
    
    [self.buttonEnter setBackgroundImage:[UIImage imageNamed:@"enter"]
                                forState:UIControlStateNormal];
    [self.buttonEnter setBackgroundImage:[UIImage imageNamed:@"enter_pressed"]
                                forState:UIControlEventTouchDown];
    self.tfEmail.delegate = self;
    self.tfPassword.delegate = self;
    
    self.buttonEnterPressedFlag = NO;
    
	//load user/pass
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//can be user email or user name here --
	NSString * old_usr = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
	NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    
    if ([userDefaults boolForKey:_AutoLogin] == FALSE)
    {
        old_pass = @"";
    }
    
    self.stringUserEmail  = (NSString*) [userDefaults objectForKey:@"PortalUseremail"];
    
    /* Reset SYM NAT status here */
    [userDefaults setInteger:TYPE_UNKNOWN forKey:APP_IS_ON_SYMMETRIC_NAT];
    [userDefaults synchronize];
    
	if (old_usr != nil)
	{
		[self.tfEmail setText:old_usr];
		
		if (old_pass != nil)
		{
			[self.tfPassword setText:old_pass];
		}
	}
	
    if ((old_usr != nil) && (old_pass != nil))
    {
        self.stringUsername = [NSString stringWithString:old_usr];
        self.stringPassword = [NSString stringWithString:old_pass];
        self.viewProgress.hidden = NO;

        BOOL shouldAutoLogin = [userDefaults boolForKey:_AutoLogin];
        
        if (shouldAutoLogin == TRUE	)
        {
            self.buttonEnterPressedFlag = YES;
            [self check3GConnectionAndPopup];
        }
        else
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"string_Camera_Mac_Being_Viewed"];
            [userDefaults synchronize];
            self.viewProgress.hidden = YES;
            NSLog(@" NO LOGIN");
        }
	}
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"string_Camera_Mac_Being_Viewed"];
        [userDefaults synchronize];
        self.viewProgress.hidden = YES;
        self.buttonEnter.enabled = NO;
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIButton *btnForgotPassword = (UIButton *)[self.view viewWithTag:955];
        btnForgotPassword.frame = CGRectMake(_buttonEnter.frame.origin.x, btnForgotPassword.frame.origin.y, btnForgotPassword.frame.size.width, btnForgotPassword.frame.size.height);
    }
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[[GAI sharedInstance] defaultTracker] sendView:@"Login Screen"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UserAccount delegate

- (void)finishStoreCameraListData:(NSMutableArray *)arrayCamProfile success:(BOOL)success
{
    [self dismissViewControllerAnimated:NO completion:
     ^{
         
         if (success)
         {
             [_delegate sendStatus:SHOW_CAMERA_LIST];
         }
         else
         {
             [_delegate sendStatus:LOGIN_FAILED_OR_LOGOUT];
         }
        
    }];
}

#pragma mark - Action

- (IBAction)buttonForgotPasswordTouchUpInsideAction:(id)sender
{
    NSLog(@"Load fpwd");
    //Load the next xib
    ForgotPwdViewController *forgotPwdController = [[ForgotPwdViewController alloc]
                                                    initWithNibName:@"ForgotPwdViewController" bundle:nil];
    
    [self.navigationController pushViewController:forgotPwdController animated:NO];
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
    NSLog(@"LoginVC - createNewAccount ---");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:TRUE forKey:FIRST_TIME_SETUP];
    [userDefaults synchronize];
    
    [self dismissViewControllerAnimated:NO completion:
     ^{
         [_delegate sendStatus:SETUP_CAMERA];
     }];
    
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
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Logging_in_to_server" ,nil, [NSBundle mainBundle],
                                                           @"Logging in to server..." , nil);
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

- (void)doSignIn:(NSTimer *) exp
{
    self.navigationController.navigationBarHidden = YES;
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(loginSuccessWithResponse:)
                                                                          FailSelector:@selector(loginFailedWithError:)
                                                                             ServerErr:@selector(loginFailedServerUnreachable)] autorelease];
    
    [jsonComm loginWithLogin:_stringUsername andPassword:_stringPassword];
    
    NSLog(@"start logging"); 
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
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [_delegate sendStatus:SHOW_CAMERA_LIST];
                }];
                
                break;
            }
            default:
                break;
        }
    }
    
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
            
            // Get user info (email)
            BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                      Selector:@selector(getUserInfoSuccessWithResponse:)
                                                                                  FailSelector:@selector(getUserInfoFailedWithResponse:)
                                                                                     ServerErr:@selector(getUserInfoFailedServerUnreachable)] autorelease];
            [jsonComm getUserInfoWithApiKey:apiKey];
            
            //Store user/pass for later use
            [userDefaults setObject:_stringUsername forKey:@"PortalUsername"];
            [userDefaults setObject:_stringPassword forKey:@"PortalPassword"];
            [userDefaults setObject:apiKey forKey:@"PortalApiKey"];
            [userDefaults synchronize];
            
            //MOVE on now ..
            
            //Register for push
            NSLog(@"Login success! 1");
#if !TARGET_IPHONE_SIMULATOR
            // Let the device know we want to receive push notifications
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIRemoteNotificationType) (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif 
             NSLog(@"Login success! 2");
//            UserAccount *account = [[UserAccount alloc] initWithUser:_stringUsername
//                                                             andPass:_stringPassword
//                                                           andApiKey:apiKey
//                                                         andListener:_delegate];
//            account.uaLoginDelegate = self;

            UserAccount *account = [[UserAccount alloc] initWithUser:_stringUsername
                                                            password:_stringPassword
                                                              apiKey:apiKey
                                                            listener:self];

            
//            [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Login"
//                                                               withAction:@"Login Success"
//                                                                withLabel:@"Login success"
//                                                                withValue:nil];
            //BLOCKED method
            [account readCameraListAndUpdate];
            [account release];
            
            //[self dismissViewControllerAnimated:NO completion:^{}];
            
            NSLog(@"Login success! 3");
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
            
//            [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Login"
//                                                               withAction:@"Login Failed"
//                                                                withLabel:@"Login failed because of an unhandled exception from server"
//                                                                withValue:nil];
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

- (void) loginFailedWithError:(NSDictionary *) responseError
{
    //reset it here
    self.buttonEnterPressedFlag = NO;
    self.buttonEnter.enabled = YES;
    
	NSLog(@"Loging failed with error code:%@", responseError);
	
	self.viewProgress.hidden = YES;
	
    
    NSString * title = NSLocalizedStringWithDefaultValue(@"Login_Error" ,nil, [NSBundle mainBundle],
                                                         @"Login Error", nil);
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Login_Error_msg2" ,nil, [NSBundle mainBundle],
                                                       @"Server error: %@", nil);
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok" ,nil, [NSBundle mainBundle],
                                                      @"OK", nil);
    
    
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:title
                          message:[NSString stringWithFormat:msg, [responseError objectForKey:@"message"]]
						  delegate:self
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
//    [[[GAI sharedInstance]defaultTracker] trackEventWithCategory:@"Login"
//                                                      withAction:@"Login Failed"
//                                                       withLabel:@"msg"
//                                                       withValue:nil];
    NSLog(@"%d", [[responseError objectForKey:@"status"] intValue]);
}

- (void) loginFailedServerUnreachable
{
    //reset it here
    self.buttonEnterPressedFlag = NO;
    self.buttonEnter.enabled = YES;
    
	NSLog(@"Loging failed : server unreachable");
	self.viewProgress.hidden = YES;
    
    NSString * title = NSLocalizedStringWithDefaultValue(@"Login_Error" ,nil, [NSBundle mainBundle],
                                                         @"Login Error", nil);
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
//    [[[GAI sharedInstance]defaultTracker] trackEventWithCategory:@"Login"
//                                                      withAction:@"Login Failed"
//                                                       withLabel:@"Login failed because of server is unreachable"
//                                                       withValue:nil];
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
    NSLog(@"Loging failed with error code:%@", responseDict);
    
    NSString * title = @"Get User info failed!";
    NSString * msg = [responseDict objectForKey:@"message"];
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok" ,nil, [NSBundle mainBundle],
                                                      @"OK", nil);
    
	//ERROR condition
	[[[[UIAlertView alloc] initWithTitle:title
                                 message:msg
                                delegate:self
                       cancelButtonTitle:ok
                       otherButtonTitles:nil]
      autorelease]
     show];
    NSLog(@"%d", [[responseDict objectForKey:@"status"] intValue]);
}

- (void)getUserInfoFailedServerUnreachable
{
    [[[[UIAlertView alloc] initWithTitle:@"Server Unreachable"
                                 message:@"Server Unreachable"
                                delegate:self
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
