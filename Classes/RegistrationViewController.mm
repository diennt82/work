//
//  RegistrationViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "RegistrationViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "Reachability.h"
#import "Step_10_ViewController.h"

@interface RegistrationViewController () <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *tfEmail;
@property (retain, nonatomic) IBOutlet UITextField *tfPassword;
@property (retain, nonatomic) IBOutlet UITextField *tfConfirmPassword;
@property (retain, nonatomic) IBOutlet UIButton *btnCheckbox;
@property (retain, nonatomic) IBOutlet UIButton *btnCreate;

@property (retain, nonatomic) NSString *stringUsername;
@property (retain, nonatomic) NSString *stringPassword;
@property (retain, nonatomic) NSString *stringCPassword;
@property (retain, nonatomic) NSString *stringEmail;
@end

@implementation RegistrationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = YES;
    self.btnCreate.enabled = NO;
    
    [self.btnCreate setBackgroundImage:[UIImage imageNamed:@"enter"] forState:UIControlStateNormal];
    [self.btnCreate setBackgroundImage:[UIImage imageNamed:@"enter_pressed"] forState:UIControlEventTouchDown];
    
    [self.btnCheckbox setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
    [self.btnCreate setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateSelected];
    [self.btnCreate setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateHighlighted];
    
    self.tfEmail.delegate = self;
    self.tfPassword.delegate = self;
    self.tfConfirmPassword.delegate =self;
}

#pragma mark - Action

- (IBAction)btnCheckboxTouchUpInsideAction:(UIButton *)sender
{
    [sender setSelected:!sender.selected];
    [self validateAllFieldsAndEnableSignUp];
}

- (IBAction)btnCreateTouchUpInsideAction:(id)sender
{
    [self checkInputDataToLogin];
}

- (IBAction)btnAlreadyTouchUpInsideAction:(id)sender
{
    [self.delegate sendStatus:LOGIN];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Methods

-(void) validateAllFieldsAndEnableSignUp
{
    if ((_tfEmail.text.length > 0) &&
        (_tfPassword.text.length     > 0) &&
        (_tfConfirmPassword.text.length    > 0) &&
        (_btnCheckbox.selected      == TRUE)
       )
    {
        //Enable the "Create" button
        self.btnCreate.enabled = YES;
    }
    else
    {
        //disable the "Create"  button
        self.btnCreate.enabled = NO;
    }
}

- (void)animateTextField: (UITextField *)textField withUp:(BOOL) up
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

- (void)checkInputDataToLogin
{
    NSString * msg = nil ;
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString * title = nil;

    if (([_tfPassword.text length] < 8) ||
             ([_tfPassword.text length] > 12) )
    {
        //error
        title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                  @"Create Account Failed" , nil);
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg1",nil, [NSBundle mainBundle],
                                                @"Password has to be between 8-12 characters" , nil);
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
    else if ( ![_tfPassword.text isEqualToString:_tfConfirmPassword.text])
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
    else if(![self isValidEmail:_tfEmail.text])
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
    
    else if (![RegistrationViewController isWifiConnectionAvailable] )
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
        self.stringEmail     = _tfEmail.text;
        self.stringUsername  = [_stringEmail substringToIndex:[_stringEmail rangeOfString:@"@"].location];
        self.stringPassword  = _tfPassword.text;
        self.stringCPassword  = _tfConfirmPassword.text;

        NSLog(@"RegistrationVC - Start registration");
        
        BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:@selector(regSuccessWithResponse:)
                                                                              FailSelector:@selector(regFailedWithError:)
                                                                                 ServerErr:@selector(regFailedServerUnreachable)] autorelease];
        [jsonComm registerAccountWithUsername:_stringUsername
                                     andEmail:_stringEmail
                                  andPassword:_stringPassword
                      andPasswordConfirmation:_stringCPassword];
        
    }
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

+ (BOOL)isWifiConnectionAvailable
{
    Reachability* wifiReach = [Reachability reachabilityForLocalWiFi];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    
    if (netStatus != ReachableViaWiFi)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField withUp:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField withUp:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self validateAllFieldsAndEnableSignUp];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _tfEmail)
    {
        [_tfPassword becomeFirstResponder];
    }
    else if(textField == _tfPassword)
    {
        [_tfConfirmPassword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - JSON call back

- (void) regSuccessWithResponse:(NSDictionary *) responseData
{
    //Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	[userDefaults setObject:_stringEmail    forKey:@"PortalUseremail"];
	[userDefaults setObject:_stringUsername forKey:@"PortalUsername"];
	[userDefaults setObject:_stringPassword forKey:@"PortalPassword"];
    [userDefaults setObject:[[responseData objectForKey:@"data"] objectForKey:@"authentication_token"]
                     forKey:@"PortalApiKey"];
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
    step10ViewController.delegate = self.delegate;
    [self.navigationController pushViewController:step10ViewController animated:NO];
    [step10ViewController release];
}

- (void) regFailedWithError:(NSDictionary *) error_response
{
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString * title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                         @"Create Account Failed" , nil);
    UIAlertView *_alert = [[UIAlertView alloc]
                           initWithTitle:title
                           message:[error_response objectForKey:@"message"]
                           delegate:self
                           cancelButtonTitle:ok
                           otherButtonTitles:nil];
    [_alert show];
    [_alert release];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tfEmail release];
    [_tfPassword release];
    [_tfConfirmPassword release];
    [_btnCheckbox release];
    [_btnCreate release];
    [super dealloc];
}
@end
