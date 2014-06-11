//
//  CamerasViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import "CamerasViewController.h"
#import <CameraScanner/CameraScanner.h>
#import "CamerasCell.h"
#import "H264PlayerViewController.h"
#import "CameraAlert.h"
#import "MenuViewController.h"
#import "CameraMenuViewController.h"
#import "AddCameraViewController.h"
#import "define.h"
#import "EarlierViewController.h"
#import "UIDeviceHardware.h"
#import "MBP_iosViewController.h"

#define MAX_CAM_ALLOWED 4
#define CAMERA_TAG_66 566
#define CAMERA_TAG_83 583 //83/ 836
#define CAMERA_STATUS_OFFLINE   -1
#define CAMERA_STATUS_UPGRADING  0
#define CAMERA_STATUS_ONLINE     1

@interface CamerasViewController () <H264PlayerVCDelegate, CamerasCellDelegate, AddCameraVCDelegate, UIAlertViewDelegate>
{
    NSString *strDocDirPath;
}

@property (nonatomic, retain) NSArray *snapshotImages;
@property (nonatomic) BOOL isFirttime;

@end

@implementation CamerasViewController

- (id)initWithDelegate:(id<ConnectionMethodDelegate>)delegate parentVC:(id)parentVC
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Cameras";
        self.parentVC = (MenuViewController *)parentVC;

        // Setup a custom title view so we can show a nice looking logo image
        UIImage *image = [UIImage imageNamed:@"hubble_logo"];
        UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
        self.navigationItem.titleView = imageview;
        
        [image release];
        [imageview release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.snapshotImages = [NSArray arrayWithObjects:@"mountain", @"garden", @"desk", @"bridge", nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    strDocDirPath = [[paths firstObject] retain];
        
    // Setup a table refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(updateCameraInfo) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    [refreshControl release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateCameraInfo];
}

#pragma mark - CamerasCellDelegate protocol methods

- (void)sendTouchSettingsActionWithRowIndex:(NSInteger)rowIdx
{
    CameraMenuViewController *cameraMenuCV = [[CameraMenuViewController alloc] init];
    cameraMenuCV.camChannel = (CamChannel *)[self.camChannels objectAtIndex:rowIdx];
    
    MenuViewController *menuVC = (MenuViewController *)self.parentVC;
    cameraMenuCV.cameraMenuDelegate = menuVC.menuDelegate;
    [self.navigationController pushViewController:cameraMenuCV animated:YES];
    
    [cameraMenuCV release];
}

#pragma mark - AddCameraVCDelegate protocol methods

- (void)continueWithAddCameraAction
{
    MenuViewController *menuViewController = (MenuViewController *)self.parentVC;
    menuViewController.notUpdateCameras = FALSE;
    [menuViewController.menuDelegate sendStatus:SETUP_CAMERA]; //initial setup
}

#pragma mark - Public Methods

- (void)camerasReloadData
{
    [self.tableView reloadData];
}

#pragma mark - H264PlayerVCDelegate protocol methods

- (void)stopStreamFinished:(CamChannel *)camChannel
{
    for (CamChannel *obj in self.camChannels) {
        if ([obj.profile.mac_address isEqualToString:camChannel.profile.mac_address]) {
            obj.waitingForStreamerToClose = NO;
        }
        else {
            NSLog(@"%@ ->waitingForClose: %d", obj.profile.name, obj.waitingForStreamerToClose);
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Private Methods

- (void)updateCameraInfoWithDelay
{
    // Update with a 60 second delay
    [self performSelector:@selector(updateCameraInfo) withObject:nil afterDelay:60.0];
}

- (void)updateCameraInfo
{
    if (self.isViewLoaded && self.view.window) {
        [self.parentVC refreshCameraList];
        [self.tableView reloadData];
    }
    [self.refreshControl endRefreshing];
}

- (void)cameraShowDialog:(int)dialogType
{
	switch (dialogType) {
		case DIALOG_CANT_ADD_CAM:
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:LocStr(@"remove_one_cam")
                                                           delegate:nil
                                                  cancelButtonTitle:LocStr(@"OK")
                                                  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
            
		default:
			break;
	}
}

- (void)addCamera
{
    if ( _camChannels.count >= MAX_CAM_ALLOWED ) {
        [self cameraShowDialog:DIALOG_CANT_ADD_CAM];
    }
    else {
        MenuViewController *menuViewController = (MenuViewController *)self.parentVC;
        menuViewController.notUpdateCameras = TRUE;
        
        //IF this is Iphone4 - Go directly to WIFI setup , as there is no BLE on IPHON4
        NSString *platformString = [UIDeviceHardware platformString];
        if( [platformString isEqualToString:@"iPhone 4"] ||
           [platformString isEqualToString:@"Verizon iPhone 4"] ||
           [platformString hasPrefix:@"iPad 2"] )
        {
            NSLog(@"**** IPHONE 4  / IPAD 2 *** use wifi setup for all");
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setInteger:WIFI_SETUP forKey:SET_UP_CAMERA];
            [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
            [userDefaults synchronize];
            
            [menuViewController dismissViewControllerAnimated:NO completion:^{
                [menuViewController.menuDelegate sendStatus:SETUP_CAMERA]; //initial setup
            }];
        }
        else {
            AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] init];
            addCameraVC.delegate = self;
            [self presentViewController:addCameraVC animated:YES completion:nil];
        }
    }
}

//- (void)cameraBackAction:(id)sender
//{
//    if ( _camChannels.count > 0 ) {
//        CamChannel *ch = (CamChannel *)[self.camChannels objectAtIndex:0];
//        
//        [CameraAlert clearAllAlertForCamera:ch.profile.mac_address];
//        [UIApplication sharedApplication].idleTimerDisabled = YES;
//        
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        [userDefaults setObject:ch.profile.mac_address forKey:CAM_IN_VEW];
//        [userDefaults synchronize];
//        
//        H264PlayerViewController *h264PlayerViewController = [[H264PlayerViewController alloc] init];
//        
//        h264PlayerViewController.selectedChannel = ch;
//        h264PlayerViewController.h264PlayerVCDelegate = self;
//        
//        NSLog(@"%@, %@", self.parentViewController.description, self.parentViewController.parentViewController);
//        
//        [((MenuViewController *)self.parentVC).navigationController pushViewController:h264PlayerViewController animated:YES];
//        [h264PlayerViewController release];
//    }
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _camChannels.count + 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == _camChannels.count ) {
        // Add Camera cell
        return 44;
    }
    else {
        // Normal Cell
        return 103;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AddCellIdentifier = @"AddCell";
    static NSString *CameraCellIdentifier = @"CamerasCell";
    
    UITableViewCell *cell = nil;

    if ( indexPath.row == _camChannels.count ) {
        // Add Camera cell
        cell = [tableView dequeueReusableCellWithIdentifier:AddCellIdentifier];
        if ( !cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddCellIdentifier];
            cell.textLabel.text = @"Add Camera";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.imageView.image = [UIImage imageNamed:@"add_camera"];
            cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"add_camera_btn"]];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"add_camera_btn_pressed"]];
        }
    }
    else {
        // Normal Cell
        cell = [tableView dequeueReusableCellWithIdentifier:CameraCellIdentifier];

        if ( !cell ) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CamerasCell" owner:nil options:nil];
            
            for (id curObj in objects) {
                if ([curObj isKindOfClass:[UITableViewCell class]]) {
                    cell = (UITableViewCell *)curObj;
                    break;
                }
            }
        }
        
        CamerasCell *camerasCell = (CamerasCell *)cell;
        camerasCell.camerasCellDelegate = self;
        camerasCell.rowIndex = indexPath.row;
        camerasCell.backgroundColor = [UIColor blackColor];
        
        CamChannel *ch = (CamChannel *)[_camChannels objectAtIndex:indexPath.row];
        NSString *strPath = [strDocDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",ch.profile.registrationID]];
        
        UIImage *img = [UIImage imageWithContentsOfFile:strPath];
        if (img) {
            camerasCell.snapshotImage.image = img;
        }
        else {
            camerasCell.snapshotImage.image = [UIImage imageNamed:[_snapshotImages objectAtIndex:indexPath.row]];
        }
        
        camerasCell.ibCameraNameLabel.text = ch.profile.name;
        NSString *boundCameraName = ch.profile.name;
        CGSize size = [boundCameraName sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:PN_SEMIBOLD_FONT size:18]}];
        
        if (size.width > 154) {
            [camerasCell.ibCameraNameLabel setFrame:CGRectMake(165, 0, 154, 30)];
            [camerasCell.ibCameraNameLabel setFont:[UIFont fontWithName:PN_SEMIBOLD_FONT size:15]];
            [camerasCell.ibCameraNameLabel setNumberOfLines:2];
        }
        else {
            [camerasCell.ibCameraNameLabel setFrame:CGRectMake(165, 15, 154, 18)];
            [camerasCell.ibCameraNameLabel setFont:[UIFont fontWithName:PN_SEMIBOLD_FONT size:15]];
            [camerasCell.ibCameraNameLabel setNumberOfLines:1];
        }
        
        camerasCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        camerasCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if ([ch.profile isFwUpgrading:[NSDate date]]) {
            camerasCell.ibIconStatusCamera.image = [UIImage imageNamed:@"online"];
            camerasCell.ibTextStatusCamera.text = @"Upgrading...";
            camerasCell.selectionStyle = UITableViewCellSelectionStyleNone;
            camerasCell.accessoryType = UITableViewCellAccessoryNone;
            
            NSLog(@"%s Fw is upgrading...", __FUNCTION__);
            [self performSelectorOnMainThread:@selector(updateCameraInfoWithDelay) withObject:nil waitUntilDone:NO];
        }
        else if ([ch.profile isNotAvailable]) {
            [camerasCell.ibIconStatusCamera setImage:[UIImage imageNamed:@"offline"]];
            [camerasCell.ibTextStatusCamera setText:@"Offline"];
        }
        else {
            [camerasCell.ibIconStatusCamera setImage:[UIImage imageNamed:@"online"]];
            [camerasCell.ibTextStatusCamera setText:@"Online"];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ( indexPath.row == _camChannels.count ) {
        // Add Camera cell
        [self addCamera];
    }
    else {
        // Camera cell
        CamChannel *ch = (CamChannel *)[_camChannels objectAtIndex:indexPath.row];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([ch.profile isNotAvailable]) {
            if ([ch.profile isSharedCam]) {
                NSLog(@"CamerasVC - didSelectRowAtIndexPath - Selected camera is NOT available & is SHARED_CAM");
            }
            else {
                // Show Earlier view
                [userDefaults setObject:ch.profile.mac_address forKey:CAM_IN_VEW];
                [userDefaults synchronize];
                
                EarlierViewController *earlierVC = [[EarlierViewController alloc] initWithCamChannel:ch];
                [self.navigationController pushViewController:earlierVC animated:YES];
                [earlierVC release];
            }
        }
        else {
            ch.profile.isSelected = TRUE;
            
            [CameraAlert clearAllAlertForCamera:ch.profile.mac_address];
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            
            [userDefaults setObject:ch.profile.registrationID forKey:REG_ID];
            [userDefaults setObject:ch.profile.mac_address forKey:CAM_IN_VEW];
            [userDefaults synchronize];
            
            H264PlayerViewController *h264PlayerViewController = [[H264PlayerViewController alloc] init];
            
            h264PlayerViewController.selectedChannel = ch;
            h264PlayerViewController.h264PlayerVCDelegate = self;
            
            [self.navigationController pushViewController:h264PlayerViewController animated:YES];
            [h264PlayerViewController release];
        }
    }
}

#pragma mark - Memory management methods

- (void)dealloc
{
    [_camChannels release];
    [super dealloc];
}

@end
