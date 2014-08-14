//
//  Step09ViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 1/9/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>

#import "Step09ViewController.h"
#import "Step_10_ViewController.h"

@interface Step09ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableViewInfo;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellUsername;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellPassword;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellConfirmPassword;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellEmail;
@property (nonatomic, weak) IBOutlet UIButton *buttonCheckbox;
@property (nonatomic, weak) IBOutlet UIButton *buttonCreate;

@property (nonatomic, copy) NSString *stringUsername;
@property (nonatomic, copy) NSString *stringPassword;
@property (nonatomic, copy) NSString *stringConfPass;
@property (nonatomic, copy) NSString *stringEmail;
@property (nonatomic) BOOL selectedCheckBox;

@end

@implementation Step09ViewController

#define USERNAME_INDEX  0
#define USERPASS_INDEX  1
#define USERCPASS_INDEX 2
#define USEREMAIL_INDEX 3

#define TAG_USERNAME 201
#define TAG_PASS     202
#define TAG_CPASS    203
#define TAG_EMAIL    204

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    _tableViewInfo.delegate = self;
    _tableViewInfo.dataSource = self;
    
    _buttonCreate.enabled = NO;
    [_buttonCreate setBackgroundImage:[UIImage imageNamed:@"enter"] forState:UIControlStateNormal];
    [_buttonCreate setBackgroundImage:[UIImage imageNamed:@"enter_pressed"] forState:UIControlEventTouchDown];
    
    [_buttonCheckbox setTitle:@"" forState:UIControlStateNormal];
    [_buttonCheckbox setTitle:@"√" forState:UIControlStateSelected];
    [_buttonCheckbox setTitle:@"√" forState:UIControlStateHighlighted];
    
    ((UITextField *)[_cellUsername viewWithTag:TAG_USERNAME]).delegate = self;
    ((UITextField *)[_cellPassword viewWithTag:TAG_PASS]).delegate = self;
    ((UITextField *)[_cellConfirmPassword viewWithTag:TAG_CPASS]).delegate = self;
    ((UITextField *)[_cellEmail viewWithTag:TAG_EMAIL]).delegate = self;
}

#pragma mark - Action

- (IBAction)buttonCheckboxTouchAction:(id)sender
{
    self.selectedCheckBox = !_selectedCheckBox;
    [sender setSelected:_selectedCheckBox];
    [self validateAllFieldsEnableSignUp];
}

- (IBAction)buttonCreateTouchAction:(id)sender
{
    [self checkingDataInputToLogin];
}

- (IBAction)buttonAlreadyAction:(id)sender
{
    [_delegate sendStatus:LOGIN];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

-(void) validateAllFieldsEnableSignUp
{
    UITextField *tfUsername = (UITextField *)[_cellUsername viewWithTag:TAG_USERNAME];
    UITextField *tfPass = (UITextField *)[_cellPassword viewWithTag:TAG_PASS];
    UITextField *tfCPass = (UITextField *)[_cellConfirmPassword viewWithTag:TAG_CPASS];
    UITextField *tfEmail = (UITextField *)[_cellEmail viewWithTag:TAG_EMAIL];
    
    if ( tfUsername.text.length > 0 && tfPass.text.length > 0 &&
        tfCPass.text.length > 0 && tfEmail.text.length > 0 && _selectedCheckBox
      ) {
        _buttonCreate.enabled = YES;
    }
    else {
        _buttonCreate.enabled = NO;
    }
}

- (void)animateTextField:(UITextField *)textField withUp:(BOOL)up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)checkingDataInputToLogin
{
    UITextField *tfUsername = (UITextField *)[_cellUsername viewWithTag:TAG_USERNAME];
    UITextField *tfPass = (UITextField *)[_cellPassword viewWithTag:TAG_PASS];
    UITextField *tfCPass = (UITextField *)[_cellConfirmPassword viewWithTag:TAG_CPASS];
    UITextField *tfEmail = (UITextField *)[_cellEmail viewWithTag:TAG_EMAIL];
    
    NSString *regex = @"[a-zA-Z0-9._-]+";
    NSPredicate *validatedUsername = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidateUsername = [validatedUsername evaluateWithObject:tfUsername.text];
    
    NSString *title = LocStr(@"Create Account Failed");
    NSString *msg = nil;
    NSString *ok = LocStr(@"Ok");
    
    // UserName at least 5 chars and at most 20 characters
    if ( tfUsername.text.length < 5 || tfUsername.text.length > 20 ) {
        msg = LocStr(@"User name has to be between 5-20 characters");
    }
    else if ( !isValidateUsername ) {
        msg = LocStr(@"Username should not contain special characters except for - _ and .");
    }
    else if ( tfPass.text.length < 8 || tfPass.text.length > 12 ) {
        msg = LocStr(@"Create_Account_Failed_msg1");
    }
    else if ( ![tfPass.text isEqualToString:tfCPass.text] ) {
        msg = LocStr(@"Create_Account_Failed_msg2");
    }
    else if( ![self isValidEmail:tfEmail.text] ) {
        msg = LocStr(@"Create_Account_Failed_msg3");
    }
    else if ( ![Step09ViewController isWifiConnectionAvailable] ) {
        msg = LocStr(@"Create_Account_Failed_msg4");
    }
    else {
        // Good info now... Register user.
        self.stringUsername = tfUsername.text;
        self.stringPassword = tfPass.text;
        self.stringConfPass = tfCPass.text;
        self.stringEmail = tfEmail.text;
        
        DLog(@"Start registration");
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:@selector(regSuccessWithResponse:)
                                                                              FailSelector:@selector(regFailedWithError:)
                                                                                 ServerErr:@selector(regFailedServerUnreachable)];
        [jsonComm registerAccountWithUsername:_stringUsername
                                     andEmail:_stringEmail
                                  andPassword:_stringPassword
                      andPasswordConfirmation:_stringConfPass];
        
    }
    
    if ( title && msg ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:ok, nil];
        [alert show];
    }
}

-(BOOL) isValidEmail:(NSString *)email
{
    if ([email rangeOfString:@"@"].location == NSNotFound) {
        return NO;
    }
    
    NSArray *array = [email componentsSeparatedByString:@"@"];
    NSString *domain = array[1];
    DLog(@"Domain is : %@", domain);
    
    NSError *error = NULL;
    NSRegularExpression *regexExpr = [NSRegularExpression regularExpressionWithPattern:@"\\([^\\)]*\\)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regexExpr stringByReplacingMatchesInString:domain options:0 range:NSMakeRange(0, [domain length]) withTemplate:@""];
    DLog(@"modifiedString ------> %@", modifiedString);
    
    NSString *regex = @"[_a-zA-Z0-9-]+(\\.[_a-zA-Z0-9-]+)+";
    NSPredicate *validatedDomain = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [validatedDomain evaluateWithObject:modifiedString];
}

+ (BOOL)isWifiConnectionAvailable
{
    Reachability *wifiReach = [Reachability reachabilityForLocalWiFi];
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
    [self validateAllFieldsEnableSignUp];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == TAG_USERNAME) {
        UITextField *passTF = (UITextField *)[_cellPassword viewWithTag:TAG_PASS];
        [passTF becomeFirstResponder];
    }
    else if(textField.tag == TAG_PASS) {
        UITextField *passCTF = (UITextField *)[_cellConfirmPassword viewWithTag:TAG_CPASS];
        [passCTF becomeFirstResponder];
    }
    else if(textField.tag == TAG_CPASS) {
        UITextField *emailTF = (UITextField *)[_cellEmail viewWithTag:TAG_EMAIL];
        [emailTF becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Rotate

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - JSON call back

- (void)regSuccessWithResponse:(NSDictionary *)responseData
{
    //Store user/pass for later use
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	[userDefaults setObject:_stringEmail forKey:@"PortalUseremail"];
	[userDefaults setObject:_stringUsername forKey:@"PortalUsername"];
	[userDefaults setObject:_stringPassword forKey:@"PortalPassword"];
    [userDefaults setObject:[responseData[@"data"] objectForKey:@"authentication_token"] forKey:@"PortalApiKey"];
    [userDefaults synchronize];
    
    //Load step 10
    DLog(@"Load Step 10");
    
    //Load the next xib
    Step_10_ViewController *step10ViewController = [[Step_10_ViewController alloc] initWithNibName:@"Step_10_ViewController" bundle:nil];
    step10ViewController.delegate = self.delegate;
    [self.navigationController pushViewController:step10ViewController animated:NO];
}

- (void)regFailedWithError:(NSDictionary *)errorResponse
{
    NSString *ok = LocStr(@"Ok");
    NSString *title = LocStr(@"Create Account Failed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:errorResponse[@"message"]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:ok, nil];
    [alert show];
}

- (void)regFailedServerUnreachable
{
	DLog(@"register failed : server unreachable");
	
    NSString *title = LocStr(@"Registration Error");
    NSString *msg = LocStr(@"Registration_Error_1");
    NSString *ok = LocStr(@"Ok");
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:ok, nil];
	[alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == USERNAME_INDEX) {
        return _cellUsername;
    }
    else if (indexPath.row == USERPASS_INDEX) {
        return _cellPassword;
    }
    else if (indexPath.row == USERCPASS_INDEX) {
        return _cellConfirmPassword;
    }
    else if(indexPath.row == USEREMAIL_INDEX) {
        return _cellEmail;
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

@end
