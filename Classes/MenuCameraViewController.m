//
//  MenuCameraViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/19/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define ALERT_REMOVE_CAM 5

#define ALERT_REMOVE_CAM_LOCAL 6
#define ALERT_REMOVE_CAM_REMOTE 7

#import <MonitorCommunication/MonitorCommunication.h>

#import "MenuCameraViewController.h"
#import "CameraSettingsCell.h"
#import "CameraNameViewController.h"

@interface MenuCameraViewController () <UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *viewProgress;
@end

@implementation MenuCameraViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Camera Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                            target:self
                                                                                            action:@selector(removeAction:)] autorelease];
    assert(self.navigationItem.rightBarButtonItem != nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)removeAction: (id)sender
{
    UIActivityIndicatorView *activityIndicator =
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    activityIndicator.color = [UIColor blackColor];
    UIBarButtonItem * barButton =
    [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    // Set to Left or Right
    [[self navigationItem] setRightBarButtonItem:barButton];
    
    [barButton release];
    [activityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.hidesBackButton = YES;
    self.view.userInteractionEnabled = NO;
    
    self.viewProgress.frame = UIScreen.mainScreen.bounds;
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    [self  showDialog:ALERT_REMOVE_CAM];
}

- (void) showDialog:(int) dialogType
{
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
	switch (dialogType) {
            
		case ALERT_REMOVE_CAM:
		{
			BOOL deviceInLocal = _camChannel.profile.isInLocal;
            
            if (deviceInLocal)
            {
                NSString * msg = NSLocalizedStringWithDefaultValue(@"Confirm_remove_cam_local",nil, [NSBundle mainBundle],
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
        [self.viewProgress removeFromSuperview];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.hidesBackButton = NO;
        self.view.userInteractionEnabled = YES;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                                target:self
                                                                                                action:@selector(removeAction:)] autorelease];
        assert(self.navigationItem.rightBarButtonItem != nil);
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
                                                                              Selector:@selector(removeCamSuccessWithResponse:)
                                                                          FailSelector:@selector(removeCamFailedWithError:)
                                                                             ServerErr:@selector(removeCamFailedServerUnreachable)] autorelease];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mac = [Util strip_colon_fr_mac:_camChannel.profile.mac_address];
    NSLog(@"mac_address = %@", mac);
    
    [jsonComm deleteDeviceWithRegistrationId:mac andApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        static NSString *CellIdentifier = @"CameraSettingsCell";
        CameraSettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CameraSettingsCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            
            if([curObj isKindOfClass:[UITableViewCell class]])
            {
                cell = (CameraSettingsCell *)curObj;
                break;
            }
        }


        cell.nameLabel.text = @"Name";
        cell.valueLabel.text = self.camChannel.profile.name;
        
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
        cell.textLabel.text = @"Change Image";
        
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
        CameraNameViewController *cameraNameViewController = [[CameraNameViewController alloc] initWithNibName:@"CameraNameViewController"
                                                                                                        bundle:nil];
        
        // Pass the selected object to the new view controller.
        
        // Push the view controller.
        cameraNameViewController.cameraName = self.camChannel.profile.name;
        [self.navigationController pushViewController:cameraNameViewController animated:YES];
        
        [cameraNameViewController release];
    }
}


#pragma BMS_JSON delegate

- (void) removeCamSuccessWithResponse:(NSDictionary *)responseData
{
	NSLog(@"removeCam success-- fatality");
    
    //[self forceRelogin];
	//[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [_menuCamerasDelegate sendStatus:AFTER_DEL_RELOGIN];
}

- (void) removeCamFailedWithError:(NSDictionary *)errorResponse
{
	NSLog(@"removeCam failed errorcode:");
    //[self forceRelogin];
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [_menuCamerasDelegate sendStatus:AFTER_DEL_RELOGIN];
}

-(void) removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
    //[self forceRelogin];
    //[self.navigationController popViewControllerAnimated:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [_menuCamerasDelegate sendStatus:AFTER_DEL_RELOGIN];
}

- (void)dealloc {
    [_viewProgress release];
    [super dealloc];
}
@end
