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
    
    self.navigationItem.title = @"Camera Configured"; 

#if 0
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
#endif
    UIBarButtonItem *nextButton = 
    [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                     style:UIBarButtonItemStylePlain 
                                    target:self 
                                    action:@selector(handleNextButton:)];          
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        
    if (indexPath.row == USERNAME_INDEX) {
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


-(void) handleNextButton:(id) sender
{
    UITextField * _userName = (UITextField *)[self.userName viewWithTag:200];
    UITextField * _userPass = (UITextField *)[self.userPass viewWithTag:200];
    UITextField * _userCPass = (UITextField *)[self.userCPass viewWithTag:200];
    UITextField * _userEmail = (UITextField *)[self.userEmail viewWithTag:200];

    
    //UserName at least 3 chars
    if ([_userName.text length] < 3)
    {
        //error
        //ERROR condition
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:@"Create Account Failed"
                               message:@"User name has to be at least 3 characters" 
                               delegate:self
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
    else if (([_userPass.text length] < 3) ||
             ([_userPass.text length] > 12) )
    {
        //error
        //ERROR condition
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:@"Create Account Failed"
                               message:@"Password has to be between 3-12 characters" 
                               delegate:self
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
    else if ( ![_userPass.text isEqualToString:_userCPass.text])
    {
        //error
        //ERROR condition
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:@"Create Account Failed"
                               message:@"Password does not match" 
                               delegate:self
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
    else if([_userEmail.text rangeOfString:@"@"].location == NSNotFound)
    {
        //error
        //ERROR condition
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:@"Create Account Failed"
                               message:@"Invalid email. Email address should be of the form somebody@somewhere.com" 
                               delegate:self
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
    
    else if (![Step_09_ViewController isWifiConnectionAvailable] )
    {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to create Account"
                                                            message:@"Please select a Wifi network to connect"
                                                           delegate:self
                                                  cancelButtonTitle:@"Settings"
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
        
        BMS_Communication * bms_comm; 
        bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                    Selector:@selector(regSuccessWithResponse:) 
                                                FailSelector:@selector(regFailedWithError:) 
                                                   ServerErr:@selector(regFailedServerUnreachable)];
        
        [bms_comm BMS_registerWithUserId:self.tmp_user_str AndPass:self.tmp_pass_str AndEmail:self.tmp_user_email];
        

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
    if (buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
}





- (void) regSuccessWithResponse:(NSData*) responseData
{
	
	NSString * response = [NSString stringWithUTF8String:(const char *)[responseData bytes]] ; 
	
	NSLog(@"register success : %@", response );
	
	//Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	[userDefaults setObject:self.tmp_user_email forKey:@"PortalUseremail"];
	[userDefaults setObject:self.tmp_user_str forKey:@"PortalUsername"];
	[userDefaults setObject:self.tmp_pass_str forKey:@"PortalPassword"];
	
	[userDefaults synchronize];
	

	//Load step 10
    NSLog(@"Load Step 10"); 
    //Load the next xib
    Step_10_ViewController *step10ViewController = [[Step_10_ViewController alloc]
                                                    initWithNibName:@"Step_10_ViewController" bundle:nil];
    [self.navigationController pushViewController:step10ViewController animated:NO];    
    [step10ViewController release];
    
}

- (void) regFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"register failed with error code:%d", [error_response statusCode]);
	

	
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
