//
//  CamerasViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "CamerasViewController.h"
#import "MenuViewController.h"
#import "H264PlayerViewController.h"
#import "CameraMenuViewController.h"
#import "AddCameraViewController.h"
#import "TimelineViewController.h"
#import "MBP_iosViewController.h"
#import "CamerasCell.h"
#import "CameraAlert.h"
#import "define.h"

@interface CamerasViewController () <H264PlayerVCDelegate, CamerasCellDelegate, AddCameraVCDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *snapshotImages;
@property (nonatomic, copy) NSString *strDocDirPath;
@property (nonatomic) BOOL isFirttime;

@end

@implementation CamerasViewController

#define MAX_CAM_ALLOWED 5
#define CAMERA_TAG_66 566
#define CAMERA_TAG_83 583 //83/ 836
#define CAMERA_STATUS_OFFLINE   -1
#define CAMERA_STATUS_UPGRADING  0
#define CAMERA_STATUS_ONLINE     1
#define DIALOG_CANT_ADD_CAM 955

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = LocStr(@"Cameras_");
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Setup a custom title view so we can show a nice looking logo image
    UIImage *image = [UIImage imageNamed:@"logo"];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
    imageview.frame = CGRectMake(0, 0, 120, 30);
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageview;

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.snapshotImages = @[@"mountain", @"garden", @"desk", @"bridge"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.strDocDirPath = [paths firstObject];
        
    // Setup a table refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(updateCameraInfo) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateCameraInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    if ( camInView ) {
        // We have a camera to view... so show it!
        NSString *camRegID = [userDefaults objectForKey:REG_ID];
        CamChannel *ch = nil;
        for ( CamChannel *obj in _camChannels ) {
            if ( [obj.profile.registrationID isEqualToString:camRegID] ) {
                ch = obj;
                break;
            }
        }
        
        if ( ch ) {
            if ( ![ch.profile isNotAvailable] ) {
                H264PlayerViewController *h264PlayerViewController = [[H264PlayerViewController alloc] initWithNibName:@"H264PlayerViewController" bundle:nil];
                h264PlayerViewController.selectedChannel = ch;
                h264PlayerViewController.h264PlayerVCDelegate = self;
                [self.navigationController pushViewController:h264PlayerViewController animated:YES];
            }
        }
        else {
            NSLog(@"[CamerasViewController viewDidAppear:] did not find a camera!");
        }
    }
    else {
        // Reload camera list with a slightly long delay with the hope that
        // all changes are reflected correctly.
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self updateCameraInfo];
        });
    }
}

#pragma mark - CamerasCellDelegate protocol methods

- (void)sendTouchSettingsActionWithRowIndex:(NSInteger)rowIdx
{
    CameraMenuViewController *cameraMenuCV = [[CameraMenuViewController alloc] initWithNibName:@"CameraMenuViewController" bundle:nil];
    cameraMenuCV.camChannel = (CamChannel *)_camChannels[rowIdx];
    
    MenuViewController *menuVC = (MenuViewController *)self.parentVC;
    cameraMenuCV.cameraMenuDelegate = menuVC.menuDelegate;
    [self.navigationController pushViewController:cameraMenuCV animated:YES];
}

#pragma mark - AddCameraVCDelegate protocol methods

- (void)continueWithAddCameraAction
{
    MenuViewController *menuViewController = (MenuViewController *)self.parentVC;
    menuViewController.notUpdateCameras = NO;
    [menuViewController.menuDelegate sendStatus:SETUP_CAMERA]; //initial setup
}

#pragma mark - Public Methods

- (void)camerasReloadData
{
    // Ensure that the table view is reloaded only on the main thread.
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - H264PlayerVCDelegate protocol methods

- (void)stopStreamFinished:(CamChannel *)camChannel
{
    for (CamChannel *obj in _camChannels) {
        if ([obj.profile.mac_address isEqualToString:camChannel.profile.mac_address]) {
            obj.waitingForStreamerToClose = NO;
        }
        else {
            NSLog(@"%@ ->waitingForClose: %d", obj.profile.name, obj.waitingForStreamerToClose);
        }
    }
    
    [self camerasReloadData];
}

#pragma mark - Private Methods

- (void)updateCameraInfoWithDelay
{
    // Update with a 60 second delay
    [self performSelector:@selector(updateCameraInfo) withObject:nil afterDelay:60.0];
}

- (void)updateCameraInfo
{
    if ( self.isViewLoaded && self.view.window ) {
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
        menuViewController.notUpdateCameras = YES;
        
        AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] initWithNibName:@"AddCameraViewController" bundle:nil];
        addCameraVC.delegate = self;
        [self presentViewController:addCameraVC animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count;
    if ( _camChannels.count == 0 ) {
        // Show the Demo Movie cell and the Add Camera cell
        count = 2;
    }
    else {
        count = _camChannels.count + 1;
    }
    return count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( _camChannels.count == 0 && indexPath.row == 0 ) {
        // Demo Movie cell
        return 220;
    }
    else if ( (_camChannels.count == 0 && indexPath.row == 1) || indexPath.row == _camChannels.count ) {
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
    static NSString *DemoCellIdentifier = @"DemoCell";
    
    UITableViewCell *cell = nil;

    if ( _camChannels.count == 0 && indexPath.row == 0 ) {
        // Demo movie cell
        cell = [tableView dequeueReusableCellWithIdentifier:DemoCellIdentifier];
        if ( !cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DemoCellIdentifier];

            // Ensure the following is done only from the main thread otherwise init of the UIWebView will crash.
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                CGRect rect = cell.contentView.bounds;
                rect.origin.x = rect.size.width/2 - 280/2;
                rect.size.width = 280;
                rect.size.height = 210; // row height - 10
                
                UIWebView *webView = [[UIWebView alloc] initWithFrame:rect];
                webView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
                [cell.contentView addSubview:webView];
                
                NSString *videoUrl = @"http://www.youtube.com/embed/LMcSrQyRI-U?rel=0";
                NSString *htmlString = [NSString stringWithFormat:
                                        @"<html>"
                                        "<head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no\"/></head>"
                                        "<body style=\"margin-top:0px;margin-left:0px;background-color:#000;\">"
                                        "<div style='width:100%%'><iframe width='280' height='210' src='%@' frameborder='0' allowfullscreen></iframe></div>"
                                        "</body></html>",videoUrl];
                
                [webView loadHTMLString:htmlString baseURL:nil];
            });
        }
    }
    else if ( (_camChannels.count == 0 && indexPath.row == 1) || indexPath.row == _camChannels.count ) {
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
        NSString *strPath = [_strDocDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",ch.profile.registrationID]];
        
        UIImage *img = [UIImage imageWithContentsOfFile:strPath];
        if (img) {
            camerasCell.snapshotImage.image = img;
        }
        else {
            camerasCell.snapshotImage.image = [UIImage imageNamed:[_snapshotImages objectAtIndex:indexPath.row]];
        }
        
        camerasCell.ibCameraNameLabel.text = ch.profile.name;
        NSString *boundCameraName = ch.profile.name;
        CGSize size = [boundCameraName sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
        
        if (size.width > 154) {
            [camerasCell.ibCameraNameLabel setFrame:CGRectMake(165, 0, 154, 30)];
            [camerasCell.ibCameraNameLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [camerasCell.ibCameraNameLabel setNumberOfLines:2];
        }
        else {
            [camerasCell.ibCameraNameLabel setFrame:CGRectMake(165, 15, 154, 18)];
            [camerasCell.ibCameraNameLabel setFont:[UIFont boldSystemFontOfSize:15]];
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
    
    if ( (_camChannels.count == 0 && indexPath.row == 1) || indexPath.row == _camChannels.count ) {
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
                // Show Timeline view
                TimelineViewController *timelineVC = [[TimelineViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil];
                timelineVC.hidesBottomBarWhenPushed = YES;
                [timelineVC loadEvents:ch];
                [self.navigationController pushViewController:timelineVC animated:YES];
            }
        }
        else {
            ch.profile.isSelected = YES;
            
            [CameraAlert clearAllAlertForCamera:ch.profile.mac_address];
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            
            [userDefaults setObject:ch.profile.registrationID forKey:REG_ID];
            [userDefaults setObject:ch.profile.mac_address forKey:CAM_IN_VEW];
            [userDefaults synchronize];
            
            H264PlayerViewController *h264PlayerViewController = [[H264PlayerViewController alloc] initWithNibName:@"H264PlayerViewController" bundle:nil];
            h264PlayerViewController.selectedChannel = ch;
            h264PlayerViewController.h264PlayerVCDelegate = self;
            
            [self.navigationController pushViewController:h264PlayerViewController animated:YES];
        }
    }
}

@end
