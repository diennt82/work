//
//  CameraMenuViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
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

@interface CameraMenuViewController () <UITableViewDataSource, UITableViewDelegate,SensitivityCellDelegate,SensitivityTemperaureCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableViewSettings;
@property (nonatomic, strong) IBOutlet UIButton *btnRmoveCamera;
@property (nonatomic, strong) IBOutlet UIView *viewProgress;
@property (nonatomic, strong) IBOutlet UIView *vwHeaderCamDetail;
@property (nonatomic, strong) IBOutlet UIView *vwHeaderNotSens;

@property (nonatomic, strong) IBOutlet UIView *vwSnapshot;
@property (nonatomic, strong) IBOutlet UIImageView *imgVSnapshot;
@property (nonatomic, strong) IBOutlet UIButton *btnSnapshotRefresh;
@property (nonatomic, strong) IBOutlet UIButton *btnSnapshotOK;

@property (nonatomic, strong) UIImage *imageSelected;
@property (nonatomic, strong) UIAlertView *alertViewRename;

@property (nonatomic, strong) SensitivityInfo *sensitivityInfo;
@property (nonatomic, strong) BMS_JSON_Communication *jsonComm;

@property (nonatomic, copy) NSString *selectedReg;
@property (nonatomic, copy) NSString *sensitivityMessage;
@property (nonatomic, copy) NSString *cameraNewName;
@property (nonatomic, copy) NSString *stringFW_Version;
@property (nonatomic, copy) NSString *apiKey;

@property (nonatomic, assign) int intTableSectionStatus; // 0 No open, 1 = 0 section open , 2 = 1 section open

@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isChangingName;

@end

@implementation CameraMenuViewController

#pragma mark - ViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Camera Settings";
    self.intTableSectionStatus = 0;
    
    _tableViewSettings.delegate = self;
    _tableViewSettings.dataSource = self;
    
    [_btnRmoveCamera setBackgroundImage:[UIImage imageNamed:@"remove_camera"]
                               forState:UIControlStateNormal];
    [_btnRmoveCamera setBackgroundImage:[UIImage imageNamed:@"remove_camera_pressed"]
                               forState:UIControlEventTouchDown];
    
    self.stringFW_Version = LocStr(@"firmware_version");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.apiKey = [userDefaults stringForKey:@"PortalApiKey"];
    
    _tableViewSettings.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    
    UIImageView *imgView = (UIImageView*)[_vwHeaderNotSens viewWithTag:500];
    if ([_camChannel.profile isNotAvailable]) {
        imgView.image = [UIImage imageNamed:@"sensitivity_disable"];
    }
    
    //Snapshot View
    _vwSnapshot.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _vwSnapshot.hidden = YES;
    [self.view addSubview:_vwSnapshot];
    
    UIBarButtonItem *removeCamButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                     target:self
                                                                                     action:@selector(removeCameraAction:)];
    self.navigationItem.rightBarButtonItem = removeCamButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.view setUserInteractionEnabled:YES];
}

#pragma mark - Action methods

- (void)removeCameraAction:(id)sender
{
    self.view.userInteractionEnabled = NO;
    _btnRmoveCamera.enabled = NO;
    
    _viewProgress.frame = UIScreen.mainScreen.bounds;
    _viewProgress.hidden = NO;
    [self.view bringSubviewToFront:_viewProgress];
    
    [self showDialog:ALERT_REMOVE_CAM];
}

#pragma mark - Private methods

- (void)showDialog:(int)dialogType
{
    NSString *title = @"";
    NSString *ok = LocStr(@"Ok");
    NSString *cancel = LocStr(@"Cancel");
    
    NSString *msg = nil;
    int tag = NSNotFound;
    
	switch (dialogType) {
		case ALERT_REMOVE_CAM:
		{
			BOOL deviceInLocal = _camChannel.profile.isInLocal;
            if (deviceInLocal) {
                msg = LocStr(@"Confirm_remove_cam_local");
                tag = ALERT_REMOVE_CAM_LOCAL;
            }
            else {
                msg = LocStr(@"Confirm_remove_cam_remote");
                tag = ALERT_REMOVE_CAM_REMOTE;
            }
            break;
		}
        case ALERT_RENAME_REPORT:
        {
            msg = @"Invaldate name";
            tag = ALERT_RENAME_REPORT;
            break;
        }
        case ALERT_RENAME_CANT_EMPTY:
		{
            msg = LocStr(@"Camera_name_cant_be_empty");
			tag = ALERT_RENAME_CANT_EMPTY;
            break;
		}
        case ALERT_RENAME_OUT_LENGTH:
        {
            title = LocStr(@"Invalid_Camera_Name");
            msg = LocStr(@"Invalid_Camera_Name_msg");
            tag = ALERT_RENAME_OUT_LENGTH;
            break;
        }
        case ALERT_RENAME_REGEX:
        {
            title = LocStr(@"Invalid_Camera_Name");
            msg = LocStr(@"Invalid_Camera_Name_msg2");
            tag = ALERT_RENAME_REGEX;
            break;
        }
		default:
			break;
	}
    
    if ( msg ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:cancel
                                              otherButtonTitles:ok, nil];
        alert.tag = tag;
        [alert show];
    }
}

#pragma  mark - Alert Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_RENAME_CAMERA) {
        if (buttonIndex == 1) {
            NSString *newName = [alertView textFieldAtIndex:0].text;
            
            if( (newName == nil) || newName.length == 0) {
                [self showDialog:ALERT_RENAME_CANT_EMPTY];
            }
            else if (newName.length < MIN_LENGTH_CAMERA_NAME || MAX_LENGTH_CAMERA_NAME < newName.length) {
                [self showDialog:ALERT_RENAME_OUT_LENGTH];
            }
            else if (![self isCamNameValidated:newName]) {
                [self showDialog:ALERT_RENAME_REGEX];
            }
            else {
                if (![newName isEqualToString:self.camChannel.profile.name]) {
                    self.cameraNewName = newName;
                    self.isChangingName = YES;
                    [_tableViewSettings reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        [hud setLabelText:@"Updating..."];
                        [self changeCameraName];
                    });
                }
                else {
                    NSLog(@"CameraMenuVC - the same as current name");
                }
            }
        }
    }
    else if(ALERT_REMOVE_CAM) {
        if (buttonIndex == 1) {
            int tag = alertView.tag ;
            
            if (tag == ALERT_REMOVE_CAM_LOCAL) {
                [self removeLocalCamera];
            }
            else if (tag == ALERT_REMOVE_CAM_REMOTE) {
                [self removeRemoteCamera];
            }
        }
        else {
            self.view.userInteractionEnabled = YES;
            _viewProgress.hidden = YES;
            _btnRmoveCamera.enabled = YES;
        }
    }
    else {
        // ALERT_RENAME_REPORT - Do nothing
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2; //1 for Camera Detail , 2 for Noti. Sensi.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return 1;
    }
    else if ( section == 1 ) {
        return 3;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _vwHeaderCamDetail;
    }
    else {
        return _vwHeaderNotSens;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( _intTableSectionStatus == 0 ) {
        return 0;
    }
    else {
        if (indexPath.section == 0 && _intTableSectionStatus == 1) {
            return 198;
        }
        else if (indexPath.section == 1 && _intTableSectionStatus == 2) {
            if (indexPath.row == 0 || indexPath.row == 1) {
                return 120;
            }
            else {
                return 227;
            }
        }
    }

    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        //General Setting
        static NSString *cellIdentifier = @"CameraDetailCell";
        CameraDetailCell *camDetCell = (CameraDetailCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if ( !camDetCell ) {
            [[NSBundle mainBundle] loadNibNamed:@"CameraDetailCell" owner:self options:nil];
            camDetCell = (CameraDetailCell *)_tableViewCell;
            self.tableViewCell = nil;
            
            [camDetCell.btnChangeImage addTarget:self action:@selector(btnChangeCameraIcon) forControlEvents:UIControlEventTouchUpInside];
            [camDetCell.btnChangeName addTarget:self action:@selector(btnChangeCameraName) forControlEvents:UIControlEventTouchUpInside];
            
            camDetCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        camDetCell.lblCameraName.text = _camChannel.profile.name;
        camDetCell.lblCamVer.text = _camChannel.profile.fw_version;
        
        cell =  camDetCell;
    }
    else {
        //Sensitive Setting
        if (indexPath.row==0 || indexPath.row==1) {
            //Motion & Sound
            static NSString *CellIdentifier = @"SensitivityCell";
            SensitivityCell *sensitivityCell = [_tableViewSettings dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SensitivityCell" owner:nil options:nil];
            for (id curObj in objects) {
                if ([curObj isKindOfClass:[UITableViewCell class]]) {
                    sensitivityCell = (SensitivityCell *)curObj;
                    break;
                }
            }
            sensitivityCell.selectionStyle = UITableViewCellSelectionStyleNone;
            sensitivityCell.sensitivityCellDelegate = self;
            sensitivityCell.rowIndex = indexPath.row ;
            
            if (indexPath.row == 0) {
                sensitivityCell.nameLabel.text = @"Motion";
                sensitivityCell.switchValue   = _sensitivityInfo.motionOn;
                sensitivityCell.settingsValue = _sensitivityInfo.motionValue;
            }
            else {
                sensitivityCell.nameLabel.text = @"Sound";
                sensitivityCell.switchValue   = _sensitivityInfo.soundOn;
                sensitivityCell.settingsValue = _sensitivityInfo.soundValue;
            }
            
            cell = sensitivityCell;
        }
        else {
            // (indexPath.row==2) Tempreture Cell
            static NSString *CellIdentifier = @"SensitivityTemperatureCell";
            SensitivityTemperatureCell *stCell = [_tableViewSettings dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SensitivityTemperatureCell" owner:nil options:nil];
            for (id curObj in objects) {
                if ([curObj isKindOfClass:[SensitivityTemperatureCell class]]) {
                    stCell = (SensitivityTemperatureCell *)curObj;
                    break;
                }
            }
            
            stCell.isFahrenheit    = _sensitivityInfo.tempIsFahrenheit;
            stCell.isSwitchOnLeft  = _sensitivityInfo.tempLowOn;
            stCell.isSwitchOnRight = _sensitivityInfo.tempHighOn;
            stCell.tempValueLeft   = _sensitivityInfo.tempLowValue;
            stCell.tempValueRight  = _sensitivityInfo.tempHighValue;
            stCell.sensitivityTempCellDelegate = self;
            stCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell = stCell;
        }
    }
    
    cell.backgroundColor = COLOR_RGB(43.0, 50.0, 56.0);
    return cell;
}

#pragma mark - Server methods

- (void)updateFWVersion_bg
{
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    NSDictionary *responseDict = [jsonComm sendCommandBlockedWithRegistrationId:_camChannel.profile.registrationID
                                                                     andCommand:@"action=command&command=get_version"
                                                                      andApiKey:_apiKey];
    if (responseDict) {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200) {
            NSString *bodykey = [[responseDict[@"data"] objectForKey:@"device_response"] objectForKey:@"body"];//get_version: 01.12.84
            NSString *cmd = @"get_version";
            
            if ([bodykey hasPrefix:cmd]) {
                _camChannel.profile.fw_version = [bodykey substringFromIndex:cmd.length + 2];
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(updateUIRow:) withObject:[NSNumber numberWithInt:1] waitUntilDone:NO];
}

- (void)updateUIRow:(NSNumber *)row
{
    NSInteger rowIndex = [row integerValue];
    
    if (rowIndex == 1) {
        self.isLoading = NO;
    }
    else {
        self.isChangingName = NO;
    }
    
    [_tableViewSettings reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeLocalCamera
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.tabBarController.tabBar.userInteractionEnabled = NO;

    HttpCommunication *comm = [[HttpCommunication alloc]init];
    comm.device_ip = _camChannel.profile.ip_address;
    comm.device_port = _camChannel.profile.port;
    
	NSString *command = SWITCH_TO_DIRECT_MODE;
	[comm sendCommandAndBlock:command];
	
	command = RESTART_HTTP_CMD;
	[comm sendCommandAndBlock:command];
    
    [self removeRemoteCamera];
}

- (void)removeRemoteCamera
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.tabBarController.tabBar.userInteractionEnabled = NO;

    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(removeCameraSuccessWithResponse:)
                                                                          FailSelector:@selector(removeCameraFailedWithError:)
                                                                             ServerErr:@selector(removeCameraFailedServerUnreachable)];
    
    [jsonComm deleteDeviceWithRegistrationId:_camChannel.profile.registrationID andApiKey:_apiKey];
}

- (void)changeCameraName_bg
{
    [self performSelectorOnMainThread:@selector(changeCameraName) withObject:nil waitUntilDone:NO];
}

- (void)changeCameraName
{
    DLog(@"CameraMenuVC - changeCameraName - _cameraNewName: %@", _cameraNewName);

    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    NSDictionary *responseDict = [jsonComm updateDeviceBasicInfoBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                               deviceName:_cameraNewName
                                                                                 timeZone:nil
                                                                                     mode:nil
                                                                          firmwareVersion:nil
                                                                                andApiKey:_apiKey];
    if ( responseDict ) {
        if ([responseDict[@"status"] integerValue] == 200) {
            _camChannel.profile.name = _cameraNewName;
        }
        else {
            DLog(@"CameraNameVC - Change cameraname failed!");
            
            [[[UIAlertView alloc] initWithTitle:@"Change Camera Name"
                                         message:responseDict[@"message"]
                                        delegate:self
                               cancelButtonTitle:nil
                               otherButtonTitles:@"OK", nil] show];
        }
    }
    else {
        DLog(@"CameraNameVC - doneAction - responseDict == nil");
        
        [[[UIAlertView alloc] initWithTitle:@"Change Camera Name"
                                     message:@"Server Error"
                                    delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil] show];
    }
    
    [_tableViewSettings reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (BOOL)isCamNameValidated:(NSString *)cameraNames
{
    NSString * regex = @"[a-zA-Z0-9 ._-]+";
    NSPredicate * validatedName = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidatedName = [validatedName evaluateWithObject:cameraNames];
    return isValidatedName;
}

#pragma BMS_JSON delegate

- (void)removeCameraSuccessWithResponse:(NSDictionary *)responseData
{
	DLog(@"CameraMenuVC- removeCam success-- fatality");
    [self.navigationController popViewControllerAnimated:YES];
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}

- (void)removeCameraFailedWithError:(NSDictionary *)errorResponse
{
	DLog(@"CameraMenuVC - removeCam failed errorcode:");
    
    [[[UIAlertView alloc] initWithTitle:@"Remove Camera"
                                 message:[errorResponse objectForKey:@"message"]
                                delegate:self
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] show];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}

- (void)removeCameraFailedServerUnreachable
{
	DLog(@"CameraMenuVC - removeCam server unreachable");
    
    [[[UIAlertView alloc] initWithTitle:@"Remove Camera"
                                 message:@"Server is unreachable"
                                delegate:self
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] show];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}

#pragma mark - Custom action methods

- (IBAction)btnCameraDetailPressed:(id)sender
{
    if ( _intTableSectionStatus != 1 ) {
        self.intTableSectionStatus = 1;
    }
    else {
        self.intTableSectionStatus = 0;
    }
    
    [_tableViewSettings beginUpdates];
    [_tableViewSettings reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableViewSettings endUpdates];
}

- (IBAction)btnNotiSenPressed:(id)sender
{
    if ([_camChannel.profile isNotAvailable]) {
        return;
    }
    
    if ( _intTableSectionStatus != 2) {
        self.intTableSectionStatus = 2;
    }
    else {
        self.intTableSectionStatus = 0;
    }
    
    [_tableViewSettings beginUpdates];
    [_tableViewSettings reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableViewSettings endUpdates];
    
    if ( _intTableSectionStatus == 2 ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:@"Loading..."];
        [self performSelector:@selector(getSensitivityInfoFromServer) withObject:nil afterDelay:0.1];
    }
}

#pragma mark - Sensitivity deletate

- (void)reportSwitchValue:(BOOL)value andRowIndex:(NSInteger)rowIndex
{
    NSString *cmd = @"action=command&command=";
    
    if (rowIndex == 0) {
        // Motion
        if (value) {
            cmd = [cmd stringByAppendingString:@"set_motion_area&grid=1x1&zone=00"]; // Enable
        }
        else {
            cmd = [cmd stringByAppendingString:@"set_motion_area&grid=1x1&zone="]; // Disable
        }
        
        self.sensitivityInfo.motionOn = value;
    }
    else {
        // Sound
        if (value) {
            cmd = [cmd stringByAppendingString:@"vox_enable"]; // Enable
        }
        else {
            cmd = [cmd stringByAppendingString:@"vox_disable"]; // Disable
        }
        
        self.sensitivityInfo.soundOn = value;
    }
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

- (void)reportChangedSettingsValue:(NSInteger)value atRow:(NSInteger)rowIndx
{
    NSString *cmd = @"action=command&command=";
    
    if (rowIndx == 0) {
        // Motion
        NSInteger motionValue = SENSITIVITY_MOTION_LOW;
        
        if (value == 0) {
            motionValue = SENSITIVITY_MOTION_LOW;
        }
        else if(value == 1) {
            motionValue = SENSITIVITY_MOTION_MEDIUM;
        }
        else {
            // value = 2
            motionValue = SENSITIVITY_MOTION_HI;
        }
        
        cmd = [cmd stringByAppendingFormat:@"set_motion_sensitivity&setup=%d", motionValue];
        
        self.sensitivityInfo.motionValue = value;
    }
    else {
        // Sound
        NSInteger soundValue = SENSITIVITY_SOUND_LOW;
        
        if (value == 0) {
            soundValue = SENSITIVITY_SOUND_LOW;
        }
        else if(value == 1) {
            soundValue = SENSITIVITY_SOUND_MEDIUM;
        }
        else {
            // value = 2
            soundValue = SENSITIVITY_SOUND_HI;
        }
        
        cmd = [cmd stringByAppendingFormat:@"vox_set_threshold&value=%d", soundValue];
        
        _sensitivityInfo.soundOn = value;
    }
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

#pragma  mark - Sensitivity temperature cell delegate

- (void)valueChangedTypeTemperaure:(BOOL)isFahrenheit // NOT need to receive
{
    _sensitivityInfo.tempIsFahrenheit = isFahrenheit;
}

- (void)valueChangedTempLowValue:(NSInteger)tempValue
{
    _sensitivityInfo.tempLowValue = tempValue;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_lo_threshold&value=%d", tempValue];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
    NSLog(@"%d", tempValue);
}

- (void)valueChangedTempLowOn:(BOOL)isOn
{
    _sensitivityInfo.tempLowOn = isOn;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_lo_enable&value=%d", isOn];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

- (void)valueChangedTempHighValue:(NSInteger)tempValue
{
    _sensitivityInfo.tempHighValue = tempValue;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_hi_threshold&value=%d", tempValue];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
    NSLog(@"%d", tempValue);
}

- (void)valueChangedTempHighOn:(BOOL)isOn
{
    _sensitivityInfo.tempHighOn = isOn;
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_temp_hi_enable&value=%d", isOn];
    
    [self performSelectorInBackground:@selector(sendToServerTheCommand:) withObject:cmd];
}

#pragma mark - BMS_JSON Comm

- (void)sendToServerTheCommand:(NSString *)command
{
    if ( !_jsonComm ) {
        self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil];
    }
    
    NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                      andCommand:command
                                                                       andApiKey:_apiKey];
    if (responseDict) {
        NSLog(@"SettingsVC - sendCommand successfully: %@, status: %@", command, [responseDict objectForKey:@"status"]);
    }
    else {
        NSLog(@"SettingsVC - sendCommand failed responseDict = nil: %@", command);
    }
}

- (void)btnChangeCameraName
{
    _cameraName = _camChannel.profile.name;
    
    if ( !_alertViewRename )
    {
        self.alertViewRename = [[UIAlertView alloc] initWithTitle:@"Change Camera Name"
                                                          message:@"Enter the new camera name."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"OK", nil];
        _alertViewRename.alertViewStyle = UIAlertViewStylePlainTextInput;
        _alertViewRename.tag = ALERT_RENAME_CAMERA;
        
        UITextField *textField = [_alertViewRename textFieldAtIndex:0];
        [textField setText:_cameraName];
        [textField setPlaceholder:@"Eg. Living Room,Nursery,etc"];
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
        if (actionSheet.cancelButtonIndex == buttonIndex) {
            return;
        }
        
        if (buttonIndex==1 && ![UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
            Alert(nil, @"You iOS device have not camera.")
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        
        if (buttonIndex==0) {
            //Gallery
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else if (buttonIndex==1) {
            //Camera
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if (buttonIndex==2) {
            //Snapshot
            [self performSelector:@selector(openViewForSetCameraFromURL) withObject:nil afterDelay:0.1];
            return;
        }
        
        [self presentViewController:picker animated:YES completion:NULL];
    }];
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageSelected = [info valueForKey:UIImagePickerControllerOriginalImage];
   
    [self dismissViewControllerAnimated:YES completion:^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *strPath = [paths firstObject];
        strPath = [strPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.camChannel.profile.registrationID]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:strPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
        }
        
        [UIImageJPEGRepresentation(_imageSelected, 0.5) writeToFile:strPath atomically:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)openViewForSetCamera:(UIImage *)image
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select Picture"
                                                    delegate:nil
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Set Picture", nil];
    as.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    if (image) {
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        imageV.frame = CGRectMake(35, -300, 250, 250);
        [as addSubview:imageV];
    }
    
    as.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
        NSLog(@"Chose %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
        
        if (actionSheet.cancelButtonIndex!=buttonIndex) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *strPath = [paths firstObject];
            strPath = [strPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.camChannel.profile.registrationID]];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:strPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
            }
            
            [UIImageJPEGRepresentation(image, 0.5) writeToFile:strPath atomically:YES];
        }
    };
    
    [as showInView:self.view];
}

- (void)openViewForSetCameraFromURL
{
    _vwSnapshot.alpha = 0.0;
    _vwSnapshot.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        _vwSnapshot.alpha = 1.0;
    }];
    
    [self btnSnapshotRefreshPressed:nil];
}

- (IBAction)btnSnapshotRefreshPressed:(id)sender
{
    _imgVSnapshot.animationImages =[NSArray arrayWithObjects:
                                   [UIImage imageNamed:@"loader_big_a"],
                                   [UIImage imageNamed:@"loader_big_b"],
                                   [UIImage imageNamed:@"loader_big_c"],
                                   [UIImage imageNamed:@"loader_big_d"],
                                   [UIImage imageNamed:@"loader_big_e"],
                                   nil];
    _imgVSnapshot.animationDuration = 1.5;
    [_imgVSnapshot startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *strURL = [self getSnapImageFromCamera];
        if( !strURL ) {
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_imgVSnapshot stopAnimating];
            self.imageSelected = [UIImage imageWithData:data];
            _imgVSnapshot.image = _imageSelected;
        });
    });
}

- (IBAction)btnSnapshotOKPressed:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        _vwSnapshot.alpha = 0.0;
    } completion:^(BOOL finished) {
        _vwSnapshot.hidden = YES;
    } ];
    
    if (_imageSelected) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *strPath = [paths firstObject];
        strPath = [strPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.camChannel.profile.registrationID]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:strPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
        }
        
        [UIImageJPEGRepresentation(_imageSelected, 0.5) writeToFile:strPath atomically:YES];
    }
}


- (NSString *)getSnapImageFromCamera
{
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSDictionary *responseDict = [jsonComm sendCommandBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                     andCommand:@"action=command&command=get_image_snapshot"
                                                                      andApiKey:_apiKey];
    
    if (responseDict) {
        if ([responseDict[@"status"] integerValue] == 200) {
            BMS_JSON_Communication *jsonCommDeviceInfo = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                               Selector:nil
                                                                                           FailSelector:nil
                                                                                              ServerErr:nil];
            NSDictionary *responseDictDInfo = [jsonCommDeviceInfo getDeviceBasicInfoBlockedWithRegistrationId:self.camChannel.profile.registrationID andApiKey:_apiKey];
            if (responseDictDInfo) {
                if ([responseDictDInfo[@"status"] integerValue] == 200) {
                    NSLog(@"-- %@",[responseDictDInfo[@"data"] valueForKey:@"snaps_url"]);
                    return [responseDictDInfo[@"data"] valueForKey:@"snaps_url"];
                }
            }
        }
    }
    
    return nil;
}

- (void)getSensitivityInfoFromServer
{
    if ( !_sensitivityInfo) {
        self.sensitivityInfo = [[SensitivityInfo alloc] init];
    }
    
    if ( !_jsonComm ) {
        self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil];
    }
    
    NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                      andCommand:@"action=command&command=device_setting"
                                                                       andApiKey:_apiKey];
    self.isLoading = NO;
    
    if ( [responseDict[@"status"] integerValue] == 200 ) {
        // "body": "error_in_control_command : 701"
        // "body : "device_setting: ms=1,me=70,vs=1,vt=80,hs=0,ls=1,ht=30,lt=18"
        NSString *body = [[responseDict[@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
        if ( [body hasPrefix:@"error"] ) {
            self.intTableSectionStatus = 0;
            self.sensitivityMessage = body;
        }
        else {
            NSRange range = [body rangeOfString:@": "];
            if (range.location != NSNotFound) {
                NSString *settingsValue = [body substringFromIndex:range.location + 2];
                NSMutableArray *settingsArray = (NSMutableArray *)[settingsValue componentsSeparatedByString:@","];
                
                for (int i = 0; i < settingsArray.count; ++i) {
                    settingsArray[i] = [settingsArray[i] substringFromIndex:3];
                }
                
                self.sensitivityInfo.motionOn = [settingsArray[0] integerValue];
                NSLog(@"%@, %d", settingsArray[0], [settingsArray[0] integerValue]);
                
                if ([settingsArray[1] integerValue] <= 10) {
                    _sensitivityInfo.motionValue = 0;
                }
                else if (10 < [settingsArray[1] integerValue] && [settingsArray[1] integerValue] <= 50) {
                    _sensitivityInfo.motionValue = 1;
                }
                else {
                    _sensitivityInfo.motionValue = 2;
                }
                
                self.sensitivityInfo.soundOn = [settingsArray[2] boolValue];
                
                if (80 <= [settingsArray[3] integerValue]) {
                    _sensitivityInfo.soundValue = 0;
                }
                else if (70 <= [settingsArray[3] integerValue] && [settingsArray[3] integerValue] < 80) {
                    _sensitivityInfo.soundValue = 1;
                }
                else {
                    _sensitivityInfo.soundValue = 2;
                }
                
                _sensitivityInfo.tempLowOn     = [settingsArray[5] boolValue];
                _sensitivityInfo.tempHighOn    = [settingsArray[4] boolValue];
                
                _sensitivityInfo.tempLowValue  = [settingsArray[7] integerValue];
                _sensitivityInfo.tempHighValue = [settingsArray[6] integerValue];
            }
            else {
                self.intTableSectionStatus = 0;
                self.sensitivityMessage = @"Error -Load Sensitivity Settings!";
            }
        }
    }
    else {
        self.intTableSectionStatus = 0;
        self.sensitivityMessage = @"Error -Load Sensitivity Settings error!";
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.tableViewSettings reloadData];
    
    if ( _intTableSectionStatus == 0 ) {
        MBProgressHUD *showError = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [showError setLabelText:_sensitivityMessage];
        [showError setMode:MBProgressHUDModeText];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
    }
}

@end
