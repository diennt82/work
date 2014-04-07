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
#import "define.h"

@interface CamerasViewController () <H264PlayerVCDelegate, CamerasCellDelegate, UIAlertViewDelegate, AddCameraVCDelegate>

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
}

#pragma mark - Actions

- (IBAction)addCameraButtonTouchAction:(id)sender
{
    [self.ibBGAddCamera setImage:[UIImage imageNamed:@"add_camera_btn"]];
    [self.ibIconAddCamera setImage:[UIImage imageNamed:@"add_camera"]];
    [self.ibTextAddCamera setTextColor:[UIColor whiteColor]];
    if (_camChannels.count >= MAX_CAM_ALLOWED)
    {
        [self cameraShowDialog:DIALOG_CANT_ADD_CAM];
    }
    else
    {
        MenuViewController *tabBarController = (MenuViewController *)self.parentVC;
        tabBarController.notUpdateCameras = TRUE;
        
        AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] init];
        addCameraVC.delegate = self;
        tabBarController.navigationController.navigationBarHidden = YES;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [self presentViewController:addCameraVC animated:YES completion:^{}];
    }
}

- (IBAction)buyCameraButtonTouchAction:(id)sender
{
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
    menuVC.navigationItem.title = @"Menu";
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


- (void)updateBottomButton
{
    if (self.camChannels.count == 0)
    {
        [self.ibTextAddCamera setTextColor:[UIColor whiteColor]];
        [self.ibTextBuyCamera setTextColor:[UIColor whiteColor]];
        [self.ibAddCameraButton setEnabled:YES];
        [self.ibBuyCameraButton setEnabled:YES];
        return;
    }
    
    if (_waitingForUpdateData == TRUE)
    {
        [self.ibTextAddCamera setTextColor:[UIColor deSelectedAddCameraTextColor]];
        [self.ibTextBuyCamera setTextColor:[UIColor deSelectedBuyCameraTextColor]];
        [self.ibAddCameraButton setEnabled:NO];
        [self.ibBuyCameraButton setEnabled:NO];
    }
    else
    {
        [self.ibTextAddCamera setTextColor:[UIColor whiteColor]];
        [self.ibTextBuyCamera setTextColor:[UIColor whiteColor]];
        [self.ibAddCameraButton setEnabled:YES];
        [self.ibBuyCameraButton setEnabled:YES];
    }
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
    if (scrollView.contentOffset.y < -64.0f)
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
        cell.snapshotImage.image = [UIImage imageNamed:[_snapshotImages objectAtIndex:indexPath.row]];
        
        CamChannel *ch = (CamChannel *)[_camChannels objectAtIndex:indexPath.row];
        cell.ibCameraNameLabel.text = ch.profile.name;
        NSString *boundCameraName = ch.profile.name;
        CGSize size = [boundCameraName sizeWithFont:[UIFont fontWithName:PN_SEMIBOLD_FONT size:18]];
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
        
        // Camera is NOT available
        if ([ch.profile isNotAvailable])
        {
            [cell.ibIconStatusCamera setImage:[UIImage imageNamed:@"offline.png"]];
            [cell.ibTextStatusCamera setText:@"Offline"];
        }
        else
        {
            [cell.ibIconStatusCamera setImage:[UIImage imageNamed:@"online.png"]];
            [cell.ibTextStatusCamera setText:@"Online"];

            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *regID = [userDefaults stringForKey:REG_ID];
            
            if ([ch.profile.registrationID isEqualToString:regID])
            {
                [cell.ibBGColorCameraSelected setBackgroundColor:[UIColor selectCameraItemColor]];
            }
            else
            {
                [cell.ibBGColorCameraSelected setBackgroundColor:[UIColor whiteColor]];
            }
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0 &&
//        tableView.numberOfSections == 1)
//    {
//        return NO;
//    }
//    
//    return YES;
//}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
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
