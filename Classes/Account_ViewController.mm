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

@interface Account_ViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell *tableViewCellChangePassword;

@property (nonatomic) NSInteger screenWidth;

@property (nonatomic,strong) NSString *strNewChangedPass;

@end

@implementation Account_ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString * msgAccount = NSLocalizedStringWithDefaultValue(@"Account_",nil, [NSBundle mainBundle],
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
    // Do any additional setup after loading the view from its nib.
    
    //[self loadUserData];
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    UILabel *lblVersion = (UILabel *)[self.view viewWithTag:559];
    
    lblVersion.text = [NSString stringWithFormat:@"Hubble Home v%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"AccountVC -viewWillAppear --");
    
    self.navigationController.navigationBarHidden = YES;
    [self loadUserData];
}

-(void)loadUserData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//can be user email or user name here --
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    
    UITextField * _user  =  (UITextField *) [userEmailCell viewWithTag:1];
    _user.text = user_email;
}

- (void)sendTouchBtnStateWithIndex:(NSInteger)rowIdx
{
    [self userLogout];
}

-(IBAction) userLogout
{
    NSLog(@"LOG OUT>>>>");
    
    MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
    
    accountInfo.hidden = YES;
    progress.hidden = NO;
    [CameraAlert clearAllAlerts];
    
    [tabBarController dismissViewControllerAnimated:NO completion:^
     {
         [tabBarController.menuDelegate sendStatus:LOGIN_FAILED_OR_LOGOUT];
     }];
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
        
        NSMutableData *dataZip = [NSMutableData dataWithLength:length];
        
        if (dataLog0)
        {
            [dataZip appendData:dataLog0];
        }
        
        [dataZip appendData:dataLog];
        
        dataZip = [NSData gzipData:dataZip];
        
        [picker addAttachmentData:[dataZip AES128EncryptWithKey:CES128_ENCRYPTION_PASSWORD] mimeType:@"text/plain" fileName:@"application.log"];
        
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
    return 3;
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
        if (CUE_RELEASE_FLAG)
        {
            return 1;
            
        }
        else
        {
            return 2;
        }
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
        return @"Profile";
    }
    else if(section == 1)
    {
        return @"Plan";
    }
    else
    {
        return @"Report";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 1)) ||
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
    
    UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 0.5f, _screenWidth, 0.5f)] autorelease];
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
            return userEmailCell;
        }
        
        if (indexPath.row == CHANGE_PASS_INDEX)
        {
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
            
            cell.textLabel.text = @"Logout";
            
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
            cell.nameLabel.text = @"Current Plan";
            cell.valueLabel.text = @"Free";
            cell.valueLabel.hidden = NO;
            
            return cell;
        }
        else
        {
            //cell.nameLabel.text = @"Upgrade Plan";
            //cell.valueLabel.text = nil;
            //cell.valueLabel.hidden = YES;
            
            cell.nameLabel.text = @"App Version";
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
        
        cell.textLabel.text = @"Send app log";
        
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
            [self userLogout];
        }
    }
    else if(indexPath.section == 2)
    {
        [self sendsAppLog];
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
    [lblTitle setText:@"Change Password"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    
    tfOldPass.placeholder = @"Old Password";
    tfNewPass.placeholder = @"New Password";
    tfConfPass.placeholder = @"Confirm Password";
    
    [tfOldPass setBackgroundColor:[UIColor whiteColor]];
    [tfNewPass setBackgroundColor:[UIColor whiteColor]];
    [tfConfPass setBackgroundColor:[UIColor whiteColor]];
    
    [alertContenerView addSubview:lblTitle];
    [alertContenerView addSubview:tfOldPass];
    [alertContenerView addSubview:tfNewPass];
    [alertContenerView addSubview:tfConfPass];
    
    [alert setContainerView:alertContenerView];
    
    [alert setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"OK", nil]];
    
    [alert setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex)
    {
        [alertView close];
        
        if(buttonIndex==1)
        {
            NSString *password = tfNewPass.text;
            NSString *passwordConfrm = tfConfPass.text;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
            
            if ((password       && password.length > 0)       &&
                (passwordConfrm && passwordConfrm.length > 0) &&
                [password isEqualToString:passwordConfrm] &&
                (tfOldPass.text.length > 0 && [old_pass isEqualToString:tfOldPass.text]))
            {
                self.strNewChangedPass = password;
                [self doChangePassword:password];
            }
            else
            {
                if((tfOldPass.text.length == 0 ||  ![old_pass isEqualToString:tfOldPass.text]))
                {
                    NSDictionary *dictError = [NSDictionary dictionaryWithObjectsAndKeys:@"Please enter correct  old password", @"message", nil];
                    [self changePasswordFialedWithError:dictError];
                }
                else
                {
                    NSDictionary *dictError = [NSDictionary dictionaryWithObjectsAndKeys:@"Validation failed: Password is not match or empty", @"message", nil];
                    [self changePasswordFialedWithError:dictError];
                }
            }
        }
        [tfOldPass release];
        [tfNewPass release];
        [tfConfPass release];
        [alertView release];
    }];
    [alert show];
}

#pragma mark - UIAlert view delegate

- (void )alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

- (void)doChangePassword:(NSString *)newPassword
{
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
    
    [[[[UIAlertView alloc] initWithTitle:@"Change Password"
                                 message:@"Successful"
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] autorelease] show];
    
}

- (void)changePasswordFialedWithError:(NSDictionary *)error_response
{
    [[[[UIAlertView alloc] initWithTitle:@"Change Password Failed"
                                 message:[error_response objectForKey:@"message"]
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] autorelease] show];
}

- (void)changePasswordFailedServerUnreachable
{
    [[[[UIAlertView alloc] initWithTitle:@"Failed: Server is unreachable"
                                 message:nil
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] autorelease] show];
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
