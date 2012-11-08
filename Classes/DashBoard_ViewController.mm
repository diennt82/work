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
@synthesize  editModeEnabled;
@synthesize edittedChannelIndex;

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

-(void) setupTopBarForEditMode:(BOOL) isEditMode
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isOffline = [userDefaults boolForKey:_OfflineMode];

    
    if (isEditMode == FALSE)
    {
        //Build ToolBar manually
        topbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        topbar.barStyle = UIBarStyleBlackOpaque;
        // create an array for the buttons
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
        
        
        if (isOffline == TRUE)
        {
//            UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
//                                           initWithTitle:@"Edit"
//                                           style:UIBarButtonItemStyleBordered
//                                           target:nil
//                                           action:nil];
//            
//            [buttons addObject:editButton];
//            [editButton release];
        }
        else
        {
            
            if ([self shouldShowEditButton])
            {
                
                UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                               initWithTitle:@"Edit"
                                               style:UIBarButtonItemStyleBordered
                                               target:self
                                               action:@selector(editCameras:)];
                
                [buttons addObject:editButton];
                [editButton release];
                
            }
        }
        
        UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                         target:self
                                         action:@selector(refreshCameras:)];
        reloadButton.style = UIBarButtonItemStyleBordered;
        [buttons addObject:reloadButton];
        [reloadButton release];
        
        // create a spacer between the buttons
        UIBarButtonItem * spacer = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
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
                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                  target:nil
                  action:nil];
        [buttons addObject:spacer];
        [spacer release];
        
        if ([self shouldShowScanButton])
        {
            // create a standard delete button with the trash icon
            UIBarButtonItem *snapButton = [[UIBarButtonItem alloc]
                                           initWithImage:[UIImage imageNamed:@"scan_camera_icon.png"]

                                           style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(scanCameras:)];
            
            [buttons addObject:snapButton];
            [snapButton release];
        }
        
        
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
    }
    else
    {
        if (topbar != nil)
        {
            [topbar removeFromSuperview]; 
            [topbar release];
            
        }
        
        //Build ToolBar manually
        topbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        topbar.barStyle = UIBarStyleBlackOpaque;
        // create an array for the buttons
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];

        
        
        if (isOffline == TRUE)
        {
//            UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
//                                           initWithTitle:@"Edit"
//                                           style:UIBarButtonItemStyleBordered
//                                           target:nil
//                                           action:nil];
//            
//            [buttons addObject:editButton];
//            [editButton release];
        }
        else
        {
            
            if ([self shouldShowEditButton])
            {
                
                UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                               initWithTitle:@"Cancel"
                                               style:UIBarButtonItemStyleBordered
                                               target:self
                                               action:@selector(editCameras:)];
                
                [buttons addObject:editButton];
                [editButton release];
                
            }
        }
               
        // create a spacer between the buttons
        UIBarButtonItem * spacer = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
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
                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                  target:nil
                  action:nil];
        [buttons addObject:spacer];
        [spacer release];
        
              
        // put the buttons in the toolbar and release them
        [topbar setItems:buttons animated:NO];
        [buttons release];
        
        
        
        [self.view addSubview:topbar];
        
    }

    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
       
    
    [self.navigationController setNavigationBarHidden:YES];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isOffline = [userDefaults boolForKey:_OfflineMode];

    
    self.editModeEnabled = FALSE;
    
    [self setupTopBarForEditMode:self.editModeEnabled];
    
       
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
        
        
        
        if (![self shouldShowEditButton])
        {
            cameraList.hidden = YES;
            emptyCameraListView.frame = CGRectMake(emptyCameraListView.frame.origin.x,
                                                   emptyCameraListView.frame.origin.y+100,
                                                   emptyCameraListView.frame.size.width,
                                                   emptyCameraListView.frame.size.height);
            [self.view addSubview:emptyCameraListView];
            [self.view bringSubviewToFront:emptyCameraListView];
            
            
        }
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return  ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
             (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}


-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear --");
    
    
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
    
    
    
}



-(BOOL) shouldAutorotate
{
    NSLog(@"shouldAutorotate --");
    return YES ;
}

-(NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"supportedInterfaceOrientations --");

    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    NSLog(@"will rotate to interface");

    [self adjustViewsForOrientation:toInterfaceOrientation];
}

-(void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{

        
        topbar.frame = CGRectMake(0, 0, 480, topbar.frame.size.height);
        UIImageView * bg = (UIImageView*) [self.view viewWithTag:1];
        if (bg != nil)
        {
            //transform.
            CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
            bg.transform = transform;
            bg.frame = CGRectMake(0,0, 480, 320);
        }
        
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{

        topbar.frame = CGRectMake(0, 0, 320, topbar.frame.size.height);
        UIImageView * bg = (UIImageView*) [self.view viewWithTag:1];
        if (bg != nil)
        {
            //transform.
            CGAffineTransform transform = CGAffineTransformMakeRotation(0);
            bg.transform = transform;
            bg.frame = CGRectMake(0,0, 320, 480);
        }
    }



}


- (BOOL) shouldShowScanButton
{
    CamChannel * chan = nil;
    int localCount = 0;
    for (int i =0 ;i<[listOfChannel count]; i++)
    {
        
        chan = (CamChannel *) [listOfChannel objectAtIndex:i];
        if (chan.profile.isInLocal == YES)
        {
            localCount ++;
        }
        
    }
    
    return (localCount >1);
    
}



- (BOOL) shouldShowEditButton
{
    return ([listOfChannel count] >0);
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
        
        
        return [listOfChannel count];
    }
    
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editModeEnabled == TRUE)
    {
        return 181;
    }
    else
    {
        return 135;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
    if (self.editModeEnabled == TRUE)
    {
        
        static NSString *CellIdentifier = @"Cell1";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        
        if (cell == nil) {
            
            [[NSBundle mainBundle] loadNibNamed:@"DashBoard_camEdit" owner:self options:nil];
            cell = self.cellView;
            self.cellView = nil;
        }
        
        
        UIImageView * snapshot = (UIImageView *) [cell viewWithTag:500];
        UILabel * camName  = (UILabel *) [cell viewWithTag:501];
        
        UIButton *renButton = (UIButton *) [cell viewWithTag:505];
        UIButton *remButton = (UIButton *) [cell viewWithTag:506];
        UIButton * alertButtons = (UIButton *) [cell viewWithTag:507];
        
        ///////IF IT IS REUSED --->> DIE DIE DIE
        renButton.tag = indexPath.row;
        remButton.tag = indexPath.row;
        alertButtons.tag = indexPath.row;
        
        // Set up the cell...
        CamChannel * ch = (CamChannel*)[listOfChannel objectAtIndex:indexPath.row] ;
        CamProfile * cp = ch.profile;
        
        if (ch != nil)
        {
            
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
    else //Normal Mode
    {
        
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
        
        
        UIImageView * soundAlert = (UIImageView *) [cell viewWithTag:508];
        UIImageView * tempAlert = (UIImageView *) [cell viewWithTag:509];
        
        
        soundAlert.hidden = YES;
        tempAlert.hidden = YES;
        
        
        
        
        // Set up the cell...
        CamChannel * ch = (CamChannel*)[listOfChannel objectAtIndex:indexPath.row] ;
        CamProfile * cp = ch.profile;
        
        //NSLog(@"cell: %d %d", indexPath.row , cp.minuteSinceLastComm);
        
        if (ch != nil)
        {
            
            NSArray * alerts  = [ CameraAlert getAllAlertForCamera:cp.mac_address];
            CameraAlert * camAlert;
            if (alerts != nil)
            {
                
                //NSLog(@"alerts count: %d for cam: %@",[alerts count], cp.mac_address);
                
                for (int i =0; i <[alerts count]; i++)
                {
                    camAlert = (CameraAlert *) [alerts objectAtIndex:i];
                    if ( [camAlert.alertType isEqualToString:ALERT_TYPE_SOUND])
                    {
                        NSLog(@"Set sound indicator for cam: %@", cp.mac_address);
                        soundAlert.hidden = NO;
                    }
                    else if ( [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_HI]  ||
                             [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_LO] )
                    {
                        NSLog(@"Set temp indicator for cam: %@", cp.mac_address);
                        tempAlert.hidden = NO;
                    }
                    
                }
            }
            
            
            
            //set camera info
            if (cp.isInLocal == TRUE)
            {
                //20121023: phung: ui review comments.
                //[camStatusInd setImage:[UIImage imageNamed:@"camera_online.png"]];
                //[camStatus setText:@"Available"];
                camStatusInd.hidden = YES;
                camStatus.hidden  = YES;
                
                [camLoc setText:@"Local Wifi"];
                
            }
            else if (cp.minuteSinceLastComm <=10 )
            {
                //20121023: phung: ui review comments.
                //[camStatusInd setImage:[UIImage imageNamed:@"camera_online.png"]];
                //[camStatus setText:@"Camera is not in local network"];
                camStatusInd.hidden = YES;
                camStatus.hidden  = YES;
                
                [camLoc setText:@"Remote Camera"];
            }
            else
            {
                [camStatusInd setImage:[UIImage imageNamed:@"camera_offline.png"]];
                camStatusInd.hidden = NO;
                [camLoc setText:@"Remote Camera"];
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
    
    
    
    
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
    if (self.editModeEnabled == TRUE)
    {
        return; // don't start streaming in Edit mode
    }
    
    CamChannel * ch = (CamChannel*)[listOfChannel objectAtIndex:indexPath.row] ;
    
    if (ch != nil &&
        ch.profile != nil &&
        (ch.profile.isInLocal ==YES || ch.profile.minuteSinceLastComm <=5)
        )
    {
        
        NSLog(@"clear alert for: %@",ch.profile.mac_address);
        // Clear all alert for this camera
        [CameraAlert clearAllAlertForCamera:ch.profile.mac_address];
        
        [tableView reloadData];
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:ch.profile.mac_address forKey:CAM_IN_VEW];
        [userDefaults synchronize];
        
        
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isOffline = [userDefaults boolForKey:_OfflineMode];

   
    UITabBarItem * camList  = [[UITabBarItem alloc]initWithTitle:@"Cameras"
                                                           image:[UIImage imageNamed:@"bb_camera_slider_icon.png"]
                                                             tag:1];
    [self setTabBarItem:camList];
    UITabBarItem * account  = [[UITabBarItem alloc]initWithTitle:@"Account"
                                                           image:[UIImage imageNamed:@"account_icon.png"]
                                                             tag:2];
    
    
    Account_ViewController * accountPage = [[Account_ViewController alloc]
                                            initWithNibName:@"Account_ViewController" bundle:nil];
    [accountPage setTabBarItem:account];
    accountPage.mdelegate = self.delegate;
    
    
    NSArray * views = [[NSArray alloc]initWithObjects:self, accountPage, nil];
    if (isOffline == TRUE)
    {
        [views release];
        views = [[NSArray alloc]initWithObjects:self,  nil];
    }
    
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
    
    
    [navController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    
    // Present the navigation controller on the specified parent
    // view controller.
    
    [parent presentModalViewController:navController animated:NO];
}



-(void) forceRelogin
{
    [delegate sendStatus:5];
}

#pragma  mark -
#pragma mark ACTIONS ..




-(IBAction)addCamera:(id)sender
{
    
    if ([listOfChannel count] < MAX_CAM_ALLOWED)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
        [userDefaults synchronize];
        
        [delegate sendStatus:1];//initial setup
        
    }
    else
    {
        [self showDialog:DIALOG_CANT_ADD_CAM];
    }
    
}
-(IBAction)checkNow:(id)sender
{
    [self forceRelogin];
}

-(IBAction)scanCameras:(id)sender
{
    if ([listOfChannel count] >1)
    {
        
        int localCameras = 0;
        CamChannel * ch;
        for (int i =0; i< [listOfChannel count]; i++)
        {
            ch = (CamChannel *) [listOfChannel objectAtIndex:i];
            
            if (ch.profile.isInLocal)
            {
                localCameras ++;
            }
        }
        
        if (localCameras > 1)
        {
            
            QuickViewCamera_ViewController * scanCamCtrl;
            scanCamCtrl = [[QuickViewCamera_ViewController alloc] initWithNibName:@"QuickViewCamera_ViewController"
                                                                           bundle:nil];
            scanCamCtrl.listOfChannel = self.listOfChannel;
            
            [self.navigationController pushViewController:scanCamCtrl animated:NO];
            [scanCamCtrl release];
        }
        else
        {
            NSLog(@"Scan disabled with less than 2 cam");
        }
    }
}

-(IBAction)editCameras:(id)sender
{
    //UIBarButtonItem * button = (UIBarButtonItem *) sender;
    
    
    
    if (self.editModeEnabled == FALSE)
    {
        self.editModeEnabled = TRUE;
       // button.title = @"Cancel";
        
    }
    else
    {
        self.editModeEnabled = FALSE;
        //button.title = @"Edit";
    }
    
    
    [self setupTopBarForEditMode:self.editModeEnabled];
    
    //Adjust orientation if needed
    UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
	[self adjustViewsForOrientation:infOrientation];
    
    [cameraList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
}


-(IBAction)refreshCameras :(id)sender
{
    [delegate sendStatus:3];
}


-(IBAction)alertSetting:(id)sender
{
    CamChannel * ch = (CamChannel *) [listOfChannel objectAtIndex:((UIButton *)sender).tag];
    
    
    
    AlertSettingViewController * alertSettings = [[AlertSettingViewController alloc]initWithNibName:@"AlertSettingViewController" bundle:nil];
    alertSettings.camera = ch.profile;
    
    
    [self.navigationController pushViewController:alertSettings animated:NO];
    [alertSettings release];
    
    
    //[self presentModalViewController:alertSettings animated:NO];
    
    
}



-(IBAction)removeCamera:(id)sender
{
    CamChannel * ch = (CamChannel *) [listOfChannel objectAtIndex:((UIButton *)sender).tag];
    
    NSLog(@"Remove camera.. %@",ch.profile.name );
    
    self.edittedChannelIndex = ((UIButton *)sender).tag;
    
    [self  showDialog:ALERT_REMOVE_CAM];
    
}
-(IBAction)renameCamera:(id)sender
{
    NSLog(@"Rename camera.. ");
    
    self.edittedChannelIndex = ((UIButton *)sender).tag;
    [self askForNewName];
    
    
}
#pragma  mark -



- (void) askForNewName
{
    
    UIAlertView * _myAlert = nil;
    
    _myAlert = [[UIAlertView alloc] initWithTitle:@"Change Camera Name"
                                          message:@"Please enter new name for this camera\n\n\n"
                                         delegate:self
                                cancelButtonTitle:@"Cancel"
                                otherButtonTitles:@"Ok",
                nil];
    _myAlert.tag = ALERT_CHANGE_NAME; //used for tracking later
    
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(32.0, 85.0, 220.0, 30.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    myTextField.placeholder = @"New Name";
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.backgroundColor = [UIColor whiteColor];
    myTextField.textColor = [UIColor blackColor];
    myTextField.delegate = self;
    myTextField.tag = 10;
    [myTextField becomeFirstResponder];
    [_myAlert addSubview:myTextField];
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [_myAlert setTransform:myTransform];
    [_myAlert show];
    [_myAlert release];
    
    
}

#pragma mark -
#pragma mark Alertview delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	int tag = alertView.tag ;
	
	if (tag == ALERT_CHANGE_NAME)
	{
		switch(buttonIndex) {
			case 0:
				break;
			case 1:
			{
				NSString * newName = [(UITextField*)[alertView viewWithTag:10] text];
				if( (newName == nil) || [newName length] ==0)
				{
					
					[self showDialog:ALERT_NAME_CANT_BE_EMPTY];
				}
				else {
					[self onCameraNameChanged:newName];
				}
				break;
			}
			default:
				break;
				
		}
	}
	else if (tag == ALERT_NAME_CANT_BE_EMPTY)
	{
		//any button pressed -- dont care -- just launched the alert to ask for name again
		[self askForNewName];
	}
	
	else if (tag == ALERT_REMOVE_CAM_LOCAL)
	{
		if (buttonIndex == 1)
		{
			[self onCameraRemoveLocal];
		}
	}
	else if (tag == ALERT_REMOVE_CAM_REMOTE)
	{
		
		if (buttonIndex == 1)
		{
			[self onCameraRemoveRemote];
		}
		
	}
	
	
}
#pragma mark -

#pragma mark Subfunctions to handle rename/remove - Borrow from menu

- (void) showDialog:(int) dialogType
{
	switch (dialogType) {
            
		case DIALOG_CANT_RENAME:
		{
			NSString * msg =@"Unable to rename this camera. Please log-in and try again";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case ALERT_NAME_CANT_BE_EMPTY:
		{
			NSString * msg =@"Camera name cant be empty, please try again";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg
								  delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			alert.tag = ALERT_NAME_CANT_BE_EMPTY;
			[alert show];
			[alert release];
			break;
		}
		case ALERT_REMOVE_CAM:
		{
            CamChannel * ch = (CamChannel *) [listOfChannel objectAtIndex:self.edittedChannelIndex];
			BOOL deviceInLocal = ch.profile.isInLocal;
            if (deviceInLocal)
            {
                
                NSString * msg =@"Please confirm that you want to remove this camera from your account. This action will also reset the camera to setup mode.";
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:msg
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"OK",nil];
                alert.tag = ALERT_REMOVE_CAM_LOCAL;
                [alert show];
                [alert release];
                
            }
            else
            {
                NSString * msg =@"Please confirm that you want to remove this camera from your account. The camera is not accessible right now, it will not be switched to setup mode. Please refer to FAQ to reset it manually.";
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:msg
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"OK",nil];
                
                alert.tag = ALERT_REMOVE_CAM_REMOTE;
                [alert show];
                [alert release];
            }
            
			
            
			break;
		}
            
		case DIALOG_CANT_ADD_CAM:
		{
			NSString * msg =@"Please remove one camera from the current  list before addding the new one";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
            
		default:
			break;
	}
}

//callback frm alert
- (void) onCameraNameChanged:(NSString*) newName
{
    
    
    CamChannel * ch = (CamChannel *) [listOfChannel objectAtIndex:self.edittedChannelIndex];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * userName = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * userPass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
    
	//Update BMS server with the new name;;
	
	BMS_Communication * bms_comm;
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(changeNameSuccessWithResponse:)
											FailSelector:@selector(changeNameFailedWithError:)
											   ServerErr:@selector(changeNameFailedServerUnreachable)];
	
	[bms_comm BMS_camNameWithUser:userName
                          AndPass:userPass
                          macAddr:ch.profile.mac_address
                          camName:newName];
    
    
    ch.profile.name = newName;
    
}



-(void) changeNameSuccessWithResponse:(NSData *) responsedata
{
    
    
    [cameraList reloadData] ;
    
}
-(void) changeNameFailedWithError:(NSHTTPURLResponse*) error_response
{
    
    [cameraList reloadData] ;
}
-(void) changeNameFailedServerUnreachable
{
    
    [cameraList reloadData] ;
}



-(void) onCameraRemoveLocal
{
	NSString * command , *response;
	
    CamChannel * ch = (CamChannel *) [listOfChannel objectAtIndex:self.edittedChannelIndex];
    
    HttpCommunication * dev_comm = [[HttpCommunication alloc]init];
    dev_comm.device_ip = ch.profile.ip_address;
    dev_comm.device_port = ch.profile.port;
    
	command = SWITCH_TO_DIRECT_MODE;
	response = [dev_comm sendCommandAndBlock:command];
	
    
	
	command = RESTART_HTTP_CMD;
	response = [dev_comm sendCommandAndBlock:command];
    
	
    
    [self onCameraRemoveRemote];
   	
}


-(void) onCameraRemoveRemote
{
    
    CamChannel * ch = (CamChannel *) [listOfChannel objectAtIndex:self.edittedChannelIndex];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * userName = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * userPass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
    
    
    
	BMS_Communication * bms_comm;
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(removeCamSuccessWithResponse:)
											FailSelector:@selector(removeCamFailedWithError:)
											   ServerErr:@selector(removeCamFailedServerUnreachable)];
	
	[bms_comm BMS_delCamWithUser:userName AndPass:userPass macAddr:ch.profile.mac_address];
    
    
}



-(void) removeCamSuccessWithResponse:(NSData *) responsedata
{
	NSLog(@"removeCam success-- fatality");
    
    [self forceRelogin];
	
}
-(void) removeCamFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"removeCam failed errorcode:");
    [self forceRelogin];
}
-(void) removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
    [self forceRelogin];
}

#pragma mark -


@end
