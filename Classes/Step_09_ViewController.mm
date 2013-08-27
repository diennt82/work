//
//  Step_09_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_09_ViewController.h"

@interface Step_09_ViewController ()

@end

@implementation Step_09_ViewController


@synthesize    tmp_user_str, tmp_pass_str, tmp_user_email;
@synthesize  userName, userPass, userCPass, userEmail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tmp_user_str = @"";
        self.tmp_pass_str = @"";
        self.tmp_user_email = @"";
    }
    return self;
}
-(void)dealloc
{

    [tmp_user_str release]; 
    [tmp_pass_str release];
    [tmp_user_email release];
    [super dealloc];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Create_Account",nil, [NSBundle mainBundle],
                                                                  @"Create Account", nil);
    
    UIBarButtonItem *nextButton = 
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Done",nil, [NSBundle mainBundle],
                                                                             @"Done", nil)
                                     style:UIBarButtonItemStyleBordered 
                                    target:self 
                                    action:@selector(handleNextButton:)];          
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];

    
    self.navigationItem.rightBarButtonItem.enabled = NO;
   
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

     
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
    UITextField * _userName = (UITextField *)[userName viewWithTag:201];
    [_userName resignFirstResponder];
    UITextField * _userPass = (UITextField *)[userPass viewWithTag:202];
    [_userPass resignFirstResponder];
    UITextField * _userCPass =(UITextField *) [userCPass viewWithTag:203];
    [_userCPass resignFirstResponder];
    UITextField * _userEmail = (UITextField *)[userEmail viewWithTag:204];
    [_userEmail resignFirstResponder];

}

-(void) adjustViewsForOrientations: (UIInterfaceOrientation) interfaceOrientation
{
    
//DO NOTHING HERE --- 
    
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {

        }
        else
        {

        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {

            
        }
        else
        {
            
        }
    }
 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4; 
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; 
}


#define USERNAME_INDEX 0
#define USERPASS_INDEX 1
#define USERCPASS_INDEX 2
#define USEREMAIL_INDEX 3

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    if (indexPath.row == USERNAME_INDEX)
    {
        return userName;
        
    }
    if (indexPath.row == USERPASS_INDEX)
    {
        
       return userPass;

    }
    if (indexPath.row == USERCPASS_INDEX)
    {
        
        return userCPass;

    }
    if (indexPath.row == USEREMAIL_INDEX)
    {
        return userEmail;
    }
       
    return nil;
    
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
    if (indexPath.row == USERNAME_INDEX) {
        UITextField * txtField = (UITextField*) [userName viewWithTag:201];
        [txtField becomeFirstResponder];

    }
    if (indexPath.row == USERPASS_INDEX)
    {
        UITextField * txtField = (UITextField*) [userPass viewWithTag:202];
        [txtField becomeFirstResponder];
    }
    if (indexPath.row == USERCPASS_INDEX)
    {
        UITextField * txtField = (UITextField*) [userCPass viewWithTag:203];
        [txtField becomeFirstResponder];

    }
    if (indexPath.row == USEREMAIL_INDEX)
    {
        UITextField * txtField = (UITextField*) [userEmail viewWithTag:204];
        [txtField becomeFirstResponder];
    }
    
    
}



- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    int tag = textField.tag;
    if (tag == 201)
        return;
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if ( tag == 202 &&
          (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
           interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        )
    {
        return;
    }
    
    //Just start Animation when the app is landscape mode
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight)
    {
        [self animateTextField: textField up: YES];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    int tag = textField.tag;
    if (tag == 201)
        return;
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if ( tag == 202 &&
        (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
         interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        )
    {
        return;
    }

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight)
    {
        [self animateTextField: textField up: NO];
    }
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self validateAllfieldsEnableSignUp];
    
    return YES;
}


-(void) validateAllfieldsEnableSignUp
{
    UITextField * _userName = (UITextField *)[userName viewWithTag:201];
    UITextField * _userPass = (UITextField *)[userPass viewWithTag:202];
    UITextField * _userCPass =(UITextField *) [userCPass viewWithTag:203];
    UITextField * _userEmail = (UITextField *)[userEmail viewWithTag:204];
    
    
    
    if ( (_userName.text.length > 0) &&
        (_userPass.text.length > 0) &&
        (_userCPass.text.length > 0) &&
        (_userEmail.text.length > 0) 
        )
    {
        //Enable the "DONE" button

        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    }
    else
    {
        //disable the "DONE"  button
                self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    

}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
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
-(IBAction) showTermOfUse_:(id) sender
{

    NSLog(@"Load Term of use");
    //Load the next xib
    ToUViewController  * vc = nil;
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        vc =[[ToUViewController alloc]
             initWithNibName:@"ToUViewController_ipad" bundle:nil];
        
    }
    else
    {
        vc =[[ToUViewController alloc]
             initWithNibName:@"ToUViewController" bundle:nil];
    }
    

    
    
    [self.navigationController pushViewController:vc animated:NO];
    [vc release];

}

-(BOOL) isValidEmail:(NSString *) email
{
    if ([email rangeOfString:@"@"].location == NSNotFound)
    {
        return NO;
    }
    
    NSArray * array = [email componentsSeparatedByString:@"@"];
    NSString * domain = [array objectAtIndex:1];
    NSLog(@"Domain is : %@",domain);
    
    NSError *error = NULL;
    NSRegularExpression *regexExpr = [NSRegularExpression regularExpressionWithPattern:@"\\([^\\)]*\\)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regexExpr stringByReplacingMatchesInString:domain options:0 range:NSMakeRange(0, [domain length]) withTemplate:@""];
    
    NSLog(@"modifiedString ------> %@", modifiedString);
    
    NSString * regex = @"[_a-zA-Z0-9-]+(\\.[_a-zA-Z0-9-]+)+";
    NSPredicate * validatedDomain = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [validatedDomain evaluateWithObject:modifiedString];
}

-(void) handleNextButton:(id) sender
{
    UITextField * _userName = (UITextField *)[self.userName viewWithTag:201];
    UITextField * _userPass = (UITextField *)[self.userPass viewWithTag:202];
    UITextField * _userCPass = (UITextField *)[self.userCPass viewWithTag:203];
    UITextField * _userEmail = (UITextField *)[self.userEmail viewWithTag:204];

    NSString * regex = @"[a-zA-Z0-9._-]+";
    NSPredicate * validatedUsername = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidateUsername = [validatedUsername evaluateWithObject:_userName.text];
    
    NSString * msg = nil ;
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString * title = nil; 
    
    //UserName at least 5 chars and at most 20 characters
    if ([_userName.text length] < 5 || [_userName.text length] > 20)
    {
        //error
        title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                  @"Create Account Failed" , nil);
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg",nil, [NSBundle mainBundle],
                                                @"User name has to be between 5-20 characters" , nil);
        //ERROR condition
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:title
                               message:msg
                               delegate:self
                               cancelButtonTitle:ok
                               otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
    else if (!isValidateUsername)
    {
        title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                  @"Create Account Failed" , nil);
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg5", nil, [NSBundle mainBundle],
                                                @"Username should not contain special characters except for - _ and ."  , nil);
        
        //ERROR condition
        [[[[UIAlertView alloc] initWithTitle:title message:msg
                                    delegate:self
                           cancelButtonTitle:ok
                           otherButtonTitles:nil]
          autorelease]
         show];
    }
    else if (([_userPass.text length] < 3) ||
             ([_userPass.text length] > 12) )
    {
        //error
        title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                  @"Create Account Failed" , nil);
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg1",nil, [NSBundle mainBundle],
                                                @"Password has to be between 3-12 characters" , nil);
        //ERROR condition
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:title
                               message:msg 
                               delegate:self
                               cancelButtonTitle:ok
                               otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
    else if ( ![_userPass.text isEqualToString:_userCPass.text])
    {
        //error
        title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                  @"Create Account Failed" , nil);
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg2",nil, [NSBundle mainBundle],
                                                @"Password does not match" , nil);

        //ERROR condition
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:title 
                               message: msg
                               delegate:self
                               cancelButtonTitle:ok
                               otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
    else if(![self isValidEmail:_userEmail.text])
    {
        //error
        title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                  @"Create Account Failed" , nil);
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg3",nil, [NSBundle mainBundle],
                                                @"Invalid email. Email address should be of the form somebody@somewhere.com"  , nil);

        //ERROR condition
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:title
                               message:msg
                               delegate:self
                               cancelButtonTitle:ok
                               otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
    
    else if (![Step_09_ViewController isWifiConnectionAvailable] )
    {

        title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                  @"Create Account Failed" , nil);
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg4",nil, [NSBundle mainBundle],
                                                @"Please select a Wifi network to connect"  , nil);

        NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Settings",nil, [NSBundle mainBundle],
                                                            @"Settings"  , nil);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:msg 
                                                           delegate:self
                                                  cancelButtonTitle:msg1
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];

    }
    else //Good info now..
    {
        //Register user ...
        self.tmp_user_str = _userName.text;
        self.tmp_pass_str  = _userPass.text;
        self.tmp_user_email  = _userEmail.text; 
        
 
        NSLog(@"Start registration"); 
#if JSON_FLAG
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                 Selector:@selector(regSuccessWithResponse:)
                                                                             FailSelector:@selector(regFailedWithError:)
                                                                                ServerErr:@selector(regFailedServerUnreachable)];
        [jsonComm registerAccountWithUsername:self.tmp_user_str andEmail:self.tmp_user_email andPassword:self.tmp_pass_str andPasswordConfirmation:self.tmp_pass_str];
#else
        BMS_Communication * bms_comm;
        bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                    Selector:@selector(regSuccessWithResponse:) 
                                                FailSelector:@selector(regFailedWithError:) 
                                                   ServerErr:@selector(regFailedServerUnreachable)];
        
        [bms_comm BMS_registerWithUserId:self.tmp_user_str AndPass:self.tmp_pass_str AndEmail:self.tmp_user_email];
#endif

    }

    
    
    
    
}


+ (BOOL)isWifiConnectionAvailable {
    
    Reachability* wifiReach = [Reachability reachabilityForLocalWiFi];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    if (netStatus!=ReachableViaWiFi)
    {
        return NO; 
    }
    
    return YES; 

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
#if 0
    if (buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
#endif 
}




#if JSON_FLAG
- (void) regSuccessWithResponse:(NSDictionary *) responseData
#else
- (void) regSuccessWithResponse:(NSData*) responseData
#endif
{
#if (JSON_FLAG == 0)
	NSString * response = [NSString stringWithUTF8String:(const char *)[responseData bytes]] ;
	NSLog(@"register success : %@", response );
#endif
	//Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	[userDefaults setObject:self.tmp_user_email forKey:@"PortalUseremail"];
	[userDefaults setObject:self.tmp_user_str forKey:@"PortalUsername"];
	[userDefaults setObject:self.tmp_pass_str forKey:@"PortalPassword"];
	
	[userDefaults synchronize];
	

	//Load step 10
    NSLog(@"Load Step 10"); 
    //Load the next xib
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
#if JSON_FLAG
- (void) regFailedWithError:(NSDictionary *) error_response
#else
- (void) regFailedWithError:(NSHTTPURLResponse*) error_response
#endif
{
//	NSLog(@"register failed with error code:%d", [error_response statusCode]);
//	
//
//    NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Registration_Error",nil, [NSBundle mainBundle],
//                                                        @"Registration Error" , nil);
//    
//    NSString * msg = NSLocalizedStringWithDefaultValue(@"Server_error_" ,nil, [NSBundle mainBundle],
//                                                       @"Server error: %@" , nil);
//    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
//
//	
//	//ERROR condition
//	UIAlertView *alert = [[UIAlertView alloc]
//						  initWithTitle:msg1
//						  message:[NSString stringWithFormat:msg, [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]] 
//						  delegate:self
//						  cancelButtonTitle:ok
//						  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
    
    NSString * title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                              @"Create Account Failed" , nil);
//    NSString * msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg3",nil, [NSBundle mainBundle],
//                                            @"Invalid email. Email address should be of the form somebody@somewhere.com"  , nil);
    
    //ERROR condition
    UIAlertView *_alert = [[UIAlertView alloc]
                           initWithTitle:title
#if JSON_FLAG
                           message:[error_response objectForKey:@"message"]
#else
                           message:[BMS_Communication getLocalizedMessageForError:[error_response statusCode]]
#endif
                           delegate:self
                           cancelButtonTitle:ok
                           otherButtonTitles:nil];
    [_alert show];
    [_alert release];
    
	return;
	
}
- (void) regFailedServerUnreachable
{
	NSLog(@"register failed : server unreachable");
	
    NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Registration_Error",nil, [NSBundle mainBundle],
                                                        @"Registration Error" , nil);
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Registration_Error_1" ,nil, [NSBundle mainBundle],
                                                       @"BMS Server is unreachable. Please goto WIFI setting to ensure iOS device is connected to router/3G network" , nil);
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:msg1
						  message:msg
						  delegate:self
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}



@end
