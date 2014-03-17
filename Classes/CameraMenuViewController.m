//
//  CameraMenuViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#define ALERT_REMOVE_CAM 5

#define ALERT_REMOVE_CAM_LOCAL 6
#define ALERT_REMOVE_CAM_REMOTE 7

#import "CameraMenuViewController.h"
#import "CameraSettingsCell.h"
#import "CameraNameViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "define.h"
#import "ChangeImageViewController.h"

@interface CameraMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *tableViewSettings;
@property (retain, nonatomic) IBOutlet UIButton *btnRmoveCamera;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;

@property (retain, nonatomic) NSString *stringFW_Version;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.view setUserInteractionEnabled:YES];
    
    [self.tableViewSettings reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                                               inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

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
            
		default:
			break;
	}
}

#pragma  mark - Alert Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSString *mac = [Util strip_colon_fr_mac:_camChannel.profile.mac_address];
    
    [jsonComm deleteDeviceWithRegistrationId:_camChannel.profile.registrationID
                                   andApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
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
    return 3;
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
        _alertView.tag = 5;
        [_alertView show];
        [_alertView release];
    }
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
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (buttonIndex == 1)
    {
        _cameraNewName = (NSString *)([alertView textFieldAtIndex:0].text);
        NSLog(@"new Camera name is %@", _cameraNewName);
        
        if ([self isCamNameValidated:_cameraNewName])
        {
            [alertView dismissWithClickedButtonIndex:0 animated:NO];
            [self doneAction:nil];
        }
    }
}

- (void)doneAction: (id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.hidesBackButton = YES;

    [self.viewPorgress setHidden:NO];
    [self.view addSubview:_viewPorgress];
    [self.view bringSubviewToFront:_viewPorgress];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults stringForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSDictionary *responseDict = [jsonComm updateDeviceBasicInfoBlockedWithRegistrationId:self.camChannel.profile.registrationID
                                                                               deviceName:_cameraNewName
                                                                                 timeZone:nil
                                                                                     mode:nil
                                                                          firmwareVersion:nil
                                                                                andApiKey:apiKey];
    [jsonComm release];
    NSLog(@"responseDict when change name is %@", responseDict);
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            self.camChannel.profile.name = _cameraNewName;
            [self.viewPorgress setHidden:YES];
            self.navigationItem.hidesBackButton = NO;
            [self.tableViewSettings reloadData];
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
}

-(BOOL) isCamNameValidated:(NSString *) cameraNames
{
    if (cameraNames.length < 3 ||
        CAMERA_NAME_MAX < cameraNames.length)
    {
        return FALSE;
    }
    
    NSString * regex = @"[a-zA-Z0-9._-]+";
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
