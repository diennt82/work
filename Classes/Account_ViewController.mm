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

@interface Account_ViewController ()

@property (retain, nonatomic) IBOutlet UITableViewCell *tableViewCellChangePassword;
@property (nonatomic) NSInteger screenWidth;

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
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        lblVersion.frame = CGRectMake(lblVersion.frame.origin.x, lblVersion.frame.origin.y - 44, lblVersion.frame.size.width, lblVersion.frame.size.height);
    }
    
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

#pragma mark - Table view delegate & data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else
    {
        if (CUE_RELEASE_FLAG)
        {
            //return 1; // Original
            return  2;//Kiran
        }
        else
        {
            return 2;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Profile";
    }
    else
    {
        return @"Plan";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 1))
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
    if (indexPath.row == 2)
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
    else
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
}

- (void)showDialogChangePassword
{
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Change Password" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    // Alert style customization
    [[av textFieldAtIndex:1] setSecureTextEntry:NO];
    [[av textFieldAtIndex:0] setPlaceholder:@"new password"];
    [[av textFieldAtIndex:1] setPlaceholder:@"confirm password"];
    [av show];
    [av release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1)
    {
        //OK
        NSLog(@"1 %@", [alertView textFieldAtIndex:0].text);
        NSLog(@"2 %@", [alertView textFieldAtIndex:1].text);
        _newPass = [alertView textFieldAtIndex:0].text;
        _newPassConfirm = [alertView textFieldAtIndex:1].text;
        [self doChangePassword];
        
        
    }
}

- (void)doChangePassword
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults stringForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(registerSuccessWithResponse:)
                                                                          FailSelector:@selector(registerFailedWithError:)
                                                                             ServerErr:@selector(registerFailedServerUnreachable)] autorelease];
    [jsonComm changePasswordWithNewPassword:_newPass andPasswordConfirm:_newPassConfirm andApiKey:apiKey];
    [jsonComm release];
}

#pragma mark - JSON call back

- (void)registerSuccessWithResponse:(NSDictionary *)responseData
{
    [[[[UIAlertView alloc] initWithTitle:@"Change Password"
                                 message:@"Successful"
                                delegate:self
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] autorelease] show];

}

- (void)registerFailedWithError:(NSDictionary *)error_response
{
    [[[[UIAlertView alloc] initWithTitle:@"Change Password"
                                 message:@"Fail"
                                delegate:self
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] autorelease] show];
}

- (void)registerFailedServerUnreachable
{
    [[[[UIAlertView alloc] initWithTitle:@"Change Password"
                                 message:@"Fail"
                                delegate:self
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] autorelease] show];
}


@end
