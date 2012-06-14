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
	
	
	NSString * old_usr = (NSString *) [userDefaults objectForKey:@"PortalUsername"];		NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
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

			break; 
		}
		case BACK_BUTTON_TAG:
		{
			
			[delegate sendStatus:7];
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

	NSLog(@"login success response: %@",tmp_user_str );
	
	//Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:tmp_user_str forKey:@"PortalUsername"];
	[userDefaults setObject:tmp_pass_str forKey:@"PortalPassword"];
	
	
	//MOVE on now .. 

	UserAccount * account ; 
	account = [[UserAccount alloc] initWithUser:tmp_user_str
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
						  message:@"BMS Server is unreachable. Please goto WIFI setting to ensure iOS device is connected to router/3G network"
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}

@end
