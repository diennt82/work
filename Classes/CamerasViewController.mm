//
//  CamerasViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define MAX_CAM_ALLOWED 4
#define CAMERA_TAG_66 566
#define CAMERA_TAG_83 583 //83/ 836

#import "CamerasViewController.h"
#import <CameraScanner/CameraScanner.h>
#import "CamerasCell.h"
#import "H264PlayerViewController.h"
#import "CameraAlert.h"
#import "MenuViewController.h"
#import "CameraMenuViewController.h"
#import "AddCameraViewController.h"

@interface CamerasViewController () <H264PlayerVCDelegate, CamerasCellDelegate, UIAlertViewDelegate, AddCameraVCDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell *addCameraCell;

@property (retain, nonatomic) NSArray *snapshotImages;
@property (nonatomic) BOOL isFirttime;

@end

@implementation CamerasViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Cameras";
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
           delegate:(id<ConnectionMethodDelegate> )delegate
           parentVC: (id)parentVC
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Cameras";
        self.parentVC = (MenuViewController *)parentVC;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBarHidden = YES;
#if 0
    //create the image for your button, and set the frame for its size
    UIImage *image = [UIImage imageNamed:@"Hubble_logo_back"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(cameraBackAction:) forControlEvents:UIControlEventTouchDown];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //then set it.  phew.
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    [barButtonItem release];
#endif
    self.snapshotImages = [NSArray arrayWithObjects:@"mountain", @"garden", @"desk", @"bridge", nil];
    
    UIButton *addBtn = (UIButton *)[_addCameraCell viewWithTag:595];
    [addBtn setImage:[UIImage imageNamed:@"add_camera"] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"add_camera_pressed"] forState:UIControlEventTouchDown];
}

- (void)viewWillAppear:(BOOL)animated
{
    //self.view.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height);
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Dismiss alertView in case interrupt : lock key, home key, phone call
    
    [super viewWillDisappear:animated];
}

#pragma mark - Actions

- (IBAction)addCameraButtonTouchAction:(id)sender
{
    if (_camChannels.count > MAX_CAM_ALLOWED)
    {
        [self cameraShowDialog:DIALOG_CANT_ADD_CAM];
    }
    else
    {
        MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
        tabBarController.notUpdateCameras = TRUE;
        
        AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] init];
        addCameraVC.delegate = self;
        
        [self presentViewController:addCameraVC animated:YES completion:^{}];
    }
}

#pragma mark - Cameras Cell Delegate

- (void)sendTouchSettingsActionWithRowIndex:(NSInteger)rowIdx
{
#if 1
    CameraMenuViewController *cameraMenuCV = [[CameraMenuViewController alloc] init];
    cameraMenuCV.camChannel = (CamChannel *)[self.camChannels objectAtIndex:rowIdx];
    
    MenuViewController *menuVC = (MenuViewController *)self.parentVC;
    
    cameraMenuCV.cameraMenuDelegate = menuVC.menuDelegate;
    menuVC.navigationItem.title = @"Menu";
    [menuVC.navigationController pushViewController:cameraMenuCV animated:YES];
    
    [cameraMenuCV release];
#else
    MenuCameraViewController *menuCamersVC = [[MenuCameraViewController alloc] init];
    menuCamersVC.camChannel = (CamChannel *)[self.camChannels objectAtIndex:rowIdx];
    
    menuCamersVC.menuCamerasDelegate = ((MenuViewController *)self.parentVC).menuDelegate;
    
    [((MenuViewController *)self.parentVC).navigationController pushViewController:menuCamersVC animated:YES];
    
    [menuCamersVC release];
#endif
}

#pragma mark - Add camera vc delegate

- (void)sendActionCommand:(BOOL)flag
{
    MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
    tabBarController.notUpdateCameras = FALSE;
    
    if (flag)
    {
        [tabBarController dismissViewControllerAnimated:NO completion:^{
            [tabBarController.menuDelegate sendStatus:SETUP_CAMERA]; //initial setup
        }];
    }
}

#pragma mark - Methods

- (void)camerasReloadData
{
    [self.tableView reloadData];
}

- (void) cameraShowDialog:(int) dialogType
{
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
	switch (dialogType)
    {
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

#pragma mark - PlayerView Delegate

- (void)stopStreamFinished:(CamChannel *)camChannel
{
    for (CamChannel *obj in self.camChannels)
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
    
    [self.tableView reloadData];
}

#pragma mark - Methods

- (void)cameraBackAction:(id)sender
{
    if (self.camChannels != nil &&
        self.camChannels.count > 0)
    {
        CamChannel *ch = (CamChannel *)[self.camChannels objectAtIndex:0];
        
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
        
        [((MenuViewController *)self.parentVC).navigationController pushViewController:h264PlayerViewController animated:YES];
        [h264PlayerViewController release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if (_waitingForUpdateData == TRUE)
    {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if(section == 1)
    {
        return self.camChannels.count;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return 190;
    }
    
    return 40; // your dynamic height...
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (_waitingForUpdateData == TRUE)
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            // Configure the cell...
            cell.textLabel.text = @"Loading...";
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            // Spacer is a 1x1 transparent png
            UIImage *spacer = [UIImage imageNamed:@"spacer"];
            
            UIGraphicsBeginImageContext(spinner.frame.size);
            
            [spacer drawInRect:CGRectMake(0, 0, spinner.frame.size.width, spinner.frame.size.height)];
            UIImage* resizedSpacer = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            cell.imageView.image = resizedSpacer;
            [cell.imageView addSubview:spinner];
            [spinner startAnimating];
            
            return cell;
        }
        else
        {
            return _addCameraCell;
        }
    }
    else
    {
        static NSString *CellIdentifier = @"CamerasCell";
        CamerasCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CamerasCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (CamerasCell *)curObj;
                break;
            }
        }
        
        cell.camerasCellDelegate = self;
        cell.rowIndex = indexPath.row;
        cell.backgroundColor = [UIColor blackColor];
        cell.snapshotImage.image = [UIImage imageNamed:[_snapshotImages objectAtIndex:indexPath.row]];
        
        CamChannel *ch = (CamChannel *)[_camChannels objectAtIndex:indexPath.row];
        cell.cameraNameLabel.text = ch.profile.name;
        
        // Camera is NOT available
        if ([ch.profile isNotAvailable])
        {
            cell.cameraNameLabel.textColor = [UIColor redColor];
        }
        else
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *regID = [userDefaults stringForKey:@"REG_ID"];
            
            if ([ch.profile.registrationID isEqualToString:regID])
            {
                cell.cameraNameLabel.textColor = [UIColor greenColor];
            }
            else
            {
                cell.cameraNameLabel.textColor = [UIColor whiteColor];
            }
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 &&
        tableView.numberOfSections == 1)
    {
        return NO;
    }
    
    return YES;
}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0)
    {
        [self addCameraButtonTouchAction:nil];
    }
    else
    {
        CamChannel *ch = (CamChannel *)[_camChannels objectAtIndex:indexPath.row];
        
        if ([ch.profile isNotAvailable] &&
            [ch.profile isSharedCam])
        {
            return;
        }
        
        ch.profile.isSelected = TRUE;
        
        [CameraAlert clearAllAlertForCamera:ch.profile.mac_address];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:ch.profile.registrationID forKey:@"REG_ID"];
        [userDefaults setObject:ch.profile.mac_address forKey:CAM_IN_VEW];
        [userDefaults synchronize];
        
        H264PlayerViewController *h264PlayerViewController = [[H264PlayerViewController alloc] init];
        
        h264PlayerViewController.selectedChannel = ch;
        h264PlayerViewController.h264PlayerVCDelegate = self;
        
        //MenuViewController *tabBarController = (MenuViewController *)self.parentViewController;
        [((MenuViewController *)self.parentVC).navigationController pushViewController:h264PlayerViewController animated:YES];
        [h264PlayerViewController release];
    }
}

- (void)dealloc {
    [_camChannels release];
    [_addCameraCell release];
    [super dealloc];
}
@end
