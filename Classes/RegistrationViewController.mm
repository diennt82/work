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

@interface RegistrationViewController () <UITextFieldDelegate, UIAlertViewDelegate>
    
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
    [self.btnCheckbox setSelected:!self.btnCheckbox.selected];
    [self validateAllFieldsAndEnableSignUp];
}

- (IBAction)btnCreateTouchUpInsideAction:(id)sender
{
    if([self checkInputDataToLogin])
    {
        NSLog(@"RegistrationVC - Start registration");
        
        NSInteger networkFailed = [RegistrationViewController checkNetworkConnectionCallback:self];
        
        if (!networkFailed) {
            [self doSignUp];
        }
    }
}

- (IBAction)btnAlreadyTouchUpInsideAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Methods

- (void)doSignUp
{
    [self.view endEditing:YES];
    [self.view addSubview:_viewProgress];
    //Register user ...
    self.stringUsername   = _tfUsername.text;
    self.stringEmail      = _tfEmail.text;
    self.stringPassword   = _tfPassword.text;
    self.stringCPassword  = _tfConfirmPassword.text;
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(registerSuccessWithResponse:)
                                                                          FailSelector:@selector(registerFailedWithError:)
                                                                             ServerErr:@selector(registerFailedServerUnreachable)] autorelease];
    [jsonComm registerAccountWithUsername:_stringUsername
                                 andEmail:_stringEmail
                              andPassword:_stringPassword
                  andPasswordConfirmation:_stringCPassword];
}

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

- (BOOL )checkInputDataToLogin
{
    NSString * msg = nil ;
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString *title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                        @"Create Account Failed" , nil);
    BOOL checkSucceed = FALSE;
    
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
    else //Good info now..
    {
        checkSucceed = TRUE;
    }
    
    if (!checkSucceed)
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
    
    return checkSucceed;
}

+ (NSInteger )checkNetworkConnectionCallback:(id)d
{
    /*
     * 1. Checking if network is not reachable.
     * 2. Checking 3G Connection.
     * 3. Checking Camera WIFI connection.
     */
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL skip_3g_popup = [userDefaults boolForKey:_Use3G];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    NSInteger tagAlert = 0;
    
    if (networkStatus == NotReachable)
    {
        NSLog(@"%s Device's network is unreachable.", __FUNCTION__);
        tagAlert = TAG_ALERT_VIEW_NETWORK_NOT_REACHABLE;
    }
    else if ((skip_3g_popup == FALSE) && (networkStatus == ReachableViaWWAN))
    {
        NSLog(@"%s Device is connecting to a 3G network.", __FUNCTION__);
        tagAlert = TAG_ALERT_VIEW_3G;
    }
    else if ([RegistrationViewController isConnectingToCameraNetwork])
    {
        NSLog(@"%s Device is connecting to a CAMERA network.", __FUNCTION__);
        tagAlert = TAG_ALERT_VIEW_CAMERA_WIFI;
    }
    else
    {
        tagAlert = 0;
    }
    
    if (tagAlert != 0)
    {
        [RegistrationViewController showAlert:tagAlert delegate:d];
    }
    
    return tagAlert;
}

+ (BOOL) isConnectingToCameraNetwork
{
    NSString * current_ssid = [CameraPassword fetchSSIDInfo] ;
    
    if ([current_ssid hasPrefix:DEFAULT_SSID_HD_PREFIX] ||
        [current_ssid hasPrefix:DEFAULT_SSID_PREFIX]
        )
    {
        return TRUE;
        
    }
    
    return FALSE;
}

+ (void)showAlert:(NSUInteger )tagAlert delegate:(id)d
{
    //self.viewProgress.hidden = YES;
    
    NSString *title = @"Network";
    NSString *msg;
    NSString *yes = NSLocalizedStringWithDefaultValue(@"Yes" ,nil, [NSBundle mainBundle],
                                                      @"Yes", nil);
    NSString *no = NSLocalizedStringWithDefaultValue(@"No" ,nil, [NSBundle mainBundle],
                                                     @"No", nil);
    NSString *skip = nil;
    
    if (tagAlert == TAG_ALERT_VIEW_NETWORK_NOT_REACHABLE)
    {
        msg = @"Network is unreachale.";
        NSString *msg1 = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg4" ,nil, [NSBundle mainBundle],
                                                @"Please go to wifi settings and select a Wifi network to connect", nil);
        msg = [msg stringByAppendingString:msg1];
        yes = NSLocalizedStringWithDefaultValue(@"ok" ,nil, [NSBundle mainBundle],
                                                @"OK", nil);
        no = nil;
        d = nil;
    }
    else if (tagAlert == TAG_ALERT_VIEW_3G)
    {
        msg = NSLocalizedStringWithDefaultValue(@"wifi_not_available" ,nil, [NSBundle mainBundle],
                                                @"Mobile data is enabled. If you continue to connect, you may incur air time charges. Do you want to proceed?", nil);
        
        skip = NSLocalizedStringWithDefaultValue(@"Yes_n" ,nil, [NSBundle mainBundle],
                                                 @"Yes and don't ask again", nil);
    }
    else if (tagAlert == TAG_ALERT_VIEW_CAMERA_WIFI)
    {
        msg = NSLocalizedStringWithDefaultValue(@"phone_is_connected_to_camera" ,nil, [NSBundle mainBundle],
                                                @"You are connecting to a Camera network which does not have internet access. Please go to wifi settings and switch to another WIFI. Do you want to continue?", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:msg
                          delegate:d
                          cancelButtonTitle:no
                          otherButtonTitles:yes, skip, nil];
    alert.tag = tagAlert;
    [alert show];
    [alert release];
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
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Regsiter failed - user: %@, error: %@", _stringUsername, msg] withProperties:nil];
    
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
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Register failed - user: %@, error: Server is unreachable", _stringUsername] withProperties:nil];
    
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
    [_tfUsername resignFirstResponder];
    [_tfEmail resignFirstResponder];
    [_tfPassword resignFirstResponder];
    [_tfConfirmPassword resignFirstResponder];
    
    ToUViewController *vc;
    
    if (isiPhone5 || isiPhone4){
        vc= [[ToUViewController alloc] initWithNibName:@"ToUViewController" bundle:nil];
    }else{
        vc= [[ToUViewController alloc] initWithNibName:@"ToUViewController_ipad" bundle:nil];
    }
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    
}

#pragma mark Alertview delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	int tag = alertView.tag;
    
    if (tag == TAG_ALERT_VIEW_3G) // 3g check
    {
        switch (buttonIndex)
        {
            case 0:
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:NO forKey:_Use3G];
                [userDefaults synchronize];
            }
                break;
                
            case 1: // Yes - go by 3g
            {
                [self doSignUp];
            }
                break;
                
            case 2://Yes - DONT ask again
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:YES forKey:_Use3G];
                [userDefaults synchronize];
                
                [self doSignUp];
            }
                break;
                
            default:
                break;
        }
    }
    else if (tag == TAG_ALERT_VIEW_CAMERA_WIFI) // camera network check
    {
        switch (buttonIndex)
        {      
            case 1:
            {
                [self doSignUp];
            }
                break;
                
            default:
                break;
        }
    }
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
