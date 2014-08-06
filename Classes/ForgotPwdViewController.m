//
//  ForgotPwdViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/10/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "ForgotPwdViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "define.h"

@interface ForgotPwdViewController ()

@property (nonatomic, retain)  NSString *userEmail;
@property (nonatomic, assign) IBOutlet UIButton  *resetPassWordButton;
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
    [_userEmail release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title =  NSLocalizedStringWithDefaultValue(@"Forgot_Password",nil, [NSBundle mainBundle],
                                                                   @"Forgot Password", nil);
    
    UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back"];
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithImage:hubbleBack
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(btnBackPressed)];
    [backBarBtn setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
    
    self.navigationItem.leftBarButtonItem = backBarBtn;
    
   /* UIBarButtonItem *nextButton =
    [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringWithDefaultValue(@"next",nil, [NSBundle mainBundle],
                                                                              @"Next", nil)
                                     style:UIBarButtonItemStylePlain 
                                    target:self 
                                    action:@selector(handleNextButton:)];          
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];*/
    
    passwordLinkSent.hidden = YES;
    [self.view addSubview:passwordLinkSent];
    
    if (isiPhone4)
    {
        self.resetPassWordButton.frame = CGRectOffset(self.resetPassWordButton.frame, 0, -40);
    }
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

-(void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)checkEmailValidation:(NSString*)strEmail{
    
    strEmail  = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
    if(strEmail.length==0)
    {
        return NO;
    }
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}


-(IBAction)handleNextButton:(id) sender
{
    if(![self checkEmailValidation:userEmailTF.text])
    {
        NSString *strMsg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg3",nil, [NSBundle mainBundle], @"Invalid email. Email address should be of the form somebody@somewhere.com", nil);
        //NSString *strMsg = @"Please enter valid email.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:strMsg delegate:nil cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil) otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    [userEmailTF resignFirstResponder];
    
    //NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
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
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
    
	//ERROR condition
	[[[[UIAlertView alloc] initWithTitle:msg1
                               message:[NSString stringWithFormat:msg, [errorResponse objectForKey:@"message"]]
                              delegate:nil
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
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
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
