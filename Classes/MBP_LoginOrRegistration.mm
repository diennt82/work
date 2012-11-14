//
//  MBP_LoginOrRegistration.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_LoginOrRegistration.h"


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


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) d;
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		delegate = d;
    }
    return self;
}


/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	  
       
    self.navigationItem.title = @"Login"; 
   
    //Back key
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];

    
    [self.view addSubview:self.progressView];
    
    
  
    
     self.temp_user_email  = @"";
    self.temp_pass_str =@"";
    self.temp_pass_str =@"";
    
	//load user/pass  
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//can be user email or user name here --  
	NSString * old_usr = (NSString *) [userDefaults objectForKey:@"PortalUsername"];	
	NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    self.temp_user_email  = (NSString*) [userDefaults objectForKey:@"PortalUseremail"];
    
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
            
            self.progressView.hidden = NO;
            [self.progressLabel setText:@"Connecting to BMS..." ];
            self.navigationItem.leftBarButtonItem.enabled = NO ;
            self.navigationItem.rightBarButtonItem.enabled = NO;  
            
            
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(doSignIn:)
                                           userInfo:nil
                                            repeats:NO]; 
            
            
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

- (BOOL) shouldAutorotate
{
    
    NSLog(@"loging autorotate"); 
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
    
}

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


- (void)dealloc {
	[userName release];
	[password release];


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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
     
	[textField resignFirstResponder];
    
    
    //NSLog(@" %d %d",[self.userName.text length], [self.password.text length] );
    
    if ([self.userName.text length] > 0
        && [self.password.text length] > 0)
    {
        //enable Done btn
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        //enable Done btn
        self.navigationItem.rightBarButtonItem.enabled = NO;

    }
    
	return NO;
}


- (void)presentModallyOn:(UIViewController *)parent
{
    UINavigationController *    navController;
    
    //setup nav controller 
    navController= [[[UINavigationController alloc]initWithRootViewController:self] autorelease];
    
   
    
    // Create a navigation controller with us as its root.
    assert(navController != nil);
    
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    // Set up the Cancel button on the left of the navigation bar.
    self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
    assert(self.navigationItem.leftBarButtonItem != nil);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone   target:self action:@selector(doneAction:)] autorelease];

    assert(self.navigationItem.rightBarButtonItem != nil);

    // Present the navigation controller on the specified parent 
    // view controller.

    [parent presentModalViewController:navController animated:NO];
}


-(void) doSignIn :(NSTimer *) exp
{
    BMS_Communication * bms_comm; 
    bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                Selector:@selector(loginSuccessWithResponse:) 
                                            FailSelector:@selector(loginFailedWithError:) 
                                               ServerErr:@selector(loginFailedServerUnreachable)];
    
    [bms_comm BMS_loginWithUser:self.temp_user_str AndPass:self.temp_pass_str];
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
                [delegate sendStatus:3];
                break;
            }
            default:
                break;
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
        ForgotPwdViewController *forgotPwdController = [[ForgotPwdViewController alloc]
                                                        initWithNibName:@"ForgotPwdViewController" bundle:nil];
        [self.navigationController pushViewController:forgotPwdController animated:NO];    
        [forgotPwdController release];
        
    }
}





#pragma mark -
#pragma mark Button Handling 

- (IBAction) createNewAccount:(id)sender
{
    [delegate sendStatus:1];
}

-(void) cancelAction:(id) sender
{
    [delegate sendStatus:7];
}

-(void) doneAction:(id) sender
{
   
    [userName resignFirstResponder];
    [password resignFirstResponder];
    
    temp_user_str = userName.text;
    temp_pass_str = password.text;
    
    
    
    BMS_Communication * bms_comm; 
    bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                Selector:@selector(loginSuccessWithResponse:) 
                                            FailSelector:@selector(loginFailedWithError:) 
                                               ServerErr:@selector(loginFailedServerUnreachable)];

    [bms_comm BMS_loginWithUser:temp_user_str AndPass:temp_pass_str];
    
    
    self.progressView.hidden = NO;
    [self.progressLabel setText:@"Connecting to Server..." ];
    [self.view bringSubviewToFront:self.progressView];
    
    self.navigationItem.leftBarButtonItem.enabled = NO ;
    self.navigationItem.rightBarButtonItem.enabled = NO;

}



- (IBAction) handleButtonPressed:(id) sender
{
	int sender_tag = ((UIButton *) sender).tag;
	NSLog(@"THIS IS NOT USED ... Sender tag:%d", sender_tag);
#if 0
	switch (sender_tag) {
		case LOGIN_BUTTON_TAG:
		{
			tmp_user_str = self.userName.text;
			tmp_pass_str = self.password.text; 
			
			if ([tmp_user_str length] == 0 || [tmp_pass_str length] <3)
			{
				//ERROR condition
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle:@"Error"
									  message:@"Username can't be empty, password has to be at lease 3 characters" 
									  delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
				[alert show];
				[alert release];
				return;
			}
			
			BMS_Communication * bms_comm; 
			bms_comm = [[BMS_Communication alloc] initWithObject:self
														 Selector:@selector(loginSuccessWithResponse:) 
													 FailSelector:@selector(loginFailedWithError:) 
														ServerErr:@selector(loginFailedServerUnreachable)];
			
			[bms_comm BMS_loginWithUser:tmp_user_str AndPass:tmp_pass_str];
			
			self.progressView.hidden = NO;
			[self.progressLabel setText:@"Connecting to BMS..." ];
			
			break;
		}
		case CREATE_NEW_BUTTON_TAG:
		{ 
			[[NSBundle mainBundle] loadNibNamed:@"MBP_LoginOrRegistration_1" 
										  owner:self 
										options:nil];
			[self.view addSubview:registraionView];
			/*[self.view addSubview:regUserName];
			[self.view addSubview:regUserPass];
			[self.view addSubview:regUserEmail];
			[self.view addSubview:regProgress];
			[self.view addSubview:regComplete];
			*/
			break; 
		}
		case BACK_BUTTON_TAG:
		{
			[delegate sendStatus:7];
			break;
		}
		case REG_CANCEL_BUTTON_TAG:
		{
			//Back to login screen
			[self.registraionView removeFromSuperview]; 
			break;
		}
		case REG_CREATE_BUTTON_TAG:
		{
			
			tmp_user_str  = self.regUserName.text;
			tmp_pass_str = self.regUserPass.text; 
			tmp_user_email= self.regUserEmail.text;
			
			NSRange validRange = [tmp_user_email rangeOfString:@"@"];
			
			
			if ([tmp_user_str length] == 0 || [tmp_pass_str length] <3)
			{
				//ERROR condition
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle:@"Error"
									  message:@"Username can't be empty and password has to be at lease 3 characters" 
									  delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
				[alert show];
				[alert release];
				return;
			}
			else if ( validRange.location == NSNotFound)
			{
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle:@"Error"
									  message:@"Email entered is not valid. A valid email format is of the form: someone@somedomain.com" 
									  delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
				[alert show];
				[alert release];
				return;
			}
			
			
			NSLog(@"Start registration"); 
			
			BMS_Communication * bms_comm; 
			bms_comm = [[BMS_Communication alloc] initWithObject:self
														Selector:@selector(regSuccessWithResponse:) 
													FailSelector:@selector(regFailedWithError:) 
													   ServerErr:@selector(regFailedServerUnreachable)];
			
			[bms_comm BMS_registerWithUserId:tmp_user_str AndPass:tmp_pass_str AndEmail:tmp_user_email];
			
			self.regProgress.hidden = NO;
			break;
		}
		default:
			break;
	}
#endif
}

#pragma mark -
#pragma mark Login Callbacks
- (void) loginSuccessWithResponse:(NSData*) responseData
{
	
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:_OfflineMode];
    [userDefaults synchronize];
	
	NSString *response = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	
	
	NSRange isEmail = [temp_user_str rangeOfString:@"@"];
	if (isEmail.location != NSNotFound)
	{
		//Dont need to extract from response data 
		self.temp_user_email = temp_user_str;
		
	}
	else if ( [response hasPrefix:@"Email="])
	{
        
        NSArray * substrings = [response componentsSeparatedByString:@"&"];
        NSString * email_ = [substrings objectAtIndex:0]; 
        NSString * id_ = [substrings objectAtIndex:1];
        
		self.temp_user_email = [email_ substringFromIndex:[@"Email=" length]]; 
		self.temp_user_email = [self.temp_user_email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        self.temp_user_str =  [id_ substringFromIndex:[@"Id=" length]];
        self.temp_user_str = [self.temp_user_str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
       
        
    }
	else 
	{
		//ERROR condition
		self.progressView.hidden = YES;
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Login Error"
							  message:@"Server response invalid, please try again!"
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
		
	}

	
		
	//Store user/pass for later use
	
	[userDefaults setObject:self.temp_user_email forKey:@"PortalUseremail"];
	[userDefaults setObject:self.temp_user_str forKey:@"PortalUsername"];
	[userDefaults setObject:self.temp_pass_str forKey:@"PortalPassword"];
	[userDefaults synchronize];
	
	//MOVE on now .. 
    
       
    
    //REGister for push 
   
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationType) (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
       
    
    
	account = [[UserAccount alloc] initWithUser:self.temp_user_email
										AndPass:self.temp_pass_str
								   WithListener: delegate];
	//[account query_camera_list];
    
    //BLOCKED method
    [account query_camera_list_blocked];

}

- (void) loginFailedWithError:(NSHTTPURLResponse*) error_response
{
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"Loging failed with error code:%d", [error_response statusCode]);
	
	self.progressView.hidden = YES;
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Login Error"
						  message:[NSString stringWithFormat:@"Server error: %@", [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]]
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	return;
	
}
- (void) loginFailedServerUnreachable
{
    
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"Loging failed : server unreachable");
	self.progressView.hidden = YES;
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Login Error"
						  message:@"Server is unreachable. Do you want to access your cameras offline?"
						  delegate:self
						  cancelButtonTitle:@"No"
						  otherButtonTitles:@"Yes", nil];
    alert.tag = 112; 
	[alert show];
	[alert release];
	
}





- (void) regSuccessWithResponse:(NSData*) responseData
{

    NSString * response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]; 
    

	
	NSLog(@"register success : %@", response );
	
	//Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setObject:temp_user_email forKey:@"PortalUseremail"];
	[userDefaults setObject:temp_user_str forKey:@"PortalUsername"];
	[userDefaults setObject:temp_pass_str forKey:@"PortalPassword"];
	
	[userDefaults synchronize];
	
	//Try to LOGIN - go back to ioController and re-login--  
	[delegate sendStatus:2];
	
}

- (void) regFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"register failed with error code:%d", [error_response statusCode]);
	
	self.regProgress.hidden = YES;
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Registration Error"
						  message:[NSString stringWithFormat:@"Server error: %@", [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]] 
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	return;
	
}
- (void) regFailedServerUnreachable
{
	NSLog(@"register failed : server unreachable");
	
	self.regProgress.hidden = YES;
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Registration Error"
						  message:@"BMS Server is unreachable. Please goto WIFI setting to ensure iOS device is connected to router/3G network"
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}






@end
