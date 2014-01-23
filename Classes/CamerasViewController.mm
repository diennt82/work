//
//  CamerasViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define MAX_CAM_ALLOWED 4

#import "CamerasViewController.h"
#import <CameraScanner/CameraScanner.h>
#import "CamerasCell.h"
#import "H264PlayerViewController.h"
#import "CameraAlert.h"
#import "MenuCameraViewController.h"

@interface CamerasViewController () <H264PlayerVCDelegate, CamerasCellDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell *addCameraCell;

@property (retain, nonatomic) NSArray *snapshotImages;
@property (retain, nonatomic) UIAlertView *alertChooseConfig;
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
        self.camerasDelegate = delegate;
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
    
    //create the image for your button, and set the frame for its size
    UIImage *image = [UIImage imageNamed:@"Hubble_logo_back.png"];
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
    if (_alertChooseConfig)
    {
        [_alertChooseConfig dismissWithClickedButtonIndex:0 animated:NO];
        [_alertChooseConfig release];
        _alertChooseConfig = nil;
    }
    
    [super viewWillDisappear:animated];
}

- (void)showDialogChooseConfigCamera
{
    NSString *selectPlease = NSLocalizedStringWithDefaultValue(@"please_select",nil, [NSBundle mainBundle],
                                                                                           @"Please select", nil);
    NSString *message = NSLocalizedStringWithDefaultValue(@"guide_choose_config",nil, [NSBundle mainBundle],
                                                                                      @"BLE to config camera through bluetooth.\nWifi to config camera through wifi.", nil);
    NSString *cancelText = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                             @"Cancel", nil);
    NSString *BLEText = NSLocalizedStringWithDefaultValue(@"BLE",nil, [NSBundle mainBundle],
                                                          @"BLE", nil);
    NSString *wifiText = NSLocalizedStringWithDefaultValue(@"Wifi",nil, [NSBundle mainBundle],
                                                           @"Wifi", nil);
    
    _alertChooseConfig = [[UIAlertView alloc]
                          initWithTitle:selectPlease
                          message:message
                          delegate:self
                          cancelButtonTitle:cancelText
                          otherButtonTitles:BLEText, wifiText, nil];
    [_alertChooseConfig show];
}

#if 1
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //Cancel button pressed
        [_alertChooseConfig dismissWithClickedButtonIndex:0 animated:NO];
        _alertChooseConfig = nil;
    }
    else if (buttonIndex == 1) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //BLE button pressed
        [userDefaults setInteger:BLUETOOTH_SETUP forKey:SET_UP_CAMERA];
        [userDefaults synchronize];
        
        if (_camChannels.count < MAX_CAM_ALLOWED)
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
            [userDefaults synchronize];
            
            NSLog(@"CameraSVC - addCameraButtonTouchAction - delegate: %@", self.camerasDelegate);
            //MenuViewController *tabBarController = (MenuViewController *)self.parentViewController;
            [((MenuViewController *)self.parentVC).menuDelegate sendStatus:SETUP_CAMERA];//initial setup
            
        }
        else
        {
            [self cameraShowDialog:DIALOG_CANT_ADD_CAM];
        }
        
    }
    else if (buttonIndex == 2) {
        //Wifi button pressed
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setInteger:WIFI_SETUP forKey:SET_UP_CAMERA];
        [userDefaults synchronize];
        
        if (_camChannels.count < MAX_CAM_ALLOWED)
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
            [userDefaults synchronize];
            
            NSLog(@"addCameraButtonTouchAction: %@", self.camerasDelegate);
            //MenuViewController *tabBarController = (MenuViewController *)self.parentViewController;
            [((MenuViewController *)self.parentVC).menuDelegate sendStatus:SETUP_CAMERA];//initial setup
            
        }
        else
        {
            [self cameraShowDialog:DIALOG_CANT_ADD_CAM];
        }
    }
}
#else

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (buttonIndex == 0) {
        //Cancel button pressed
        [_alertChooseConfig dismissWithClickedButtonIndex:0 animated:NO];
        _alertChooseConfig = nil;
    }
    else if (buttonIndex == 1) {
        //BLE button pressed
        [userDefaults setInteger:BLUETOOTH_SETUP forKey:SET_UP_CAMERA];
        [userDefaults synchronize];
        
        if (_camChannels.count < MAX_CAM_ALLOWED)
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
            [userDefaults synchronize];
            
            NSLog(@"addCameraButtonTouchAction: %@", self.camerasDelegate);
            //MenuViewController *tabBarController = (MenuViewController *)self.parentViewController;
            [((MenuViewController *)self.parentVC).menuDelegate sendStatus:SETUP_CAMERA];//initial setup
            
        }
        else
        {
            [self cameraShowDialog:DIALOG_CANT_ADD_CAM];
        }
        
    }
    else if (buttonIndex == 2) {
        //Wifi button pressed
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setInteger:WIFI_SETUP forKey:SET_UP_CAMERA];
        [userDefaults synchronize];
        
        if (_camChannels.count < MAX_CAM_ALLOWED)
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
            [userDefaults synchronize];
            
            NSLog(@"addCameraButtonTouchAction: %@", self.camerasDelegate);
            //MenuViewController *tabBarController = (MenuViewController *)self.parentViewController;
            [((MenuViewController *)self.parentVC).menuDelegate sendStatus:SETUP_CAMERA];//initial setup
            
        }
        else
        {
            [self cameraShowDialog:DIALOG_CANT_ADD_CAM];
        }
    }
}
#endif

- (IBAction)addCameraButtonTouchAction:(id)sender
{
    //show dialog for user choose method to config for camera
    [self showDialogChooseConfigCamera];
}

#pragma mark - Cameras Cell Delegate

- (void)sendTouchSettingsActionWithRowIndex:(NSInteger)rowIdx
{
    MenuCameraViewController *menuCamersVC = [[MenuCameraViewController alloc] init];
    menuCamersVC.camChannel = (CamChannel *)[self.camChannels objectAtIndex:rowIdx];
    
    menuCamersVC.menuCamerasDelegate = ((MenuViewController *)self.parentVC).menuDelegate;
    
    [((MenuViewController *)self.parentVC).navigationController pushViewController:menuCamersVC animated:YES];
    
    [menuCamersVC release];
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
        return 168;
    }
    
    return 44; // your dynamic height...
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return _addCameraCell;
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
        
//        if (ch.profile.hasUpdateLocalStatus == TRUE)
//        {
//            NSLog(@"ch.profile.hasUpdateLocalStatus == TRUE");
//        }
        
        CamProfile *camProfile = ch.profile;
        
        //cell.snapshotImage.image = self.snapshotImg;
        cell.cameraNameLabel.text = camProfile.name;
        
        return cell;
    }
    
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    // Configure the cell...
//    
//    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return NO;
    }
    
    return YES;
}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    //<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
   // [self.navigationController pushViewController:detailViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0)
    {
        return;
    }
    
    CamChannel *ch = (CamChannel *)[_camChannels objectAtIndex:indexPath.row] ;
    
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


- (void)dealloc {
    [_camChannels release];
    [_addCameraCell release];
    [_alertChooseConfig release];
    [super dealloc];
}
@end
