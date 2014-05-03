//
//  ForgotPwdViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/10/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "ForgotPwdViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface ForgotPwdViewController ()

@property (nonatomic, retain)  NSString *userEmail;

@end

@implementation ForgotPwdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) dealloc
{
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
    
    passwordLinkSent.hidden = YES;
    [self.view addSubview:passwordLinkSent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [userEmailTF becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [userEmailTF resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(BOOL) shouldAutorotate
{
    return NO;
}


-(NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void) handleNextButton:(id) sender
{
    [userEmailTF resignFirstResponder];
    
    //NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
    //                                                  @"Ok", nil);
    self.userEmail = userEmailTF.text ;
    
    self.navigationItem.leftBarButtonItem.enabled = NO ;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(forgotSuccessWithResponse:)
                                                                         FailSelector:@selector(forgotFailedWithError:)
                                                                            ServerErr:@selector(forgotFailedServerUnreachable)] autorelease];
    [jsonComm forgotPasswordWithLogin:_userEmail];
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

-(void) forgotSuccessWithResponse:(NSDictionary *)responseData
{
    passwordLinkSent.hidden  = NO;
    [self.view bringSubviewToFront:passwordLinkSent];
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.navigationItem setHidesBackButton:YES];
    
    toEmail.text  = _userEmail;
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Login" ,nil, [NSBundle mainBundle],
                                                       @"Login" , nil);
    
    UIBarButtonItem *loginButton =
    [[UIBarButtonItem alloc] initWithTitle:msg
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleLoginButton:)];
    self.navigationItem.rightBarButtonItem = loginButton;
    [loginButton release];
}

- (void) forgotFailedWithError:(NSDictionary *)errorResponse
{
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"ForgotPwdVC -  forgotFailedWithError code: %d", [[errorResponse objectForKey:@"status"] intValue]);
    
    NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Reset_Password_Error",nil, [NSBundle mainBundle],
                                                        @"Reset Password Error" , nil);
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Server_error_" ,nil, [NSBundle mainBundle],
                                                       @"Server error: %@" , nil);
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
	//ERROR condition
	[[[[UIAlertView alloc] initWithTitle:msg1
                               message:[NSString stringWithFormat:msg, [errorResponse objectForKey:@"message"]]
                              delegate:self
                     cancelButtonTitle:ok
                     otherButtonTitles:nil]
      autorelease]
     show];
}

- (void) forgotFailedServerUnreachable
{
    
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"ForgotPwdVC -  forgotFailedServerUnreachable");

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
