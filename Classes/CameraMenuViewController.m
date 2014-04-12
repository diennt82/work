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

#define ALERT_REMOVE_CAM        5
#define ALERT_REMOVE_CAM_LOCAL  6
#define ALERT_REMOVE_CAM_REMOTE 7

#define ALERT_RENAME_CAMERA         8
#define ALERT_RENAME_REPORT         9
#define ALERT_RENAME_CANT_EMPTY     10
#define ALERT_RENAME_OUT_LENGTH     11
#define ALERT_RENAME_REGEX          12


#define ENABLE_CHANGE_IMAGE 0

@interface CameraMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *tableViewSettings;
@property (retain, nonatomic) IBOutlet UIButton *btnRmoveCamera;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;

@property (retain, nonatomic) NSString *stringFW_Version;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic) BOOL isChangingName;

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
    // Do any additional setup after loading the view from its nib.
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
    
    if (![self.camChannel.profile isNotAvailable])
    {
        self.isLoading = TRUE;
        [self performSelectorInBackground:@selector(updateFWVersion_bg) withObject:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.view setUserInteractionEnabled:YES];
}

#pragma mark - Action

- (IBAction)btnRemoveCameraTouchUpInsideAction:(id)sender
{
    self.navigationItem.hidesBackButton = YES;
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
                                                                   @"Please confirm that you want to remove this camera from your account. The camera is not accessible right now, it will not be switched to setup mode. Please refer to FAQ to reset it manually.", nil);
                
                
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
                                                               @"Camera Name has to be between 3-20 characters", nil);
            
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
            else if (newName.length < 3 || CAMERA_NAME_MAX < newName.length)
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
                    _cameraNewName = newName;
                    self.isChangingName = TRUE;
                    [self.tableViewSettings reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                                                               inSection:0]]
                                                  withRowAnimation:UITableViewRowAnimationAutomatic];

                    [self changeCameraName];
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
            
            self.navigationItem.hidesBackButton = NO;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
#if ENABLE_CHANGE_IMAGE
    return 3;
#else
    return 2;
#endif
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"General";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.camChannel.profile.name.length > 10 &&
        indexPath.row == 0)
    {
        return 66;
    }
    
    return 45;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
}

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


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
    if (indexPath.row == 0)
    {
        _cameraName = self.camChannel.profile.name;
        _alertView = [[UIAlertView alloc] init];
        [_alertView setDelegate:self];
        [_alertView setTitle:@"Change Camera Name"];
        [_alertView setMessage:@"Enter the new camera location"];
        _alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        //get text of textField
        UITextField *textField = [_alertView textFieldAtIndex:0];
        [textField setText:_cameraName];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [_alertView addButtonWithTitle:@"Cancel"];
        [_alertView addButtonWithTitle:@"OK"];
        _alertView.tag = ALERT_RENAME_CAMERA;
        [_alertView show];
        [_alertView release];
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
    self.navigationItem.hidesBackButton = YES;

    [self.viewPorgress setHidden:NO];
    [self.view addSubview:_viewPorgress];
    [self.view bringSubviewToFront:_viewPorgress];
    
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
    
    self.navigationItem.hidesBackButton = NO;
    
    [self performSelectorOnMainThread:@selector(updateUIRow:) withObject:[NSNumber numberWithInt:0] waitUntilDone:NO];
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
    [super dealloc];
}
@end
