//
//  MenuViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define DISABLE_VIEW_RELEASE_FLAG 0

#import "MenuViewController.h"
#import "SettingsViewController.h"
#import "Account_ViewController.h"
#import "H264PlayerViewController.h"
#import "UserAccount.h"

@interface MenuViewController () <H264PlayerVCDelegate, UserAccountDelegate>

@property (retain, nonatomic) Account_ViewController *accountVC;
@property (nonatomic) BOOL isFirttime;
@property (nonatomic, retain) NSMutableArray *restoredProfiles;
@property (nonatomic, retain) NSMutableArray *arrayChannel;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Menu";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
     withConnDelegate:(id<ConnectionMethodDelegate> ) caller
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.menuDelegate = caller;
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = NO;
    
    UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back.png"];
    
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithImage:hubbleBack
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(menuBackAction:)];
    [backBarBtn setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
    
    self.navigationItem.leftBarButtonItem = backBarBtn;
   // assert(self.navigationController.navigationItem.leftBarButtonItem != nil);
    
    self.camerasVC = [[CamerasViewController alloc] initWithStyle:nil
                                                         delegate:self.menuDelegate
                                                         parentVC:self];
    //self.camerasVC.camChannels = self.cameras;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_camerasVC];
    
    //[self.navigationController initWithRootViewController:camerasVC];
#if DISABLE_VIEW_RELEASE_FLAG
    self.accountVC = [[Account_ViewController alloc] init];
    
    NSLog(@"viewDidLoad: %p, %p", self.menuDelegate, self.accountVC.mdelegate);
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:_accountVC];
    
    self.viewControllers = [NSArray arrayWithObjects:nav, nav2, nil];
    
    [nav release];
    [nav2 release];
#else
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    settingsVC.parentVC = self;
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    self.accountVC = [[Account_ViewController alloc] init];
    
    NSLog(@"viewDidLoad: %p, %p", self.menuDelegate, self.accountVC.mdelegate);
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:_accountVC];
    
    
    self.viewControllers = [NSArray arrayWithObjects:nav, nav1, nav2, nil];
    
    UITabBarItem *camItem = [self.tabBar.items objectAtIndex:0];
    [camItem setImage:[UIImage imageNamed:@"camera.png"]];
    
    UITabBarItem *settingsItem = [self.tabBar.items objectAtIndex:1];
    [settingsItem setImage:[UIImage imageNamed:@"settings.png"]];

    UITabBarItem *accountItem = [self.tabBar.items objectAtIndex:2];
    [accountItem setImage:[UIImage imageNamed:@"account_icon.png"]];
    
    [nav release];
    [nav2 release];
    [settingsVC release];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back.png"];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
    self.accountVC.mdelegate = self.menuDelegate;
    //self.camerasVC.camChannels = self.cameras;

    if (!_isFirttime) //revert
    {
        self.isFirttime = TRUE;
        
        [self menuBackAction:nil];
        
    }
    else
    {
        self.camerasVC.waitingForUpdateData = TRUE;
        [self.camerasVC.tableView reloadData];
        [self performSelectorInBackground:@selector(recreateAccount)
                               withObject:nil];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    //self.camerasVC.parentVC = self;
    
    
    NSLog(@"viewDidAppear: %p, %p", self.menuDelegate, _accountVC.mdelegate);
}

- (void)menuBackAction: (id)sender
{
    // Back to Player view. What is camera selected? 0?
    
    if (self.cameras != nil &&
        self.cameras.count > 0)
    {
        CamChannel *ch = (CamChannel *)[self.cameras objectAtIndex:0];
        
        [CameraAlert clearAllAlertForCamera:ch.profile.mac_address];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:ch.profile.mac_address forKey:CAM_IN_VEW];
        [userDefaults synchronize];
        
        H264PlayerViewController *h264PlayerViewController = [[H264PlayerViewController alloc] init];
        
        h264PlayerViewController.selectedChannel = ch;
        h264PlayerViewController.h264PlayerVCDelegate = self;
        
        NSLog(@"%@, %@", self.parentViewController.description, self.parentViewController.parentViewController);
        
        //MenuViewController *tabBarController = (MenuViewController *)self.parentViewController;
        
        [self.navigationController pushViewController:h264PlayerViewController animated:YES];
        [h264PlayerViewController release];
    }
}

- (void)stopStreamFinished:(CamChannel *)camChannel
{
    if (self.cameras != nil &&
        self.cameras.count > 0)
    {
        CamChannel *ch = (CamChannel *)[self.cameras objectAtIndex:0];
        
        if ([ch.profile.mac_address isEqualToString:camChannel.profile.mac_address])
        {
            ch.waitingForStreamerToClose = NO;
        }
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.title = item.title;
}

#pragma mark - Update Camera list

- (void)recreateAccount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username  = [userDefaults stringForKey:@"PortalUsername"];
    NSString *userEmail = [userDefaults stringForKey:@"PortalUseremail"];
    NSString *apiKey    = [userDefaults stringForKey:@"PortalApiKey"];
    UserAccount *account = [[UserAccount alloc] initWithUser:username
                                                     andPass:userEmail
                                                   andApiKey:apiKey
                                                 andListener:nil];
    account.userAccountDelegate = self;
    [account readCameraListAndUpdate];
    
    [account release];
}

- (void)finishStoreCameraListData:(NSMutableArray *)camProfiles
{
    [self rebindCamerasResource];
    
    [self updateCameraList];
    
    self.camerasVC.camChannels = _cameras;
    
    self.camerasVC.waitingForUpdateData = NO;
    [self.camerasVC.tableView performSelectorInBackground:@selector(reloadData)
                                               withObject:nil];
}

- (void)updateCameraList
{
    NSMutableArray * validChannels = [[NSMutableArray alloc] init];
    
    for (int i = _arrayChannel.count - 1 ; i > -1; i--)
	{
		CamChannel * ch = [_arrayChannel objectAtIndex:i];
		
        if (ch.profile != nil)
        {
			[validChannels addObject:[_arrayChannel objectAtIndex:i]];
        }
	}
    
	self.cameras = validChannels;
}

- (BOOL)rebindCamerasResource
{
    BOOL restore_successful = [self restoreConfigData];
    
    if (restore_successful == YES)
    {
        for (int i = 0; i< [_arrayChannel count]; i++)
        {
            CamChannel* ch = (CamChannel*) [_arrayChannel objectAtIndex:i];
            
            if ( ch.profile != nil)
            {
                for (int j = 0; j < _restoredProfiles.count; j++)
                {
                    CamProfile * cp = (CamProfile *) [_restoredProfiles objectAtIndex:j];
                    
                    if ( !cp.isSelected)
                    {
                        //Re-bind camera - channel
                        [ch setCamProfile:cp];
                        cp.isSelected = TRUE;
                        [cp setChannel:ch];
                        break;
                    }
                }
            }
            else {
                
                //NSLog(@"channel profile = nil");
            }
        }
    }
    
    return restore_successful;
}

- (BOOL) restoreConfigData
{
	SetupData * savedData = [[SetupData alloc]init];
    
	if ([savedData restore_session_data] ==TRUE)
	{
		//NSLog(@"restored data done");
		self.arrayChannel = savedData.channels;
		self.restoredProfiles = savedData.configured_cams;
	}
    
    [savedData release];
    
	return TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_accountVC release];
    [super dealloc];
}

@end
