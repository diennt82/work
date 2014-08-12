//
//  RegistrationViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Hubble Connected Limited. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>

#import "RegistrationViewController.h"
#import "Step_10_ViewController.h"
#import "UserAccount.h"
#import "ToUViewController.h"

#define GAI_CATEGORY @"Registration view"

@interface RegistrationViewController () <UITextFieldDelegate>
    
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet UIButton *checkboxButton;
@property (nonatomic, weak) IBOutlet UIButton *createButton;
@property (nonatomic, weak) IBOutlet UIButton *termsAgreeButton;
@property (nonatomic, weak) IBOutlet UIButton *accountExistsButton;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *passwordConfirmation;
@property (nonatomic, copy) NSString *email;

@property (nonatomic) BOOL isVisisble;

@end

@implementation RegistrationViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UIScreen.mainScreen.bounds.size.height < 568) {
        [[NSBundle mainBundle] loadNibNamed:@"RegistrationViewController_35"
                                      owner:self
                                    options:nil];
    }
    
    self.navigationController.navigationBarHidden = YES;
    _createButton.enabled = NO;
    
    [_createButton setBackgroundImage:[UIImage imageNamed:@"enter"] forState:UIControlStateNormal];
    [_createButton setBackgroundImage:[UIImage imageNamed:@"enter_pressed"] forState:UIControlEventTouchDown];
    
    [_checkboxButton setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
    [_checkboxButton setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateSelected];
    [_checkboxButton setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateHighlighted];
    
    _usernameTextField.delegate = self;
    _emailTextField.delegate = self;
    _passwordTextField.delegate = self;
    _confirmPasswordTextField.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIButton *btnCheckbox = (UIButton *)[self.view viewWithTag:501];
        
        btnCheckbox.frame = CGRectMake(_createButton.frame.origin.x - 6, btnCheckbox.frame.origin.y, btnCheckbox.frame.size.width, btnCheckbox.frame.size.height);
        UILabel *lblTermServices = (UILabel *)[self.view viewWithTag:502];
        lblTermServices.frame = CGRectMake(btnCheckbox.frame.origin.x + btnCheckbox.frame.size.width, lblTermServices.frame.origin.y, lblTermServices.frame.size.width, lblTermServices.frame.size.height);
        UIButton *btn = (UIButton *)[self.view viewWithTag:504];
        btn.frame = lblTermServices.frame;
        self.progressView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    }
    
    // Set widgets to use localized string resources
    _usernameTextField.placeholder = LocStr(@"Username");
    _emailTextField.placeholder = LocStr(@"Email");
    _passwordTextField.placeholder = LocStr(@"Password");
    _confirmPasswordTextField.placeholder = LocStr(@"Confirm Password");
    
    [_createButton setTitle:LocStr(@"Create") forState:UIControlStateNormal];
    [_accountExistsButton setTitle:LocStr(@"Already have an account?") forState:UIControlStateNormal];
    
    // Setup the Terms of Service button to look like it's hyper linked.
    UIColor *tintColor = [UINavigationBar appearance].tintColor;
    
    NSDictionary *attrDict = @{ NSFontAttributeName : _termsAgreeButton.titleLabel.font,
                                NSForegroundColorAttributeName : tintColor };
    
    NSString *titleStr = LocStr(@"I agree with the Terms of Service");
    NSString *titleSubStr = LocStr(@"Terms of Service");
    NSRange range = NSMakeRange([titleStr rangeOfString:titleSubStr].location, titleSubStr.length);
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:titleStr attributes:attrDict];
    [attrTitle addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
    
    [_termsAgreeButton setAttributedTitle:attrTitle forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    self.navigationController.navigationBarHidden = YES;
    self.trackedViewName = GAI_CATEGORY;

    // Ensure logo image is shown. View frame will be reset after having
    // viewed a ToS view controller.
    _logoImageView.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isVisisble = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isVisisble = NO;
    [self.view endEditing:YES];
}

#pragma mark - Action methods

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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnTermsConditionPressed:(id)sender
{
    self.isVisisble = NO;
    ToUViewController *vc= [[ToUViewController alloc] initWithNibName:@"ToUViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Private methods

- (void)validateAllFieldsAndEnableSignUp
{
    if ( _usernameTextField.text.length > 0 &&
        _emailTextField.text.length > 0 &&
        _passwordTextField.text.length > 0 &&
        _confirmPasswordTextField.text.length > 0 &&
        _checkboxButton.selected
       )
    {
        _createButton.enabled = YES;
    }
    else {
        _createButton.enabled = NO;
    }
}

- (void)animateTextField:(UITextField *)textField withUp:(BOOL)up
{
    //if ( self.isViewLoaded && self.view.window ) {
    if ( !_isVisisble ) {
        // Do not do anything as view is not visible.
        [textField resignFirstResponder];
        return;
    }
    
    CGRect rect = self.view.frame;
    BOOL doit = NO;
    
    // Sanity check if movement is really needed
    if ( rect.origin.y == 0 && up ) {
        // Can go up when y is zero.
        doit = YES;
    }
    else if ( rect.origin.y != 0 && !up ) {
        // Can go back down when y is not zero.
        doit = YES;
    }
    
    if ( doit ) {
        // Tweak as needed
        const float movementDuration = 0.3f;
        NSInteger movementDistance = 180;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            movementDistance = 190;
        }
        else if (UIScreen.mainScreen.bounds.size.height < 568) {
            movementDistance = 155;
        }
        
        int movement = up ? -movementDistance : movementDistance;
        
        [UIView beginAnimations:@"anim" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:movementDuration];
        
        self.view.frame = CGRectOffset(rect, 0, movement);
        _logoImageView.hidden = up;
        
        [UIView commitAnimations];
    }
}

- (void)checkInputDataToLogin
{
    BOOL checkFailed = YES;
    
    NSString *regex = @"[a-zA-Z0-9._-]+";
    NSPredicate *validatedUsername = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidateUsername = [validatedUsername evaluateWithObject:_usernameTextField.text];

    NSString *msg = nil ;

    //UserName at least 5 chars and at most 20 characters
    if ([_usernameTextField.text length] < 5 || 20 < [_usernameTextField.text length]) {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg",nil, [NSBundle mainBundle],
                                                @"User name has to be between 5-20 characters" , nil);
    }
    else if (!isValidateUsername) {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg5", nil, [NSBundle mainBundle],
                                                @"Username should not contain special characters except for - _ and ."  , nil);
    }
    else if (([_passwordTextField.text length] < 8) || ([_passwordTextField.text length] > 12) ) {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg1",nil, [NSBundle mainBundle],
                                                @"Password has to be between 8-12 characters" , nil);
    }
    else if ( ![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg2",nil, [NSBundle mainBundle],
                                                @"Password does not match" , nil);
    }
    else if (![self isValidEmail:_emailTextField.text]) {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg3",nil, [NSBundle mainBundle],
                                                @"Invalid email. Email address should be of the form somebody@somewhere.com"  , nil);
    }
    else if (![RegistrationViewController isWifiConnectionAvailable] ) {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg4",nil, [NSBundle mainBundle],
                                                @"Please select a Wifi network to connect"  , nil);
    }
    else {
        // Good info now ...
        checkFailed = NO;
        [self.view endEditing:YES];
        [self.view addSubview:_progressView];

        // Register user ...
        self.username   = _usernameTextField.text;
        self.email      = _emailTextField.text;
        self.password   = _passwordTextField.text;
        self.passwordConfirmation  = _confirmPasswordTextField.text;

        DLog(@"RegistrationVC - Start registration");
        
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:@selector(registerSuccessWithResponse:)
                                                                              FailSelector:@selector(registerFailedWithError:)
                                                                                 ServerErr:@selector(registerFailedServerUnreachable)];
        [jsonComm registerAccountWithUsername:_username
                                     andEmail:_email
                                  andPassword:_password
                      andPasswordConfirmation:_passwordConfirmation];
    }

    if (checkFailed) {
        // ERROR condition
        UIAlertView *alertViewError = [[UIAlertView alloc] initWithTitle:LocStr(@"Create_Account_Failed")
                                                                 message:msg
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:LocStr(@"OK"), nil];
        [alertViewError show];
    }
}

- (BOOL)isValidEmail:(NSString *)email
{
    if ([email rangeOfString:@"@"].location == NSNotFound) {
        return NO;
    }
    
    NSArray *array = [email componentsSeparatedByString:@"@"];
    
    if (array.count > 2) {
        // qwe@uyt.uyt@dd - Too many @ characters
        return NO;
    }
    
    NSString *domain = array[1];
    DLog(@"Domain is : %@",domain);
    
    NSError *error = NULL;
    NSRegularExpression *regexExpr = [NSRegularExpression regularExpressionWithPattern:@"\\([^\\)]*\\)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regexExpr stringByReplacingMatchesInString:domain options:0 range:NSMakeRange(0, domain.length) withTemplate:@""];
    DLog(@"modifiedString ------> %@", modifiedString);
    
    NSString *regex = @"[_a-zA-Z0-9-]+(\\.[_a-zA-Z0-9-]+)+";
    NSPredicate *validatedDomain = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [validatedDomain evaluateWithObject:modifiedString];
}

+ (BOOL)isWifiConnectionAvailable
{
    Reachability* wifiReach = [Reachability reachabilityForLocalWiFi];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    
    if (netStatus != ReachableViaWiFi) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField withUp:YES];
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
    if (textField == _usernameTextField) {
        [_emailTextField becomeFirstResponder];
    }
    else if (textField == _emailTextField) {
        [_passwordTextField becomeFirstResponder];
    }
    else if(textField == _passwordTextField) {
        [_confirmPasswordTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - JSON call back

- (void)registerSuccessWithResponse:(NSDictionary *)responseData
{
    [self.progressView removeFromSuperview];
    
    //Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	[userDefaults setObject:_email    forKey:@"PortalUseremail"];
	[userDefaults setObject:_username forKey:@"PortalUsername"];
	[userDefaults setObject:_password forKey:@"PortalPassword"];
    [userDefaults setObject:[responseData[@"data"] objectForKey:@"authentication_token"] forKey:@"PortalApiKey"];
    [userDefaults synchronize];
    
    UserAccount *account = [[UserAccount alloc] initWithUser:_username
                                                    password:_password
                                                      apiKey:[userDefaults stringForKey:@"PortalApiKey"]
                                             accountDelegate:nil];
    
    [account sync_online_and_offline_data:nil];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Register successfully - user: %@", _username] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Register successfully - user: %@", _username]
                                                     withLabel:nil
                                                     withValue:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if (_delegate) {
        [_delegate sendStatus:SHOW_CAMERA_LIST];
    }
}

- (void)registerFailedWithError:(NSDictionary *)error_response
{
    [self.progressView removeFromSuperview];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Create_Account_Failed")
                                                     message:error_response[@"message"]
                                                    delegate:self
                                           cancelButtonTitle:LocStr(@"Ok")
                                           otherButtonTitles:nil];
    [alert show];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Regsiter failed - user: %@, error: %@", _username, alert.message] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Register successfully - user: %@", _username]
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)registerFailedServerUnreachable
{
    [self.progressView removeFromSuperview];
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Registration_Error")
                                                    message:LocStr(@"Registration_Error_1")
                                                   delegate:self
                                          cancelButtonTitle:LocStr(@"Ok")
                                          otherButtonTitles:nil];
	[alert show];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Register failed - user: %@, error: Server is unreachable", _username] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Register failed, Server is unreachable - user: %@", _username]
                                                     withLabel:nil
                                                     withValue:nil];
}

@end
