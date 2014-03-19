//
//  Step09ViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 1/9/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#define USERNAME_INDEX  0
#define USERPASS_INDEX  1
#define USERCPASS_INDEX 2
#define USEREMAIL_INDEX 3

#define TAG_USERNAME 201
#define TAG_PASS     202
#define TAG_CPASS    203
#define TAG_EMAIL    204

#import "Step09ViewController.h"
//#import "Reachability.h"
#import "Step_10_ViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface Step09ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITableView *tableViewInfo;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellUsername;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellPassword;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellConfirmPassword;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (retain, nonatomic) IBOutlet UIButton *buttonCheckbox;
@property (retain, nonatomic) IBOutlet UIButton *buttonCreate;

@property (retain, nonatomic) NSString *stringUsername;
@property (retain, nonatomic) NSString *stringPassword;
@property (retain, nonatomic) NSString *stringConfPass;
@property (retain, nonatomic) NSString *stringEmail;
@property (nonatomic) BOOL selectedCheckBox;

@end

@implementation Step09ViewController

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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        [[NSBundle mainBundle] loadNibNamed:@"Step09ViewController_iPad"
                                      owner:self
                                    options:nil];
        
    }
    
    self.navigationController.navigationBarHidden = YES;
    
    self.tableViewInfo.delegate = self;
    self.tableViewInfo.dataSource = self;
    
    //NSLog(@"%f, %f, %f",  _tableViewInfo.frame.origin.y,  _tableViewInfo.frame.size.width,  _tableViewInfo.frame.origin.x);
    
    self.buttonCreate.enabled = NO;
    self.navigationController.navigationBarHidden = YES;
    
    [self.buttonCreate setBackgroundImage:[UIImage imageNamed:@"enter"] forState:UIControlStateNormal];
    [self.buttonCreate setBackgroundImage:[UIImage imageNamed:@"enter_pressed"] forState:UIControlEventTouchDown];
    
    [self.buttonCheckbox setTitle:@"" forState:UIControlStateNormal];
    [self.buttonCheckbox setTitle:@"√" forState:UIControlStateSelected];
    [self.buttonCheckbox setTitle:@"√" forState:UIControlStateHighlighted];
    
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
    [self.delegate sendStatus:LOGIN];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Methods

-(void) validateAllFieldsEnableSignUp
{
    UITextField *tfUsername = (UITextField *)[_cellUsername     viewWithTag:TAG_USERNAME];
    UITextField *tfPass     = (UITextField *)[_cellPassword     viewWithTag:TAG_PASS];
    UITextField *tfCPass    = (UITextField *)[_cellConfirmPassword viewWithTag:TAG_CPASS];
    UITextField *tfEmail    = (UITextField *)[_cellEmail        viewWithTag:TAG_EMAIL];
    
    if ((tfUsername.text.length > 0) &&
        (tfPass.text.length     > 0) &&
        (tfCPass.text.length    > 0) &&
        (tfEmail.text.length    > 0) &&
        (_selectedCheckBox      == TRUE)
      )
    {
        //Enable the "Create" button
        
        self.buttonCreate.enabled = YES;
    }
    else
    {
        //disable the "Create"  button
        self.buttonCreate.enabled = NO;
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

- (void)checkingDataInputToLogin
{
    UITextField *tfUsername = (UITextField *)[_cellUsername viewWithTag:TAG_USERNAME];
    UITextField *tfPass     = (UITextField *)[_cellPassword viewWithTag:TAG_PASS];
    UITextField *tfCPass    = (UITextField *)[_cellConfirmPassword viewWithTag:TAG_CPASS];
    UITextField *tfEmail    = (UITextField *)[_cellEmail viewWithTag:TAG_EMAIL];
    
    NSString * regex = @"[a-zA-Z0-9._-]+";
    NSPredicate * validatedUsername = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidateUsername = [validatedUsername evaluateWithObject:tfUsername.text];
    
    NSString * msg = nil ;
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString * title = nil;
    
    //UserName at least 5 chars and at most 20 characters
    if ([tfUsername.text length] < 5 || [tfUsername.text length] > 20)
    {
        //error
        title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                  @"Create Account Failed" , nil);
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg",nil, [NSBundle mainBundle],
                                                @"User name has to be between 5-20 characters" , nil);
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
    else if (!isValidateUsername)
    {
        title = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed",nil, [NSBundle mainBundle],
                                                  @"Create Account Failed" , nil);
        msg = NSLocalizedStringWithDefaultValue(@"Create_Account_Failed_msg5", nil, [NSBundle mainBundle],
                                                @"Username should not contain special characters except for - _ and ."  , nil);
        
        //ERROR condition
        [[[[UIAlertView alloc] initWithTitle:title message:msg
                                    delegate:self
                           cancelButtonTitle:ok
                           otherButtonTitles:nil]
          autorelease]
         show];
    }
    else if (([tfPass.text length] < 8) ||
             ([tfPass.text length] > 12) )
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
    else if ( ![tfPass.text isEqualToString:tfCPass.text])
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
    else if(![self isValidEmail:tfEmail.text])
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
    
    else if (![Step09ViewController isWifiConnectionAvailable] )
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
        self.stringUsername  = tfUsername.text;
        self.stringPassword  = tfPass.text;
        self.stringConfPass  = tfCPass.text;
        self.stringEmail     = tfEmail.text;
        
        
        NSLog(@"Start registration");
        
        BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:@selector(regSuccessWithResponse:)
                                                                              FailSelector:@selector(regFailedWithError:)
                                                                                 ServerErr:@selector(regFailedServerUnreachable)] autorelease];
        [jsonComm registerAccountWithUsername:_stringUsername
                                     andEmail:_stringEmail
                                  andPassword:_stringPassword
                      andPasswordConfirmation:_stringConfPass];
        
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
    [self validateAllFieldsEnableSignUp];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == TAG_USERNAME)
    {
        UITextField *passTF = (UITextField *)[_cellPassword viewWithTag:TAG_PASS];
        [passTF becomeFirstResponder];
    }
    else if(textField.tag == TAG_PASS)
    {
        UITextField *passCTF = (UITextField *)[_cellConfirmPassword viewWithTag:TAG_CPASS];
        [passCTF becomeFirstResponder];
    }
    else if(textField.tag == TAG_CPASS)
    {
        UITextField *emailTF = (UITextField *)[_cellEmail viewWithTag:TAG_EMAIL];
        [emailTF becomeFirstResponder];
    }
    else
    {
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == USERNAME_INDEX)
    {
        return _cellUsername;
    }
    else if (indexPath.row == USERPASS_INDEX)
    {
        return _cellPassword;
    }
    else if (indexPath.row == USERCPASS_INDEX)
    {
        return _cellConfirmPassword;
    }
    else if(indexPath.row == USEREMAIL_INDEX)
    {
        return _cellEmail;
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    return cell;
}

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableViewInfo release];
    [_cellUsername release];
    [_cellPassword release];
    [_cellConfirmPassword release];
    [_cellEmail release];
    [_buttonCheckbox release];
    [_buttonCreate release];
    [super dealloc];
}
@end
