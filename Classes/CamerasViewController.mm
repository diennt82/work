//
//  CamerasViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
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

@interface CamerasViewController () <H264PlayerVCDelegate, CamerasCellDelegate, UIAlertViewDelegate, AddCameraVCDelegate>
{
    BOOL shouldHighlightAtRow[MAX_CAM_ALLOWED];
    
    NSString *strDocDirPath;
}

@property (retain, nonatomic) IBOutlet UITableViewCell *addCameraCell;
@property (retain, nonatomic) IBOutlet UIView *ibViewAddCamera;
@property (retain, nonatomic) IBOutlet UIView *ibViewBuyCamera;


@property (retain, nonatomic) IBOutlet UIImageView *ibBGAddCamera;
@property (retain, nonatomic) IBOutlet UIImageView *ibIconAddCamera;
@property (retain, nonatomic) IBOutlet UILabel *ibTextAddCamera;
@property (retain, nonatomic) IBOutlet UIButton *ibAddCameraButton;

@property (retain, nonatomic) IBOutlet UIImageView *ibBGBuyCamera;
@property (retain, nonatomic) IBOutlet UIImageView *ibIconBuyCamera;
@property (retain, nonatomic) IBOutlet UILabel *ibTextBuyCamera;
@property (retain, nonatomic) IBOutlet UIButton *ibBuyCameraButton;


- (IBAction)addCameraButtonTouchAction:(id)sender;
- (IBAction)buyCameraButtonTouchAction:(id)sender;
- (IBAction)addCameraButtonTouchDownAction:(id)sender;
@property (retain, nonatomic) NSArray *snapshotImages;
@property (nonatomic) BOOL isFirttime;

@end

@implementation CamerasViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
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
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"Cameras";
        self.parentVC = (MenuViewController *)parentVC;
        self.ibTableListCamera.delegate = self;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
             delegate:(id<ConnectionMethodDelegate> )delegate
             parentVC: (id)parentVC
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"Cameras";
        self.parentVC = (MenuViewController *)parentVC;
        self.ibTableListCamera.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.snapshotImages = [NSArray arrayWithObjects:@"mountain", @"garden", @"desk", @"bridge", nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    strDocDirPath = [[paths objectAtIndex:0] retain];
        
    [self.ibTableListCamera setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 69 - 45)];
    [self.ibViewAddCamera setFrame:CGRectMake(0, SCREEN_HEIGHT - 45, 160, 45)];
    [self.ibViewBuyCamera setFrame:CGRectMake(160, SCREEN_HEIGHT - 45, 160, 45)];
    
    [self.ibAddCameraButton setImage:[UIImage imageNamed:@"add_camera_btn"] forState:UIControlStateNormal];
    [self.ibAddCameraButton setImage:[UIImage imageNamed:@"add_camera_btn_pressed"] forState:UIControlEventTouchDown];
    
    [self.ibBuyCameraButton setImage:[UIImage imageNamed:@"buy_camera_btn"] forState:UIControlStateNormal];
    [self.ibBuyCameraButton setImage:[UIImage imageNamed:@"buy_camera_btn_pressed"] forState:UIControlEventTouchDown];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.ibTableListCamera.delegate = self;

    [self updateBottomButton];
}

#pragma mark - Actions

- (IBAction)addCameraButtonTouchAction:(id)sender
{

#if 1
    
    [self.ibIconAddCamera setImage:[UIImage imageNamed:@"add_camera_pressed"]];
    [self.ibTextAddCamera setTextColor:[UIColor deSelectedAddCameraTextColor]];
    
    if (_camChannels.count >= MAX_CAM_ALLOWED)
    {
        [self cameraShowDialog:DIALOG_CANT_ADD_CAM];
    }
    else
    {
        MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
        tabBarController.notUpdateCameras = TRUE;
        
        //IF this is Iphone4 - Go directly to WIFI setup , as there is no BLE on IPHON4
        NSString *platformString = [UIDeviceHardware platformString];
        if( [platformString isEqualToString:@"iPhone 4"] ||
            [platformString isEqualToString:@"Verizon iPhone 4"] ||
            [platformString hasPrefix:@"iPad 2"]
           )
        {
            NSLog(@"**** IPHONE 4  / IPAD 2 *** use wifi setup for all");
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setInteger:WIFI_SETUP forKey:SET_UP_CAMERA];
            [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
            [userDefaults synchronize];
            
            [tabBarController dismissViewControllerAnimated:NO completion:^{
                [tabBarController.menuDelegate sendStatus:SETUP_CAMERA]; //initial setup
            }];
            
        }
        else
        {
            AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] init];
            addCameraVC.delegate = self;
            tabBarController.navigationController.navigationBarHidden = YES;
            self.navigationItem.leftBarButtonItem.enabled = NO;
            [self presentViewController:addCameraVC animated:YES completion:^{}];
        }
    }
    [self.ibIconAddCamera setImage:[UIImage imageNamed:@"add_camera"]];
    [self.ibTextAddCamera setTextColor:[UIColor whiteColor]];
#else
    
#pragma mark DEBUG Push notification 
    int rcvTimeStamp = [[NSDate date] timeIntervalSince1970];
    CameraAlert * camAlert = [[CameraAlert alloc]initWithTimeStamp1:rcvTimeStamp];// autorelease];
    
    
#if 0
    //set other values
    camAlert.cameraMacNoColon = @"44334C5FF075";
    
    camAlert.cameraName = @"Camera-fake motion push";
    camAlert.alertType = @"4";
    camAlert.alertTime =@"2014-04-30T04:51:54+00:00";
    camAlert.alertVal = @"20140430090958000";
    camAlert.registrationID = @"01006644334C5FF075GPIRBEXE";
#else 
    camAlert.cameraMacNoColon = @"44334C5FF075";
    
    camAlert.cameraName = @"Camera-fake Temp push";
    camAlert.alertType = @"1";
    camAlert.alertTime =@"2014-04-30T04:51:54+00:00";
    camAlert.alertVal = @"1";
    camAlert.registrationID = @"01006644334C5FF075GPIRBEXE";
    
#endif
    
    
    
    
    NSLog(@"Fake push  aaa");
    MenuViewController * vc = (MenuViewController * )self.parentVC;
    
    [(MBP_iosViewController *) vc.menuDelegate pushNotificationRcvedInForeground:camAlert];
#endif
}

- (IBAction)buyCameraButtonTouchAction:(id)sender
{
    [self.ibIconBuyCamera setImage:[UIImage imageNamed:@"cart_pressed"]];
    [self.ibTextBuyCamera setTextColor:[UIColor deSelectedBuyCameraTextColor]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://hubblehome.com/hubble-products/"]];
}

- (IBAction)addCameraButtonTouchDownAction:(id)sender
{
    [self.ibBGAddCamera setImage:[UIImage imageNamed:@"add_camera_btn_pressed"]];
    [self.ibIconAddCamera setImage:[UIImage imageNamed:@"add_camera_pressed"]];
    [self.ibTextAddCamera setTextColor:[UIColor deSelectedAddCameraTextColor]];
}

#pragma mark - Cameras Cell Delegate

- (void)sendTouchSettingsActionWithRowIndex:(NSInteger)rowIdx
{
    CameraMenuViewController *cameraMenuCV = [[CameraMenuViewController alloc] init];
    cameraMenuCV.camChannel = (CamChannel *)[self.camChannels objectAtIndex:rowIdx];
    
    MenuViewController *menuVC = (MenuViewController *)self.parentVC;
    
    cameraMenuCV.cameraMenuDelegate = menuVC.menuDelegate;
    //menuVC.navigationItem.title = @"Menu";
    [menuVC.navigationController pushViewController:cameraMenuCV animated:YES];
    
    [cameraMenuCV release];
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
    else
    {
        tabBarController.navigationController.navigationBarHidden = NO;
    }
}

#pragma mark - Methods

- (void)camerasReloadData
{
    [self.ibTableListCamera reloadData];
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
    
    [self.ibTableListCamera reloadData];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.camChannels.count == 0)
    {
        return 0;
    }
    if (_waitingForUpdateData == TRUE)
    {
        return 1;
    }
    return self.camChannels.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_waitingForUpdateData == TRUE)
    {
        return 40; // your dynamic height...
    }
    
    return 103;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -64.0f && !_waitingForUpdateData)
    {
        [self.parentVC refreshCameraList];
        [self.ibTableListCamera reloadData];
    }
}

- (void)updateCameraInfo
{
    [self performSelector:@selector(updateCameraInfo_delay) withObject:nil afterDelay:60];
}

- (void)updateCameraInfo_delay
{
    if (self.isViewLoaded && self.view.window)
    {
        [self.parentVC refreshCameraList];
        [self.ibTableListCamera reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateBottomButton];
    
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
        static NSString *CellIdentifier = @"CamerasCell";
        CamerasCell *cell = [self.ibTableListCamera dequeueReusableCellWithIdentifier:CellIdentifier];
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
        
        CamChannel *ch = (CamChannel *)[_camChannels objectAtIndex:indexPath.row];
        
        NSString *strPath = [strDocDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",ch.profile.registrationID]];
        UIImage *img = [UIImage imageWithContentsOfFile:strPath];
        if(img){
            cell.snapshotImage.image = img;
        }else{
           cell.snapshotImage.image = [UIImage imageNamed:[_snapshotImages objectAtIndex:indexPath.row]];
        }       
        cell.ibCameraNameLabel.text = ch.profile.name;
        NSString *boundCameraName = ch.profile.name;
        CGSize size = [boundCameraName sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:PN_SEMIBOLD_FONT size:18]}];
        
        if (size.width > 154)
        {
            [cell.ibCameraNameLabel setFrame:CGRectMake(165, 0, 154, 30)];
            [cell.ibCameraNameLabel setFont:[UIFont fontWithName:PN_SEMIBOLD_FONT size:15]];
            [cell.ibCameraNameLabel setNumberOfLines:2];
        }
        else
        {
            [cell.ibCameraNameLabel setFrame:CGRectMake(165, 15, 154, 18)];
            [cell.ibCameraNameLabel setFont:[UIFont fontWithName:PN_SEMIBOLD_FONT size:15]];
            [cell.ibCameraNameLabel setNumberOfLines:1];
        }
        
        if ([ch.profile isFwUpgrading:[NSDate date]])
        {
            shouldHighlightAtRow[indexPath.row] = NO;
            [cell.ibIconStatusCamera setImage:[UIImage imageNamed:@"online"]];
            [cell.ibTextStatusCamera setText:@"FW is upgrading..."];
            
            NSLog(@"%s Fw is upgrading...", __FUNCTION__);
            
            [self performSelectorOnMainThread:@selector(updateCameraInfo) withObject:nil waitUntilDone:NO];
        }
        else if ([ch.profile isNotAvailable])
        {
            shouldHighlightAtRow[indexPath.row] = YES;
            [cell.ibIconStatusCamera setImage:[UIImage imageNamed:@"offline"]];
            [cell.ibTextStatusCamera setText:@"Offline"];
        }
        else
        {
            shouldHighlightAtRow[indexPath.row] = YES;
            [cell.ibIconStatusCamera setImage:[UIImage imageNamed:@"online"]];
            [cell.ibTextStatusCamera setText:@"Online"];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *regID = [userDefaults stringForKey:REG_ID];
            
            if ([ch.profile.registrationID isEqualToString:regID])
            {
                [cell.ibBGColorCameraSelected setBackgroundColor:[UIColor selectCameraItemColor]];
                [cell setSelected:YES];
            }
            else
            {
                [cell.ibBGColorCameraSelected setBackgroundColor:[UIColor whiteColor]];
                [cell setSelected:NO];
            }
        }
        
        return cell;
    }
}

- (void)updateBottomButton
{
    if (self.camChannels.count == 0)
    {
        [self.ibTextAddCamera setTextColor:[UIColor whiteColor]];
        [self.ibAddCameraButton setImage:[UIImage imageNamed:@"add_camera_btn"] forState:UIControlStateNormal];
        [self.ibAddCameraButton setEnabled:YES];
        [self.ibIconAddCamera setImage:[UIImage imageNamed:@"add_camera"]];
        _waitingForUpdateData = NO;
        return;
    }
    
    if (_waitingForUpdateData == TRUE)
    {
        [self.ibTextAddCamera setTextColor:[UIColor deSelectedAddCameraTextColor]];
        [self.ibAddCameraButton setEnabled:NO];
        [self.ibIconAddCamera setImage:[UIImage imageNamed:@"add_camera_pressed"]];
    }
    else
    {
        [self.ibTextAddCamera setTextColor:[UIColor whiteColor]];
        [self.ibAddCameraButton setEnabled:YES];
        [self.ibIconAddCamera setImage:[UIImage imageNamed:@"add_camera"]];
    }
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_waitingForUpdateData == TRUE)
    {
        return NO;
    }
    
    return shouldHighlightAtRow[indexPath.row];
}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    CamChannel *ch = (CamChannel *)[_camChannels objectAtIndex:indexPath.row];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([ch.profile isNotAvailable])
    {
        if([ch.profile isSharedCam])
        {
            NSLog(@"CamerasVC - didSelectRowAtIndexPath - Selected camera is NOT available & is SHARED_CAM");
        }
        else
        {
            // Show Earlier view
            [userDefaults setObject:ch.profile.mac_address forKey:CAM_IN_VEW];
            [userDefaults synchronize];
            
            EarlierViewController *earlierVC = [[EarlierViewController alloc] initWithCamChannel:ch];
            [((MenuViewController *)self.parentVC).navigationController pushViewController:earlierVC animated:YES];
            [earlierVC release];
        }
    }
    else
    {
        ch.profile.isSelected = TRUE;
        
        [CameraAlert clearAllAlertForCamera:ch.profile.mac_address];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [userDefaults setObject:ch.profile.registrationID forKey:REG_ID];
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
    [_ibTableListCamera release];
    [_ibAddCameraButton release];
    [_ibBuyCameraButton release];
    [_ibBGAddCamera release];
    [_ibIconAddCamera release];
    [_ibTextAddCamera release];
    [_ibAddCameraButton release];
    [_ibBGBuyCamera release];
    [_ibIconBuyCamera release];
    [_ibTextBuyCamera release];
    [_ibBuyCameraButton release];
    [_ibViewAddCamera release];
    [_ibViewBuyCamera release];
    [super dealloc];
}

@end
