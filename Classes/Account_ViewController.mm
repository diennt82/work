//
//  Account_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Account_ViewController.h"
#import "CameraSettingsCell.h"
#import "MenuViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "PublicDefine.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "NSData+AESCrypt.h"
#import "CustomIOS7AlertView.h"
#import "MBProgressHUD.h"
#import "define.h"
#import "UIView+Custom.h"

@interface Account_ViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, CustomIOS7AlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell * userEmailCell;
@property (retain, nonatomic) IBOutlet UITableViewCell * versionCell;
@property (retain, nonatomic) IBOutlet UITableView * accountInfo;
@property (retain, nonatomic) IBOutlet UITableViewCell *tableViewCellChangePassword;
@property (nonatomic, assign) IBOutlet UIButton *logoutButton;

@property (nonatomic,strong) NSString *strNewChangedPass;
@property (nonatomic, retain) CustomIOS7AlertView *customAlertView;

@end

@implementation Account_ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString * msgAccount = NSLocalizedStringWithDefaultValue(@"account",nil, [NSBundle mainBundle],
                                                                  @"Account", nil);
        self.title = msgAccount;
    }
    return self;
}

-(void) dealloc
{
    [_tableViewCellChangePassword release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self xibDefaultLocalization];
    // Do any additional setup after loading the view from its nib.
    UILabel *lblVersion = (UILabel *)[self.view viewWithTag:559];
    
    lblVersion.text = [NSString stringWithFormat:@"Hubble Home v%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    debugEnabledCount = 8;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"AccountVC -viewWillAppear --");
#if 0
    self.navigationController.navigationBarHidden = YES;
#endif
    [self loadUserData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"%s", __FUNCTION__);
    
    [self customIOS7dialogButtonTouchUpInside:_customAlertView clickedButtonAtIndex:0];
}

-(void)removeSubViewOfNavigationController {
    for (UIView *subView in self.navigationController.view.subviews)
    {
        if ([subView isKindOfClass:[UIToolbar class]])
        {
            [subView removeFromSuperview];
        }
    }
}

- (void)xibDefaultLocalization
{
    [self.logoutButton setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_accountpage_button_text_logout", nil, [NSBundle mainBundle], @"Logout", nil)];
}

-(void)loadUserData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//can be user email or user name here --
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    
    UITextField * _user  =  (UITextField *) [_userEmailCell viewWithTag:1];
    _user.text = user_email;
}

- (IBAction)btnLogoutTouchUpInsideAction:(id)sender
{
    NSLog(@"LOG OUT>>>>");
    
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    hub.labelText = NSLocalizedStringWithDefaultValue(@"hud_logout", nil, [NSBundle mainBundle], @"Log out...", nil);
    
    MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
    
    _accountInfo.hidden = YES;
    ((UIButton *)sender).enabled = NO;
    [CameraAlert clearAllAlerts];
    
#if 1
    //[tabBarController.navigationController popToRootViewControllerAnimated:NO];
    [tabBarController.menuDelegate sendStatus:LOGIN_FAILED_OR_LOGOUT];
    tabBarController.menuDelegate = nil;
#else
    [tabBarController dismissViewControllerAnimated:NO completion:^
     {
         [tabBarController.menuDelegate sendStatus:LOGIN_FAILED_OR_LOGOUT];
     }];
#endif
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)sendsAppLog
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *logAppPath = [cachesDirectory stringByAppendingPathComponent:@"application.log"];
        NSString *logPath0 = [cachesDirectory stringByAppendingPathComponent:@"application0.log"];
        

        NSData *dataLog = [NSData dataWithContentsOfFile:logAppPath];
        NSData *dataLog0 = nil;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:logPath0])
        {
            dataLog0 = [NSData dataWithContentsOfFile:logPath0];
        }
        
        NSInteger length = dataLog.length;
        
        if (dataLog0)
        {
            length += dataLog0.length;
        }


        NSMutableData *dataZip = [[[NSMutableData alloc]initWithCapacity:0] autorelease];
        
        if (dataLog0)
        {
            [dataZip appendData:dataLog0];
        }
        
        [dataZip appendData:dataLog];
       
       
        NSData * dataZip1 = [NSData gzipData:dataZip];
        
        [picker addAttachmentData:[dataZip1 AES128EncryptWithKey:CES128_ENCRYPTION_PASSWORD] mimeType:@"text/plain" fileName:@"application.log"];
        
        //[picker addAttachmentData:dataZip  mimeType:@"text/plain" fileName:@"application.log"];
        
        // Set the subject of email
        [picker setSubject:@"iOS app log"];
        NSArray *toRecipents = [NSArray arrayWithObject:@"ios.crashreport@cvisionhk.com"];
        [picker setToRecipients:toRecipents];
        
        MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
        tabBarController.navigationController.navigationBarHidden = YES;
        
        // Show email view
        [self presentViewController:picker animated:YES completion:NULL];
        
        // Release picker
        [picker release];
    }
    else
    {
        NSLog(@"%s Can not send Email from this device", __FUNCTION__);
    }
}

#pragma mark - Table view delegate & data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if( [userDefaults boolForKey:@"DebugOpt"] == YES)
    {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if(section == 1)
    {
        return 2;
    }
    else if(section == 2)
    {
       
        return 1;
    }
    else
    {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedStringWithDefaultValue(@"profile", nil, [NSBundle mainBundle], @"Profile", nil);
    }
    else if(section == 1)
    {
        return NSLocalizedStringWithDefaultValue(@"plan", nil, [NSBundle mainBundle], @"Plan", nil);
    }
    else
    {
        return NSLocalizedStringWithDefaultValue(@"report", nil, [NSBundle mainBundle], @"Report", nil);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 1)) ||
         (indexPath.section ==1  && indexPath.row == 1) ||
        indexPath.section == 2)
    {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (id obj in cell.contentView.subviews)
    {
        if ([obj isKindOfClass:[UIView class]] &&
            ((UIView *)obj).tag == 905)
        {
            [obj removeFromSuperview];
            break;
        }
    }
    
    UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 0.5f, SCREEN_WIDTH, 0.5f)] autorelease];
    if (indexPath.row == 2 || indexPath.section == 2)
    {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:17];
        cell.textLabel.textColor = [UIColor colorWithRed:(128/255.f) green:(128/255.f) blue:(128/255.f) alpha:1];
    }
    
    lineView.backgroundColor = [UIColor colorWithRed:195/255.f green:195/255.f blue:195/255.f alpha:1];
    lineView.tag = 905;
    [cell.contentView addSubview:lineView];
    cell.backgroundColor = [UIColor colorWithRed:249/255.f green:249/255.f blue:249/255.f alpha:1];
}

#define USEREMAIL_INDEX     0
#define CHANGE_PASS_INDEX   1
#define APPVERSION_INDEX    2


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == USEREMAIL_INDEX)
        {
            UILabel *lableText = (UILabel *)[self.userEmailCell viewWithTag:201];
            lableText.text = NSLocalizedStringWithDefaultValue(@"cell_email", nil, [NSBundle mainBundle], @"Email", nil);
            return _userEmailCell;
        }
        
        if (indexPath.row == CHANGE_PASS_INDEX)
        {
            UILabel *lableText = (UILabel *)[self.tableViewCellChangePassword viewWithTag:301];
            lableText.text = NSLocalizedStringWithDefaultValue(@"cell_password_changed", nil, [NSBundle mainBundle], @"Change Password", nil);
            return _tableViewCellChangePassword;
        }
        else
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            // Configure the cell...
            
            cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"cell_logout", nil, [NSBundle mainBundle], @"Logout", nil);
            
            return cell;
        }
    }
    else if(indexPath.section == 1)
    {
        static NSString *CellIdentifier = @"CameraSettingsCell";
        CameraSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CameraSettingsCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (CameraSettingsCell *)curObj;
                break;
            }
        }
        
        if (indexPath.row == 0)
        {
            cell.nameLabel.text = NSLocalizedStringWithDefaultValue(@"cell_current_plan", nil, [NSBundle mainBundle], @"Current Plan", nil);
            cell.valueLabel.text = NSLocalizedStringWithDefaultValue(@"cell_free", nil, [NSBundle mainBundle], @"Free", nil);
            cell.valueLabel.hidden = NO;
            
            return cell;
        }
        else
        {
            //cell.nameLabel.text = @"Upgrade Plan";
            //cell.valueLabel.text = nil;
            //cell.valueLabel.hidden = YES;
            
            cell.nameLabel.text = NSLocalizedStringWithDefaultValue(@"cell_app_version", nil, [NSBundle mainBundle], @"App Version", nil);
            NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
            cell.valueLabel.text = [infoDict objectForKey:@"CFBundleShortVersionString"];
            cell.valueLabel.hidden = NO;
            return cell;
        }
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        
        cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"cell_send_app_log", nil, [NSBundle mainBundle], @"Send app log", nil);
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == CHANGE_PASS_INDEX)
        {
            // change password
            [self showDialogChangePassword];
            
        }
        else if (indexPath.row == 2)
        {
            //log out
            [self btnLogoutTouchUpInsideAction:nil];
        }
    }
    else if(indexPath.section == 1 && indexPath.row == 1 ) //App Version
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL debugEnabled = [userDefaults  boolForKey:@"DebugOpt"];
        if (debugEnabled == YES)
        {
           
        }
        else
        {
            //Increase debug enabled counter
            debugEnabledCount --;
            if (debugEnabledCount < 0)
            {
                debugEnabledCount =0 ;
            }
            
            if (debugEnabledCount == 0 )
            {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [hud setLabelText:@"Developer mode enabled"];
                

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(),
                               ^{
                                   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                               });
                
                [userDefaults setBool:YES forKey:@"DebugOpt"];
                [userDefaults synchronize];
                
                [tableView reloadData];
                //TODO: turn on SEND LOG options
                
            }
        }
    }
    else if(indexPath.section == 2)
    {
        [self sendsAppLog];
    }
}

- (void)showDialogChangePassword
{
    self.customAlertView = [[CustomIOS7AlertView alloc] init];
    [self.customAlertView setBackgroundColor:[UIColor whiteColor]];
    
    UIView *alertContenerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    UITextField *tfOldPass = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, 280, 30)];
    UITextField *tfNewPass = [[UITextField alloc] initWithFrame:CGRectMake(10, 75, 280, 30)];
    UITextField *tfConfPass = [[UITextField alloc] initWithFrame:CGRectMake(10, 110, 280, 30)];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 280, 25)];
    [lblTitle setText:NSLocalizedStringWithDefaultValue(@"change_password", nil, [NSBundle mainBundle], @"Change Password", nil)];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    
    tfOldPass.placeholder = NSLocalizedStringWithDefaultValue(@"old_password", nil, [NSBundle mainBundle], @"Old Password", nil);
    tfNewPass.placeholder = NSLocalizedStringWithDefaultValue(@"new_password", nil, [NSBundle mainBundle], @"New Password", nil);
    tfConfPass.placeholder = NSLocalizedStringWithDefaultValue(@"confirm_password", nil, [NSBundle mainBundle], @"Confirm Password", nil);
    
    [tfOldPass setSecureTextEntry:YES];
    [tfNewPass setSecureTextEntry:YES];
    [tfConfPass setSecureTextEntry:YES];
    
    [tfOldPass setBackgroundColor:[UIColor whiteColor]];
    [tfNewPass setBackgroundColor:[UIColor whiteColor]];
    [tfConfPass setBackgroundColor:[UIColor whiteColor]];
    
    [alertContenerView addSubview:lblTitle];
    [alertContenerView addSubview:tfOldPass];
    [alertContenerView addSubview:tfNewPass];
    [alertContenerView addSubview:tfConfPass];
    
    [self.customAlertView setContainerView:alertContenerView];
    
    [self.customAlertView setButtonTitles:[NSMutableArray arrayWithObjects:
                            NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil),
                            NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil]];
    [self.customAlertView setDelegate:self];
    
    [self.customAlertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex)
    {
        [alertView close];
        
        if(buttonIndex==1)
        {
            NSString *password = tfNewPass.text;
            NSString *passwordConfrm = tfConfPass.text;
            NSString *oldPass = tfOldPass.text;
            
            //FIXME: lenght >= 8 chars, provide correct popup message
            
            if ((password && password.length > 0)  &&
                (passwordConfrm && passwordConfrm.length > 0) &&
                (oldPass && oldPass.length > 0) &&
                [password isEqualToString:passwordConfrm])
                
            {
                self.strNewChangedPass = password;
                //[self doChangePassword:password];
                [self checkOldPass:oldPass NewPass:password];
            }
            else
            {
                if(tfOldPass.text.length == 0)
                {
                    NSDictionary *dictError = [NSDictionary dictionaryWithObjectsAndKeys:
                                               NSLocalizedStringWithDefaultValue(@"alert_mes_please_enter_correct_old_password", nil, [NSBundle mainBundle], @"Please enter correct old password", nil), @"message", nil];
                    [self changePasswordFialedWithError:dictError];
                }
                else
                {
                    NSDictionary *dictError = [NSDictionary dictionaryWithObjectsAndKeys:
                                               NSLocalizedStringWithDefaultValue(@"alert_mes_password_is_not_match_or_empty", nil, [NSBundle mainBundle], @"Validation failed: Password is not match or empty", nil), @"message", nil];
                    [self changePasswordFialedWithError:dictError];
                }
            }
        }
        [tfOldPass release];
        [tfNewPass release];
        [tfConfPass release];
        [alertView release];
    }];
    [self.customAlertView show];
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%s buttonIndex:%d", __FUNCTION__, buttonIndex);
    
    [alertView setDelegate:nil];
    [alertView close];
}

-(void)checkOldPass:(NSString *)strOldPass NewPass:(NSString *)strNewPass
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:NSLocalizedStringWithDefaultValue(@"hud_please_wait", nil, [NSBundle mainBundle], @"Please wait ...", nil)];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(loginSuccessWithResponse:)
                                                                          FailSelector:@selector(loginFailedWithError:)
                                                                             ServerErr:@selector(loginFailedServerUnreachable)] autorelease];
    
    
    NSString *strUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortalUsername"];
#if 1
    [jsonComm loginPostWithLogin:strUserId
                        password:strOldPass];
#else
    [jsonComm loginWithLogin:strUserId andPassword:strOldPass];
#endif
}

#pragma mark Login Callbacks
- (void) loginSuccessWithResponse:(NSDictionary *)responseDict
{
   	if (responseDict) {
        NSInteger statusCode = [[responseDict objectForKey:@"status"] intValue];
        
        if (statusCode == 200) // success
        {
            NSString *apiKey = [[responseDict objectForKey:@"data"] objectForKey:@"authentication_token"];
            [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:@"PortalApiKey"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self doChangePassword:self.strNewChangedPass];
            
        }
        else
        {
            NSLog(@"Invalid response: %@", responseDict);
            
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_change_password_failed", nil, [NSBundle mainBundle], @"Change Password Failed", nil)
                                         message:NSLocalizedStringWithDefaultValue(@"alert_mes_enter_correct_old_password", nil, [NSBundle mainBundle], @"Enter correct old password.", nil)
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
         
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        }
    }
    else
    {
        NSLog(@"Error - loginSuccessWithResponse: reponseDict = nil");
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    }
}

- (void) loginFailedWithError:(NSDictionary *) responseError
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_change_password_failed", nil, [NSBundle mainBundle], @"Change Password Failed", nil)
                                 message:NSLocalizedStringWithDefaultValue(@"alert_mes_enter_correct_old_password", nil, [NSBundle mainBundle], @"Enter correct old password.", nil)
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
}

- (void)loginFailedServerUnreachable
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_server_is_unreachable", nil, [NSBundle mainBundle], @"Failed: Server is unreachable", nil)
                                 message:nil
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
    
}


- (void)doChangePassword:(NSString *)newPassword
{
    MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
    [tabBarController.menuDelegate startPasswordChanged];
    
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(changePasswordSuccessWithResponse:)
                                                                          FailSelector:@selector(changePasswordFialedWithError:)
                                                                             ServerErr:@selector(changePasswordFailedServerUnreachable)] autorelease];
    [jsonComm changePasswordWithNewPassword:newPassword andPasswordConfirm:newPassword andApiKey:apiKey];
}

#pragma mark - JSON call back

- (void)changePasswordSuccessWithResponse:(NSDictionary *)responseData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.strNewChangedPass forKey:@"PortalPassword"];
    [userDefaults synchronize];
    
    //Response data does not give the new apikey, need to try login again to get it
    [self getNewApiKey];
}

- (void)changePasswordFialedWithError:(NSDictionary *)error_response
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_change_password_failed", nil, [NSBundle mainBundle], @"Change Password Failed", nil)
                                 message:[error_response objectForKey:@"message"]
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
}

- (void)changePasswordFailedServerUnreachable
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_server_is_unreachable", nil, [NSBundle mainBundle], @"Failed: Server is unreachable", nil)
                                 message:nil
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
}
#pragma mark - Verify new password

-(void) getNewApiKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * strNewpass =[userDefaults objectForKey:@"PortalPassword"];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(reloginSuccessWithResponse:)
                                                                          FailSelector:@selector(reloginFailedWithError:)
                                                                             ServerErr:@selector(reloginFailedServerUnreachable)] autorelease];
    
    
    NSString *strUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortalUsername"];
#if 1
    [jsonComm loginPostWithLogin:strUserId
                        password:strNewpass];
#else
    [jsonComm loginWithLogin:strUserId andPassword:strNewpass];
#endif
}
- (void) reloginSuccessWithResponse:(NSDictionary *)responseDict
{
   	if (responseDict) {
        //NSLog(@"%s Relogin after changed password %@", __FUNCTION__, [responseDict description]);
        NSInteger statusCode = [[responseDict objectForKey:@"status"] intValue];
        
        if (statusCode == 200) // success
        {
            NSString *apiKey = [[responseDict objectForKey:@"data"] objectForKey:@"authentication_token"];
            [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:@"PortalApiKey"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_change_password", nil, [NSBundle mainBundle], @"Change Password", nil)
                                         message:NSLocalizedStringWithDefaultValue(@"alert_mes_successful", nil, [NSBundle mainBundle], @"Successful", nil)
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
        }
        else
        {
            NSLog(@"%s Invalid response: %@", __FUNCTION__, responseDict);
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_change_password_failed", nil, [NSBundle mainBundle], @"Change Password Failed", nil)
                                         message:NSLocalizedStringWithDefaultValue(@"alert_mes_enter_correct_old_password", nil, [NSBundle mainBundle], @"Enter correct old password.", nil)
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
        }
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        NSLog(@"Error - loginSuccessWithResponse: reponseDict = nil");
    }
    
    MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
    [tabBarController.menuDelegate finishPasswordChanged];
}

- (void) reloginFailedWithError:(NSDictionary *) responseError
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_change_password_failed", nil, [NSBundle mainBundle], @"Change Password Failed", nil)
                                 message:NSLocalizedStringWithDefaultValue(@"alert_mes_enter_correct_old_password", nil, [NSBundle mainBundle], @"Enter correct old password.", nil)
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
    MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
    [tabBarController.menuDelegate finishPasswordChanged];
}

- (void)reloginFailedServerUnreachable
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_server_is_unreachable", nil, [NSBundle mainBundle], @"Failed: Server is unreachable", nil)
                                 message:nil
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
    MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
    [tabBarController.menuDelegate finishPasswordChanged];
}






#pragma mark - UIAlert view delegate

- (void )alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

#pragma mark - FMail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
    tabBarController.navigationController.navigationBarHidden = NO;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
