//
//  Account_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#define DISABLE_VIEW_RELEASE_FLAG 1

#import "Account_ViewController.h"
#import "MBP_iosViewController.h"
#import "CameraSettingsCell.h"
#import "TimelineButtonCell.h"

@interface Account_ViewController () <TimelineButtonCellDelegate>

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
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self loadUserData];
    
    
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
    NSLog(@"viewWillAppear --");
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
	NSString * user_name = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    
    
    UITextField * _user = (UITextField *) [userNameCell viewWithTag:1];
    _user.text = user_name;
    _user =  (UITextField *) [userEmailCell viewWithTag:1];
    _user.text = user_email;
    
    UITextField * _version = (UITextField *) [versionCell viewWithTag:1];
    
    //NSString * msg = NSLocalizedStringWithDefaultValue(@"version",nil, [NSBundle mainBundle],
    //                                                 @"Version %@" , nil);
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //version = [NSString stringWithFormat:msg,version];
    _version.text = version;
    
    
}

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
        
    }	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        
        //since at this time.. the orientation is still NOT CHANGED so need to use the OTHER size
        int screenWidth = [UIScreen mainScreen].bounds.size.width  ;//320
        [self buildTopToolBar:screenWidth];
        
    }
    
    
#if 0
    
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //[[NSBundle mainBundle] loadNibNamed:@"Account_ViewController_land_ipad"
            //                           owner:self
            //                          options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"Account_ViewController_land"
                                          owner:self
                                        options:nil];
            
            //since at this time.. the orientation is still NOT CHANGED so need to use the OTHER size
            int screenWidth = [UIScreen mainScreen].bounds.size.height  ;//480
            int screenHeight = [UIScreen mainScreen].bounds.size.width;
            
            mtopbar.frame = CGRectMake(0, 0, screenWidth, mtopbar.frame.size.height);
            
            
            UIImageView * bg = (UIImageView*) [self.view viewWithTag:1];
            if (bg != nil)
            {
                //transform.
                CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
                bg.transform = transform;
                //bg.frame = CGRectMake(0,0, 480, 320);
                
                bg.frame = CGRectMake(0,0,  screenWidth,screenHeight);
            }
            
            if (mtopbar == nil)
            {
                NSLog(@"create new tool bar");
                [self buildTopToolBar];
                
            }
            
        }
        
        
        
        
        
        
    }
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //[[NSBundle mainBundle] loadNibNamed:@"Account_ViewController_ipad"
            //                             owner:self
            //                          options:nil];
        }
        else
        {
            
            [[NSBundle mainBundle] loadNibNamed:@"Account_ViewController"
                                          owner:self
                                        options:nil];
            
            //since at this time.. the orientation is still NOT CHANGED so need to use the OTHER size
            int screenWidth = [UIScreen mainScreen].bounds.size.width  ;//320
            int screenHeight = [UIScreen mainScreen].bounds.size.height;
            
            //            mtopbar.frame = CGRectMake(0, 0, screenWidth, mtopbar.frame.size.height);
            
            UIImageView * bg = (UIImageView*) [self.view viewWithTag:1];
            if (bg != nil)
            {
                //transform.
                CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                bg.transform = transform;
                //bg.frame = CGRectMake(0,0, 320, 480);
                bg.frame = CGRectMake(0,0, screenWidth,screenHeight);
            }
            
            if (mtopbar == nil)
            {
                [self buildTopToolBar];
            }
            
        }
        
        
        
        
	}
    
    
    
    if (mtopbar != nil)
    {
        [self.view addSubview:mtopbar];
        
        [self.view bringSubviewToFront:mtopbar];
    }
    
#endif
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#if DISABLE_VIEW_RELEASE_FLAG
    return 1;
#else
    return 2;
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 4;
    }
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Profile";
    }
    
    return @"Plan";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        return 60;
    }
    
    return 44;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}

#define USERNAME_INDEX 0
#define USEREMAIL_INDEX 1
#define APPVERSION_INDEX 2



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == USERNAME_INDEX) {
            return userNameCell;
        }
        
        
        if (indexPath.row == USEREMAIL_INDEX)
        {
            return userEmailCell;
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
            
            return cell;
        }
    }
    else
    {
        if (indexPath.row == 0)
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
            
            cell.nameLabel.text = @"Current Plan";
            cell.valueLabel.text = @"Free";
            
            return cell;
        }
        
    }

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    cell.textLabel.text = @"Upgrade Plan";
    
    return cell;
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
