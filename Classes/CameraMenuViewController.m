//
//  CameraMenuViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CameraMenuViewController.h"
#import "CameraSettingsCell.h"
#import "CameraNameViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "define.h"
#import "ChangeImageViewController.h"
#import "CameraDetailCell.h"
#import "SensitivityTemperatureCell.h"
#import "SensitivityCell.h"
#import "SensitivityInfo.h"
#import "MBProgressHUD.h"
#import "UIActionSheet+Blocks.h"
#import "PublicDefine.h"



#define ALERT_REMOVE_CAM        5
#define ALERT_REMOVE_CAM_LOCAL  6
#define ALERT_REMOVE_CAM_REMOTE 7

#define ALERT_RENAME_CAMERA         8
#define ALERT_RENAME_REPORT         9
#define ALERT_RENAME_CANT_EMPTY     10
#define ALERT_RENAME_OUT_LENGTH     11
#define ALERT_RENAME_REGEX          12

#define SENSITIVITY_MOTION_LOW      10
#define SENSITIVITY_MOTION_MEDIUM   50
#define SENSITIVITY_MOTION_HI       90

#define SENSITIVITY_SOUND_LOW       80
#define SENSITIVITY_SOUND_MEDIUM    70
#define SENSITIVITY_SOUND_HI        25

#define ENABLE_CHANGE_IMAGE 0

#define SENSITIVITY_MOTION_VALUE(x) (x<=SENSITIVITY_MOTION_LOW?0:(x<=SENSITIVITY_MOTION_MEDIUM?1:2))
#define SENSITIVITY_SOUND_VALUE(x)  (x>=SENSITIVITY_SOUND_LOW?0:(x>=SENSITIVITY_SOUND_MEDIUM?1:2))

@interface CameraMenuViewController () <UITableViewDataSource, UITableViewDelegate,SensitivityCellDelegate,SensitivityTemperaureCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    int intTableSectionStatus; // 0 No open, 1 = 0 section open , 2 = 1 section open
    
    IBOutlet UIView *vwSnapshot;
    IBOutlet UIImageView *imgVSnapshot;
    IBOutlet UIButton *btnSnapshotRefresh,*btnSnapshotOK;
    
}
@property (retain, nonatomic) SensitivityInfo *sensitivityInfo;
@property (nonatomic, retain) NSString *selectedReg;
@property (nonatomic, retain) NSString *sensitivityMessage;
@property (nonatomic, retain) BMS_JSON_Communication *jsonComm;


@property (retain, nonatomic) IBOutlet UITableView *tableViewSettings;
@property (retain, nonatomic) IBOutlet UIButton *btnRmoveCamera;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;

@property (retain, nonatomic) NSString *stringFW_Version;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic) BOOL isChangingName;
@property (nonatomic, retain) UIAlertView *alertViewRename;

@property (retain, nonatomic) IBOutlet UIView *vwHeaderCamDetail,*vwHeaderNotSens;
@property (nonatomic) BOOL shouldWaitForUpdateSettings;
@property (assign, nonatomic) SensitivityTemperatureCell *sensitivityTemperatureCell;

@end

@implementation CameraMenuViewController
@synthesize cameraName = _cameraName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Camera Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    intTableSectionStatus = 0;
    self.shouldWaitForUpdateSettings = FALSE;
    
    self.tableViewSettings.delegate = self;
    self.tableViewSettings.dataSource = self;
    
    [self.btnRmoveCamera setBackgroundImage:[UIImage imageNamed:@"remove_camera"]
                                   forState:UIControlStateNormal];
    [self.btnRmoveCamera setBackgroundImage:[UIImage imageNamed:@"remove_camera_pressed"]
                                   forState:UIControlEventTouchDown];
    
    self.stringFW_Version = NSLocalizedStringWithDefaultValue(@"firmware_version", nil, [NSBundle mainBundle],
                                                   @"Firmware version", nil);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.apiKey = [userDefaults stringForKey:@"PortalApiKey"];
    
//    if (![self.camChannel.profile isNotAvailable])
//    {
//        self.isLoading = TRUE;
//        [self performSelectorInBackground:@selector(updateFWVersion_bg) withObject:nil];
//    }
    
    self.tableViewSettings.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    
    UIImageView *imgView = (UIImageView*)[self.vwHeaderNotSens viewWithTag:500];
    if([self.camChannel.profile isNotAvailable]){
        imgView.image = [UIImage imageNamed:@"sensitivity_disable@2x.png"];
    }
    
    
    //Set Navigation Back Button
    UIImage *image = [UIImage imageNamed:@"Hubble_logo_back"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //then set it.  phew.
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [self.navigationItem setHidesBackButton:YES];
    [barButtonItem release];
    
    //Snapshot View
    vwSnapshot.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    vwSnapshot.hidden = YES;
    [self.view addSubview:vwSnapshot];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.view setUserInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableViewSettings release];
    [_btnRmoveCamera release];
    [_viewProgress release];
    [_viewPorgress release];
    [_alertViewRename release];
    [super dealloc];
}

#pragma mark - Action

-(void)backButtonPressed
{
    self.navigationItem.leftBarButtonItem = NO;
    self.shouldWaitForUpdateSettings = FALSE;
    
    if (_sensitivityTemperatureCell)
    {
        self.shouldWaitForUpdateSettings = [_sensitivityTemperatureCell shouldWaitForUpdateSettings];
    }
    
    if (_shouldWaitForUpdateSettings)
    {
        MBProgressHUD *showError = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [showError setLabelText:@"Updating..."];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)btnRemoveCameraTouchUpInsideAction:(id)sender
{
    //self.navigationItem.hidesBackButton = YES;
    self.view.userInteractionEnabled = NO;
    self.btnRmoveCamera.enabled = NO;
    
    self.viewProgress.frame = UIScreen.mainScreen.bounds;
    self.viewProgress.hidden = NO;
    [self.view bringSubviewToFront:_viewProgress];
    
    [self  showDialog:ALERT_REMOVE_CAM];
}

- (void) showDialog:(int) dialogType
{
    NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                         @"Invalid Camera Name", nil);
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok", nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel", nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
	switch (dialogType) {
            
		case ALERT_REMOVE_CAM:
		{
			BOOL deviceInLocal = _camChannel.profile.isInLocal;
            
            if (deviceInLocal)
            {
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Confirm_remove_cam_local", nil, [NSBundle mainBundle],
                                                                   @"Please confirm that you want to remove this camera from your account. This action will also reset the camera to setup mode.", nil);
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:msg
                                      delegate:self
                                      cancelButtonTitle:cancel
                                      otherButtonTitles:ok, nil];
                alert.tag = ALERT_REMOVE_CAM_LOCAL;
                [alert show];
                [alert release];
                
            }
            else
            {
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Confirm_remove_cam_remote",nil, [NSBundle mainBundle],
                                                                   @"You are about to remove the paired camera from the app. You will have to pair it back again in order to use it in future. Continue?", nil);
                
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:msg
                                      delegate:self
                                      cancelButtonTitle:cancel
                                      otherButtonTitles:ok, nil];
                
                alert.tag = ALERT_REMOVE_CAM_REMOTE;
                [alert show];
                [alert release];
            }
		}
            break;
            
        case ALERT_RENAME_REPORT:
        {
            NSString * msg = @"Invaldate name";
            
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:msg
                                  delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:ok, nil];
            
            alert.tag = ALERT_RENAME_REPORT;
            [alert show];
            [alert release];
        }
            break;
            
        case ALERT_RENAME_CANT_EMPTY:
		{
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Camera_name_cant_be_empty",nil, [NSBundle mainBundle],
                                                               @"Camera name cant be empty, please try again", nil);
            
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg
								  delegate:nil
								  cancelButtonTitle:nil
								  otherButtonTitles:ok, nil];
			alert.tag = ALERT_RENAME_CANT_EMPTY;
			[alert show];
			[alert release];
		}
            break;
            
        case ALERT_RENAME_OUT_LENGTH:
        {
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg", nil, [NSBundle mainBundle],
                                                               @"Camera Name has to be between 5-30 characters", nil);
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                             message:msg
                                                            delegate:nil
                                                   cancelButtonTitle:ok
                                                   otherButtonTitles:nil];
            alert.tag = ALERT_RENAME_OUT_LENGTH;
            [alert show];
            [alert release];
        }
            break;
            
        case ALERT_RENAME_REGEX:
        {
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg2", nil, [NSBundle mainBundle],
                                                               @"Camera name is invalid. Please enter [0-9],[a-Z], space, dot, hyphen, underscore & single quote only.", nil);
            
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                             message:msg
                                                            delegate:nil
                                                   cancelButtonTitle:ok
                                                   otherButtonTitles:nil];
            
            alert.tag = ALERT_RENAME_REGEX;
            [alert show];
            [alert release];
        }
            break;
            
		default:
			break;
	}
}

#pragma  mark - Alert Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_RENAME_CAMERA)
    {
        if (buttonIndex == 1)
        {
            NSString *newName = [alertView textFieldAtIndex:0].text;
            
            if( (newName == nil) || newName.length == 0)
            {
                [self showDialog:ALERT_RENAME_CANT_EMPTY];
            }
            else if (newName.length < MIN_LENGTH_CAMERA_NAME || MAX_LENGTH_CAMERA_NAME < newName.length)
            {
                [self showDialog:ALERT_RENAME_OUT_LENGTH];
            }
            else if (![self isCamNameValidated:newName])
            {
                [self showDialog:ALERT_RENAME_REGEX];
            }
            else
            {
                if (![newName isEqualToString:self.camChannel.profile.name])
                {
                    _cameraNewName = [newName copy];
                    self.isChangingName = TRUE;
                    [self.tableViewSettings reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                                                               inSection:0]]
                                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        [hud setLabelText:@"Updating..."];
                        [self changeCameraName];
                    });
                }
                else
                {
                    NSLog(@"CameraMenuVC - the same as current name");
                }
            }
        }
    }
    else if(ALERT_REMOVE_CAM)
    {
        if (buttonIndex == 1)
        {
            int tag = alertView.tag ;
            
            if (tag == ALERT_REMOVE_CAM_LOCAL)
            {
                [self removeLocalCamera];
            }
            else if (tag == ALERT_REMOVE_CAM_REMOTE)
            {
                [self removeRemoteCamera];
            }
        }
        else
        {
            self.viewProgress.hidden = YES;
            
            //self.navigationItem.hidesBackButton = NO;
            self.view.userInteractionEnabled = YES;
            self.btnRmoveCamera.enabled = YES;
        }
    }
    else// if(ALERT_RENAME_REPORT)
    {
        // Do nothing
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    //return 1;
    
    return 2; //1 for Camera Detail , 2 for Noti. Sensi.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
/*    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
#if ENABLE_CHANGE_IMAGE
    return 3;
#else
    return 2;
#endif
 */
   
    /*if(intTableSectionStatus==0)
    {
        return 0;
    }
    else{
        if(section==0 && intTableSectionStatus==1){
            return 1;
        }
        else if(section==1 && intTableSectionStatus==2){
            return 3;
        }
    }*/
    
    if(section==0){
        return 1;
    }
    else if(section==1){
        return 3;
    }
    return 0;
    
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(section==0)
    {
        return self.vwHeaderCamDetail;
    }
    else {
        return self.vwHeaderNotSens;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   /* if (self.camChannel.profile.name.length > 10 &&
        indexPath.row == 0)
    {
        return 66;
    }
    
    return 45;*/
    
    if(intTableSectionStatus==0)
    {
        return 0;
    }
    else{
        if(indexPath.section==0 && intTableSectionStatus==1){
            return 198;
        }
        else if(indexPath.section==1 && intTableSectionStatus==2){
            if(indexPath.row==0 || indexPath.row==1)
            {
                return 120;
            }
            else{
                return 227;
            }
        }
    }

    return 0;
}

/*- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
}*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if ENABLE_CHANGE_IMAGE
    if (indexPath.row == 0 ||
        indexPath.row == 2)
    {
        static NSString *CellIdentifier = @"CameraSettingsCell";
        CameraSettingsCell *cell = [self.tableViewSettings dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CameraSettingsCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (CameraSettingsCell *)curObj;
                break;
            }
        }
        
        if (indexPath.row == 0)
        {
            if (self.camChannel.profile.name.length > 10)
            {
                cell.valueLabel.frame = CGRectMake(cell.valueLabel.frame.origin.x, cell.valueLabel.frame.origin.y, cell.valueLabel.frame.size.width, cell.valueLabel.frame.size.height * 2);
                cell.nameLabel.frame = CGRectMake(cell.nameLabel.frame.origin.x, cell.valueLabel.center.y - cell.nameLabel.frame.size.height / 2, cell.nameLabel.frame.size.width, cell.nameLabel.frame.size.height);
            }
            
            cell.nameLabel.text = @"Name";
            cell.valueLabel.text = self.camChannel.profile.name;
        }
        else
        {
            cell.nameLabel.text = _stringFW_Version;
            cell.valueLabel.text = self.camChannel.profile.fw_version;
        }
        
        return cell;
    }
    else // indexPath.row == 1
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        cell.textLabel.text = @"Change Image";
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:17];
        cell.textLabel.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1];
        
        return cell;
    }
#else
    if (indexPath.row == 0 ||
        indexPath.row == 1)
    {
        static NSString *CellIdentifier = @"CameraSettingsCell";
        CameraSettingsCell *cell = [self.tableViewSettings dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CameraSettingsCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (CameraSettingsCell *)curObj;
                break;
            }
        }
        
        if (indexPath.row == 0)
        {
            if (_isChangingName)
            {
                static NSString *CellIdentifier = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                }
                
                // Configure the cell...
                cell.textLabel.text = @"Name";
                
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                // Spacer is a 1x1 transparent png
                UIImage *spacer = [UIImage imageNamed:@"spacer"];
                
                UIGraphicsBeginImageContext(spinner.frame.size);
                
                [spacer drawInRect:CGRectMake(0, 0, spinner.frame.size.width, spinner.frame.size.height)];
                UIImage* resizedSpacer = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
                cell.imageView.image = resizedSpacer;
                spinner.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width - spinner.frame.size.width - 30, 0, spinner.frame.size.width, spinner.frame.size.height);
                [cell.imageView addSubview:spinner];
                [spinner startAnimating];
                
                return cell;
            }
            else
            {
                if (self.camChannel.profile.name.length > 10)
                {
                    cell.valueLabel.frame = CGRectMake(cell.valueLabel.frame.origin.x, cell.valueLabel.frame.origin.y, cell.valueLabel.frame.size.width, cell.valueLabel.frame.size.height * 2);
                    cell.nameLabel.frame = CGRectMake(cell.nameLabel.frame.origin.x, cell.valueLabel.center.y - cell.nameLabel.frame.size.height / 2, cell.nameLabel.frame.size.width, cell.nameLabel.frame.size.height);
                }
                
                cell.nameLabel.text = @"Name";
                cell.valueLabel.text = self.camChannel.profile.name;
            }
        }
        else
        {
            if (_isLoading)
            {
                static NSString *CellIdentifier = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                }
                
                // Configure the cell...
                cell.textLabel.text = _stringFW_Version;
                
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                // Spacer is a 1x1 transparent png
                UIImage *spacer = [UIImage imageNamed:@"spacer"];
                
                UIGraphicsBeginImageContext(spinner.frame.size);
                
                [spacer drawInRect:CGRectMake(0, 0, spinner.frame.size.width, spinner.frame.size.height)];
                UIImage* resizedSpacer = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
                cell.imageView.image = resizedSpacer;
                spinner.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width - spinner.frame.size.width - 30, 0, spinner.frame.size.width, spinner.frame.size.height);
                [cell.imageView addSubview:spinner];
                [spinner startAnimating];
                
                return cell;
            }
            else
            {
                cell.nameLabel.text = _stringFW_Version;
                cell.valueLabel.text = self.camChannel.profile.fw_version;
            }
        }
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        
        return cell;
    }
#endif
}
 */

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)//General Setting
    {
        static NSString *cellIdentifier = @"CameraDetailCell";
        CameraDetailCell *camDetCell = (CameraDetailCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(camDetCell == nil)
        {
            camDetCell = [[[CameraDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            [camDetCell.btnChangeImage addTarget:self action:@selector(btnChangeCameraIcon) forControlEvents:UIControlEventTouchUpInside];
            [camDetCell.btnChangeName addTarget:self action:@selector(btnChangeCameraName) forControlEvents:UIControlEventTouchUpInside];
            
            camDetCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        camDetCell.lblCameraName.text = self.camChannel.profile.name;
        camDetCell.lblCamVer.text = self.camChannel.profile.fw_version;
        return camDetCell;

    }
    else //Sensitive Setting
    {
        if(indexPath.row==0 || indexPath.row==1)//Motion & Sound
        {
            static NSString *CellIdentifier = @"SensitivityCell";
            SensitivityCell *cell = [self.tableViewSettings dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SensitivityCell" owner:nil options:nil];
            
            for (id curObj in objects)
            {
                
                if([curObj isKindOfClass:[UITableViewCell class]])
                {
                    cell = (SensitivityCell *)curObj;
                    cell.backgroundColor = COLOR_RGB(43.0, 50.0, 56.0);
                    break;
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.sensitivityCellDelegate = self;
            cell.rowIndex = indexPath.row ;
            
            if (indexPath.row == 0)
            {
                cell.nameLabel.text = @"Motion";
                cell.switchValue   = _sensitivityInfo.motionOn;
                cell.settingsValue = _sensitivityInfo.motionValue;

            }
            else
            {
                cell.nameLabel.text = @"Sound";
                cell.switchValue   = _sensitivityInfo.soundOn;
                cell.settingsValue = _sensitivityInfo.soundValue;
            }
            
            return cell;

        }
        else
        { //if(indexPath.row==2) Tempreture Cell
            static NSString *CellIdentifier = @"SensitivityTemperatureCell";
            SensitivityTemperatureCell *cell = [self.tableViewSettings dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SensitivityTemperatureCell" owner:nil options:nil];
            
            for (id curObj in objects)
            {
                if([curObj isKindOfClass:[SensitivityTemperatureCell class]])
                {
                    cell = (SensitivityTemperatureCell *)curObj;
                    cell.backgroundColor = COLOR_RGB(43.0, 50.0, 56.0);
                    break;
                }
            }
            cell.isFahrenheit    = _sensitivityInfo.tempIsFahrenheit;
            cell.isSwitchOnLeft  = _sensitivityInfo.tempLowOn;
            cell.isSwitchOnRight = _sensitivityInfo.tempHighOn;
            cell.tempValueLeft   = _sensitivityInfo.tempLowValue;
            cell.tempValueRight  = _sensitivityInfo.tempHighValue;
            cell.sensitivityTempCellDelegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.sensitivityTemperatureCell = cell;
            
            return cell;
        }
    }
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
   /* if (indexPath.row == 0)
    {
        _cameraName = self.camChannel.profile.name;
        
        if (_alertViewRename == nil)
        {
            self.alertViewRename = [[UIAlertView alloc] initWithTitle:@"Enter the new Camera name"
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Ok", nil];
            self.alertViewRename.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *textField = [_alertViewRename textFieldAtIndex:0];
            [textField setText:_cameraName];
            self.alertViewRename.tag = ALERT_RENAME_CAMERA;
        }
        
        [_alertViewRename show];
    }
#if ENABLE_CHANGE_IMAGE
    else if (indexPath.row == 1)
    {
        //change Image
        ChangeImageViewController *changeImageVC = [[ChangeImageViewController alloc] initWithNibName:@"ChangeImageViewController" bundle:nil];
        [UIView transitionWithView:self.view
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromBottom
                        animations:^{
                            [self.view addSubview:changeImageVC.view];
                        }
                        completion:NULL];
        
        
    }
#endif
    */
}

#pragma mark - Server methods

- (void)updateFWVersion_bg
{
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSDictionary *responseDict = [jsonComm sendCommandBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                     andCommand:@"action=command&command=get_version"
                                                                      andApiKey:_apiKey];
    [jsonComm release];
    
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            NSString *bodykey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];//get_version: 01.12.84
            
            NSString *cmd = @"get_version";
            
            if ([bodykey hasPrefix:cmd])
            {
                self.camChannel.profile.fw_version = [bodykey substringFromIndex:cmd.length + 2];
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(updateUIRow:) withObject:[NSNumber numberWithInt:1] waitUntilDone:NO];
}

- (void)updateUIRow: (NSNumber *)row
{
    [self.viewPorgress removeFromSuperview];
    NSInteger rowIndex = [row integerValue];
    
    if (rowIndex == 1)
    {
        self.isLoading = FALSE;
    }
    else
    {
        self.isChangingName = FALSE;
    }
    
    [self.tableViewSettings reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:rowIndex
                                                                                               inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) removeLocalCamera
{
    HttpCommunication * dev_comm = [[HttpCommunication alloc]init];
    dev_comm.device_ip = _camChannel.profile.ip_address;
    dev_comm.device_port = _camChannel.profile.port;
    
	NSString * command = SWITCH_TO_DIRECT_MODE;
	[dev_comm sendCommandAndBlock:command];
	
	command = RESTART_HTTP_CMD;
	[dev_comm sendCommandAndBlock:command];
    
    [dev_comm release];
    
    [self removeRemoteCamera];
}

-(void) removeRemoteCamera
{
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(removeCameraSuccessWithResponse:)
                                                                          FailSelector:@selector(removeCameraFailedWithError:)
                                                                             ServerErr:@selector(removeCameraFailedServerUnreachable)] autorelease];
    
    [jsonComm deleteDeviceWithRegistrationId:_camChannel.profile.registrationID
                                   andApiKey:_apiKey];
}

- (void)changeCameraName_bg
{
    [self performSelectorOnMainThread:@selector(changeCameraName) withObject:nil waitUntilDone:NO];
}

- (void)changeCameraName
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //self.navigationItem.hidesBackButton = YES;

    //[self.viewPorgress setHidden:NO];
    //[self.view addSubview:_viewPorgress];
    //[self.view bringSubviewToFront:_viewPorgress];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSLog(@"CameraMenuVC - changeCameraName - _cameraNewName: %@", _cameraNewName);
    NSDictionary *responseDict = [jsonComm updateDeviceBasicInfoBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                               deviceName:_cameraNewName
                                                                                 timeZone:nil
                                                                                     mode:nil
                                                                          firmwareVersion:nil
                                                                                andApiKey:_apiKey];
    [jsonComm release];
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            self.camChannel.profile.name = _cameraNewName;
        }
        else
        {
            NSLog(@"CameraNameVC - Change cameraname failed!");
            
            [[[[UIAlertView alloc] initWithTitle:@"Change Camera Name"
                                         message:[responseDict objectForKey:@"message"]
                                        delegate:self
                               cancelButtonTitle:nil
                               otherButtonTitles:@"OK", nil] autorelease] show];
        }
    }
    else
    {
        NSLog(@"CameraNameVC - doneAction - responseDict == nil");
        
        [[[[UIAlertView alloc] initWithTitle:@"Change Camera Name"
                                     message:@"Server Error"
                                    delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil] autorelease] show];
    }
    
    //self.navigationItem.hidesBackButton = NO;
    
    //[self performSelectorOnMainThread:@selector(updateUIRow:) withObject:[NSNumber numberWithInt:0] waitUntilDone:NO];
    
    [self.tableViewSettings reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

-(BOOL) isCamNameValidated:(NSString *) cameraNames
{
    NSString * regex = @"[a-zA-Z0-9 ._-]+";
    NSPredicate * validatedName = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidatedName = [validatedName evaluateWithObject:cameraNames];
    
    return isValidatedName;
}

#pragma BMS_JSON delegate

- (void) removeCameraSuccessWithResponse:(NSDictionary *)responseData
{
	NSLog(@"CameraMenuVC- removeCam success-- fatality");
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) removeCameraFailedWithError:(NSDictionary *)errorResponse
{
	NSLog(@"CameraMenuVC - removeCam failed errorcode:");
    
    [[[[UIAlertView alloc] initWithTitle:@"Remove Camera"
                                 message:[errorResponse objectForKey:@"message"]
                                delegate:self
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK",
       nil] autorelease] show];
    
}

-(void) removeCameraFailedServerUnreachable
{
	NSLog(@"CameraMenuVC - removeCam server unreachable");
    
    [[[[UIAlertView alloc] initWithTitle:@"Remove Camera"
                                 message:@"Server is unreachable"
                                delegate:self
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK",
       nil] autorelease] show];
}

-(IBAction)btnCameraDetailPressed:(id)sender
{
    if(intTableSectionStatus!=1){
        intTableSectionStatus = 1;
    }else{
        intTableSectionStatus = 0;
    }
    [self.tableViewSettings beginUpdates];
    [self.tableViewSettings reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableViewSettings endUpdates];
    
    

}

-(IBAction)btnNotiSenPressed:(id)sender
{
    if([self.camChannel.profile isNotAvailable]){

        return;
    }
    
    if(intTableSectionStatus!=2){
        intTableSectionStatus = 2;
    }else{
        intTableSectionStatus = 0;
    }
    
    //[self.tableViewSettings reloadData];
     [self.tableViewSettings beginUpdates];
    [self.tableViewSettings reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationAutomatic];
     [self.tableViewSettings endUpdates];
    
    if(intTableSectionStatus==2){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:@"Loading..."];
        [self performSelector:@selector(getSensitivityInfoFromServer) withObject:nil afterDelay:0.1];
    }
}



#pragma mark - Sensitivity deletate

- (void)reportSwitchValue:(BOOL)value andRowIndex:(NSInteger)rowIndex
{
    //valueSwitchs[rowIndex] = value;
    
    NSString *cmd = @"action=command&command=";
    
    if (rowIndex == 0) // Motion
    {
        if (value)
        {
            cmd = [cmd stringByAppendingString:@"set_motion_area&grid=1x1&zone=00"]; // Enable
        }
        else
        {
            cmd = [cmd stringByAppendingString:@"set_motion_area&grid=1x1&zone="]; // Disable
        }
        
        self.sensitivityInfo.motionOn = value;
    }
    else // Sound
    {
        if (value)
        {
            cmd = [cmd stringByAppendingString:@"vox_enable"]; // Enable
        }
        else
        {
            cmd = [cmd stringByAppendingString:@"vox_disable"]; // Disable
        }
        
        self.sensitivityInfo.soundOn = value;
    }
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

- (void)reportChangedSettingsValue:(NSInteger)value atRow:(NSInteger)rowIndx
{
    //valueSettings[rowIndx] = value;
    NSString *cmd = @"action=command&command=";
    
    if (rowIndx == 0) // Motion
    {
        NSInteger motionValue = value==0?SENSITIVITY_MOTION_LOW:(value==1?SENSITIVITY_MOTION_MEDIUM:SENSITIVITY_MOTION_HI);
        
        cmd = [cmd stringByAppendingFormat:@"set_motion_sensitivity&setup=%d", motionValue];
        
        self.sensitivityInfo.motionValue = value;
    }
    else // Sound
    {
        NSInteger soundValue = value==0?SENSITIVITY_SOUND_LOW:(value==1?SENSITIVITY_SOUND_MEDIUM:SENSITIVITY_SOUND_HI);
        cmd = [cmd stringByAppendingFormat:@"vox_set_threshold&value=%d", soundValue];
        
        self.sensitivityInfo.soundOn = value;
    }
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

#pragma  mark - Sensitivity temperature cell delegate

- (void)valueChangedTypeTemperaure:(BOOL)isFahrenheit // NOT need to receive
{
    self.sensitivityInfo.tempIsFahrenheit = isFahrenheit;
}

- (void)valueChangedTempLowValue:(NSInteger)tempValue
{
    self.sensitivityInfo.tempLowValue = tempValue;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_lo_threshold&value=%d", tempValue];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
    
    NSLog(@"%d", tempValue);
}

- (void)valueChangedTempLowOn:(BOOL)isOn
{
    self.sensitivityInfo.tempLowOn = isOn;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_lo_enable&value=%d", isOn];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

- (void)valueChangedTempHighValue:(NSInteger)tempValue
{
    self.sensitivityInfo.tempHighValue = tempValue;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_hi_threshold&value=%d", tempValue];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
    NSLog(@"%d", tempValue);
}

- (void)valueChangedTempHighOn:(BOOL)isOn
{
    self.sensitivityInfo.tempHighOn = isOn;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_hi_enable&value=%d", isOn];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

#pragma mark - BMS_JSON Comm

- (void)sendToServerTheCommand:(NSString *) command
{
    if (_jsonComm == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonComm = comm;
        [comm release];
    }
    
    NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                      andCommand:command
                                                                       andApiKey:_apiKey];
    //NSLog(@"SettingsVC - sendCommand: %@, response: %@", command, responseDict);
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSInteger errorCode = -1;
    NSString *errorMessage = @"Update failed";
    
    if (responseDict)
    {
        errorCode = [[responseDict objectForKey:@"status"] integerValue];
        
        if (errorCode == 200)
        {
            errorCode = [[[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"device_response_code"] integerValue];
        }
        else
        {
            errorMessage = [responseDict objectForKey:@"message"];
        }
    }
    
    NSLog(@"%s cmd:%@, error: %d", __func__, command, errorCode);
    
    if (errorCode == 200)
    {
        if (_shouldWaitForUpdateSettings)
        {
            self.shouldWaitForUpdateSettings = FALSE;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        MBProgressHUD *showError = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [showError setLabelText:errorMessage];
        [showError setMode:MBProgressHUDModeText];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (_shouldWaitForUpdateSettings)
            {
                self.shouldWaitForUpdateSettings = FALSE;
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    }
}

-(void)btnChangeCameraName
{
    _cameraName = self.camChannel.profile.name;
    
    if (_alertViewRename == nil)
    {
        self.alertViewRename = [[UIAlertView alloc] initWithTitle:@"Change Camera Name"
                                                          message:@"Enter the new camera name."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"OK", nil];
        self.alertViewRename.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [_alertViewRename textFieldAtIndex:0];
        [textField setText:_cameraName];
        [textField setPlaceholder:@"Eg. Living Room,Nursery,etc"];
        self.alertViewRename.tag = ALERT_RENAME_CAMERA;
    }
    
    [_alertViewRename show];
}

-(void)btnChangeCameraIcon
{
    [UIActionSheet showInView:self.view
                    withTitle:@"Change Image"
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
            otherButtonTitles:@[@"Select image from gallery", @"Take a photo from Camera",@"Take a snapshot now"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
    {
        if(actionSheet.cancelButtonIndex == buttonIndex)
        {
            return ;
        }
        
        if(buttonIndex==1 && ![UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera])
        {
            Alert(nil, @"You iOS device have not camera.")
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //picker.allowsEditing = YES;
        if(buttonIndex==0)//Gallery
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else if(buttonIndex==1)//Camera
        {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if(buttonIndex==2)//Snapshot
        {
            [self performSelector:@selector(openViewForSetCameraFromURL) withObject:nil afterDelay:0.1];
            return;
        }
        [self presentViewController:picker animated:YES completion:NULL];
        
    }];
}

#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imageSelected = [[info valueForKey:UIImagePickerControllerOriginalImage] copy];
   
    [self dismissViewControllerAnimated:YES completion:^{
       
        [self uploadImageToServer:imageSelected];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *strPath = [paths objectAtIndex:0];
        
        strPath = [strPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.camChannel.profile.registrationID]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:strPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
        }
        [UIImageJPEGRepresentation(imageSelected, 0.5) writeToFile:strPath atomically:YES];

    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)openViewForSetCamera:(UIImage *)image
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select Picture"
                                                    delegate:nil
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Set Picture", nil];
    as.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    if(image)
    {
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        imageV.frame = CGRectMake(35, -300, 250, 250);
        [as addSubview:imageV];
        [imageV release];
    }
    
    as.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
        NSLog(@"Chose %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
        
        if(actionSheet.cancelButtonIndex!=buttonIndex)
        {
            //self.camChannel.profile.registrationID
            NSArray *paths = NSSearchPathForDirectoriesInDomains
            (NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *strPath = [paths objectAtIndex:0];
            
            strPath = [strPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.camChannel.profile.registrationID]];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:strPath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
            }
            [UIImageJPEGRepresentation(image, 0.5) writeToFile:strPath atomically:YES];
            // [strPath release];
        }
    };
    [as showInView:self.view];
}

-(void)openViewForSetCameraFromURL
{
    vwSnapshot.alpha = 0.0;
    vwSnapshot.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        vwSnapshot.alpha = 1.0;
    }];
    
    [self btnSnapshotRefreshPressed:nil];
}

-(IBAction)btnSnapshotRefreshPressed:(id)sender
{
    if(!imgVSnapshot.isAnimating)
    {
        imgVSnapshot.animationImages =[NSArray arrayWithObjects:
                                   [UIImage imageNamed:@"loader_big_a"],
                                   [UIImage imageNamed:@"loader_big_b"],
                                   [UIImage imageNamed:@"loader_big_c"],
                                   [UIImage imageNamed:@"loader_big_d"],
                                   [UIImage imageNamed:@"loader_big_e"],
                                   nil];
        imgVSnapshot.animationDuration = 1.5;
        [imgVSnapshot startAnimating];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                   ^{
                       NSString *strURL = [self getSnapImageFromCamera];
                       if(strURL==nil)
                       {
                           return ;
                       }
                       NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [imgVSnapshot stopAnimating];
                           imageSelected = [UIImage imageWithData:data];
                           imgVSnapshot.image = imageSelected;
                       });
                   });
}

-(IBAction)btnSnapshotOKPressed:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        vwSnapshot.alpha = 0.0;
    } completion:^(BOOL finished) {
        vwSnapshot.hidden = YES;
    }];
    
    if(imageSelected)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *strPath = [paths objectAtIndex:0];
        
        strPath = [strPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.camChannel.profile.registrationID]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:strPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
        }
        [UIImageJPEGRepresentation(imageSelected, 0.5) writeToFile:strPath atomically:YES];
    }
}


-(NSString*)getSnapImageFromCamera
{
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSDictionary *responseDict = [jsonComm sendCommandBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                     andCommand:@"action=command&command=get_image_snapshot"
                                                                      andApiKey:_apiKey];
    [jsonComm release];
    
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            sleep(15);
            return [self getSnapImageUrlFromServer];
        }
    }
    return nil;
}

- (NSString *)getSnapImageUrlFromServer
{
    BMS_JSON_Communication *jsonCommDeviceInfo = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                       Selector:nil
                                                                                   FailSelector:nil
                                                                                      ServerErr:nil];
    NSDictionary *responseDictDInfo = [jsonCommDeviceInfo getDeviceBasicInfoBlockedWithRegistrationId:self.camChannel.profile.registrationID andApiKey:_apiKey];
    [jsonCommDeviceInfo release];
    if (responseDictDInfo)
    {
        if ([[responseDictDInfo objectForKey:@"status"] integerValue] == 200)
        {            
            return [[responseDictDInfo valueForKey:@"data"] valueForKey:@"snaps_url"];
        }
    }
    return nil;
}

//MOVE THIS IN FRAMEWORK
-(NSString*)getUploadToken
{
    NSString *strURLForGetUploadToken = @"https://api.hubble.in/v1/users/upload_token.json";
    NSMutableURLRequest *postRequestForUploadToken = [[NSMutableURLRequest alloc] init];
    [postRequestForUploadToken setURL:[NSURL URLWithString:strURLForGetUploadToken]];
    [postRequestForUploadToken setHTTPMethod:@"POST"];
    
    NSString *strPara  = [NSString stringWithFormat:@"api_key=%@",_apiKey];
    [postRequestForUploadToken setHTTPBody:[strPara dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response1;
    NSError *error1;
    NSData *dataResponseToken = [NSURLConnection sendSynchronousRequest:postRequestForUploadToken returningResponse:&response1 error:&error1];
    NSString *strToken = [[NSString alloc] initWithData:dataResponseToken encoding:NSASCIIStringEncoding];
    NSLog(@"--- %@",strToken);
    NSDictionary *dicResultToken  = [NSJSONSerialization JSONObjectWithData:dataResponseToken options:NSJSONReadingMutableLeaves error:nil];
    if(dicResultToken!=nil && [[dicResultToken valueForKey:@"status"] intValue]==200)
    {
        return [[dicResultToken valueForKey:@"data"] valueForKey:@"upload_token"];
    }
    return nil;
}



-(void)uploadImageToServer:(UIImage*)image
{
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Uploading image ..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *strUploadToken = [[self getUploadToken] retain];
        NSData *dataImage = [UIImageJPEGRepresentation(image, 1.0) retain];
        
        BMS_JSON_Communication *jsonCommDeviceInfo = [[BMS_JSON_Communication alloc] initWithObject:self Selector:nil FailSelector:nil ServerErr:nil];
        
        NSDictionary *responseDictDInfo = [jsonCommDeviceInfo uploadImageWithASIFormDataRequest:dataImage registerID:[self.camChannel.profile.registrationID retain] uploadToken:strUploadToken];
        
        if (responseDictDInfo)
        {
            if ([[responseDictDInfo objectForKey:@"status"] integerValue] == 200)
            {
                // NSLog(@"-- %@",responseDictDInfo);
                hud.mode = MBProgressHUDModeText;
                [hud setLabelText:@"Upload image successfully"];
            }
        }
        
        [hud hide:YES afterDelay:2.0];
    });
}


- (void)getSensitivityInfoFromServer
{
    //self.selectedReg = [[NSUserDefaults standardUserDefaults] stringForKey:@"REG"];
    //NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"PortalApiKey"];
    
    if(self.sensitivityInfo==nil){
        SensitivityInfo *senInfo = [[SensitivityInfo alloc] init];
        self.sensitivityInfo = senInfo;
        [senInfo release];
    }
    
    if (_jsonComm == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonComm = comm;
        [comm release];
    }
    
    NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                      andCommand:@"action=command&command=device_setting"
                                                                       andApiKey:_apiKey];
    
    self.isLoading = FALSE;
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            // "body": "error_in_control_command : 701"
            // "body:: "device_setting: ms=1,me=70,vs=1,vt=80,hs=0,ls=1,ht=30,lt=18"
            NSString *body = [[[responseDict objectForKey: @"data"] objectForKey: @"device_response"] objectForKey: @"body"];
            
            if ([body hasPrefix:@"error"])
            {
                //numOfRows[indexPath.section] = 2;
                intTableSectionStatus=0;
                self.sensitivityMessage = body;
            }
            else
            {
                NSRange range = [body rangeOfString:@": "];
                
                if (range.location != NSNotFound)
                {
                    NSString *settingsValue = [body substringFromIndex:range.location + 2];
                    NSMutableArray *settingsArray = (NSMutableArray *)[settingsValue componentsSeparatedByString:@","];
                    
                    for (int i = 0; i < settingsArray.count; ++i)
                    {
                        settingsArray[i] = [settingsArray[i] substringFromIndex:3];
                    }
                    
                    self.sensitivityInfo.motionOn      = [settingsArray[0] integerValue];
                    
                    self.sensitivityInfo.motionValue = SENSITIVITY_MOTION_VALUE([settingsArray[1] integerValue]);

                    self.sensitivityInfo.soundOn       = [settingsArray[2] boolValue];
                    
                    self.sensitivityInfo.soundValue = SENSITIVITY_SOUND_VALUE([settingsArray[3] integerValue]);
                    
                    self.sensitivityInfo.tempLowOn     = [settingsArray[5] boolValue];
                    self.sensitivityInfo.tempHighOn    = [settingsArray[4] boolValue];
                    
                    self.sensitivityInfo.tempLowValue  = [settingsArray[7] integerValue];
                    self.sensitivityInfo.tempHighValue = [settingsArray[6] integerValue];
                    
                    self.sensitivityInfo.tempIsFahrenheit = [[NSUserDefaults standardUserDefaults] boolForKey:IS_FAHRENHEIT];
                    NSLog(@"%s, mv:%d, sv:%d", __FUNCTION__, _sensitivityInfo.motionValue, _sensitivityInfo.soundValue);
                    //numOfRows[indexPath.section] = 4;
                    //self.isExistSensitivityData = TRUE;
                }
                else
                {
                    //numOfRows[indexPath.section] = 2;
                    intTableSectionStatus = 0;
                    self.sensitivityMessage = @"Error -Load Sensitivity Settings!";
                }
            }
        }
        else
        {
            //numOfRows[indexPath.section] = 2;
            intTableSectionStatus = 0;
            self.sensitivityMessage = @"Error -Load Sensitivity Settings error!";
        }
    }
    else
    {
       // numOfRows[indexPath.section] = 2;
        intTableSectionStatus=0;
        self.sensitivityMessage = @"Error -Load Sensitivity Settings error!";
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.tableViewSettings reloadData];
    
    if(intTableSectionStatus==0)
    {
        MBProgressHUD *showError = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [showError setLabelText:self.sensitivityMessage];
        [showError setMode:MBProgressHUDModeText];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
    }
}


@end
