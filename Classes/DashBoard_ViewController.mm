//
//  DashBoard_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/31/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "DashBoard_ViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "H264PlayerViewController.h"
#import "PlaylistInfo.h"
#import "PlaybackViewController.h"
#import "MTStackDefaultContainerView.h"
#import "MTStackViewController.h"
#import "BMMenuViewController.h"
#import "MyFrontViewController.h"
#import "NotificationSettingsViewController.h"
@interface DashBoard_ViewController() <H264PlayerVCDelegate>

@end

@implementation DashBoard_ViewController
@synthesize  cellView;
@synthesize  listOfChannel;
@synthesize  delegate;

@synthesize  tabBarController;

@synthesize  topbar;
@synthesize  editModeEnabled;
@synthesize edittedChannelIndex;
@synthesize  cameraList;


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
-(void)removeSubViewOfNavigationController {
    if (self.topbar != nil)
    {
        [self.topbar removeFromSuperview];
        self.topbar = nil;
        [topbar release];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        // Load resources for iOS 7 or later
        [self.navigationController setNavigationBarHidden:NO];
        for (UIView *subView in self.navigationController.view.subviews)
        {
            if ([subView isKindOfClass:[UIToolbar class]])
            {
                
                [subView removeFromSuperview];
            }
        }
        [self.navigationController.toolbar removeFromSuperview];
    }
}
-(void) setupTopBarForEditMode:(BOOL) isEditMode
{
//    if (topbar != nil)
//    {
//        [topbar removeFromSuperview];
//        [topbar release];
//        
//    }
    
    [self removeSubViewOfNavigationController];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isOffline = [userDefaults boolForKey:_OfflineMode];

   
    int screenWidth = self.view.frame.size.width;
    
    
    
    if (isEditMode == FALSE)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            // Load resources for iOS 7 or later
            //Build ToolBar manually
            self.topbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 20, screenWidth, 44)];
        } else {
            // Load resources for iOS 6.1 or earlier
            //Build ToolBar manually
            self.topbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
            self.topbar.barStyle = UIBarStyleBlackOpaque;
        }
        
        [self.topbar setAutoresizingMask: UIViewAutoresizingFlexibleWidth|
                                      UIViewAutoresizingFlexibleLeftMargin|
                                      UIViewAutoresizingFlexibleRightMargin ];
        
        
        // create an array for the buttons
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
        
        
        if (isOffline == TRUE)
        {

        }
        else
        {
            
            if ([self shouldShowEditButton])
            {
                
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Edit_",nil, [NSBundle mainBundle],
                                                                     @"Edit", nil);
                
                UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                               initWithTitle:msg
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
        
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Cameras_",nil, [NSBundle mainBundle],
                                                           @"Cameras", nil);
        
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
        [self.topbar setItems:buttons animated:NO];
        [buttons release];
        
        
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self.navigationController.view addSubview:self.topbar];
        } else {
            [self.view addSubview:topbar];
        }
    }
    else //isEditMode = TRUE
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            // Load resources for iOS 7 or later
            //Build ToolBar manually
            topbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 20, screenWidth, 44)];
        } else {
            // Load resources for iOS 6.1 or earlier
            //Build ToolBar manually
            topbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
            topbar.barStyle = UIBarStyleBlackOpaque;
        }

        [topbar setAutoresizingMask: UIViewAutoresizingFlexibleWidth|
                                      UIViewAutoresizingFlexibleLeftMargin|
                                      UIViewAutoresizingFlexibleRightMargin];
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
                
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Cancel_",nil, [NSBundle mainBundle],
                                                                   @"Cancel", nil);

                UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                               initWithTitle:msg
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
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Cameras_",nil, [NSBundle mainBundle],
                                                           @"Cameras", nil);

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
        
              
        // put the buttons in the toolbar and release them
        [topbar setItems:buttons animated:NO];
        [buttons release];
        
        
        [topbar setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleWidth)];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self.navigationController.view addSubview:topbar];
        } else {
            [self.view addSubview:topbar];
        }
        
    }

    
    
    //adjust for offline mode
    if( offlineView != nil && offlineView.isHidden == NO)
    {
        
        offlineView.frame = CGRectMake(0, cameraList.frame.origin.y + cameraList.frame.size.height,
                                       offlineView.frame.size.width,
                                       offlineView.frame.size.height);
    }
    

    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[[GAI sharedInstance] defaultTracker] sendView:@"DashBoard_ViewController"];
//    self.trackedViewName = @"DasBoard_ViewController";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self.navigationController setNavigationBarHidden:NO];
    } else {
        [self.navigationController setNavigationBarHidden:YES];
    }
    [self setupTopBarForEditMode:self.editModeEnabled];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isOffline = [userDefaults boolForKey:_OfflineMode];

    if (isOffline == YES)
    {
        NSLog(@"OFFLINE OFFLINE OFFLINE");
        
        int delta_h =  offlineView.frame.size.height;
        
//        self.tabBarController.tabBar.hidden = YES;
//        
//        if (self.tabBarController.tabBar.hidden == NO)
//        {
//            delta_h += self.tabBarController.tabBar.frame.size.height;
//        }
        
        int newHeight = (cameraList.frame.size.height-delta_h) ;
        
        
        //Adjust table size
        cameraList.frame = CGRectMake(cameraList.frame.origin.x, cameraList.frame.origin.y,
                                      cameraList.frame.size.width,
                                      newHeight);
        
        
        
        
        offlineView.frame = CGRectMake(offlineView.frame.origin.x,
                                       /*cameraList.frame.origin.y + cameraList.frame.size.height,*/
                                       1000,//obscure place
                                       offlineView.frame.size.width, offlineView.frame.size.height);
        
        
        //UIScrollView * scrollView =  (UIScrollView*) [offlineView viewWithTag:1];
        //UIScrollView * scrollView =  (UIScrollView*) [offlineView.subviews objectAtIndex:0];
        
        UIView * scrollView =  [offlineView.subviews objectAtIndex:0];

        
        if (scrollView != nil && [scrollView isKindOfClass:[UIScrollView class]] )
        {
            UIScrollView* scrollView_ = (UIScrollView*) scrollView;
            [scrollView_ setContentSize:CGSizeMake(offlineView.frame.size.width,200)];
        }

        
        offlineView.hidden = NO;
        //add a subview in layout.
        [self.view addSubview:offlineView];
        
        
        
        
    }
    else
    {
        offlineView.hidden = YES;

        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
                       
           // Dont resize the table for IPAD .. unless someone is complaining...
        }
        else
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7)
            {
                cameraList.frame = CGRectMake(cameraList.frame.origin.x, cameraList.frame.origin.y + 64,
                                              cameraList.frame.size.width,
                                              387);
            }
            else
            {
                cameraList.frame = CGRectMake(cameraList.frame.origin.x, cameraList.frame.origin.y,
                                          cameraList.frame.size.width,
                                          387);
            }
        }

       
        
        
        
        if (![self shouldShowEditButton])
        {
            cameraList.hidden = YES;
//            emptyCameraListView.frame = CGRectMake(emptyCameraListView.frame.origin.x,
//                                                   emptyCameraListView.frame.origin.y+100,
//                                                   emptyCameraListView.frame.size.width,
//                                                   emptyCameraListView.frame.size.height);
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
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


-(void)viewWillAppear:(BOOL)animated
{
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;

	[self adjustViewsForOrientation:infOrientation];
}

-(BOOL) shouldAutorotate
{

        return YES ;
    
}

-(NSUInteger)supportedInterfaceOrientations
{


    return UIInterfaceOrientationMaskAllButUpsideDown;
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    if( offlineView != nil && offlineView.isHidden == NO)
    {
        
        offlineView.frame = CGRectMake(0,  cameraList.frame.origin.y + cameraList.frame.size.height,
                                       offlineView.frame.size.width, offlineView.frame.size.height);
    }

    
    
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    

    [self adjustViewsForOrientation:toInterfaceOrientation];
    
}


-(void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        
        if (emptyCameraListView != nil)
        {
            NSInteger offsetX = (screenHeight - emptyCameraListView.frame.size.width) / 2;
            emptyCameraListView.frame = CGRectMake(offsetX,
                                                   60,
                                                   emptyCameraListView.frame.size.width,
                                                   emptyCameraListView.frame.size.height);
        }
        [cameraList reloadData];
        
                
        
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{

        
        if (emptyCameraListView != nil)
        {
            emptyCameraListView.frame = CGRectMake(0,
                                                   100,
                                                   emptyCameraListView.frame.size.width,
                                                   emptyCameraListView.frame.size.height);
        }
        
        [cameraList reloadData];
        
       
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

        // Use Subclass
        
        EditCameraCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            [[NSBundle mainBundle] loadNibNamed:@"DashBoard_camEdit" owner:self options:nil];
            cell = (EditCameraCell *)self.cellView;
            self.cellView = nil;
        }
        //set transparent for cell in iOS7
        cell.backgroundColor = [UIColor clearColor];

        
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
        
        [camName setNumberOfLines:2];
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
        
        // NSLog(@"cell index : %d ", indexPath.row);
        cell.cameraIndex  = indexPath.row;
        cell.vc = self; 
        
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
        
        //set transparent for cell in iOS7
        cell.backgroundColor = [UIColor clearColor];
        
        //Get refernce to cell content
        UIImageView * snapshot = (UIImageView *) [cell viewWithTag:500];
        UILabel * camName  = (UILabel *) [cell viewWithTag:501];
        UILabel * camLoc  = (UILabel *) [cell viewWithTag:502];
        UIImageView * camStatusInd = (UIImageView *) [cell viewWithTag:503];
        UILabel * camStatus = (UILabel *) [cell viewWithTag:504];
        
        
        UIImageView * soundAlert = (UIImageView *) [cell viewWithTag:508];
        UIImageView * tempAlert = (UIImageView *) [cell viewWithTag:509];
        UIActivityIndicatorView * spinner = (UIActivityIndicatorView *) [cell viewWithTag:510];
        
        soundAlert.hidden = YES;
        tempAlert.hidden = YES;
        
        
        
        
        // Set up the cell...
        CamChannel * ch = (CamChannel*)[listOfChannel objectAtIndex:indexPath.row] ;
        CamProfile * cp = ch.profile;
        
        // Set frame for camName
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationPortrait && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGRect frame = CGRectMake(camName.frame.origin.x, camName.frame.origin.y, 195, 48);
            [camName setFrame:frame];
            
            [camName setNumberOfLines:2];
        }
        else
        {
            CGRect frame = CGRectMake(camName.frame.origin.x, camName.frame.origin.y, 350, 48);
            [camName setFrame:frame];
        }
        
        //NSLog(@"cell: %d %d", indexPath.row , cp.minuteSinceLastComm);
        if (cp.hasUpdateLocalStatus == TRUE && !ch.waitingForStreamerToClose)
        {
            [spinner stopAnimating]; 
            spinner.hidden = YES;

            
            camStatusInd.hidden = NO;
            camStatus.hidden  = NO;
            camLoc.hidden = NO;

            
            if (ch != nil)
            {
                
                //Set camera name
                [camName setText:cp.name];
#if 0 //
                NSArray * alerts  = [ CameraAlert getAllAlertForCamera:cp.mac_address];
                CameraAlert * camAlert;
                if (alerts != nil)
                {
                    
                    //NSLog(@"alerts count: %d for cam: %@",[alerts count], cp.mac_address);
                    
                    for (int i =0; i <[alerts count]; i++)
                    {
                        camAlert = (CameraAlert *) [alerts objectAtIndex:i];
                        if ( [camAlert.alertType isEqualToString:ALERT_TYPE_SOUND]   &&
                            (soundAlert.hidden == YES) )
                        {
                            //NSLog(@"Set sound indicator for cam: %@", cp.mac_address);
                            soundAlert.hidden = NO;
                        }
                        else if ( ([camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_HI]  ||
                                   [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_LO] )   &&
                                 (tempAlert.hidden == YES) )
                        {
                            //NSLog(@"Set temp indicator for cam: %@", cp.mac_address);
                            tempAlert.hidden = NO;
                        }
                        
                    }
                }
#endif
                
                NSString * msg = nil;
                
                //set camera info
                if (cp.isInLocal == TRUE)
                {
                    //20121023: phung: ui review comments.
                    //[camStatusInd setImage:[UIImage imageNamed:@"camera_online.png"]];
                    //[camStatus setText:@"Available"];
                    camStatusInd.hidden = YES;
                    camStatus.hidden  = YES;
                    
                    
                    msg = NSLocalizedStringWithDefaultValue(@"Local_Wifi",nil, [NSBundle mainBundle],
                                                            @"Local Wifi", nil);
                    [camLoc setText:msg];
                    
                }
                else if (cp.minuteSinceLastComm <=10 )
                {
                    //20121023: phung: ui review comments.
                    //[camStatusInd setImage:[UIImage imageNamed:@"camera_online.png"]];
                    //[camStatus setText:@"Camera is not in local network"];
                    camStatusInd.hidden = YES;
                    camStatus.hidden  = YES;
                    
                    msg = NSLocalizedStringWithDefaultValue(@"Remote_Camera",nil, [NSBundle mainBundle],
                                                            @"Remote Camera", nil);
                    
                    
                    [camLoc setText:msg];
                }
                else
                {
                    [camStatusInd setImage:[UIImage imageNamed:@"camera_offline.png"]];
                    camStatusInd.hidden = NO;
                    msg = NSLocalizedStringWithDefaultValue(@"Remote_Camera",nil, [NSBundle mainBundle],
                                                            @"Remote Camera", nil);
                    
                    
                    [camLoc setText:msg];
                    msg = NSLocalizedStringWithDefaultValue(@"Not_Available",nil, [NSBundle mainBundle],
                                                            @"Not Available", nil);
                    
                    
                    [camStatus setText:msg];
                }
                
                
              
                
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
        }
        else
        {
            //spinning..
            //Set camera name
            [camName setText:cp.name];

            
            camStatusInd.hidden = YES;
            camStatus.hidden  = YES;
            camLoc.hidden = YES;
            
            spinner.hidden = NO;
            
             [spinner startAnimating];
        }
        
        return cell;
        
    } 
}

- (void)stopStreamFinished: (CamChannel *)camChannel
{
    for (CamChannel *obj in self.listOfChannel)
    {
        if ([obj.profile.mac_address isEqualToString:camChannel.profile.mac_address])
        {
            obj.waitingForStreamerToClose = NO;
        }
        else
        {
            NSLog(@"%@ ->waitingForClose: %d", obj.profile.name, obj.waitingForStreamerToClose);
        }
    }
    
    [self.cameraList reloadData];
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
    if (self.editModeEnabled == TRUE)
    {
        return; // don't start streaming in Edit mode
    }
    else
    {
        [self removeSubViewOfNavigationController];
    }
    
    CamChannel *ch = (CamChannel*)[listOfChannel objectAtIndex:indexPath.row] ;
    
    NSLog(@"ch = %@, ch.profile = %@, ch.profile.minuteSinceLastComm = %d", ch, ch.profile, ch.profile.minuteSinceLastComm);
    
    if (ch != nil &&
        ch.profile != nil &&
        ch.waitingForStreamerToClose == NO &&
        ch.profile.hasUpdateLocalStatus == YES)
    {
        [CameraAlert clearAllAlertForCamera:ch.profile.mac_address];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:ch.profile.mac_address forKey:CAM_IN_VEW];
        [userDefaults synchronize];
        
        H264PlayerViewController *h264PlayerViewController = [[H264PlayerViewController alloc] init];
        h264PlayerViewController.selectedChannel = ch;
        h264PlayerViewController.h264PlayerVCDelegate = self;
        [self.navigationController pushViewController:h264PlayerViewController animated:YES];
        [h264PlayerViewController release];
    }

//Slide menu

//    if (ch != nil && ch.profile != nil)
//    {
//        MTStackViewController *stackViewController = [[MTStackViewController alloc] init];
//        stackViewController.animationDurationProportionalToPosition = YES;
//        
//        //MTMenuViewController *menuViewController = [[MTMenuViewController alloc] init];
//        BMMenuViewController *menuViewController = [[BMMenuViewController alloc] init];
//        CGRect foldFrame = CGRectMake(0, 0, stackViewController.slideOffset, CGRectGetHeight(self.view.bounds));
//        menuViewController.view.frame = foldFrame;
//        
//        //stackViewController.leftContainerView = [[MTZoomContainerView alloc] initWithFrame:foldFrame];
//        stackViewController.leftViewController = menuViewController;
//        
//        
//        H264PlayerViewController *h264ViewController = [[H264PlayerViewController alloc] init];
//        h264ViewController.selectedChannel = ch;
//
//        stackViewController.rightViewController = h264ViewController;
//        stackViewController.rightViewControllerEnabled = YES;
//        
//        menuViewController.firstViewController = h264ViewController;
//        
//        UINavigationController *contentNavigationController = [UINavigationController new];
//        //UINavigationController *contenNavigationController = self.navigationController;
//       stackViewController.contentViewController = contentNavigationController;
//        //stackViewController.contentContainerView = (UINavigationController *)self.navigationController;
//        
//        [self presentViewController:stackViewController animated:NO completion:nil];
//       
//    }
}

- (void)reportClosedStatusWithSelectedChannel:(CamChannel *)selectedChannel
{
    for (CamChannel *ch in listOfChannel)
    {
        if ([ch.profile.mac_address isEqualToString:selectedChannel.profile.mac_address])
        {
            ch.waitingForStreamerToClose = NO;
        }
        else
        {
            NSLog(@"Camera %@ waitingForStreamerToClose = %d", ch.profile.name, ch.waitingForStreamerToClose);
        }
    }
    [self.cameraList reloadData];
}

#pragma mark -



- (void)presentModallyOn:(UIViewController *)parent
{
    MBPNavController *    navController;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
   
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Cameras_",nil, [NSBundle mainBundle],
                                                       @"Cameras", nil);
    
    UITabBarItem * camList  = [[UITabBarItem alloc]initWithTitle:msg
                                                           image:[UIImage imageNamed:@"bb_camera_slider_icon.png"]
                                                             tag:1];
    [self setTabBarItem:camList];
    
    [camList release];
    
    NSString * msgAccount = NSLocalizedStringWithDefaultValue(@"Account_",nil, [NSBundle mainBundle],
                                            @"Account", nil);
    
    UITabBarItem * account  = [[UITabBarItem alloc]initWithTitle:msgAccount
                                                           image:[UIImage imageNamed:@"account_icon.png"]
                                                             tag:2];
    
    Account_ViewController * accountPage = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        accountPage = [[Account_ViewController alloc]
                       initWithNibName:@"Account_ViewController_ipad" bundle:nil];
    }
    else
    {
        
        accountPage = [[Account_ViewController alloc]
                       initWithNibName:@"Account_ViewController" bundle:nil];
    
    }
    
    [accountPage setTabBarItem:account];
    [account release];
    
    accountPage.mdelegate = self.delegate;
    
    NSArray * views = [[NSArray alloc]initWithObjects:self, accountPage, nil];
    if (isOffline == TRUE)
    {
        [views release];
        views = [[NSArray alloc]initWithObjects:self,  nil];
    }
    
    
    tabBarController = [[UITabBarController alloc]init];
    [tabBarController setViewControllers:views];
    
    [views release];
    
    //setup nav controller
    navController= [[[MBPNavController alloc]initWithRootViewController:tabBarController] autorelease];
    
    // Create a navigation controller with us as its root.
    assert(navController != nil);
    
    
//    [navController setNavigationBarHidden:YES];
//    [self setupTopBarForEditMode:self.editModeEnabled];
    
    // Set up the Cancel button on the left of the navigation bar.
    self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
    assert(self.navigationItem.leftBarButtonItem != nil);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone   target:self action:@selector(doneAction:)] autorelease];
    assert(self.navigationItem.rightBarButtonItem != nil);
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [navController.navigationBar setBarStyle:UIBarStyleDefault];
    } else {
        [navController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    }
    
    
    // Present the navigation controller on the specified parent
    // view controller.
    
    //[parent presentModalViewController:navController animated:NO];
    [parent presentViewController:navController animated:NO completion:^{}];
}





#pragma  mark -
#pragma mark ACTIONS ..


-(void) forceRelogin
{
    [delegate sendStatus:AFTER_DEL_RELOGIN];
}

-(IBAction)addCamera:(id)sender
{
    
    if ([listOfChannel count] < MAX_CAM_ALLOWED)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
        [userDefaults synchronize];
        
        [delegate sendStatus:SETUP_CAMERA];//initial setup
        
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
    //[delegate sendStatus:3];
    //Need to relogin so as to update remote camera status
    [self forceRelogin];
}

-(IBAction)alertSetting:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults objectForKey:@"APP_ID"] == nil)
    {
        [[[[UIAlertView alloc] initWithTitle:@"Settings Error"
                                   message:@"App don't register notification"
                                  delegate:self
                         cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil] autorelease] show];
        return;
    }
    
    CamChannel *ch = (CamChannel *) [listOfChannel objectAtIndex:((UIButton *)sender).tag];
    
    NotificationSettingsViewController *notifSettingsVC = [[NotificationSettingsViewController alloc] init];
    notifSettingsVC.camProfile = ch.profile;
    
    [self.navigationController pushViewController:notifSettingsVC animated:YES];
    [notifSettingsVC release];
}

-(IBAction)removeCamera:(id)sender
{
    //CamChannel * ch = (CamChannel *) [listOfChannel objectAtIndex:((UIButton *)sender).tag];
    
    //NSLog(@"Remove camera.. %@",ch.profile.name );
    
    self.edittedChannelIndex = ((UIButton *)sender).tag;
    
   

    
    [self  showDialog:ALERT_REMOVE_CAM];
    
}
-(IBAction)renameCamera:(id)sender
{
    self.edittedChannelIndex = ((UIButton *)sender).tag;
    [self askForNewName];
}


#pragma  mark -



- (void) askForNewName
{

       
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Change_Camera_Name",nil, [NSBundle mainBundle],
                                                       @"Change Camera Name", nil);
    NSString * msg2 = NSLocalizedStringWithDefaultValue(@"enter_new_camera_name",nil, [NSBundle mainBundle],
                                            @"Enter new camera name", nil);
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                        @"Cancel", nil);

    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                        @"Ok", nil);

   // NSString * newName = NSLocalizedStringWithDefaultValue(@"New_Name",nil, [NSBundle mainBundle],
  //                                                    @"New Name", nil);
#if 0
    UIAlertView * _myAlert = nil;

    _myAlert = [[UIAlertView alloc] initWithTitle:msg
                                          message:msg2 
                                         delegate:self
                                cancelButtonTitle:cancel
                                otherButtonTitles:ok,
                nil];
    _myAlert.tag = ALERT_CHANGE_NAME; //used for tracking later
    
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(32.0, 85.0, 220.0, 30.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    myTextField.placeholder = newName;
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.backgroundColor = [UIColor whiteColor];
    myTextField.textColor = [UIColor blackColor];
    myTextField.delegate = self;
    myTextField.tag = 10;
    [myTextField becomeFirstResponder];
    
    [_myAlert addSubview:myTextField];
  
  
    [_myAlert show];
    [_myAlert release];
    
#else
    
    AlertPrompt *prompt = [AlertPrompt alloc];
    prompt = [prompt initWithTitle:msg
                           message:msg2
                      promptholder:msg2
                          delegate:self
                 cancelButtonTitle:cancel
                     okButtonTitle:ok];
    prompt.tag = ALERT_CHANGE_NAME;
    [prompt show];
    [prompt release];
#endif
}


-(BOOL) isCameraNameValidated:(NSString *) cameraNames
{
    
    NSString * validString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890. '_-";
    
    
    
    for (int i = 0; i < cameraNames.length; i ++)
    {
        NSRange range = [validString rangeOfString:[NSString stringWithFormat:@"%c",[cameraNames characterAtIndex:i]]];
        if (range.location == NSNotFound) {
            return NO;
        }
    }
    
    
    return YES;
    
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
                NSString *newName = [(AlertPrompt *)alertView enteredText];
                
				if( (newName == nil) || [newName length] ==0)
				{
					
					[self showDialog:ALERT_NAME_CANT_BE_EMPTY];
				}
                else if (newName.length < 3 || newName.length > 15)
                {
                    NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                                         @"Invalid Camera Name", nil);
                    
                    NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg", nil, [NSBundle mainBundle],
                                                                       @"Camera Name has to be between 3-15 characters", nil);
                    
                    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                                      @"Ok", nil);
                    
                    
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                                     message:msg
                                                                    delegate:self
                                                           cancelButtonTitle:ok
                                                           otherButtonTitles:nil];
                    
                    [alert show];
                    [alert release];
                }
                else if (![self isCameraNameValidated:newName])
                {
                    NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                                         @"Invalid Camera Name", nil);
                    
                    NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg2", nil, [NSBundle mainBundle],
                                                                       @"Camera name is invalid. Please enter [0-9],[a-Z], space, dot, hyphen, underscore & single quote only.", nil);
                    
                    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                                      @"Ok", nil);
                    
                    
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                                     message:msg
                                                                    delegate:self
                                                           cancelButtonTitle:ok
                                                           otherButtonTitles:nil];
                    
                    [alert show];
                    [alert release];
                    
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
//    else if (tag == ALERT_INVALID_CAMERA_NAME)
//    {
//    
//    }
	
	
}
#pragma mark -

#pragma mark Subfunctions to handle rename/remove - Borrow from menu

- (void) showDialog:(int) dialogType
{
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);

	switch (dialogType) {
            
		case DIALOG_CANT_RENAME:
		{
            
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Unable_to_rename_this_camera",nil, [NSBundle mainBundle],
                                                                @"Unable to rename this camera. Please log-in and try again", nil);

          

            
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg
								  delegate:nil
								  cancelButtonTitle:ok
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case ALERT_NAME_CANT_BE_EMPTY:
		{
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Camera_name_cant_be_empty",nil, [NSBundle mainBundle],
                                                               @"Camera name cant be empty, please try again", nil);

			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg
								  delegate:self
								  cancelButtonTitle:ok
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
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Confirm_remove_cam_local",nil, [NSBundle mainBundle],
                                                                   @"Please confirm that you want to remove this camera from your account. This action will also reset the camera to setup mode.", nil);
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:msg
                                      delegate:self
                                      cancelButtonTitle:cancel
                                      otherButtonTitles:ok,nil];
                alert.tag = ALERT_REMOVE_CAM_LOCAL;
                [alert show];
                [alert release];
                
            }
            else
            {
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Confirm_remove_cam_remote",nil, [NSBundle mainBundle],
                                                                   @"Please confirm that you want to remove this camera from your account. The camera is not accessible right now, it will not be switched to setup mode. Please refer to FAQ to reset it manually.", nil);
                

                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:msg
                                      delegate:self
                                      cancelButtonTitle:cancel
                                      otherButtonTitles:ok,nil];
                
                alert.tag = ALERT_REMOVE_CAM_REMOTE;
                [alert show];
                [alert release];
            }
            
			
            
			break;
		}
            
		case DIALOG_CANT_ADD_CAM:
		{
            NSString * msg = NSLocalizedStringWithDefaultValue(@"remove_one_cam",nil, [NSBundle mainBundle],
                                                              @"Please remove one camera from the current  list before addding the new one", nil);            

			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg
								  delegate:nil
								  cancelButtonTitle:ok
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

- (void) onCameraNameChanged:(NSString *) newName
{
    
    
    CamChannel * ch = (CamChannel *) [listOfChannel objectAtIndex:self.edittedChannelIndex];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
	
	//Update BMS_JSON server with the new name;
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(changeNameSuccessWithResponse:)
                                                                         FailSelector:@selector(changeNameFailedWithError:)
                                                                            ServerErr:@selector(changeNameFailedServerUnreachable)] autorelease];
    NSString *mac = [Util strip_colon_fr_mac:ch.profile.mac_address];
    [jsonComm updateDeviceBasicInfoWithRegistrationId:mac
                                              andName:newName
                                       andAccessToken:apiKey
                                            andApiKey:apiKey];
    
    ch.profile.name = newName;
    
    progressView.hidden  = NO;
    [self.view addSubview:progressView];
    [self.view bringSubviewToFront:progressView];
    
}

-(void) changeNameSuccessWithResponse:(NSDictionary *) responseData
{
    [cameraList reloadData] ;
    
    //TODO: save to offline data
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userName = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString *userPass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString *userApiKey = (NSString *)[userDefaults objectForKey:@"PortalApiKey"];
    
	UserAccount * account = [[UserAccount alloc] initWithUser:userName
                                                      andPass:userPass
                                                    andApiKey:userApiKey
                                                  andListener:nil];
    //RE- READ data from server and update offline record
    [account readCameraListAndUpdate];
    [account release];
    
    progressView.hidden  = YES;
}
-(void) changeNameFailedWithError:(NSDictionary *)errorResponse
{
    [cameraList reloadData] ;
}

-(void) changeNameFailedServerUnreachable
{
    
    [cameraList reloadData] ;
}

-(void) onCameraRemoveLocal
{
    CamChannel *ch = (CamChannel *) [listOfChannel objectAtIndex:self.edittedChannelIndex];
    
    HttpCommunication * dev_comm = [[[HttpCommunication alloc]init] autorelease];
    dev_comm.device_ip = ch.profile.ip_address;
    dev_comm.device_port = ch.profile.port;
    
	NSString * command = SWITCH_TO_DIRECT_MODE;
	[dev_comm sendCommandAndBlock:command];
	
	command = RESTART_HTTP_CMD;
	[dev_comm sendCommandAndBlock:command];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(removeCamSuccessWithResponse:)
                                                                         FailSelector:@selector(removeCamFailedWithError:)
                                                                            ServerErr:@selector(removeCamFailedServerUnreachable)] autorelease];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mac = [Util strip_colon_fr_mac:ch.profile.mac_address];
    NSLog(@"mac_address = %@", mac);
    [jsonComm deleteDeviceWithRegistrationId:mac andApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
}

-(void) onCameraRemoveRemote
{
    CamChannel * ch = (CamChannel *) [listOfChannel objectAtIndex:self.edittedChannelIndex];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(removeCamSuccessWithResponse:)
                                                                         FailSelector:@selector(removeCamFailedWithError:)
                                                                            ServerErr:@selector(removeCamFailedServerUnreachable)] autorelease];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mac = [Util strip_colon_fr_mac:ch.profile.mac_address];
    NSLog(@"mac_address = %@", mac);
    
    [jsonComm deleteDeviceWithRegistrationId:mac andApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
}

- (void) removeCamSuccessWithResponse:(NSDictionary *)responseData
{
	NSLog(@"removeCam success-- fatality");
    
    [self forceRelogin];
	
}

- (void) removeCamFailedWithError:(NSDictionary *)errorResponse
{
	NSLog(@"removeCam failed errorcode:");
    [self forceRelogin];
}

-(void) removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
    [self forceRelogin];
}

@end
