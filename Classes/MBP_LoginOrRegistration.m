//
//  MBP_LoginOrRegistration.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_LoginOrRegistration.h"


@implementation MBP_LoginOrRegistration

@synthesize userName, password, remember_pass_sw;
@synthesize progressLabel, progressView;

@synthesize regUserName;
@synthesize regUserPass;
@synthesize regUserEmail; 
@synthesize regProgress, regComplete, registraionView; 

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
	
	NSLog(@"Login Or register viewdidload");
	//load user/pass  
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//can be user email or user name here --  
	NSString * old_usr = (NSString *) [userDefaults objectForKey:@"PortalUsername"];	
	NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
	if (old_usr != nil)
	{
		[self.userName setText:old_usr];
		
		if (old_pass != nil)
		{
			[self.password setText:old_pass];
		}
	}
	
	BOOL shouldAutoLogin = [userDefaults boolForKey:_AutoLogin];
	if (shouldAutoLogin == TRUE	)
	{
		if ((old_usr != nil) && (old_pass != nil))
		{
			tmp_user_str = old_usr;
			tmp_pass_str = old_pass;
			BMS_Communication * bms_comm; 
			bms_comm = [[BMS_Communication alloc] initWithObject:self
														Selector:@selector(loginSuccessWithResponse:) 
													FailSelector:@selector(loginFailedWithError:) 
													   ServerErr:@selector(loginFailedServerUnreachable)];
			
			[bms_comm BMS_loginWithUser:tmp_user_str AndPass:tmp_pass_str];
			
			
			self.progressView.hidden = NO;
			[self.progressLabel setText:@"Connecting to BMS..." ];
			
		}
	}
	

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
	        (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
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
    [super dealloc];
	[userName release];
	[password release];
	[remember_pass_sw release];

	[progressView release];
	[progressLabel release];
	[regUserName release];
	[regUserPass release];
	[regUserEmail release]; 
	[regProgress release];
	[regComplete release];
	[registraionView release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}


#pragma mark -
#pragma mark Button Handling 


- (IBAction) handleButtonPressed:(id) sender
{
	int sender_tag = ((UIButton *) sender).tag;
	
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
}

#pragma mark -
#pragma mark Login Callbacks
- (void) loginSuccessWithResponse:(NSData*) responseData
{
	
	
	NSString *response = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	
	
	NSLog(@"login success response: %@",response );
	
	NSRange isEmail = [tmp_user_str rangeOfString:@"@"];
	if (isEmail.location != NSNotFound)
	{
		//Dont need to extract from response data 
		tmp_user_email = tmp_user_str;
		
	}
	else if ( [response hasPrefix:@"Email="])
	{
		tmp_user_email = [response substringFromIndex:[@"Email=" length]]; 
		tmp_user_email = [tmp_user_email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSLog(@"extracted email  : %@", tmp_user_email);
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

	
	NSLog(@"before saving usr : %@ , %@", tmp_user_str, tmp_user_email);
	
	//Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:tmp_user_email forKey:@"PortalUseremail"];
	[userDefaults setObject:tmp_user_str forKey:@"PortalUsername"];
	[userDefaults setObject:tmp_pass_str forKey:@"PortalPassword"];
	[userDefaults synchronize];
	
	//MOVE on now .. 

	UserAccount * account ; 
	account = [[UserAccount alloc] initWithUser:tmp_user_email
										AndPass:tmp_pass_str
								   WithListener: delegate];
	[account query_camera_list];


}

- (void) loginFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"Loging failed with error code:%d", [error_response statusCode]);
	
	self.progressView.hidden = YES;
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Login Error"
						  message:[NSString stringWithFormat:@"Server error code: %d", [error_response statusCode]] 
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	return;
	
}
- (void) loginFailedServerUnreachable
{
	NSLog(@"Loging failed : server unreachable");
	self.progressView.hidden = YES;
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Login Error"
						  message:@"BMS Server is unreachable. Please go to WIFI setting to ensure iOS device is connected to WiFi network or turn on 3G data network"
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}





- (void) regSuccessWithResponse:(NSData*) responseData
{
	
	NSString * response = [NSString stringWithCharacters:[responseData bytes] length:[responseData length]]; 
	
	NSLog(@"register success : %@", response );
	
	//Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setObject:tmp_user_email forKey:@"PortalUseremail"];
	[userDefaults setObject:tmp_user_str forKey:@"PortalUsername"];
	[userDefaults setObject:tmp_pass_str forKey:@"PortalPassword"];
	
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
						  message:[NSString stringWithFormat:@"Server error code: %d", [error_response statusCode]] 
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
