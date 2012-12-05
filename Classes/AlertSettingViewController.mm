//
//  AlertSettingViewController.m
//  MBP_ios
//
//  Created by NxComm on 10/1/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "AlertSettingViewController.h"

@interface AlertSettingViewController ()

@end

@implementation AlertSettingViewController


@synthesize  camera;
@synthesize soundCellView, tempHiCellView,  tempLoCellView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@" viewdidload camera: %@",camera.name);
    
    [f_title  setText:camera.name];
    
    [self.view addSubview:progressView];
    [self.view bringSubviewToFront:progressView];
    
    progressView.hidden = NO;
    
    // Do any additional setup after loading the view from its nib.
    
    [self performSelector:@selector(query_disabled_alert_list:) withObject:self.camera afterDelay:0.1];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillDisappear:(BOOL)animated {
	NSArray *viewControllers = self.navigationController.viewControllers;
	if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self)
    {
        
    }
    else if ([viewControllers indexOfObject:self] == NSNotFound)
    {
		// View is disappearing because it was popped from the stack
		NSLog(@"View controller was popped --- ");
        
        [self.navigationController setNavigationBarHidden:YES];
        
	}
}



-(void) viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO];
	[self checkOrientation];
}


-(void) checkOrientation
{
    
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
    
    
    
}
//// DEPRECATED from IOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	return YES;
}

//////////////// IOS6 replacement

-(BOOL) shouldAutorotate
{
    NSLog(@"Should Auto Rotate");
  	return YES;
}

/////////////

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
	[self adjustViewsForOrientation:toInterfaceOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    
    
    BOOL shouldShowProgress = progressView.hidden;
    NSString * f_titleText = f_title.text; 
    
    
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        
        [[NSBundle mainBundle] loadNibNamed:@"AlertSettingViewController_land"
                                      owner:self
                                    options:nil];


        
        
    }
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        
        [[NSBundle mainBundle] loadNibNamed:@"AlertSettingViewController"
                                      owner:self
                                    options:nil];

        
	}
    
    
    
    
    f_title.text =f_titleText;
    progressView.hidden = shouldShowProgress;
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"didRotateFromInterfaceOrientation 1");
    [alertTable reloadData];
}

#pragma mark -
#pragma mark Table view delegates & datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UISwitch * alertSw;
    switch (indexPath.row) {
        case 0:
            alertSw = (UISwitch *) [soundCellView viewWithTag:1];
            [alertSw setOn:camera.soundAlertEnabled];
            
            return soundCellView;
            break;
        case 1:
            alertSw = (UISwitch *) [tempHiCellView viewWithTag:1];
            [alertSw setOn:camera.tempHiAlertEnabled];
            
            return tempHiCellView;
            break;
        case 2:
            alertSw = (UISwitch *) [tempLoCellView viewWithTag:1];
            [alertSw setOn:camera.tempLoAlertEnabled];
            
            return tempLoCellView;
            break;
        default:
            break;
    }
    NSLog(@"Index is:%d", indexPath.row);
    
    return nil ;
    
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
    
    
}

#pragma mark -

-(IBAction)donePressed:(id)sender
{
    //[self dismissModalViewControllerAnimated:NO	];
    [self.navigationController popViewControllerAnimated:NO];
    
}

-(IBAction)soundAlertChanged   :(id)sender
{
    UISwitch * alertSw = (UISwitch *) sender;
    if (camera.soundAlertEnabled  ==  alertSw.isOn )
    {
        
    }
    else
    {
        
        progressView.hidden = NO;
        [self.view bringSubviewToFront:progressView];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                       selector:@selector(updateSoundAlert:)
                                       userInfo:alertSw
                                        repeats:NO];
        
    }
}

-(void) updateSoundAlert:(NSTimer *) exp
{
    UISwitch * alertSw = (UISwitch *) exp.userInfo;
    NSLog(@"update sound alert");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * user_email  = (NSString*)[userDefaults objectForKey:@"PortalUseremail"];
    
    
    BMS_Communication * bms_alerts = [[BMS_Communication alloc] initWithObject:self
                                                                      Selector:nil
                                                                  FailSelector:nil
                                                                     ServerErr:nil];
    if (alertSw.isOn)
    {
        //call get camlist query here
        NSData* responseData = [bms_alerts BMS_enabledAlertBlockWithUser_1:user_email
                                                                   AndPass:user_pass
                                                                     ofMac:camera.mac_address
                                                                 alertType:ALERT_TYPE_SOUND];
    }
    else
    {
        //call get camlist query here
        NSData* responseData = [bms_alerts BMS_disabledAlertBlockWithUser_1:user_email
                                                                    AndPass:user_pass
                                                                      ofMac:camera.mac_address
                                                                  alertType:ALERT_TYPE_SOUND];
        
    }
    
    camera.soundAlertEnabled  =  alertSw.isOn;
    progressView.hidden = YES;
    
}

-(IBAction)tempHiAlertChanged   :(id)sender
{
    UISwitch * alertSw = (UISwitch *) sender;
    if (camera.tempHiAlertEnabled ==  alertSw.isOn )
    {
        
    }
    else
    {
        
        progressView.hidden = NO;
        [[progressView superview] bringSubviewToFront:progressView];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                       selector:@selector(updateTempHiAlert:)
                                       userInfo:alertSw
                                        repeats:NO];
        
        
        
    }
}

-(void) updateTempHiAlert:(NSTimer *) exp
{
    
    UISwitch * alertSw = (UISwitch *) exp.userInfo;
    
    NSLog(@"update temmp hi alert");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * user_email  = (NSString*)[userDefaults objectForKey:@"PortalUseremail"];
    
    
    BMS_Communication * bms_alerts = [[BMS_Communication alloc] initWithObject:self
                                                                      Selector:nil
                                                                  FailSelector:nil
                                                                     ServerErr:nil];
    
    if (alertSw.isOn)
    {
        
        NSData* responseData = [bms_alerts BMS_enabledAlertBlockWithUser_1:user_email
                                                                   AndPass:user_pass
                                                                     ofMac:camera.mac_address
                                                                 alertType:ALERT_TYPE_TEMP_HI];
    }
    else
    {
        
        NSData* responseData = [bms_alerts BMS_disabledAlertBlockWithUser_1:user_email
                                                                    AndPass:user_pass
                                                                      ofMac:camera.mac_address
                                                                  alertType:ALERT_TYPE_TEMP_HI];
        
    }
    
    camera.tempHiAlertEnabled  =  alertSw.isOn;
    
    progressView.hidden = YES;
    
}
-(IBAction)tempLoAlertChanged   :(id)sender
{
    UISwitch * alertSw = (UISwitch *) sender;
    if (camera.tempLoAlertEnabled  ==  alertSw.isOn )
    {
        
    }
    else
    {
        
        progressView.hidden = NO;
        [[progressView superview] bringSubviewToFront:progressView];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                       selector:@selector(updateTempLoAlert:)
                                       userInfo:alertSw
                                        repeats:NO];
        
        
        
    }
}
-(void) updateTempLoAlert:(NSTimer *) exp
{
    
    UISwitch * alertSw = (UISwitch *) exp.userInfo;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * user_email  = (NSString*)[userDefaults objectForKey:@"PortalUseremail"];
    
    
    BMS_Communication * bms_alerts = [[BMS_Communication alloc] initWithObject:self
                                                                      Selector:nil
                                                                  FailSelector:nil
                                                                     ServerErr:nil];
    NSLog(@"update temmp log alert");
    if (alertSw.isOn)
    {
        //call get camlist query here
        NSData* responseData = [bms_alerts BMS_enabledAlertBlockWithUser_1:user_email
                                                                   AndPass:user_pass
                                                                     ofMac:camera.mac_address
                                                                 alertType:ALERT_TYPE_TEMP_LO];
    }
    else
    {
        //call get camlist query here
        NSData* responseData = [bms_alerts BMS_disabledAlertBlockWithUser_1:user_email
                                                                    AndPass:user_pass
                                                                      ofMac:camera.mac_address
                                                                  alertType:ALERT_TYPE_TEMP_LO];
        
    }
    
    camera.tempLoAlertEnabled  =  alertSw.isOn;    progressView.hidden = YES;
    
}

#pragma  mark -
#pragma  mark query disabled alerts

-(void) query_disabled_alert_list:(CamProfile *) cp
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * userName = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * userPass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
    //All enabled - default
    cp.soundAlertEnabled = TRUE;
    cp.tempHiAlertEnabled = TRUE;
    cp.tempLoAlertEnabled = TRUE;
    
    BMS_Communication * bms_alerts = [[BMS_Communication alloc] initWithObject:self
                                                                      Selector:nil
                                                                  FailSelector:nil
                                                                     ServerErr:nil];
	
	//call get camlist query here
	NSData* responseData = [bms_alerts BMS_getDisabledAlertBlockWithUser_1:userName
                                                                   AndPass:userPass
                                                                     ofMac:cp.mac_address];
    
    
    NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"response: %@", raw_data);
    //    Response:
    //    ""<br>mac=[mac address]
    //    <br>cameraname=[camera name]
    //    <br>Total_disabled_alerts=[count]
    //    <br>alert=<alert>
    //    <br>alert=<alert>
    //    <br>alert=<alert>
    NSArray * token_list;
    
	token_list = [raw_data componentsSeparatedByString:@"<br>"];
    if ([token_list count] > 4)
    {
        int alertCount;
        
        NSArray * token_list_1 = [[token_list objectAtIndex:3] componentsSeparatedByString:@"="];
        
        alertCount = [[token_list_1 objectAtIndex:1] intValue];
        NSLog(@"Alert disabled is: %d", alertCount);
        
        int i = 0;
        NSString * disabledAlert;
        while (i < alertCount)
        {
            token_list_1 = [[token_list objectAtIndex:(i+4)] componentsSeparatedByString:@"="];
            
            disabledAlert= [token_list_1 objectAtIndex:1] ;
            disabledAlert = [disabledAlert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSLog(@"disabledAlert disabled is:%@--> %@",[token_list objectAtIndex:(i+4)],  disabledAlert);
            
            if ( [disabledAlert isEqualToString:ALERT_TYPE_SOUND])
            {
                NSLog(@"Set sound  for cam: %@", cp.mac_address);
                cp.soundAlertEnabled = FALSE;
                
            }
            else if ( [disabledAlert isEqualToString:ALERT_TYPE_TEMP_HI] )
            {
                NSLog(@"Set tempHiAlertEnabled  for cam: %@", cp.mac_address);
                cp.tempHiAlertEnabled = FALSE;
                
            }
            else if ([disabledAlert isEqualToString:ALERT_TYPE_TEMP_LO] )
            {
                NSLog(@"Set temp low  for cam: %@", cp.mac_address);
                cp.tempLoAlertEnabled = FALSE;
            }
            
            i++;
        }
        
        
        
        
    }
    else
    {
        NSLog(@"Token list count <4 :%@, %@, %@, %@",[token_list objectAtIndex:0],
              [token_list objectAtIndex:1],
              [token_list objectAtIndex:2],
              [token_list objectAtIndex:3]);
        
        
        
    }
    
    
    
    
    [alertTable reloadData];
    progressView.hidden = YES;
    
    
    
}



#pragma  mark -

@end
