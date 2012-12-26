//
//  ForgotPwdViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/10/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "ForgotPwdViewController.h"

@interface ForgotPwdViewController ()

@end

@implementation ForgotPwdViewController


@synthesize userEmail;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        userEmail = @""; 
    }
    return self;
}
-(void) dealloc
{
    [  userEmail release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title =  NSLocalizedStringWithDefaultValue(@"Forgot_Password",nil, [NSBundle mainBundle],
                                                                   @"Forgot Password", nil);
    
    
    UIBarButtonItem *nextButton = 
    [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringWithDefaultValue(@"Next",nil, [NSBundle mainBundle],
                                                                              @"Next", nil)
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
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) handleNextButton:(id) sender
{

    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);

    
    userEmail= userEmailTF.text ; 
     
    
    if (userEmail == nil  ||
        [userEmail rangeOfString:@"@"].location == NSNotFound)
    {
        //ERROR condition
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedStringWithDefaultValue(@"Email_Format_error",nil, [NSBundle mainBundle],
                                                                              @"Email Format error", nil)
                              message:NSLocalizedStringWithDefaultValue(@"Email_Format_error_msg",nil, [NSBundle mainBundle],
                                                                        @"Correct email format is of the form: someone@somedomain.com. Please try again!", nil)
                              delegate:self
                              cancelButtonTitle:ok
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return; 
    }
    
    self.navigationItem.leftBarButtonItem.enabled = NO ;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    BMS_Communication * bms_comm; 
    bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                Selector:@selector(resetSuccessWithResponse:) 
                                            FailSelector:@selector(resetFailedWithError:) 
                                               ServerErr:@selector(resetFailedServerUnreachable)];
    
    [bms_comm BMS_resetUserPassword:userEmail];
    
    
}

-(void) handleLoginButton:(id) sender
{
    [self.navigationController popViewControllerAnimated:NO];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}


-(void) resetSuccessWithResponse:(NSData*) responseData
{
    [self.view addSubview:passwordLinkSent];
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.navigationItem setHidesBackButton:YES];
    
    
    toEmail.text  = userEmail; 
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Login" ,nil, [NSBundle mainBundle],
                                                      @"Login" , nil);

    UIBarButtonItem *nextButton = 
    [[UIBarButtonItem alloc] initWithTitle:msg
                                     style:UIBarButtonItemStylePlain 
                                    target:self 
                                    action:@selector(handleLoginButton:)];          
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
    
  
}

- (void) resetFailedWithError:(NSHTTPURLResponse*) error_response
{
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"ResetPass failed with error code:%d", [error_response statusCode]);

    NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Reset_Password_Error",nil, [NSBundle mainBundle],
                                                       @"Reset Password Error" , nil);
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Server_error_" ,nil, [NSBundle mainBundle],
                                                       @"Server error: %@" , nil);

    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
    
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:msg1
						  message:[NSString stringWithFormat:msg, [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]] 
						  delegate:self
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	return;
	
}
- (void) resetFailedServerUnreachable
{
    
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"Reset pass failed : server unreachable");

    NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Reset_Password_Error",nil, [NSBundle mainBundle],
                                                        @"Reset Password Error" , nil);
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Server_error_1" ,nil, [NSBundle mainBundle],
                                                       @"Server is unreachable. Please try again later." , nil);
    
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
