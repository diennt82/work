//
//  Step_06_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "NetworkInfoToCamera_VController.h"
#import "Step_10_ViewController_ble.h"
#import "define.h"
#import "Step_02_ViewController.h"

#define BTN_CONTINUE_TAG    599
#define BTN_TRY_AGAIN_TAG   559
#define BTN_SETUP_WIFI      569
#define BLE_TIMEOUT_PROCESS 4*60.0

@interface NetworkInfoToCamera_VController () <UITextFieldDelegate, SecurityChangingDelegate>

@property (retain, nonatomic) IBOutlet UIView *viewProgress;
@property (retain, nonatomic) IBOutlet UIView *viewError;
@property (retain, nonatomic) IBOutlet UIButton *btnContinueMain;

@property (retain, nonatomic) UITextField *tfSSID;
@property (retain, nonatomic) UITextField *tfPassword;
@property (retain, nonatomic) UITextField *tfConfirmPass;

@property (retain, nonatomic) NSTimer *timerTimeoutConnectBLE;
@property (nonatomic) BOOL shouldTimeoutProcessing;
@property (nonatomic, retain) UIButton *btnContinue;
@property (nonatomic, retain) UIButton *btnTryAgain;
@property (nonatomic, retain) UIButton *btnSetupWithWifi;

@end

@implementation NetworkInfoToCamera_VController

@synthesize securityCell, ssidCell, passwordCell, confPasswordCell;

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
    [_tfSSID release];
    [_tfPassword release];
    [_tfConfirmPass release];
    
    [_ssid release];
    [_security release];
    [_password release];
    [_deviceConf release];
    [_ib_dialogVerifyNetwork release];
    [_viewProgress release];
    [_btnContinueMain release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Enter_Network_Information",nil, [NSBundle mainBundle],
                                                                  @"Enter Network Information" , nil);
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringWithDefaultValue(@"back",nil, [NSBundle mainBundle],
                                                                               @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    self.navigationItem.hidesBackButton = NO;
    
    self.btnContinue = (UIButton *)[_viewError viewWithTag:BTN_CONTINUE_TAG];
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    [self.btnContinue addTarget:self action:@selector(btnContinueTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    self.btnContinue.titleLabel.text = NSLocalizedString(@"continue", @"Continue");
    
    self.btnTryAgain = (UIButton *)[_viewError viewWithTag:BTN_TRY_AGAIN_TAG];
    [self.btnTryAgain setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnTryAgain setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    [self.btnTryAgain addTarget:self action:@selector(btnTryAgainTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnTryAgain setTitle:NSLocalizedString(@"Re-try setup with Bluetooth", @"Re-try setup with Bluetooth") forState:UIControlStateNormal];
    
    self.btnSetupWithWifi = (UIButton *)[_viewError viewWithTag:BTN_SETUP_WIFI];
    [self.btnSetupWithWifi setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnSetupWithWifi setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    [self.btnSetupWithWifi addTarget:self action:@selector(btnSetupWithWifiAction:) forControlEvents:UIControlEventTouchUpInside];
    self.btnSetupWithWifi.titleLabel.text = NSLocalizedString(@"Setup with WIFI", @"Setup with WIFI");
    
    UIImageView *imageView = (UIImageView *)[_viewProgress viewWithTag:595];
    imageView.animationImages =[NSArray arrayWithObjects:
                                [UIImage imageNamed:@"setup_camera_c1"],
                                [UIImage imageNamed:@"setup_camera_c2"],
                                [UIImage imageNamed:@"setup_camera_c3"],
                                [UIImage imageNamed:@"setup_camera_c4"],
                                nil];
    imageView.animationDuration = 1.5;
    imageView.animationRepeatCount = 0;
    [imageView startAnimating];
    
    if (self.ssid == nil)
    {
        NSLog(@"empty SSID ");
    }
    if (self.security == nil)
    {
        NSLog(@"empty security ");
    }
    
    UITextField * tfSsid = (UITextField *) [self.ssidCell viewWithTag:202];
    if (tfSsid != nil && (self.isOtherNetwork == FALSE))
    {
        tfSsid.text = self.ssid;
    }
    
    UITextField * _sec = (UITextField *) [self.securityCell viewWithTag:1];
    if (_sec != nil)
    {
        _sec.text = [self.security uppercaseString];
    }
    
#if 0
    UIBarButtonItem *nextButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"next",nil, [NSBundle mainBundle],
                                                                             @"Next", nil)
     
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleNextButton:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [nextButton release];
#endif
    self.btnContinueMain.enabled = NO;
    
    self.tfSSID = (UITextField *)[self.ssidCell viewWithTag:202];
    
    if (self.tfSSID.text.length > 0 &&
        ([[self.security lowercaseString] isEqualToString:@"none"] ||
         [[self.security lowercaseString] isEqualToString:@"open"]  )
        )
    {
        self.navigationItem.rightBarButtonItem .enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }
    
    self.tfPassword = (UITextField *)[self.passwordCell viewWithTag:200];
    self.tfPassword.delegate = self;
    
    self.tfConfirmPass = (UITextField *)[self.confPasswordCell viewWithTag:201];
    self.tfConfirmPass.delegate = self;
    
    /* initialize transient object here */
	self.deviceConf = [[[DeviceConfiguration alloc] init] autorelease];
	
    if (![self restoreDataIfPossible] )
	{
		//Try to read the ssid from preference:
        self.deviceConf.ssid = self.ssid;
    }
    else
    {
        /*
         * 1. Check deviceConf.ssid vs self.ssid
         * 2. check sec type : OPEN , WeP, wpa
         * 3. If ( =)  -> prefill pass- deviceConf.key  to  password/conf password text field
         */
        
        NSLog(@"%s - deviceConf.ssid: %@, - self.ssid: %@, - self.security: %@", __FUNCTION__, self.deviceConf.ssid, self.ssid, self.security);
        
        if ([self.deviceConf.ssid isEqualToString:self.ssid] &&
            (  ![[self.security lowercaseString] isEqualToString:@"none"] &&
               ![[self.security lowercaseString] isEqualToString:@"open"] )
            )
        {
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.btnContinueMain.enabled = YES;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
            
            self.tfPassword.text = self.deviceConf.key;
            self.tfConfirmPass.text = self.deviceConf.key;
        }
    }
    
    NSString *message = NSLocalizedStringWithDefaultValue(@"take_up_to_a_minute", nil, [NSBundle mainBundle],
                                                          @"This may take up to a minute", nil);
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:FW_VERSION] compare:FW_VERSION_FACTORY_SHOULD_BE_UPGRADED] == NSOrderedSame)
    {
        message = NSLocalizedStringWithDefaultValue(@"note_camera_upgrade_lasted_software", nil, [NSBundle mainBundle],
                                                    @"Note: Your camera may be upgraded to latest software. This may take about 5 minutes. During this time, you will not be able to access the camera.", nil);
    }
    
    UILabel *lblProgress = (UILabel *)[_viewProgress viewWithTag:695];
    lblProgress.text = message;
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
}

- (void)viewDidUnload
{
    [self setIb_dialogVerifyNetwork:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    //remove delegate
    [BLEConnectionManager getInstanceBLE].delegate = nil;
    
    [super viewWillDisappear:animated];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//        
//        self.viewProgress.frame = rect;
//        self.viewError.frame = rect;
//    }
    
    NSLog(@"update security type");
    UITextField * _sec = (UITextField *) [self.securityCell viewWithTag:1];
    if (_sec != nil)
    {
        _sec.text = [self.security uppercaseString];
    }
}

#pragma mark - Actions



- (IBAction)btnTryAgainTouchUpInsideAction:(UIButton *)sender
{
    sender.enabled = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnSetupWithWifiAction:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    if (_timerTimeoutConnectBLE != nil)
    {
        [self.timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    NSLog(@"%s Killing BLE.", __FUNCTION__);
    [BLEConnectionManager getInstanceBLE].delegate = nil;
    [[BLEConnectionManager getInstanceBLE] stopScanBLE];
    [BLEConnectionManager getInstanceBLE].needReconnect = NO;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral didDisconnect];
    
    id aViewController = self.navigationController.viewControllers[0];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    if ([aViewController isKindOfClass:[Step_02_ViewController class]])
    {
        [((Step_02_ViewController *)aViewController) btnContinueTouchUpInsideAction:nil];
    }
    else
    {
        NSLog(@"%s aViewController:%@", __FUNCTION__, aViewController);
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 202)
    { // SSID
        
        NSInteger ssidTextLength = 0;
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        
        if (isBackSpace == -8)
        {
            ssidTextLength = textField.text.length - 1;
        }
        else {
            ssidTextLength = textField.text.length + string.length;
        }
        if (ssidTextLength > 0 && self.tfPassword.text.length>0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.btnContinueMain.enabled = YES;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.btnContinueMain.enabled = NO;
            self.navigationItem.rightBarButtonItem.tintColor = nil;
        }
    }
    else if (textField.tag == 200) { // Password
        
        NSString *passString = @"";
        
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        
        if (isBackSpace == -8)
        {
            passString = [textField.text substringToIndex:textField.text.length - 1];
        }
        else {
            passString = [textField.text stringByAppendingString:string];
        }
        if (self.tfSSID.text.length > 0 && passString.length>0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.btnContinueMain.enabled = YES;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.btnContinueMain.enabled = NO;
            self.navigationItem.rightBarButtonItem.tintColor = nil;
        }
    }
    else if (textField.tag == 201) { // Confirm Password
        
        NSString *confirmPassString = @"";
        
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        
        if (isBackSpace == -8)
        {
            confirmPassString = [textField.text substringToIndex:textField.text.length - 1];
        }
        else {
            confirmPassString = [textField.text stringByAppendingString:string];
        }
        if (self.tfSSID.text.length > 0 && [self.tfPassword.text isEqualToString:confirmPassString]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.btnContinueMain.enabled = YES;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.btnContinueMain.enabled = NO;
            self.navigationItem.rightBarButtonItem.tintColor = nil;
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag !=202 ) // Dont move if it's the SSID name
    {
        [self animateTextField: textField up: YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag !=202 ) // Dont move if it's the SSID name
    {
        [self animateTextField: textField up: NO];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int movementDistance = 80; // tweak as needed
    
    const float movementDuration = 0.3f; // tweak as needed
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    
    if (textField.tag ==201 &&
        (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
         interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        ) //Confirm Password cell
    {
        movementDistance+= 40;
    }
    
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 200) //password
    {
        self.password = textField.text;
        //[self.tfConfirmPass becomeFirstResponder];
        [textField resignFirstResponder];
    }
    else if (textField.tag ==201) //conf password
    {
        [textField resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (void)hideAllKeyboard
{
    UITextField * textField = nil;
    
    textField = (UITextField *) [self.view viewWithTag:200];
    if(textField != nil)
    {
        [textField resignFirstResponder];
    }
    
    textField = (UITextField *) [self.view viewWithTag:201];
    if(textField != nil)
    {
        [textField resignFirstResponder];
    }
    
    textField = (UITextField *) [self.view viewWithTag:202];
    if(textField != nil)
    {
        [textField resignFirstResponder];
    }
}

#pragma  mark -
#pragma mark Table View delegate & datasource

#define SSID_SECTION 0
#define SEC_SECTION 1

#define SSID_INDEX 0

#define SEC_INDEX 0
#define PASSWORD_INDEX 1
#define CONFPASSWORD_INDEX 2

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SEC_SECTION)
    {
        if (indexPath.row == PASSWORD_INDEX)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                return 75;
            }
            else {
                return 65;
            }
        }
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    int tag = tableView.tag;
    
    if (tag == 13)
    {
        if (indexPath.section == SSID_SECTION)
        {
            //only one cell in this section
            if (self.isOtherNetwork == TRUE)
            {
                UITextField *tfSsid  = (UITextField*) [ssidCell viewWithTag:202];
                
                [tfSsid setUserInteractionEnabled:TRUE];
            }
            return ssidCell;
        }
        else if (indexPath.section == SEC_SECTION)
        {
            
            if (indexPath.row == SEC_INDEX) {
                [self.securityCell setAccessoryType:UITableViewCellAccessoryNone];
                if (self.isOtherNetwork) {
                    [self.securityCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
                return securityCell;
            }
            if (indexPath.row == PASSWORD_INDEX)
            {
                if ([[self.passwordCell viewWithTag:501] isKindOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *) [self.passwordCell viewWithTag:501];
                    [button setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateSelected];
                    [button setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateHighlighted];
                    [button addTarget:self action:@selector(handlerShowPasswordButon:) forControlEvents:UIControlEventTouchUpInside];
                }
                return passwordCell;
            }
            if (indexPath.row == CONFPASSWORD_INDEX)
            {
                return confPasswordCell;
            }
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tag = tableView.tag;
    
    if (tag == 13)
    {
        if (section == SSID_SECTION)
            return 1;
        if (section == SEC_SECTION)
        {
            if ([self.security isEqualToString:@"open"] ||
                [self.security isEqualToString:@"none"])
            {
                return 1;
            }
            else
            {
                return 2;
            }
        }
    }
    
    
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int tag = tableView.tag;
    
    if (tag == 13)
    {
        return 2;
    }
    
    return 0;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
//    if ([self.ssid isEqualToString:@"Other Network"])
//    {
//        
//        if (indexPath.section == SEC_SECTION)
//        {
//            if (indexPath.row == SEC_INDEX)
//            {
//                [self changeSecurityType];
//                
//            }
//        }
//    }
    
    if (indexPath.section == SSID_SECTION)
    {
        //only one cell in this section
        if (self.isOtherNetwork == TRUE)
        {
            UITextField *tfSsid  = (UITextField*) [ssidCell viewWithTag:202];
            [tfSsid setUserInteractionEnabled:TRUE];
            [tfSsid becomeFirstResponder];
        }
    }
    else if (indexPath.section == SEC_SECTION)
    {
        if (indexPath.row == PASSWORD_INDEX)
        {
            UITextField * txtField = (UITextField*) [passwordCell viewWithTag:200];
            [txtField becomeFirstResponder];
        }
        
        if (indexPath.row == CONFPASSWORD_INDEX)
        {
            UITextField * txtField = (UITextField*) [confPasswordCell viewWithTag:201];
            [txtField becomeFirstResponder];
        }
        else if (indexPath.row == SEC_INDEX && self.isOtherNetwork == TRUE)
        {
            [self changeSecurityType];
        }
    }
}

#pragma  mark -


-(void) changeSecurityType
{
    //load step 07
    NSLog(@"Load step 7");
    
    NSLog(@"Load step 7");
    
    
    //Load the next xib
    Step_07_ViewController *step07ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        
        step07ViewController = [[Step_07_ViewController alloc]
                                initWithNibName:@"Step_07_ViewController_ipad" bundle:nil];
        
    }
    else
    {
        step07ViewController = [[Step_07_ViewController alloc]
                                initWithNibName:@"Step_07_ViewController" bundle:nil];
        
    }
    
    step07ViewController.securityDelegate = self;
    [self.navigationController pushViewController:step07ViewController animated:NO];
    
    [step07ViewController release];
}



-(IBAction) handleNextButton:(id) sender
{
    //check if password is ok?
    
    UITextField * my_ssid = (UITextField*) [self.ssidCell viewWithTag:202];
    
    NSLog(@"%s other: %d, security: %@", __FUNCTION__, self.isOtherNetwork, self.security);
    
    if (self.isOtherNetwork == TRUE)
    {
        
        if ([my_ssid.text length] == 0)
        {
            //error
            //ERROR condition
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_ssid_cannot_be_empty", nil, [NSBundle mainBundle], @"SSID cannot be empty", nil)
                                   message:NSLocalizedStringWithDefaultValue(@"alert_mes_fill_the_ssid_try_again", nil, [NSBundle mainBundle], @"Please fill the SSID name and try again", nil)
                                   delegate:self
                                   cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil)
                                   otherButtonTitles:nil];
            [_alert show];
            [_alert release];
            
            return;
        }
        else
        {
            self.ssid = my_ssid.text;
        }
    }
    
    if ([self.security isEqualToString:@"open"])
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.btnContinueMain.enabled = NO;
        
        /* Start timer to check for camera connection issue */
        
        self.timerTimeoutConnectBLE  = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                       target:self
                                                     selector:@selector(timeoutBLESetupProcessing:)
                                                     userInfo:nil
                                                      repeats:NO];
        
        /* Blocking call, after this return the camera should be either added or failed setup already */
        self.password = @"";
        [self sendWifiInfoToCamera];
        
    }
    else
    {
        UITextField  * pass = (UITextField*)[self.passwordCell viewWithTag:200];
        //UITextField  * confpass = (UITextField*)[self.confPasswordCell viewWithTag:201];
        
        if ( [pass.text length] == 0 )
        {
            //error
            
           // NSString * msg_fail = NSLocalizedStringWithDefaultValue(@"Confirm_Pass_Fail", nil, [NSBundle mainBundle], @"Le mot de passe ne correspond pas. S'il vous plaît, saisir à nouveau !", nil);
            
            //ERROR condition
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_password_failed", nil, [NSBundle mainBundle], @"Password Failed", nil)
                                   message:NSLocalizedStringWithDefaultValue(@"alert_title_edter_password", nil, [NSBundle mainBundle], @"Enter Password", nil)
                                   delegate:self
                                   cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil)
                                   otherButtonTitles:nil];
            [_alert show];
            [_alert release];
            return;
        }
        else
        {
            //cont
            self.password = [NSString stringWithString:[pass text]];
            //NSLog(@"password is : %@", self.password);
            NSLog(@"NetworkInfo - handleNextButton - Create time out ble setup process");
            
          
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.btnContinueMain.enabled = NO;
            
            /* Start timer to check for camera connection issue */
            self.timerTimeoutConnectBLE  = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                           target:self
                                                         selector:@selector(timeoutBLESetupProcessing:)
                                                         userInfo:nil
                                                          repeats:NO];
            
            /* Blocking call, after this return the camera should be either added or failed setup already */
            [self sendWifiInfoToCamera ];
        }
    }   
}

- (void)timeoutBLESetupProcessing:(NSTimer *)timer
{
    self.view.userInteractionEnabled = YES;
    
    self.shouldTimeoutProcessing = TRUE;
    
    //disconnect to BLE and return to guide screen.
    if ([BLEConnectionManager getInstanceBLE].state == CONNECTED)
    {
        [BLEConnectionManager getInstanceBLE].needReconnect = NO;
        [[BLEConnectionManager getInstanceBLE] stopScanBLE];
        [self disconnectToBLE];
    }
    else
    {
        [self.viewProgress removeFromSuperview];
        
        [self.view addSubview:_viewError];
        [self.view bringSubviewToFront:_viewError];
    }
}

-(void) prepareWifiInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *camera_mac = [userDefaults objectForKey:@"CameraMacSave"];
    NSLog(@"Check camera_mac is %@", camera_mac);
    self.deviceConf.ssid = self.ssid;
    
    //save mac address for used later
    [userDefaults setObject: [Util add_colon_to_mac:camera_mac] forKey:@"CameraMacWithQuote"];
    [userDefaults synchronize];
    
    self.deviceConf.addressMode = @"DHCP";
    
    if ([self.security isEqualToString:@"wep"])
    {
        //@"Open",@"WEP", @"WPA-PSK/WPA2-PSK"
        self.deviceConf.securityMode = @"WEP";
        self.deviceConf.wepType = @"OPEN"; //default
        self.deviceConf.keyIndex = @"1"; //default;
    }
    else if( [self.security isEqualToString:@"wpa"])
    {
        self.deviceConf.securityMode = @"WPA-PSK/WPA2-PSK";
    }
    else if ([self.security isEqualToString:@"shared"])
    {
        self.deviceConf.securityMode = @"SHARED";
    }
    else
    {
        self.deviceConf.securityMode= @"OPEN";
    }
    
    self.deviceConf.key = self.password;
    
    self.deviceConf.usrName = BASIC_AUTH_DEFAULT_USER;
    NSLog(@"02 cam password is : %@", [CameraPassword getPasswordForCam:camera_mac]);
    NSString* camPass = [CameraPassword getPasswordForCam:camera_mac];
    
    if (camPass == nil ) //// default pass
    {
        camPass = @"00000000";
        NSLog(@"02 cam password is default: %@", camPass);
    }
    
    self.deviceConf.passWd = camPass;
}

#pragma mark - BLEConnectionManagerDelegate

- (void) didReceiveBLEList:(NSMutableArray *)bleLists
{
        NSLog(@"NWINFO : rescan completed ");
   CBPeripheral * ble_uart = (CBPeripheral *)[[BLEConnectionManager getInstanceBLE].listBLEs objectAtIndex:0];
    
    [[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:ble_uart];
}


-(void) bleDisconnected
{
    NSLog(@"NWINFO : BLE device is DISCONNECTED - state: %d, - shouldTimeoutProcessing: %d", stage, _shouldTimeoutProcessing);
    
    if (_shouldTimeoutProcessing)
    {
        //NSLog(@"NWINFO - bleDisconnected");
        [self.viewProgress removeFromSuperview];
        
        [self.view addSubview:_viewError];

        [self.view bringSubviewToFront:_viewError];
    }
    else
    {
        [self rescanToConnectToBLE];
    }
}
- (void)disconnectToBLE
{
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE] disconnect];
}

- (void)rescanToConnectToBLE
{
    NSLog(@"NetworkInfo - rescanToConnectToBLE - Reconnect after 2s");
    
    NSDate * date;
    date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    //[[BLEConnectionManager getInstanceBLE] reinit];
    
    [[BLEConnectionManager getInstanceBLE] reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
}



- (void) didConnectToBle:(CBUUID*) service_id
{
    NSLog(@"BLE device connected - now, latest stage: %d", stage);
}

- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera
{
    NSLog(@"NetworkInfo - onReceiveDataError: %d, cmd: %@", error_code, commandToCamera);
}

- (void)didReceiveData:(NSString *)string
{
    NSLog(@"NetworkInfoToCameraVC - didReceiveData: %@", string);
    
    if ([string hasPrefix:@"setup_wireless_save"])
    {
        stage = SENT_WIFI;
    
        NSLog(@"Finishing SETUP_HTTP_COMMAND");
        
    }
    else if ([string hasPrefix:GET_STATE_NETWORK_CAMERA])
    {
        stage = CHECKING_WIFI;
        
        NSLog(@"Recv: %@", string);
        NSString *state = string;
        NSString *_currentStateCamera;
     
        if (state != nil && [state length] > 0)
        {
            _currentStateCamera = [[state componentsSeparatedByString:@": "] objectAtIndex:1];
        }
        else
        {
            _currentStateCamera = @"";
        }
        
        if ([_currentStateCamera isEqualToString:@"CONNECTED"])
        {
            stage = CHECKING_WIFI_PASSED;
        }
        else
        {
             stage = CHECKING_WIFI;
        }
    }
    else if ([string hasPrefix:RESTART_HTTP_CMD])
    {
        NSLog(@"Finishing RESTART_HTTP_CMD");
    }
    else
    {
        NSLog(@"Receive un-expected data, Try to findout what to do next??? ");
    }
}

#pragma mark - Methods

- (void)sendCommandRestartSystem
{
    NSLog(@"Send RESTART Command, now");
    
    NSDate * date;
    while( ([BLEConnectionManager getInstanceBLE].state != CONNECTED) &&
          ( self.shouldTimeoutProcessing == FALSE ) )
    {
        NSLog(@"sendCommandRestartSystem:  BLE disconnected - stage: %d, sleep 2s ", stage);
        
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( self.shouldTimeoutProcessing == TRUE)
    {
        NSLog(@"sendCommandRestartSystem: SETUP PROCESS TIMEOUT -- return");
        return ;
    }
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:RESTART_HTTP_CMD withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];

    
    if ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy  )
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
        if([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy  )
        {
            NSLog(@"BLE still busy, camera may have already rebooted. Moving on..");
        }
    }
}

- (BOOL)sendCommandHTTPSetup
{
    NSLog(@"Send command SETUP HTTP Command, now");
    NSDate * date;
    while( ([BLEConnectionManager getInstanceBLE].state != CONNECTED) &&
          ( self.shouldTimeoutProcessing == FALSE ) )
    {
        NSLog(@"sendCommandHTTPSetup:  BLE disconnected - stage: %d, sleep 2s ", stage);
        
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( self.shouldTimeoutProcessing == TRUE)
    {
        NSLog(@"sendCommandHTTPSetup: SETUP PROCESS TIMEOUT -- return");
        return FALSE;
    }
    
    //send next command
    DeviceConfiguration * sent_conf = [[DeviceConfiguration alloc] init];
    
    [sent_conf restoreConfigurationData:[Util readDeviceConfiguration]];
    NSString * conf = [sent_conf getDeviceEncodedConfString];
    
    NSString * cmmd = [NSString stringWithFormat:@"%@%@", SETUP_HTTP_CMD, conf];
    
    //send cmd to Device
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:cmmd withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    [sent_conf release];
    
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    NSLog(@"After sending Save Wireless wait for 3sec, after that - return TRUE");
    date = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    
    return TRUE;
}

-(void)sendWifiInfoToCamera
{
    [self.view endEditing:YES];
    //should hide back in navigation bar
    self.navigationItem.hidesBackButton = YES;
    // should be show dialog here, make sure user input username and password
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    //and then disable user interaction
    [self.view setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    [self prepareWifiInfo];
    
    //Save and send
    if ( [_deviceConf isDataReadyForStoring])
    {
        [Util writeDeviceConfigurationData:[_deviceConf getWritableConfiguration]];
    }

    stage = INIT;

    [BLEConnectionManager getInstanceBLE].delegate = self;
    
    if ([self sendCommandHTTPSetup])
    {
        while (stage != SENT_WIFI && !_shouldTimeoutProcessing);
        
        int count = 20;
        NSDate * exp_reading_status = [[NSDate date] dateByAddingTimeInterval:3*60];
        
        do
        {
            [self readWifiStatusOfCamera:nil];
            
            if ([exp_reading_status compare:[NSDate date]] == NSOrderedAscending )
            {
                NSLog(@"wifi pass check failed -- 3 min passed");
                break;
            }
            
        }
        while (stage !=  CHECKING_WIFI_PASSED && count -- >0 && !_shouldTimeoutProcessing);
        
        if (stage == CHECKING_WIFI)
        {
            //Failed!!
            if (_timerTimeoutConnectBLE != nil)
            {
                [self.timerTimeoutConnectBLE invalidate];
                self.timerTimeoutConnectBLE = nil;
            }
            
            [self timeoutBLESetupProcessing:nil];
            NSLog(@"wifi pass check failed!!! call timeout");
        }
        else if (stage == CHECKING_WIFI_PASSED)
        {
            //CONNECTED... Move on now..
            [self sendCommandRestartSystem];
            
            [self showNextScreen];
            [self.view setUserInteractionEnabled:YES];
            [self.navigationController.navigationBar setUserInteractionEnabled:YES];
        }
    }
}

-(void) readWifiStatusOfCamera:(NSTimer *) exp
{
    NSLog(@"now,readWifiStatusOfCamera blocking ");
    
    NSDate * date;
    while( ([BLEConnectionManager getInstanceBLE].state != CONNECTED) &&
          ( self.shouldTimeoutProcessing == FALSE ) )
    {
        NSLog(@"readWifiStatusOfCamera:  BLE disconnected - stage: %d, sleep 2s ", stage);
        
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    if ( self.shouldTimeoutProcessing == TRUE)
    {
        NSLog(@"readWifiStatusOfCamera: SETUP PROCESS TIMEOUT -- return");
        return ;
    }
    
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_STATE_NETWORK_CAMERA withTimeOut:LONG_TIME_OUT_SEND_COMMAND];
    
    NSLog(@"Finished sending: %@",GET_STATE_NETWORK_CAMERA);

    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
    }
    
    date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
    
    [[NSRunLoop currentRunLoop] runUntilDate:date];
}

- (void) showNextScreen
{
    NSLog(@"NetworkInfo - SSID: %@   - %@", self.ssid, self.deviceConf.ssid );
    
    if (_timerTimeoutConnectBLE != nil)
    {
        [self.timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    NSLog(@"%s Killing BLE.", __FUNCTION__);
    [BLEConnectionManager getInstanceBLE].delegate = nil;
    [[BLEConnectionManager getInstanceBLE] stopScanBLE];
    [BLEConnectionManager getInstanceBLE].needReconnect = NO;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral didDisconnect];
    
    DeviceConfiguration * sent_conf = [[DeviceConfiguration alloc] init];
    
    [sent_conf restoreConfigurationData:[Util readDeviceConfiguration]];
    
    //load step 10
    
    NSLog(@"Load Step 10");
    //[self.ib_dialogVerifyNetwork setHidden:YES];
    [_viewProgress removeFromSuperview];
    if (sent_conf.ssid != nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:sent_conf.ssid  forKey:HOME_SSID];
        [userDefaults synchronize];
    }
    
    //Load the next xib
    
    Step_10_ViewController_ble *step10ViewController = [[Step_10_ViewController_ble alloc]
                                initWithNibName:@"Step_10_ViewController_ble" bundle:nil];
    
    [self.navigationController pushViewController:step10ViewController animated:NO];
    [step10ViewController release];
    
    [sent_conf release];
}

- (BOOL) restoreDataIfPossible
{
	NSDictionary * saved_data = [Util readDeviceConfiguration];
	
	if ( saved_data != nil)
	{
		[self.deviceConf restoreConfigurationData:saved_data];
		//populate the fields with stored data
		return TRUE;
	}
    
	return FALSE;
}

- (void)handlerShowPasswordButon:(id)sender {
    UIButton *button = sender;
    [button setSelected:!button.selected];
    [self.tfPassword setSecureTextEntry:!self.tfPassword.secureTextEntry];
}

#pragma mark - SecurityChangingDelegate
- (void)changeSecurityType:(NSString *)security {
    self.security = security;
}
@end
