//
//  ForgotPwdViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/10/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import "ForgotPwdViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface ForgotPwdViewController ()

@property (nonatomic, copy)  NSString *userEmail;

@end

@implementation ForgotPwdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title =  NSLocalizedStringWithDefaultValue(@"Forgot_Password",nil, [NSBundle mainBundle],
                                                                   @"Forgot Password", nil);
    
    UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back"];
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithImage:hubbleBack
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(btnBackPressed)];
    [backBarBtn setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
    
    self.navigationItem.leftBarButtonItem = backBarBtn;

    _passwordLinkSent.hidden = YES;
    [self.view addSubview:_passwordLinkSent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [_userEmailTF becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_userEmailTF resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (BOOL)shouldAutorotate
{
    return NO;
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)checkEmailValidation:(NSString*)strEmail {
    
    strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strEmail.length == 0) {
        return NO;
    }
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}

- (IBAction)handleNextButton:(id)sender
{
    if(![self checkEmailValidation:_userEmailTF.text]) {
        NSString *strMsg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg3",nil, [NSBundle mainBundle], @"Create_Account_Failed_msg3", nil);
        //NSString *strMsg = @"Please enter valid email.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    [_userEmailTF resignFirstResponder];
    
    self.userEmail = _userEmailTF.text;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(forgotSuccessWithResponse:)
                                                                         FailSelector:@selector(forgotFailedWithError:)
                                                                            ServerErr:@selector(forgotFailedServerUnreachable)] autorelease];
    [jsonComm forgotPasswordWithLogin:_userEmail];
}

- (void)handleLoginButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

- (void)forgotSuccessWithResponse:(NSDictionary *)responseData
{
    _passwordLinkSent.hidden  = NO;
    [self.view bringSubviewToFront:_passwordLinkSent];
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.navigationItem setHidesBackButton:YES];
    
    _toEmail.text  = _userEmail;
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

- (void)forgotFailedWithError:(NSDictionary *)errorResponse
{
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"ForgotPwdVC -  forgotFailedWithError code: %d", [[errorResponse objectForKey:@"status"] intValue]);
    
    NSString *msg1 = NSLocalizedStringWithDefaultValue(@"Reset_Password_Error",nil, [NSBundle mainBundle],
                                                        @"Reset Password Error" , nil);
    
    NSString *msg = NSLocalizedStringWithDefaultValue(@"Server_error_" ,nil, [NSBundle mainBundle],
                                                       @"Server error: %@" , nil);
    
    NSString *ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
	//ERROR condition
	[[[[UIAlertView alloc] initWithTitle:msg1
                               message:[NSString stringWithFormat:msg, [errorResponse objectForKey:@"message"]]
                              delegate:nil
                     cancelButtonTitle:ok
                     otherButtonTitles:nil] autorelease] show];
}

- (void)forgotFailedServerUnreachable
{
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	NSLog(@"ForgotPwdVC -  forgotFailedServerUnreachable");

    NSString *msg1 = NSLocalizedStringWithDefaultValue(@"Reset_Password_Error",nil, [NSBundle mainBundle],
                                                        @"Reset Password Error" , nil);
    
    NSString *msg = NSLocalizedStringWithDefaultValue(@"Server_error_1" ,nil, [NSBundle mainBundle],
                                                       @"Server is unreachable. Please try again later." , nil);
    
    NSString *ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:msg1
						  message:msg
						  delegate:nil
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
