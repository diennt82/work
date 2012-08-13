//
//  DashBoard_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/31/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "DashBoard_ViewController.h"

@interface DashBoard_ViewController ()

@end

@implementation DashBoard_ViewController
@synthesize  cellView;
@synthesize  listOfChannel;
@synthesize  delegate; 

@synthesize  tabBarController;

@synthesize  topbar;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
withConnDelegate:(id<ConnectionMethodDelegate> ) caller
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.delegate = caller; 
    }
    return self;
    
}


-(void ) dealloc
{
    [topbar release];
    [listOfChannel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
    
    [self.navigationController setNavigationBarHidden:YES];
    
    //Build ToolBar manually
    
   
    topbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    topbar.barStyle = UIBarStyleBlackOpaque;
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    // create a standard reload button
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                     target:nil
                                     action:nil];
    reloadButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:reloadButton];
    [reloadButton release];
    
    // create a spacer between the buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    [buttons addObject:spacer];
    [spacer release];
    
    //Label
    UIBarButtonItem *label = [[UIBarButtonItem alloc]
                              init];
    label.style = UIBarButtonItemStylePlain;
    label.title =@"Cameras";
    [buttons addObject:label];
    [label release];

    
    // create a spacer between the buttons
    spacer = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
              target:nil
              action:nil];
    [buttons addObject:spacer];
    [spacer release];

    
    
    // create a standard delete button with the trash icon
    UIBarButtonItem *snapButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                   target:nil
                                   action:nil];
    snapButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:snapButton];
    [snapButton release];
    
    
    // create a standard delete button with the trash icon
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                   target:self
                                  action:@selector(addCamera:)];
    addButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:addButton];
    [addButton release];
    
    // put the buttons in the toolbar and release them
    [topbar setItems:buttons animated:NO];
    [buttons release];

    
        
    [self.view addSubview:topbar];
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
    
    if (isOffline == YES)
    {
        NSLog(@"OFFLINE OFFLINE OFFLINE");
        
        int delta_h =  offlineView.frame.size.height;
        
        if (self.tabBarController.tabBar.hidden == NO)
        {
            delta_h += self.tabBarController.tabBar.frame.size.height;
        }
        
        
        //Adjust table size
        cameraList.frame = CGRectMake(cameraList.frame.origin.x, cameraList.frame.origin.y,
                                      cameraList.frame.size.width,
                                      cameraList.frame.size.height-delta_h);
        offlineView.hidden = NO; 
        
        offlineView.frame = CGRectMake(offlineView.frame.origin.x, 
                                       cameraList.frame.origin.y + cameraList.frame.size.height,
                                       offlineView.frame.size.width, offlineView.frame.size.height);
        
        //add a subview in layout. 
        [self.view addSubview:offlineView];
    }
    else
    {
        offlineView.hidden = YES; 
        //[offlineView removeFromSuperview]; 
        cameraList.frame = CGRectMake(cameraList.frame.origin.x, cameraList.frame.origin.y,
                                      cameraList.frame.size.width,
                                      387);
       
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view delegates & datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    
    if (listOfChannel != nil)
    {
         NSLog(@"Num of row: %d",[listOfChannel count]);
    
        return [listOfChannel count];
    }
    
    return 0; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DashBoard_camView" owner:self options:nil];
        cell = self.cellView;
        self.cellView = nil; 
    }
    //Get refernce to cell content
    UIImageView * snapshot = (UIImageView *) [cell viewWithTag:500];
    UILabel * camName  = (UILabel *) [cell viewWithTag:501];
    UILabel * camLoc  = (UILabel *) [cell viewWithTag:502];
    UIImageView * camStatusInd = (UIImageView *) [cell viewWithTag:503];
    UILabel * camStatus = (UILabel *) [cell viewWithTag:504];
    
    
    
    // Set up the cell...
    CamChannel * ch = (CamChannel*)[listOfChannel objectAtIndex:indexPath.row] ;
    CamProfile * cp = ch.profile; 
    
    //NSLog(@"cell: %d %d", indexPath.row , cp.minuteSinceLastComm);
    
    if (ch != nil)
    {
        
        //set camera info
        if (cp.isInLocal == TRUE)
        {

            [camStatusInd setImage:[UIImage imageNamed:@"camera_online.png"]];

            [camLoc setText:@"Local Wifi"]; 
            [camStatus setText:@"Available"];
            
        }
        else if (cp.minuteSinceLastComm <=5 ) 
        {
            [camStatusInd setImage:[UIImage imageNamed:@"camera_remote.png"]];
            [camLoc setText:@"Remote Network"];
            [camStatus setText:@"Camera is not in local network"];
        }
        else 
        {
            [camStatusInd setImage:[UIImage imageNamed:@"camera_offline.png"]];
            [camLoc setText:@"Remote Network"];
            [camStatus setText:@"Not Available"];
        }

        
        //Set camera name
        [camName setText:cp.name]; 
        
        //set camera image
        if (cp.profileImage != nil)
        {
            [snapshot setImage:cp.profileImage];
        }
        else 
        {
            [snapshot setImage:[UIImage imageNamed:@"photo_item.png"]];
        }

    }
    else {
        NSLog(@"cell: %d nil", indexPath.row);
    }
    
    
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] 
                             animated:NO];
    
    int idx=indexPath.row;
    
    NSLog(@"cell: %d pressed",idx);
    CamChannel * ch = (CamChannel*)[listOfChannel objectAtIndex:indexPath.row] ;
    
    if (ch != nil &&
        ch.profile != nil &&
        (ch.profile.isInLocal ==YES || ch.profile.minuteSinceLastComm <=5)
        )
    {
        
        CameraViewController * viewCamCtrl;
        viewCamCtrl = [[CameraViewController alloc] initWithNibName:@"CameraViewController"
                                                               bundle:nil];
        viewCamCtrl.selected_channel = ch;
        
        [self.navigationController pushViewController:viewCamCtrl animated:NO];    
        [viewCamCtrl release];
    }
    
}

#pragma mark -



- (void)presentModallyOn:(UIViewController *)parent
{
    UINavigationController *    navController;
    
    //tabBarController isalready initiated
    
#if 0
    //setup nav controller 
    navController= [[[UINavigationController alloc]initWithRootViewController:self] autorelease];
    
    // Create a navigation controller with us as its root.
    assert(navController != nil);
    
    
    // Set up the Cancel button on the left of the navigation bar.
    self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
    assert(self.navigationItem.leftBarButtonItem != nil);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone   target:self action:@selector(doneAction:)] autorelease];
    assert(self.navigationItem.rightBarButtonItem != nil);
#else 
    
    NSLog(@"Nav + TAB"); 
    UITabBarItem * camList  = [[UITabBarItem alloc]initWithTitle:@"Cameras"
                                                           image:[UIImage imageNamed:@"bb_camera_slider_icon.png"]
                                                             tag:1];
    [self setTabBarItem:camList];
    UITabBarItem * account  = [[UITabBarItem alloc]initWithTitle:@"Account"
                                                           image:[UIImage imageNamed:@"bb_setting_icon.png"]
                                                             tag:2];
    
    
    Account_ViewController * accountPage = [[Account_ViewController alloc]
                                             initWithNibName:@"Account_ViewController" bundle:nil];
    [accountPage setTabBarItem:account];
    accountPage.mdelegate = self.delegate;
    
    NSArray * views = [[NSArray alloc]initWithObjects:self, accountPage, nil];
    tabBarController = [[UITabBarController alloc]init]; 
    [tabBarController setViewControllers:views];
    
    
    
    
    

    //setup nav controller 
    navController= [[[UINavigationController alloc]initWithRootViewController:tabBarController] autorelease];
    
    // Create a navigation controller with us as its root.
    assert(navController != nil);
    
    [navController setNavigationBarHidden:YES];
    
    
    // Set up the Cancel button on the left of the navigation bar.
    self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
    assert(self.navigationItem.leftBarButtonItem != nil);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone   target:self action:@selector(doneAction:)] autorelease];
    assert(self.navigationItem.rightBarButtonItem != nil);
#endif
    // Present the navigation controller on the specified parent 
    // view controller.
    
    [parent presentModalViewController:navController animated:YES];
}



-(void) forceRelogin
{
    [delegate sendStatus:5];
}

-(IBAction)addCamera:(id)sender
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
    [userDefaults synchronize];
    
    [delegate sendStatus:1];//initial setup 
    
    
    
}
-(IBAction)checkNow:(id)sender
{
    [self forceRelogin];
}


@end
