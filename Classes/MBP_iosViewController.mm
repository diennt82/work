//
//  MBP_iosViewController.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import <CFNetwork/CFNetwork.h>
#import "MBP_FirstPage.h"
#import "MBP_iosViewController.h"
//#import "MBP_CamView.h"
#import "Util.h"
#import "ADPCMDecoder.h"
#import "AsyncUdpSocket.h"


#import "CameraPassword.h"
#include <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import  "IpAddress.h"


@implementation MBP_iosViewController

//@synthesize  mainMenuView;

@synthesize toTakeSnapShot,recordInProgress ;
@synthesize bc_addr,own_addr;


@synthesize channel_array; 
@synthesize restored_profiles ; 

@synthesize progressView;



@synthesize app_stage;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
// Custom initialization

}
return self;
}
 */

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

[super loadView];


}*/

- (void) initialize 
{
	self.toTakeSnapShot = NO;
	self.recordInProgress = NO;


	self.app_stage = APP_STAGE_INIT;

}

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	[super viewDidLoad];

    
    //self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	[self initialize];

	//go Back to main menu
	[NSTimer scheduledTimerWithTimeInterval:2
		target:self
		selector:@selector(wakeup_display_login:)
		userInfo:nil
		repeats:NO];

    



}

- (void)wakeup_display_login:(NSTimer*) timer_exp
{

	self.app_stage = APP_STAGE_INIT;

	//hide splash screen page
	[self.view addSubview:backgroundView];


    //load user/pass
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//can be user email or user name here --
	NSString * old_usr = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
	NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    
    if (old_usr  != nil && old_pass != nil)
    {
        
        [userDefaults setBool:TRUE forKey:_AutoLogin];
        [userDefaults synchronize];
        
        
        MBP_LoginOrRegistration * loginOrReg;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            loginOrReg = [[MBP_LoginOrRegistration alloc] initWithNibName:@"MBP_LoginOrRegistration_ipad"
                                                        bundle:nil
                                              withConnDelegate:self];
        }
        else
        {
            loginOrReg = [[MBP_LoginOrRegistration alloc]
                          initWithNibName:@"MBP_LoginOrRegistration"
                                                        bundle:nil
                                              withConnDelegate:self];
        }
        
        //Use navigation controller
        [loginOrReg presentModallyOn:self];
    }
    else
    {
        MBP_FirstPage * firstPage;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage_ipad"
                                                        bundle:nil
                                              withConnDelegate:self];
        }
        else
        {
            firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage"
                                                        bundle:nil
                                              withConnDelegate:self];
        }
        
        
        [self presentModalViewController:firstPage animated:NO];
        
    }



}


- (void)wakeup_display_first_page:(NSTimer*) timer_exp
{
    
	self.app_stage = APP_STAGE_INIT;
    
	//hide splash screen page
	[self.view addSubview:backgroundView];
    
    MBP_FirstPage * firstPage;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage_ipad"
                                                    bundle:nil
                                          withConnDelegate:self];
    }
    else
    {
        firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage"
                                                    bundle:nil
                                          withConnDelegate:self];
    }
    
    [self presentModalViewController:firstPage animated:NO];
    
    
}




-(void) startShowingCameraList
{

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSLog(@"Load IPad");
        
        dashBoard = [[DashBoard_ViewController alloc] initWithNibName:@"DashBoard_ViewController_ipad"
                                                               bundle:nil
                                                     withConnDelegate:self];
    }
    else
    {
        NSLog(@"Load IPhne");

        dashBoard = [[DashBoard_ViewController alloc] initWithNibName:@"DashBoard_ViewController"
                                                               bundle:nil
                                                     withConnDelegate:self];
    }


	


	NSMutableArray * validChannels = [[NSMutableArray alloc]init ];

	for (int i =0 ; i< [channel_array count]; i++)
	{
		CamChannel * ch = [channel_array objectAtIndex:i]; 
		if (ch.profile != nil)
			[validChannels addObject:[channel_array objectAtIndex:i]]; 

	}
	dashBoard.listOfChannel = validChannels;

	[dashBoard presentModallyOn:self];

}



/*
// Override to allow orientations other than the default portrait orientation.
  */
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

	return YES;

}




- (BOOL) shouldAutorotate
{
    
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{

    return UIInterfaceOrientationMaskAllButUpsideDown;
}







- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {

	// [mainMenuView release];

	[bc_addr release];
	[own_addr release];

	[channel_array release]; 
	[restored_profiles release];


	[super dealloc];
}

-(void) viewWillAppear:(BOOL)animated
{

//    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    //[self adjustViewsForOrientations:interfaceOrientation];
}

#pragma mark -
#pragma mark Rotating



-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustViewsForOrientations:toInterfaceOrientation];
}

-(void) adjustViewsForOrientations: (UIInterfaceOrientation) interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"MBP_iosViewController_ipad" owner:self options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"MBP_iosViewController_land" owner:self options:nil];
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"MBP_iosViewController_ipad" owner:self options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"MBP_iosViewController" owner:self options:nil];
        }
    }
}

#pragma mark -
#pragma mark ConnectionMethodDelegate - Views navigation 

/**** Main program switching point is here *****/ 
- (void)sendStatus:(int) method
{
	switch (method) {
		case SETUP_CAMERA: 
			{

				NSLog(@">>> SETUP ");
				[self dismissModalViewControllerAnimated:NO	];

                
                self.app_stage = APP_STAGE_SETUP;

                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                BOOL isFirstTimeSetup = [userDefaults boolForKey:FIRST_TIME_SETUP];
                if (isFirstTimeSetup ==FALSE)
                {
                    //Normal add cam sequence
                    //Load the next xib
                    Step_02_ViewController *step02ViewController = nil;
                    
                    
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        step02ViewController = [[Step_02_ViewController alloc]
                                                initWithNibName:@"Step_02_ViewController_ipad" bundle:nil];
                    }
                    else
                    {
                        
                        step02ViewController = [[Step_02_ViewController alloc]
                                                initWithNibName:@"Step_02_ViewController" bundle:nil];
                    }
                    

                    step02ViewController.delegate = self;
                    [step02ViewController presentModallyOn:self];
                }
                else
                {
                    
                    MBP_InitialSetupViewController *initSeupViewController = nil;
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        
                        initSeupViewController = [[MBP_InitialSetupViewController alloc]
                                                  initWithNibName:@"MBP_InitialSetupViewController_ipad" bundle:nil];
                        
                    }
                    else
                    {   
                        initSeupViewController = [[MBP_InitialSetupViewController alloc]
                                                  initWithNibName:@"MBP_InitialSetupViewController" bundle:nil];
                        
                    }
                    
                    initSeupViewController.delegate = self;
                    [initSeupViewController presentModallyOn:self];
                    
                }

				break;
			}
		case LOGIN: //GOTO ROUTER mode - Login
			{
				//NSLog(@">>> Login "); 

				[self dismissModalViewControllerAnimated:NO	];

                
				NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

				[userDefaults setBool:TRUE forKey:_AutoLogin];
				[userDefaults synchronize];

                
                MBP_LoginOrRegistration * loginOrReg;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    loginOrReg = [[MBP_LoginOrRegistration alloc] initWithNibName:@"MBP_LoginOrRegistration_ipad"
                                                                           bundle:nil
                                                                 withConnDelegate:self];
                }
                else
                {
                    loginOrReg = [[MBP_LoginOrRegistration alloc]
                                  initWithNibName:@"MBP_LoginOrRegistration"
                                  bundle:nil
                                  withConnDelegate:self];
                }


				


				//Use navigation controller 
				[loginOrReg presentModallyOn:self];

				break;
			}
		case SCAN_CAMERA:
			//may be offline mode
            NSLog(@"start scanning"); 
            statusDialogLabel.hidden = NO;
			self.app_stage = APP_STAGE_LOGGED_IN;

			[self performSelector:@selector(scan_for_devices)
                       withObject:nil
                       afterDelay:0.1];

			//Back from login- login success 
			[self dismissModalViewControllerAnimated:NO];
			self.progressView.hidden = NO;

			break; 
		case AFTER_ADD_RELOGIN:
			{
				NSLog(@" back from adding cam. relogin -- to get the new cam data");

				NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				[userDefaults setBool:TRUE forKey:_AutoLogin];
				[userDefaults synchronize];



				[NSTimer scheduledTimerWithTimeInterval:0.01
					target:self
					selector:@selector(show_login_or_reg:)
					userInfo:nil
					repeats:NO];

				break; 
			}
		case AFTER_DEL_RELOGIN: //Just remove camera, currently in CameraMenu page 
			{

                statusDialogLabel.hidden = YES;
				[self dismissModalViewControllerAnimated:NO];

				NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				[userDefaults setBool:TRUE forKey:_AutoLogin];
				[userDefaults synchronize];

				[NSTimer scheduledTimerWithTimeInterval:2.0
					target:self
					selector:@selector(show_login_or_reg:)
					userInfo:nil
					repeats:NO];

				break;
			}
		case  BACK_FRM_MENU_NOLOAD: //USED by AppDelegate as well.. please check if modifying this case
			{
				NSLog(@"Back from menu");
                statusDialogLabel.hidden = YES;
				[self dismissModalViewControllerAnimated:NO];
				//[self.streamer startStreaming];
                


				break;
			}
		case  FRONT_PAGE:
			{
				NSLog(@" display first page ");
                statusDialogLabel.hidden = YES;
                [self dismissModalViewControllerAnimated:NO];
        
                [NSTimer scheduledTimerWithTimeInterval:0.01
                                                 target:self
                                               selector:@selector(wakeup_display_first_page:)
                                               userInfo:nil
                                                repeats:NO];

				break;
			}
		case LOGIN_FAILED_OR_LOGOUT : //back from login -failed Or logout
			{
                statusDialogLabel.hidden = YES;
				[self dismissModalViewControllerAnimated:NO	];

                [self performSelectorInBackground:@selector(logoutAndUnregistration_bg) withObject:nil];
			
				break;
			}
		default:
			break;
	}

}


- (BOOL) isThisMacStoredOffline:(NSString*) mac_without_colon
{

	if (self.restored_profiles == nil && 
			self.channel_array == nil)
	{
		// No offline data is available --> force re login
		return FALSE;

	}


	CamProfile * cp = nil; 
	for (int i =0; i< [self.restored_profiles count]; i++)
	{
		cp = (CamProfile *) [self.restored_profiles objectAtIndex:i]; 
		if (cp!= nil && 
				cp.mac_address != nil )
		{
			NSString *  mac_wo_colon = [Util strip_colon_fr_mac:cp.mac_address]; 
			if ([mac_wo_colon isEqualToString:mac_without_colon])
			{
				return TRUE; 
			}
		}

	}


	return FALSE; 
}



-(BOOL) pushNotificationRcvedInForeground:(CameraAlert *) camAlert

{
	//Check if we should popup
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//mac with COLON 
	NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];

	if (camInView != nil)
	{

		if ( [[Util strip_colon_fr_mac:camInView] isEqualToString:camAlert.cameraMacNoColon])
		{
			NSLog(@"Silencely return, don't popup"); 
			return FALSE;
		}

	}


    NSString * msg = NSLocalizedStringWithDefaultValue(@"Sound_detected",nil, [NSBundle mainBundle],
                                                       @"Sound detected", nil);



	if ( [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_HI]  )
	{
		msg =NSLocalizedStringWithDefaultValue( @"Temperature_too_high",nil, [NSBundle mainBundle],
                                                @"Temperature too high", nil);
	}
	else if ([camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_LO])
	{
		msg =NSLocalizedStringWithDefaultValue( @"Temperature_too_low",nil, [NSBundle mainBundle],
                                                    @"Temperature too low", nil);
	}


	if (pushAlert != nil )
	{
		if ([pushAlert isVisible])
		{
			[pushAlert dismissWithClickedButtonIndex:0 animated:NO]; 
		}

		[pushAlert release]; 
	}

    
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                       @"Cancel", nil);
    
    NSString * msg2 = NSLocalizedStringWithDefaultValue(@"Go_to_Camera_list",nil, [NSBundle mainBundle],
                                                       @"Go to Camera list", nil);
    
	pushAlert = [[UIAlertView alloc]
		initWithTitle:camAlert.cameraName
		message:msg
		delegate:self
		cancelButtonTitle:cancel
		otherButtonTitles:msg2,nil];
	if ([self isThisMacStoredOffline:camAlert.cameraMacNoColon])
	{

		pushAlert.tag = ALERT_PUSH_RECVED_RESCAN_AFTER;
	}
	else
	{
		NSLog(@"Relogin"); 
		[self sendStatus:2];
		pushAlert.tag = ALERT_PUSH_RECVED_RELOGIN_AFTER;
	}

	[pushAlert show];


	return TRUE; 

}

-(void) logoutAndUnregistration_bg
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSLog(@"De-Register push with both parties: APNs and BMS ");
    
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * user_email  = (NSString*)[userDefaults objectForKey:@"PortalUseremail"];
    NSString * devTokenStr =(NSString*) [userDefaults objectForKey:_push_dev_token];
    
    //REmove password and registration id
    [userDefaults removeObjectForKey:@"PortalPassword"];
    [userDefaults removeObjectForKey:_push_dev_token];
    //[userDefaults setBool:FALSE forKey:_AutoLogin];
    [userDefaults synchronize];
    
    
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    BMS_Communication * bms_comm1;
    bms_comm1  = [[BMS_Communication alloc] initWithObject:self
                                                  Selector:nil
                                              FailSelector:nil
                                                 ServerErr:nil];
    
    //NSData * response_dat =
    [bms_comm1 BMS_sendPushUnRegistrationBlockWithUser:user_email
                                                                       AndPass:user_pass
                                                                         regId:devTokenStr];
    
    
    
    [NSThread sleepForTimeInterval:0.10];
    
    [self performSelectorOnMainThread:@selector(show_login_or_reg:)
                           withObject:nil
                        waitUntilDone:NO];
    
	[pool release];
}





#pragma mark -
#pragma mark Alertview delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

	int tag = alertView.tag ;

	if (tag == ALERT_PUSH_RECVED_RESCAN_AFTER)
	{
		switch(buttonIndex) {
			case 0:
				break;
			case 1:


				if (dashBoard != nil)
				{
					NSLog(@"close all windows and thread"); 

					//[dashBoard.navigationController popToRootViewControllerAnimated:NO]; 

					NSArray * views = dashBoard.navigationController.viewControllers;                     
					NSLog(@"views count = %d",[views count] );
					if ( [views count] > 1) 
					{
						CameraViewController * camView = (CameraViewController *) [views objectAtIndex:1]; 
						[camView goBackToCameraList]; 
					}




				}

				[self dismissModalViewControllerAnimated:NO];

				NSLog(@"Re-scan "); 
				[self sendStatus:3];



				break;
			default:
				break;

		}
	}
	else if (tag == ALERT_PUSH_RECVED_RELOGIN_AFTER)
	{
		switch(buttonIndex) {
			case 0:
				break;
			case 1:


				if (dashBoard != nil)
				{
					NSLog(@"close all windows and thread"); 

					//[dashBoard.navigationController popToRootViewControllerAnimated:NO]; 

					NSArray * views = dashBoard.navigationController.viewControllers;                     
					NSLog(@"views count = %d",[views count] );
					if ( [views count] > 1) 
					{
						CameraViewController * camView = (CameraViewController *) [views objectAtIndex:1]; 
						[camView goBackToCameraList]; 
					}




				}

				[self dismissModalViewControllerAnimated:NO];

				NSLog(@"Re-login  "); 
				[self sendStatus:2];
				break;
			default:
				break;

		}
	}

}
#pragma mark - 




#pragma mark -
#pragma mark Scan For cameras


- (void) scan_for_devices
{

    
	BOOL restore_successful = FALSE;
	restore_successful = [self restoreConfigData];
    
    if ( restore_successful == TRUE)
	{

        
        /* Rebinding  cameras to restored channel
         In the case of remote access, the mac address is set to an
         invalid value "NOTSET" which will not match any MAC address gathered thru
         scanning.
         */
        CamChannel* ch = nil;
        
        for (int i = 0; i< [channel_array count]; i++)
        {
            ch = (CamChannel*) [channel_array objectAtIndex:i];
            
            if ( ch.profile != nil)
            {
                for (int j = 0; j < [restored_profiles count]; j++)
                {
                    CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
                    if ( !cp.isSelected //&&
                        //[cp.mac_address isEqualToString:ch.profile.mac_address]
                        )
                    {
                        //Re-bind camera - channel
                        
                        [ch setCamProfile:cp];
                        cp.isSelected = TRUE;
                        [cp setChannel:ch];
                        break;
                        
                    }
                    
                    
                }
            }
            else {
                
                //NSLog(@"channel profile = nil");
            }
            
            
        }
        
        
        if ( [self isCurrentConnection3G] ||
            [self.restored_profiles count] ==0 )
        {
            NSLog(@" Connection over 3g OR empty cam list  --> Skip scanning all together");
            
            
            for (int j = 0; j < [restored_profiles count]; j++)
            {
                CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
                
                cp.isInLocal = FALSE;
                cp.hasUpdateLocalStatus = TRUE;
            }
            
            
            
            
            [self finish_scanning];
        }
        else
        {
            //start
            nextCameraToScanIndex = 0;
            [self scan_next_camera:self.restored_profiles index:nextCameraToScanIndex];
        }
        
        
        NSLog(@" showing cameralist early aaa"); 
        [self startShowingCameraList];
    }
}





- (void) scan_next_camera:(NSArray *) profiles index:(int) i
{
    NSMutableArray * finalResult = [[NSMutableArray alloc] init];
    CamProfile * cp = nil;
    
    BOOL skipScan = FALSE;

    cp =(CamProfile *) [profiles objectAtIndex:i];
        
    if (cp != nil &&
        cp.mac_address !=nil)
    {
        
        //Check if we are in the same network as the camera.. IF so
        // Try to scan .. otherwise... no point ..
        //20121130: phung: incase the ip address is not valid... also try to scan .. 
        if ( cp.ip_address == nil || [self isInTheSameNetworkAsCamera:cp ])
        {
            skipScan = [self isCurrentIpAddressValid:cp];
            
            if (skipScan)
            {
                //Dont need to scan.. call scan_done directly
                [finalResult addObject:cp];
                
                [self performSelector:@selector(scan_done:)
                           withObject:finalResult afterDelay:0.1];
                
            }
            else // NEED to do local scan
            {
                
                ScanForCamera * scanner;
                scanner = [[ScanForCamera alloc] initWithNotifier:self];
                [scanner scan_for_device:cp.mac_address];
                
                
            } /* skipScan = false*/
            
        }
        else
        {
            //Skip scanning too and assume we don't get any result
            [self performSelector:@selector(scan_done:)
                       withObject:nil afterDelay:0.1];
        }
        
        
    }
    return ;
}

- (void)scan_done:(NSArray *) _scan_results
{
     CamProfile * cp =(CamProfile *) [self.restored_profiles objectAtIndex:nextCameraToScanIndex];
    //scan Done. read scan result
    
    
    
    if ( _scan_results == nil  || [_scan_results count] == 0 )
    {
        //Empty ..not found & also can't use the current IP?
        //Dont add to the final result
        cp.isInLocal = FALSE;
        cp.hasUpdateLocalStatus = TRUE;
       
    }
    else
    {
        //found the camera ..
        // --> update local IP and other info
       
        cp.ip_address = ((CamProfile*) [_scan_results objectAtIndex:0]).ip_address;
        cp.isInLocal = TRUE;
        cp.port = 80;//localport is always 80
        
        cp.hasUpdateLocalStatus = TRUE;
    }

    NSLog(@"cam:%@ is in Local? %d", cp.mac_address, cp.isInLocal);
    
    
    
    if ( (nextCameraToScanIndex+1) <[self.restored_profiles count])
    {
        
        if (dashBoard != nil)
        {
            NSLog(@"reload dashboard in scan_done");
            [dashBoard.cameraList reloadData];
            
        }
        
        
        nextCameraToScanIndex ++;
        [self scan_next_camera:self.restored_profiles index:nextCameraToScanIndex];
    }
    else
    {
        NSLog(@"Stop Scanning");
        [self finish_scanning];
    }
}



- (void)finish_scanning
{
    
	//Hide it, since we're done
	self.progressView.hidden = YES;
    
#if 0
    CamChannel * ch = nil;
    /* Rebinding  cameras to restored channel
     In the case of remote access, the mac address is set to an
     invalid value "NOTSET" which will not match any MAC address gathered thru
     scanning.
     */
    for (int i = 0; i< [channel_array count]; i++)
    {
        ch = (CamChannel*) [channel_array objectAtIndex:i];
        
        if ( ch.profile != nil)
        {
            for (int j = 0; j < [restored_profiles count]; j++)
            {
                CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
                if ( !cp.isSelected //&&
                    //[cp.mac_address isEqualToString:ch.profile.mac_address]
                    )
                {
                    //Re-bind camera - channel
                    
                    [ch setCamProfile:cp];
                    cp.isSelected = TRUE;
                    [cp setChannel:ch];
                    break;
                    
                }
                
                
            }
        }
        else {
            
            //NSLog(@"channel profile = nil");
        }
        
        
    }
#endif
    
    //TODO: Need to save offline data here???
    
    /* show the camera list page now
    [self performSelectorOnMainThread:@selector(startShowingCameraList)
                           withObject:nil
                        waitUntilDone:NO];
       NOT USED anymore
     */
    if (dashBoard != nil)
    {
        NSLog(@"reload dashboard in finish");
        [dashBoard setupTopBarForEditMode:dashBoard.editModeEnabled];
        
        [dashBoard.cameraList reloadData];
        
    }
        
}



-(BOOL) isInTheSameNetworkAsCamera :(CamProfile *) cp
{
    long ip = 0, ownip =0 ;
    long netMask = 0 ;
	struct ifaddrs *ifa = NULL, *ifList;
    
    NSString * bc = @"";
	NSString * own = @"";
	[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own ipasLong:&ownip];
    
    
    getifaddrs(&ifList); // should check for errors
    for (ifa = ifList; ifa != NULL; ifa = ifa->ifa_next) {
        
        
        if (ifa->ifa_netmask != NULL)
        {
            ip = (( struct sockaddr_in *)ifa->ifa_addr)->sin_addr.s_addr;
            if (ip == ownip)
            {
                netMask = (( struct sockaddr_in *)ifa->ifa_netmask)->sin_addr.s_addr;
                
                break;
            }
        }
        
    }
    freeifaddrs(ifList); // clean up after yourself
    
    
    if (netMask ==0 || ip ==0)
    {
        return FALSE;
    }
    
    long camera_ip =0 ;
    if (cp != nil &&
        cp.ip_address != nil)
    {
        NSArray * tokens = [cp.ip_address componentsSeparatedByString:@"."];
        if ([tokens count] != 4)
        {
            //sth is wrong
            return FALSE;
        }
        
        camera_ip = [tokens[0] integerValue] |
        ([tokens[1] integerValue] << 8) |
        ([tokens[2] integerValue] << 16) |
        ([tokens[3] integerValue] << 24) ;
        
        
        
        if ( (camera_ip & netMask) == (ip & netMask))
        {
            NSLog(@"in same subnet");
            return TRUE;
        }
    }
    
    return FALSE;
    
}
-(BOOL) isCurrentIpAddressValid :(CamProfile *) cp
{
    
    
    
    if (cp != nil &&
        cp.ip_address != nil)
    {
        HttpCommunication * dev_com = [[HttpCommunication alloc] init];
        
        dev_com.device_ip = cp.ip_address;
        
        NSString * mac = [dev_com sendCommandAndBlock:GET_MAC_ADDRESS withTimeout:5.0];
        
        if (mac != nil && mac.length == 12)
        {
            mac = [Util add_colon_to_mac:mac];
            
            
            if([mac isEqualToString:cp.mac_address])
            {
                return TRUE;
            }
        }
        
    }
    
    
    return FALSE;
}


#pragma mark -
#pragma mark 3G connection checks


-(BOOL) isCurrentConnection3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        
        return TRUE;
    }
   
    
     return FALSE;
    
}


#pragma mark -






+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip
{

	int ret;
	//Free & re-init Addresses
	FreeAddresses();

	ret = GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP = nil;
	NSString *deviceIP = nil ;

	NSString * log = @"";


	int i;

	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;

		theAddr = ip_addrs[i];

		if (theAddr == INVALID_IP)
		{

			break;
		}

		if (theAddr == localHost) continue;

		if (strncmp(if_names[i], "en", strlen("en")) == 0)
		{
			deviceBroadcastIP =  [NSString stringWithFormat:@"%s", broadcast_addrs[i]];
			deviceIP = [NSString stringWithFormat:@"%s", ip_names[i]];
		}



		//NSLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i], 
		// broadcast_addrs[i]);

		log = [log stringByAppendingFormat:@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i], 
		    broadcast_addrs[i]];

	}


	//For Iphone4
	//deviceBroadcastIP = [NSString stringWithFormat:@"%s", broadcast_addrs[i-1]];

	//NSLog(@"broadcast iP: %d %@",i, deviceBroadcastIP);
	//NSLog(@"own iP: %d %@",i, deviceIP);
	if (deviceIP != nil)
	{
		*ownip = [NSString stringWithString:deviceIP];
	}

	if (deviceBroadcastIP != nil)
	{
		*bcast = [NSString stringWithString:deviceBroadcastIP];
	}

	
	return ;
}
+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip ipasLong:(long *) _ownip
{
    
	int ret;
	//Free & re-init Addresses
	FreeAddresses();
    
	ret = GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP = nil;
	NSString *deviceIP = nil ;
    
	NSString * log = @"";
    
    
	int i;
    
	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;
        
		theAddr = ip_addrs[i];
        
		if (theAddr == INVALID_IP)
		{
            
			break;
		}
        
		if (theAddr == localHost) continue;
        
		if (strncmp(if_names[i], "en", strlen("en")) == 0)
		{
			deviceBroadcastIP =  [NSString stringWithFormat:@"%s", broadcast_addrs[i]];
			deviceIP = [NSString stringWithFormat:@"%s", ip_names[i]];
            *_ownip = ip_addrs[i];
		}
        
        
        
		//NSLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
		// broadcast_addrs[i]);
        
		log = [log stringByAppendingFormat:@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
               broadcast_addrs[i]];
        
	}
    
    
	//For Iphone4
	//deviceBroadcastIP = [NSString stringWithFormat:@"%s", broadcast_addrs[i-1]];
    
	//NSLog(@"broadcast iP: %d %@",i, deviceBroadcastIP);
	//NSLog(@"own iP: %d %@",i, deviceIP);
	if (deviceIP != nil)
	{
		*ownip = [NSString stringWithString:deviceIP];
	}
    
	if (deviceBroadcastIP != nil)
	{
		*bcast = [NSString stringWithString:deviceBroadcastIP];
	}
    
	
	return ;
}

#pragma mark -
#pragma mark SetupHTTPDelegate --- NOT USED --- check ..



-(void) show_login_or_reg:(NSTimer*) exp
{

	NSLog(@"show_login..."); 


    MBP_LoginOrRegistration * loginOrReg;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        loginOrReg = [[MBP_LoginOrRegistration alloc] initWithNibName:@"MBP_LoginOrRegistration_ipad"
                                                               bundle:nil
                                                     withConnDelegate:self];
    }
    else
    {
        loginOrReg = [[MBP_LoginOrRegistration alloc]
                      initWithNibName:@"MBP_LoginOrRegistration"
                      bundle:nil
                      withConnDelegate:self];
    }



	//Use navigation controller
	[loginOrReg presentModallyOn:self];

}



#pragma mark -
#pragma mark Read Configure data 




- (BOOL) restoreConfigData
{
	SetupData * savedData = [[SetupData alloc]init];
	if ([savedData restore_session_data] ==TRUE)
	{
		//NSLog(@"restored data done");
		self.channel_array = savedData.channels;


		self.restored_profiles = savedData.configured_cams;
	}

	return TRUE;
}

@end
