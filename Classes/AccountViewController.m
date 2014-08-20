//
//  AccountViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "AccountViewController.h"
#import "CameraSettingsCell.h"
#import "MenuViewController.h"
#import "PublicDefine.h"
#import "NSData+AESCrypt.h"
#import "CustomIOS7AlertView.h"
#import "CameraAlert.h"

@interface AccountViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *accountInfo;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *progress;
@property (nonatomic, strong) IBOutlet UITableViewCell *userEmailCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *changePasswordCell;
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) IBOutlet UILabel *changePasswordLabel;
@property (nonatomic, copy) NSString *strNewChangedPass;
@property (nonatomic) NSInteger screenWidth;

@end

@implementation AccountViewController

#define PROFILE_SECTION     0
#define EMAIL_ROW           0
#define CHANGE_PASSWORD_ROW 1

#define PLAN_SECTION        1
#define SUBSCRIPTION_ROW    0
#define VERSION_ROW         1

#define NUM_SECTIONS        2

#define CHANGE_PASSWORD_DIALOG_TAG  111
#define LOGOUT_DIALOG_TAG           222

#pragma mark - UIViewController methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set title here and not in viewDidLoad otherwise problem occurs in a tabbedViewController parent.
        self.title = LocStr(@"Account");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    UILabel *lblVersion = (UILabel *)[self.view viewWithTag:559];
    
#ifdef VTECH
    lblVersion.text = [NSString stringWithFormat:LocStr(@"VTech Connect v%@"), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
#else
    lblVersion.text = [NSString stringWithFormat:LocStr(@"Hubble Home v%@"), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
#endif
    
    _emailLabel.text = LocStr(@"Email");
    _changePasswordLabel.text = LocStr(@"Change Password");
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:LocStr(@"Logout")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(confirmUserLogout)];
    self.navigationItem.rightBarButtonItem = logoutButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"AccountVC -viewWillAppear --");
    [self loadUserData];
    
    // Don't know why but on iOS 7.1 the tintColor was getting unset somehow
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7+
        self.navigationItem.rightBarButtonItem.tintColor = [UIApplication sharedApplication].keyWindow.tintColor;
    }
}

#pragma mark - Private methods

- (void)removeSubViewOfNavigationController
{
    for (UIView *subView in self.navigationController.view.subviews) {
        if ([subView isKindOfClass:[UIToolbar class]]) {
            [subView removeFromSuperview];
        }
    }
}

- (void)loadUserData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	// can be user email or user name here --
	NSString *user_email = (NSString *)[userDefaults objectForKey:@"PortalUseremail"];
    UITextField *userTextField = (UITextField *)[_userEmailCell viewWithTag:1];
    userTextField.text = user_email;
}

- (void)sendTouchBtnStateWithIndex:(NSInteger)rowIdx
{
    [self confirmUserLogout];
}

- (void)confirmUserLogout
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Confirm")
                                                    message:LocStr(@"Are you sure?")
                                                   delegate:self
                                          cancelButtonTitle:LocStr(@"Cancel")
                                          otherButtonTitles:LocStr(@"OK"), nil];
    alert.tag = LOGOUT_DIALOG_TAG;
    [alert show];
}

- (void)userLogout
{
    DLog(@"LOG OUT >>>>");
    
    _accountInfo.hidden = YES;
    _progress.hidden = NO;
    [CameraAlert clearAllAlerts];
    
    MenuViewController *menuViewController = (MenuViewController *)self.parentVC;
    
    [menuViewController dismissViewControllerAnimated:NO completion:^{
        [menuViewController.menuDelegate sendStatus:LOGIN_FAILED_OR_LOGOUT];
    }];
}

#pragma mark - Table view delegate & data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == PROFILE_SECTION) {
        return 2;
    }
    else {
        //section == PLAN_SECTION
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == PROFILE_SECTION) {
        return LocStr(@"Profile");
    }
    else {
        // if (section == PLAN_SECTION) {
        return LocStr(@"Plan");
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == PROFILE_SECTION && indexPath.row == CHANGE_PASSWORD_ROW ) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (id obj in cell.contentView.subviews) {
        if ([obj isKindOfClass:[UIView class]] && ((UIView *)obj).tag == 905) {
            [obj removeFromSuperview];
            break;
        }
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 0.5f, _screenWidth, 0.5f)];
    lineView.backgroundColor = [UIColor colorWithRed:195/255.f green:195/255.f blue:195/255.f alpha:1];
    lineView.tag = 905;
    [cell.contentView addSubview:lineView];
    cell.backgroundColor = [UIColor colorWithRed:249/255.f green:249/255.f blue:249/255.f alpha:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == PROFILE_SECTION ) {
        if ( indexPath.row == EMAIL_ROW ) {
            return _userEmailCell;
        }
        
        if ( indexPath.row == CHANGE_PASSWORD_ROW ) {
            return _changePasswordCell;
        }
        else {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if ( !cell ) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = LocStr(@"Logout");
            return cell;
        }
    }
    else {
        // PLAN SECTION
        static NSString *CellIdentifier = @"CameraSettingsCell";
        CameraSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CameraSettingsCell" owner:nil options:nil];
        for (id curObj in objects) {
            if([curObj isKindOfClass:[UITableViewCell class]]) {
                cell = (CameraSettingsCell *)curObj;
                break;
            }
        }
        
        if ( indexPath.row == SUBSCRIPTION_ROW ) {
            cell.nameLabel.text = LocStr(@"Current Plan");
            cell.valueLabel.text = LocStr(@"Free");
            cell.valueLabel.hidden = NO;
            return cell;
        }
        else {
            cell.nameLabel.text = LocStr(@"App Version");
            NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
            cell.valueLabel.text = [infoDict objectForKey:@"CFBundleShortVersionString"];
            cell.valueLabel.hidden = NO;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( indexPath.section == PROFILE_SECTION ) {
        if ( indexPath.row == CHANGE_PASSWORD_ROW ) {
            [self showDialogChangePassword];
        }
    }
}

- (void)showDialogChangePassword
{
    CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
    [alert setBackgroundColor:[UIColor whiteColor]];
    
    UIView *alertContenerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    UITextField *tfOldPass = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, 280, 30)];
    UITextField *tfNewPass = [[UITextField alloc] initWithFrame:CGRectMake(10, 75, 280, 30)];
    UITextField *tfConfPass = [[UITextField alloc] initWithFrame:CGRectMake(10, 110, 280, 30)];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 280, 25)];
    [lblTitle setText:LocStr(@"Change Password")];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    
    tfOldPass.placeholder = LocStr(@"Old Password");
    tfNewPass.placeholder = LocStr(@"New Password");
    tfConfPass.placeholder = LocStr(@"Confirm Password");
    
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
    
    [alert setContainerView:alertContenerView];
    
    [alert setButtonTitles:@[LocStr(@"Cancel"), LocStr(@"Ok")]];
    
    [alert setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        [alertView close];
        
        if ( buttonIndex == 1 ) {
            NSString *password = tfNewPass.text;
            NSString *passwordConfrm = tfConfPass.text;
            NSString *oldPass = tfOldPass.text;
            
            if (password && password.length > 0  &&
                passwordConfrm && passwordConfrm.length > 0 &&
                oldPass && oldPass.length > 0 &&
                [password isEqualToString:passwordConfrm])
            {
                self.strNewChangedPass = password;
                [self checkOldPass:oldPass NewPass:password];
            }
            else {
                if ( password.length == 0 || oldPass.length == 0 ) {
                    NSDictionary *dict = @{ @"message" : LocStr(@"New and old passwords required") };
                    [self changePasswordFialedWithError:dict];
                }
                else {
                    NSDictionary *dict = @{@"message" : LocStr(@"Password confirmation did not match") };
                    [self changePasswordFialedWithError:dict];
                }
            }
        }
    }];
    
    [alert show];
}

- (void)checkOldPass:(NSString *)strOldPass NewPass:(NSString *)strNewPass
{
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(loginSuccessWithResponse:)
                                                                          FailSelector:@selector(loginFailedWithError:)
                                                                             ServerErr:@selector(loginFailedServerUnreachable)];
    
    NSString *strUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortalUsername"];
    [jsonComm loginWithLogin:strUserId andPassword:strOldPass];
}

#pragma mark Login Callbacks

- (void)loginSuccessWithResponse:(NSDictionary *)responseDict
{
   	if (responseDict) {
        NSInteger statusCode = [responseDict[@"status"] intValue];
        
        if (statusCode == 200) {
            // success
            NSString *apiKey = [responseDict[@"data"] objectForKey:@"authentication_token"];
            [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:@"PortalApiKey"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self doChangePassword:_strNewChangedPass];
        }
        else {
            DLog(@"Invalid response: %@", responseDict);
            
            [[[UIAlertView alloc] initWithTitle:LocStr(@"Change Password Failed")
                                         message:LocStr(@"Old password was incorrect")
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:LocStr(@"Ok"), nil] show];
        }
    }
    else {
        DLog(@"Error - loginSuccessWithResponse: reponseDict = nil");
    }
}

- (void)loginFailedWithError:(NSDictionary *)responseError
{
    [self changePasswordFialedWithError:responseError];
}

- (void)loginFailedServerUnreachable
{
    [self changePasswordFailedServerUnreachable];
}

- (void)doChangePassword:(NSString *)newPassword
{
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(changePasswordSuccessWithResponse:)
                                                                          FailSelector:@selector(changePasswordFialedWithError:)
                                                                             ServerErr:@selector(changePasswordFailedServerUnreachable)];
    [jsonComm changePasswordWithNewPassword:newPassword andPasswordConfirm:newPassword andApiKey:apiKey];
}

#pragma mark - JSON call back

- (void)changePasswordSuccessWithResponse:(NSDictionary *)responseData
{    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.strNewChangedPass forKey:@"PortalPassword"];
    [userDefaults synchronize];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:LocStr(@"Change Password Succeeded")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:LocStr(@"Ok"), nil];
    [alertView show];
}

- (void)changePasswordFialedWithError:(NSDictionary *)errorResponse
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocStr(@"Change Password Failed")
                                                        message:errorResponse[@"message"]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:LocStr(@"Ok"), nil];
    [alertView show];
}

- (void)changePasswordFailedServerUnreachable
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocStr(@"Change Password Failed")
                                                        message:LocStr(@"Server is unreachable")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:LocStr(@"Ok"), nil];
    [alertView show];
}

#pragma mark - UIAlertView delegate

- (void )alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex != alertView.cancelButtonIndex ) {
        if ( alertView.tag == CHANGE_PASSWORD_DIALOG_TAG ) {
            NSString *password = [alertView textFieldAtIndex:0].text;
            NSString *passwordConfrm = [alertView textFieldAtIndex:1].text;
            
            if ( password.length > 0 && passwordConfrm.length > 0 && [password isEqualToString:passwordConfrm] ) {
                [self doChangePassword:password];
            }
            else {
                NSDictionary *dictError = @{@"message" : LocStr(@"Password did not match or is empty.")};
                [self changePasswordFialedWithError:dictError];
            }
        }
        else if ( alertView.tag == LOGOUT_DIALOG_TAG ) {
            [self userLogout];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate protocol methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    MenuViewController *menuViewController = (MenuViewController *)_parentVC;
    menuViewController.navigationController.navigationBarHidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
