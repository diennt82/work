//
//  RegistrationViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "RegistrationViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "KISSMetricsAPI.h"
#import "Step_10_ViewController.h"
#import "UserAccount.h"
//#import "TermsCondController.h"
#import "ToUViewController.h"

#define GAI_CATEGORY    @  "Registration view"

@interface RegistrationViewController () <UITextFieldDelegate>
    
@property (retain, nonatomic) IBOutlet UITextField *tfUsername;
@property (retain, nonatomic) IBOutlet UITextField *tfEmail;
@property (retain, nonatomic) IBOutlet UITextField *tfPassword;
@property (retain, nonatomic) IBOutlet UITextField *tfConfirmPassword;
@property (retain, nonatomic) IBOutlet UIButton *btnCheckbox;
@property (retain, nonatomic) IBOutlet UIButton *btnCreate;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;
@property (nonatomic, assign) IBOutlet UIButton     *agreeButton;

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
    
    if (UIScreen.mainScreen.bounds.size.height < 568)
    {
        [[NSBundle mainBundle] loadNibNamed:@"RegistrationViewController_35"
                                      owner:self
                                    options:nil];
    }
    
    self.navigationController.navigationBarHidden = YES;
    self.btnCreate.enabled = NO;
    
    [self.btnCreate setBackgroundImage:[UIImage imageNamed:@"enter"] forState:UIControlStateNormal];
    [self.btnCreate setBackgroundImage:[UIImage imageNamed:@"enter_pressed"] forState:UIControlEventTouchDown];
    
    [self.btnCheckbox setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
    [self.btnCheckbox setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateSelected];
    [self.btnCheckbox setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateHighlighted];
    
    self.tfUsername.delegate = self;
    self.tfEmail.delegate = self;
    self.tfPassword.delegate = self;
    self.tfConfirmPassword.delegate =self;
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:self.agreeButton.titleLabel.text];
    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
    [self.agreeButton.titleLabel setAttributedText:commentString];
    [commentString release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    self.trackedViewName = GAI_CATEGORY;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIButton *btnCheckbox = (UIButton *)[self.view viewWithTag:501];
        
        btnCheckbox.frame = CGRectMake(_btnCreate.frame.origin.x - 6, btnCheckbox.frame.origin.y, btnCheckbox.frame.size.width, btnCheckbox.frame.size.height);
        UILabel *lblTermServices = (UILabel *)[self.view viewWithTag:502];
        lblTermServices.frame = CGRectMake(btnCheckbox.frame.origin.x + btnCheckbox.frame.size.width, lblTermServices.frame.origin.y, lblTermServices.frame.size.width, lblTermServices.frame.size.height);
        UIButton *btn = (UIButton *)[self.view viewWithTag:504];
        btn.frame = lblTermServices.frame;
        self.viewProgress.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Methods

-(void) validateAllFieldsAndEnableSignUp
{
    if ((_tfUsername.text.length > 0) &&
        (_tfEmail.text.length > 0) &&
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
    //const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    NSInteger movementDistance = 180; // tweak as needed
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        movementDistance = 190;
    }
    
    if (UIScreen.mainScreen.bounds.size.height < 568)
    {
        movementDistance = 155;
    }
    
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
    NSString *title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                        @"Create Account Failed" , nil);
    BOOL checkFailed = TRUE;
    
    NSString * regex = @"[a-zA-Z0-9._-]+";
    NSPredicate * validatedUsername = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidateUsername = [validatedUsername evaluateWithObject:_tfUsername.text];

    //UserName at least 5 chars and at most 20 characters
    if ([_tfUsername.text length] < 5 || 20 < [_tfUsername.text length])
    {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg",nil, [NSBundle mainBundle],
                                                @"User name has to be between 5-20 characters" , nil);
    }
    else if (!isValidateUsername)
    {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg5", nil, [NSBundle mainBundle],
                                                @"Username should not contain special characters except for - _ and ."  , nil);
    }
    else if (([_tfPassword.text length] < 8) ||
             ([_tfPassword.text length] > 12) )
    {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg1",nil, [NSBundle mainBundle],
                                                @"Password has to be between 8-12 characters" , nil);
    }
    else if ( ![_tfPassword.text isEqualToString:_tfConfirmPassword.text])
    {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg2",nil, [NSBundle mainBundle],
                                                @"Password does not match" , nil);
    }
    else if(![self isValidEmail:_tfEmail.text])
    {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg3",nil, [NSBundle mainBundle],
                                                @"Invalid email. Email address should be of the form somebody@somewhere.com"  , nil);
    }
    
    else if (![RegistrationViewController isWifiConnectionAvailable] )
    {
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg4",nil, [NSBundle mainBundle],
                                                @"Please select a Wifi network to connect"  , nil);
    }
    else //Good info now..
    {
        checkFailed = FALSE;
        [self.view endEditing:YES];
        [self.view addSubview:_viewProgress];
        //Register user ...
        self.stringUsername   = _tfUsername.text;
        self.stringEmail      = _tfEmail.text;
        self.stringPassword   = _tfPassword.text;
        self.stringCPassword  = _tfConfirmPassword.text;

        NSLog(@"RegistrationVC - Start registration");
        
        BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:@selector(registerSuccessWithResponse:)
                                                                              FailSelector:@selector(registerFailedWithError:)
                                                                                 ServerErr:@selector(registerFailedServerUnreachable)] autorelease];
        [jsonComm registerAccountWithUsername:_stringUsername
                                     andEmail:_stringEmail
                                  andPassword:_stringPassword
                      andPasswordConfirmation:_stringCPassword];
        
    }
    
    if (checkFailed)
    {
        //ERROR condition
        UIAlertView *alertViewError = [[UIAlertView alloc]
                               initWithTitle:title
                               message:msg
                               delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:ok, nil];
        [alertViewError show];
        [alertViewError release];
    }
}

-(BOOL) isValidEmail:(NSString *) email
{
    if ([email rangeOfString:@"@"].location == NSNotFound)
    {
        return NO;
    }
    
    NSArray * array = [email componentsSeparatedByString:@"@"];
    
    if (array.count > 2) //qwe@uyt.uyt@dd - Too many @ characters
    {
        return NO;
    }
    
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
    if (textField == _tfUsername)
    {
        [_tfEmail becomeFirstResponder];
    }
    else if (textField == _tfEmail)
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

- (void)registerSuccessWithResponse:(NSDictionary *)responseData
{
    [self.viewProgress removeFromSuperview];
    
    //Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	[userDefaults setObject:_stringEmail    forKey:@"PortalUseremail"];
	[userDefaults setObject:_stringUsername forKey:@"PortalUsername"];
	[userDefaults setObject:_stringPassword forKey:@"PortalPassword"];
    [userDefaults setObject:[[responseData objectForKey:@"data"] objectForKey:@"authentication_token"]
                     forKey:@"PortalApiKey"];
    [userDefaults synchronize];
    
    UserAccount *account = [[UserAccount alloc] initWithUser:_stringUsername
                                                    password:_stringPassword
                                                      apiKey:[userDefaults stringForKey:@"PortalApiKey"]
                                                    listener:nil];
    [account sync_online_and_offline_data:nil];
    [account release];
    
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Register successfully - user: %@", _stringUsername] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Register successfully - user: %@", _stringUsername]
                                                     withLabel:nil
                                                     withValue:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if (_delegate)
    {
        [_delegate sendStatus:SHOW_CAMERA_LIST];
    }
}

- (void)registerFailedWithError:(NSDictionary *)error_response
{
    [self.viewProgress removeFromSuperview];
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString * title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                         @"Create Account Failed" , nil);
    NSString *msg = [error_response objectForKey:@"message"];
    UIAlertView *_alert = [[UIAlertView alloc]
                           initWithTitle:title
                           message:msg
                           delegate:self
                           cancelButtonTitle:ok
                           otherButtonTitles:nil];
    [_alert show];
    [_alert release];
    
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Regsiter failed - user: %@, error: %@", _stringUsername, msg] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Register successfully - user: %@", _stringUsername]
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)registerFailedServerUnreachable
{
    [self.viewProgress removeFromSuperview];
	
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
    
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Register failed - user: %@, error: Server is unreachable", _stringUsername] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Register failed, Server is unreachable - user: %@", _stringUsername]
                                                     withLabel:nil
                                                     withValue:nil];
}

-(IBAction)btnTermsConditionPressed:(id)sender
{
    /*TermsCondController *tcVC = [[TermsCondController alloc] initWithNibName:@"TermsCondController" bundle:nil];
    [self.navigationController pushViewController:tcVC animated:YES];
    [tcVC release];
     */
    ToUViewController *vc;
    
    if (isiPhone5 || isiPhone4){
        vc= [[ToUViewController alloc] initWithNibName:@"ToUViewController" bundle:nil];
    }else{
        vc= [[ToUViewController alloc] initWithNibName:@"ToUViewController_ipad" bundle:nil];
    }
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    
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
    [_viewProgress release];
    [_tfUsername release];
    [super dealloc];
}
@end
