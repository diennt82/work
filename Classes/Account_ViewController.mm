//
//  Account_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Account_ViewController.h"
#import "MBP_iosViewController.h"
#import "CameraSettingsCell.h"
#import "TimelineButtonCell.h"
#import "NotificationSettingsCell.h"

@interface Account_ViewController () <TimelineButtonCellDelegate, NotifSettingsCellDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell *tableViewCellChangePassword;
@property (nonatomic) BOOL enabledSTUN;

@end

@implementation Account_ViewController

@synthesize  mdelegate;
@synthesize  mtopbar;

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
    [mtopbar release];
    [_tableViewCellChangePassword release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadUserData];
    self.enabledSTUN = FALSE;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_enabledSTUN forKey:@"enabled_stun"];
    [userDefaults synchronize];
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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self.navigationController setNavigationBarHidden:NO];
    } else {
        [self.navigationController setNavigationBarHidden:YES];
    }
    UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    self.navigationController.navigationBarHidden = YES;
    
	[self adjustViewsForOrientation:infOrientation];
    [self loadUserData];
    
}

-(void)loadUserData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//can be user email or user name here --
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    
    UITextField * _user  =  (UITextField *) [userEmailCell viewWithTag:1];
    _user.text = user_email;
    
    UITextField * _version = (UITextField *) [versionCell viewWithTag:1];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //version = [NSString stringWithFormat:msg,version];
    _version.text = version;
}

#if 1
-(void) buildTopToolBar: (NSInteger)width
{
}
#else

-(void) buildTopToolBar: (NSInteger)width
{
    int screenWidth = width;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        // Load resources for iOS 7 or later
        [self removeSubViewOfNavigationController];
        mtopbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 20, screenWidth, 44)];
    } else {
        // Load resources for iOS 6.1 or earlier
        mtopbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
        mtopbar.barStyle = UIBarStyleBlackOpaque;
    }
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    
    // create a spacer between the buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil
                               action:nil];
    [buttons addObject:spacer];
    [spacer release];
    
    
    NSString * msg  = NSLocalizedStringWithDefaultValue(@"Account",nil, [NSBundle mainBundle],
                                                        @"Account" , nil);
    
    //Label
    UIBarButtonItem *label = [[UIBarButtonItem alloc]
                              init];
    label.style = UIBarButtonItemStylePlain;
    label.title =msg;
    [buttons addObject:label];
    [label release];
    
    
    // create a spacer between the buttons
    spacer = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
              target:nil
              action:nil];
    [buttons addObject:spacer];
    [spacer release];
    
    
    msg  = NSLocalizedStringWithDefaultValue(@"Logout",nil, [NSBundle mainBundle],
                                             @"Logout" , nil);
    
    // create a standard delete button with the trash icon
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                     initWithTitle:msg
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(userLogout)];
    
    [buttons addObject:logoutButton];
    [logoutButton release];
    
    // put the buttons in the toolbar and release them
    [mtopbar setItems:buttons animated:NO];
    [buttons release];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self.navigationController.view addSubview:mtopbar];
    } else {
//        [mtopbar setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|
//                                       UIViewAutoresizingFlexibleLeftMargin|
//                                       UIViewAutoresizingFlexibleRightMargin) ];
        [self.view addSubview:mtopbar];
    }
}
#endif

- (void)sendTouchBtnStateWithIndex:(NSInteger)rowIdx
{
    [self userLogout];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


-(BOOL) shouldAutorotate
{
    return YES ;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [self adjustViewsForOrientation:toInterfaceOrientation];
}

-(void ) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self loadUserData];
    //    [self adjustViewsForOrientation:fromInterfaceOrientation];
    // [accountInfo reloadData];
}
-(void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        //since at this time.. the orientation is still NOT CHANGED so need to use the OTHER size
        int screenWidth = [UIScreen mainScreen].bounds.size.height  ;//480
        NSLog(@"screenWidth is  %d", screenWidth);
        //            mtopbar.frame = CGRectMake(0, 0, screenWidth, mtopbar.frame.size.height);
        [self buildTopToolBar:screenWidth];
    }
    else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        //since at this time.. the orientation is still NOT CHANGED so need to use the OTHER size
        int screenWidth = [UIScreen mainScreen].bounds.size.width  ;//320
        [self buildTopToolBar:screenWidth];
    }
}

-(void) userLogout
{
    NSLog(@"LOG OUT>>>>");
    if (mdelegate != nil)
    {
        accountInfo.hidden = YES;
        progress.hidden = NO;
        
        //User logout --
        // 1 . Clear all alert
        [CameraAlert clearAllAlerts];
        //TODO: 2 . Clear offline data
        
        
        [mdelegate sendStatus:LOGIN_FAILED_OR_LOGOUT];
        
        [self dismissViewControllerAnimated:NO completion:^{}];
    }
    else
    {
        NSLog(@"Delegate is nill");
    }
}

#pragma mark - Notification cell delegate

- (void)reportSwitchValue:(BOOL)value andRowIndex:(NSInteger)rowIndex
{
    self.enabledSTUN = value;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_enabledSTUN forKey:@"enabled_stun"];
    [userDefaults synchronize];
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
        return 4;
    }
    else if (section == 1)
    {
        return 2;
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Profile";
    }
    else if (section == 1)
    {
        return @"Plan";
    }
    
    return @"Remote stream mode";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        return 60;
    }
    
    return 45;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        return NO;
    }
    
    return YES;
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
    
    UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 0.5f, cell.contentView.frame.size.width, 0.5f)] autorelease];
    if (indexPath.row == 3)
    {
        lineView.frame = CGRectMake(0, 59.5f, cell.contentView.frame.size.width, 0.5f);
    }
    
    lineView.backgroundColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1];
    lineView.tag = 905;
    [cell.contentView addSubview:lineView];
    cell.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
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
        
        if (indexPath.row == APPVERSION_INDEX)
        {
            return versionCell;
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
            cell.textLabel.textColor = [UIColor blueColor];
            
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
            cell.nameLabel.text = @"Upgrade Plan";
            cell.valueLabel.text = nil;
            cell.valueLabel.hidden = YES;
            
            return cell;
        }
    }
    else
    {
        //NotificationSettingsCell
        static NSString *CellIdentifier = @"NotificationSettingsCell";
        NotificationSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NotificationSettingsCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (NotificationSettingsCell *)curObj;
                break;
            }
        }
        
        cell.notifSettingsDelegate = self;
        cell.settingsLabel.text = @"Enable STUN";
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:17];
        cell.textLabel.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1];
        [cell.settingSwitch setOn:_enabledSTUN];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 3)
    {
        [self userLogout];
    }
}

@end
