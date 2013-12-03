//
//  MBP_LoginOrRegistration.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_LoginOrRegistration.h"

@interface MBP_LoginOrRegistration()

@property (nonatomic, retain) NSString *apiKey;

@end

@implementation MBP_LoginOrRegistration

@synthesize userName, password;
@synthesize progressLabel, progressView;

@synthesize regUserName;
@synthesize regUserPass;
@synthesize regUserEmail; 
@synthesize regProgress, regComplete, registraionView; 


@synthesize userPassCell, userNameCell, forgotPassCell;

@synthesize temp_user_str; 
@synthesize temp_pass_str; 
@synthesize temp_user_email  ;

@synthesize  account;
@synthesize client = _client;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) d;
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])){
        // Custom initialization
		
		delegate = d;
    }
    return self;
}


/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	  [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Login",nil, [NSBundle mainBundle],
                                                          @"Login", nil);
    self.navigationItem.title = msg;
   
    
    msg = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                            @"Back", nil);
    
    //Back key
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:msg
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];

    
    [self.view addSubview:self.progressView];
    
    
    self.temp_user_email  = @"";
    self.temp_pass_str =@"";
    self.temp_pass_str =@"";
    
	//load user/pass  
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _doneButtonPressed = NO;
	
	//can be user email or user name here --  
	NSString * old_usr = (NSString *) [userDefaults objectForKey:@"PortalUsername"];	
	NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    self.temp_user_email  = (NSString*) [userDefaults objectForKey:@"PortalUseremail"];
    
    
    
    /* Reset SYM NAT status here */
    [userDefaults setInteger:TYPE_UNKNOWN forKey:APP_IS_ON_SYMMETRIC_NAT];
    [userDefaults synchronize];
    
    
    
	if (old_usr != nil)
	{
		[self.userName setText:old_usr];
		
		if (old_pass != nil)
		{
			[self.password setText:old_pass];
		}
	}
	
    if ((old_usr != nil) && (old_pass != nil))
    {
        self.temp_user_str = [NSString stringWithString:old_usr];
        self.temp_pass_str = [NSString stringWithString:old_pass];
        
    
        self.progressView.hidden = NO;         
        
        
        BOOL shouldAutoLogin = [userDefaults boolForKey:_AutoLogin];
       
        if (shouldAutoLogin == TRUE	)
        {

            _doneButtonPressed = YES;
            [self check3GConnectionAndPopup];
            

        }
        else 
        {
            
            self.progressView.hidden = YES;  
            NSLog(@" NO LOGIN"); 
        }
	}
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }

}


/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
	        (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}
*/
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//
//-(void) viewWillAppear:(BOOL)animated
//{
//    
//    NSLog(@"viewWillAppear");  
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
//    //[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait];
//    
//}
- (void)dealloc {
    [_client release];
	[userName release];
	[password release];
    [_apiKey release];

	[progressView release];
	[progressLabel release];
	[regUserName release];
	[regUserPass release];
	[regUserEmail release]; 
	[regProgress release];
	[regComplete release];
	[registraionView release];
    
    [temp_pass_str release];
    [temp_user_email release];
    [temp_user_str release];
    [account release];
     [super dealloc];
}

- (void)presentModallyOn:(UIViewController *)parent
{
    MBPNavController *    navController;
    
    //setup nav controller 
    navController= [[[MBPNavController alloc]initWithRootViewController:self] autorelease];
    

    
    // Create a navigation controller with us as its root.
    assert(navController != nil);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        // Load resources for iOS 7 or later
        navController.navigationBar.barStyle = UIBarStyleDefault;
    } else {
        navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    }
    

    // Set up the Cancel button on the left of the navigation bar.
    self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
    assert(self.navigationItem.leftBarButtonItem != nil);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone   target:self action:@selector(doneAction:)] autorelease];

    assert(self.navigationItem.rightBarButtonItem != nil);

    // Present the navigation controller on the specified parent 
    // view controller.

    //[parent presentModalViewController:navController animated:NO];
        
    [parent presentViewController:navController animated:NO completion:^{}];
}

- (void)doSignIn :(NSTimer *) exp
{
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(loginSuccessWithResponse:)
                                                                         FailSelector:@selector(loginFailedWithError:)
                                                                            ServerErr:@selector(loginFailedServerUnreachable)] autorelease];
    [jsonComm loginWithLogin:self.temp_user_str andPassword:self.temp_pass_str];
    
    
    
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

-(BOOL) isCurrentConnection3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        
        return TRUE;
    }
    
    
    return FALSE;
    
}

/* Return True to stop at login screen 
          False to ignore and continue*/

-(void) check3GConnectionAndPopup
{
 
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL skip_3g_popup = [userDefaults boolForKey:_Use3G];
    
    if (  (skip_3g_popup ==FALSE)  && [self isCurrentConnection3G])
    {
        //Popup now..
        
        self.navigationItem.leftBarButtonItem.enabled = YES ;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        NSLog(@"Wifi is not available ");
        self.progressView.hidden = YES;
        
   
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
        self.progressView.hidden = NO;
        [self.progressLabel setText:msg];
        self.navigationItem.leftBarButtonItem.enabled = NO ;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        
        
        //Is on WIFI -> proceed
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(doSignIn:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.trackedViewName = @"Login Screen";
    [[[GAI sharedInstance] defaultTracker] sendView:@"Login Screen"];
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
   
#if 0
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //[[NSBundle mainBundle] loadNibNamed:@"MBP_LoginOrRegistration_land_ipad" owner:self options:nil];
           
        }
        else
        {
            
            
            
            NSString * user = userName.text;
            NSString * pass = password.text;
            [self.progressView removeFromSuperview];
            
            
            [[NSBundle mainBundle] loadNibNamed:@"MBP_LoginOrRegistration_land" owner:self options:nil];
            
            if (_doneButtonPressed == YES)
            {
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Logging_in_to_server" ,nil, [NSBundle mainBundle],
                                                                   @"Logging in to server..." , nil);
                [self.view addSubview:self.progressView];
                self.progressView.hidden = NO;
                [self.progressLabel setText:msg];
                [self.view bringSubviewToFront:self.progressView];
                self.navigationItem.leftBarButtonItem.enabled = NO ;
                self.navigationItem.rightBarButtonItem.enabled = NO;
                
                
            }
            
            userName.text = user;
            password.text = pass;

        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //[[NSBundle mainBundle] loadNibNamed:@"MBP_LoginOrRegistration_ipad" owner:self options:nil];
            
        }
        else
        {
            NSString * user = userName.text;
            NSString * pass = password.text;
            [self.progressView removeFromSuperview];
            
            [[NSBundle mainBundle] loadNibNamed:@"MBP_LoginOrRegistration" owner:self options:nil];
            
            [[NSBundle mainBundle] loadNibNamed:@"MBP_LoginOrRegistration_land" owner:self options:nil];
            
            if (_doneButtonPressed == YES)
            {
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Logging_in_to_server" ,nil, [NSBundle mainBundle],
                                                                   @"Logging in to server..." , nil);
                [self.view addSubview:self.progressView];
                self.progressView.hidden = NO;
                [self.progressLabel setText:msg];
                [self.view bringSubviewToFront:self.progressView];
                self.navigationItem.leftBarButtonItem.enabled = NO ;
                self.navigationItem.rightBarButtonItem.enabled = NO;
                
                
            }
            
            userName.text = user;
            password.text = pass;
        }
    }
    
    
#endif 
    
}

#pragma mark -
#pragma mark TextView  delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
	[textField resignFirstResponder];
    
    
    //NSLog(@" %d %d",[self.userName.text length], [self.password.text length] );
#if 0
    if ([self.userName.text length] > 0
        && [self.password.text length] > 0)
    {
        //enable Done btn
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        //disable Done btn
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    }
#endif 
    
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int tag = textField.tag;
    
    if (tag == 204 /*password tag */)
    {
        //NSLog(@"%@ len :%d ",textField.text, [textField.text length]);
        if ( ([textField.text length] + [string length] ) >2)
        {
            //enable Done btn
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else
        {
            //disable Done btn
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    return YES;
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
                
                //signal iosViewController
                //[delegate sendStatus:SCAN_CAMERA];
                //Scan using bonjour
                [delegate sendStatus:SCAN_BONJOUR_CAMERA];
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
                self.progressView.hidden = NO;
                [self.progressLabel setText:msg];
                self.navigationItem.leftBarButtonItem.enabled = NO ;
                self.navigationItem.rightBarButtonItem.enabled = NO;
                
                
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
                self.progressView.hidden = NO;
                [self.progressLabel setText:msg];
                self.navigationItem.leftBarButtonItem.enabled = NO ;
                self.navigationItem.rightBarButtonItem.enabled = NO;

                
                //signal iosViewController
                [self doSignIn:nil];
                
                break;
            }
            
        }

    }


}


#pragma mark -
#pragma mark TableView delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section ==0 ) return 2; 
    
    return 1; 
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 2; 
}


#define USERNAME_INDEX 0
#define USERPASS_INDEX 1

#define FORGOTPASS_INDEX 0 


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    
    
    if (indexPath.section == 0 && indexPath.row == USERNAME_INDEX) 
    {
        
        UITextField * txtField = (UITextField*) [userNameCell viewWithTag:203];
        txtField.delegate = self; 
        return userNameCell;
    }
    if (indexPath.section == 0 && indexPath.row == USERPASS_INDEX)
    {
        
        UITextField * txtField = (UITextField*) [userPassCell viewWithTag:204];
        txtField.delegate = self;

        return userPassCell;
    }
    if (indexPath.section == 1 &&  indexPath.row == FORGOTPASS_INDEX)
    {
        return forgotPassCell;
    }
    

    return nil;
    
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] 
                             animated:NO];
    
    int idx=indexPath.section;
    
    if (idx == 1)
    {
        
        NSLog(@"Load fpwd");
        //Load the next xib
        ForgotPwdViewController *forgotPwdController;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            forgotPwdController = [[ForgotPwdViewController alloc]
                                   initWithNibName:@"ForgotPwdViewController_ipad" bundle:nil];

            
        }
        else
        {
            forgotPwdController = [[ForgotPwdViewController alloc]
                                   initWithNibName:@"ForgotPwdViewController" bundle:nil];

        }
       
        
        [self.navigationController pushViewController:forgotPwdController animated:NO];    
        [forgotPwdController release];
        
    }
    
    
    if (indexPath.section == 0 && indexPath.row == USERNAME_INDEX)
    {
        
        UITextField * txtField = (UITextField*) [userNameCell viewWithTag:203];
        [txtField becomeFirstResponder];
        
    }
    if (indexPath.section == 0 && indexPath.row == USERPASS_INDEX)
    {
        
        UITextField * txtField = (UITextField*) [userPassCell viewWithTag:204];
        [txtField becomeFirstResponder];
       
    }

    
    
}





#pragma mark -
#pragma mark Button Handling 

- (IBAction) createNewAccount:(id)sender
{
    NSLog(@"createNewAccount ---");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:TRUE forKey:FIRST_TIME_SETUP];
    [userDefaults synchronize];
    
    [delegate sendStatus:1];
}

-(void) cancelAction:(id) sender
{
    [delegate sendStatus:7];
}

-(void) doneAction:(id) sender
{
    _doneButtonPressed = YES;
    [userName resignFirstResponder];
    [password resignFirstResponder];
    
   
    self.temp_user_str = [NSString stringWithString:userName.text];
    self.temp_pass_str = [NSString stringWithString:password.text];
    
    [self check3GConnectionAndPopup];
    
}



- (IBAction) handleButtonPressed:(id) sender
{
	int sender_tag = ((UIButton *) sender).tag;
	NSLog(@"THIS IS NOT USED ... Sender tag:%d", sender_tag);
}
#pragma mark -
#pragma mark PJNATH Callbacks

-(void)symmetric_check_result: (BOOL) isBehindSymNat
{
    
    
    NSInteger result = (isBehindSymNat == TRUE)?TYPE_SYMMETRIC_NAT:TYPE_NON_SYMMETRIC_NAT;
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:result forKey:APP_IS_ON_SYMMETRIC_NAT];
    [userDefaults synchronize];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [self.client shutdown];
                      // [self.client release];
                   }
                   );
    
    
    
}


#pragma mark -
#pragma mark Login Callbacks
- (void) loginSuccessWithResponse:(NSDictionary*) responseData
{
    //reset it here
     _doneButtonPressed = NO;
	
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:_OfflineMode];
    [userDefaults synchronize];
    
	if (responseData) {
        NSInteger statusCode = [[responseData objectForKey:@"status"] intValue];
        if (statusCode == 200) // success
        {
            self.apiKey = [[responseData objectForKey:@"data"] objectForKey:@"authentication_token"];
            
            // Get user info (email)
            BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                     Selector:@selector(getUserInfoSuccessWithResponse:)
                                                                                 FailSelector:@selector(getUserInfoFailedWithResponse:)
                                                                                    ServerErr:@selector(getUserInfoFailedServerUnreachable)] autorelease];
            [jsonComm getUserInfoWithApiKey:self.apiKey];
        }
        else
        {
            NSLog(@"Invalid response: %@", responseData);
            //ERROR condition
            self.progressView.hidden = YES;
            
            
            NSString * title = NSLocalizedStringWithDefaultValue(@"Login_Error" ,nil, [NSBundle mainBundle],
                                                                 @"Login Error", nil);
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Login_Error_msg" ,nil, [NSBundle mainBundle],
                                                               @"Server response invalid, please try again!", nil);
            
            NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok" ,nil, [NSBundle mainBundle],
                                                              @"OK", nil);
            
            [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Login"
                                                               withAction:@"Login Failed"
                                                                withLabel:@"Login failed because of an unhandled exception from server"
                                                                withValue:nil];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:msg
                                  delegate:self
                                  cancelButtonTitle:ok
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
            
        }
    }
			
	//Store user/pass for later use
	
	[userDefaults setObject:self.temp_user_str forKey:@"PortalUsername"];
	[userDefaults setObject:self.temp_pass_str forKey:@"PortalPassword"];
    [userDefaults setObject:self.apiKey forKey:@"PortalApiKey"];

	[userDefaults synchronize];
	
	//MOVE on now .. 
    
       
    
    //REGister for push 
   
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationType) (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
       
    
    account = [[UserAccount alloc] initWithUser:self.temp_user_str
                                        andPass:self.temp_pass_str
                                      andApiKey:self.apiKey
                                    andListener:delegate];
    [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Login"
                                                       withAction:@"Login Success"
                                                        withLabel:@"Login success"
                                                        withValue:nil];
    //BLOCKED method
    [account query_camera_list_blocked];
    NSLog(@"Login success!");
    return;
}

- (void) loginFailedWithError:(NSDictionary *) responseError
{
    //reset it here
    _doneButtonPressed = NO;
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"Loging failed with error code:%@", responseError);
	
	self.progressView.hidden = YES;
	
    
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
    [[[GAI sharedInstance]defaultTracker] trackEventWithCategory:@"Login"
                                                      withAction:@"Login Failed"
                                                       withLabel:@"msg"
                                                       withValue:nil];
    NSLog(@"%d", [[responseError objectForKey:@"status"] intValue]);
	return;
}
- (void) loginFailedServerUnreachable
{
    
    //reset it here
    _doneButtonPressed = NO;
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"Loging failed : server unreachable");
	self.progressView.hidden = YES;
    
    
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
    [[[GAI sharedInstance]defaultTracker] trackEventWithCategory:@"Login"
                                                      withAction:@"Login Failed"
                                                       withLabel:@"Login failed because of server is unreachable"
                                                       withValue:nil];
	
}

- (void)getUserInfoSuccessWithResponse: (NSDictionary *)responseDict
{
    if (responseDict) {
        self.temp_user_email = [[responseDict objectForKey:@"data"] objectForKey:@"email"];
        
        NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
        [userDefalts setObject:self.temp_user_email forKey:@"PortalUseremail"];
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

@end
