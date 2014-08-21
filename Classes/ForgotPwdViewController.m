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

@property (nonatomic, copy) NSString *userEmail;

@end

@implementation ForgotPwdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title =  LocStr(@"Forgot Password");
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:LocStr(@"Invalid email. Email address should be in the form somebody@somewhere.com")
                                                           delegate:nil
                                                  cancelButtonTitle:LocStr(@"Ok")
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [_userEmailTF resignFirstResponder];
    
    self.userEmail = _userEmailTF.text;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(forgotSuccessWithResponse:)
                                                                         FailSelector:@selector(forgotFailedWithError:)
                                                                            ServerErr:@selector(forgotFailedServerUnreachable)];
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
    
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:LocStr(@"Login")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleLoginButton:)];
    self.navigationItem.rightBarButtonItem = loginButton;
}

- (void)forgotFailedWithError:(NSDictionary *)errorResponse
{
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	DLog(@"ForgotPwdVC -  forgotFailedWithError code: %d", [errorResponse[@"status"] intValue]);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Reset Password Error")
                                                    message:[NSString stringWithFormat:LocStr(@"Server error: %@"), errorResponse[@"message"]]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:LocStr(@"Ok"), nil];
    [alert show];
}

- (void)forgotFailedServerUnreachable
{
    self.navigationItem.leftBarButtonItem.enabled = YES ;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	DLog(@"ForgotPwdVC -  forgotFailedServerUnreachable");

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Reset Password Error")
                                                    message:LocStr(@"Server is unreachable. Please try again later.")
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:LocStr(@"Ok"), nil];
	[alert show];
}

@end
