//
//  MBP_iosAppDelegate.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_iosAppDelegate.h"


@implementation MBP_iosAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    // OBSOLETE: [window addSubview:viewController.view];
  
    [window setRootViewController:viewController];
    [window makeKeyAndVisible];

	
	
#if TARGET_IPHONE_SIMULATOR == 0
	
	
	NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	NSString *logPath = [cachesDirectory stringByAppendingPathComponent:@"application.log"];
	
	freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
	NSLog(@"Log location: %@",logPath);
#endif
    

    [CameraAlert reloadBlankTableIfNeeded];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    //clear status notification 
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
   
    
    
    
    if (userInfo)
    {
        NSString * str2 = (NSString *) [userInfo objectForKey:@"alert"]; 
        NSString * str3 = (NSString *) [userInfo objectForKey:@"mac"]; 
        NSString * str4 = (NSString *) [userInfo objectForKey:@"val"]; 
        NSString * str5 = (NSString *) [userInfo objectForKey:@"time"]; 
        NSString * str6 = (NSString *) [userInfo objectForKey:@"cameraname"]; 
        
        NSLog(@"%@ %@ %@ %@ %@",  str2, str3, str4 , str5, str6);  
        
        if (str2 == nil ||
            str3 == nil ||
            str4 == nil ||
            str5 == nil ||
            str6 == nil )
        {
            NSLog(@"NIL info.. silencely return"); 
            return; 
        }
        
        int rcvTimeStamp = [[NSDate date] timeIntervalSince1970];
        CameraAlert * camAlert = [[CameraAlert alloc]initWithTimeStamp1:rcvTimeStamp];
        //set other values
        camAlert.cameraMacNoColon = str3;
        
        camAlert.cameraName = str6;
        camAlert.alertType = str2;
        camAlert.alertTime =str5;
        camAlert.alertVal = str4;
        
        BOOL shouldStoreAlert = TRUE; 

        
        //Next few lines: ORDER MATTERS
        if ( [application applicationState] == UIApplicationStateActive)
        {
            //App is running now
            shouldStoreAlert = [viewController pushNotificationRcvedInForeground: camAlert];
            
        }
        
        if (shouldStoreAlert && [CameraAlert insertAlertForCamera:camAlert] == TRUE)
        {
            NSLog(@"Alert inserted successfully"); 
        }
        
        
        
    
        
        if ( [application applicationState] == UIApplicationStateInactive)
        {
            
            NSLog(@"Re login"); 
            [self performSelectorOnMainThread:@selector(forceLogin) withObject:nil waitUntilDone:YES];             
        }
        
    }

}


-(void) forceLogin
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setBool:TRUE forKey:_AutoLogin];
    [userDefaults synchronize];
    
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:viewController
                                   selector:@selector(show_login_or_reg:)
                                   userInfo:nil
                                    repeats:NO];
   
}

-(void) forceScan
{
    [viewController sendStatus:SCAN_CAMERA];
}
-(void) showInit
{
    [viewController sendStatus:FRONT_PAGE]; 
}



- (BOOL) shouldAlertForThisMac:(NSString*) mac_without_colon
{
    SetupData * savedData = [[SetupData alloc]init];
	if ([savedData restore_session_data] ==TRUE)
	{
		
		NSArray * restored_profiles = savedData.configured_cams;
        CamProfile * cp = nil; 
        for (int i =0; i< [restored_profiles count]; i++)
        {
            cp = (CamProfile *) [restored_profiles objectAtIndex:i]; 
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
        
        
        
        
	}
    
    return FALSE; 
}



// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {

    //NSLog(@"My token is: %@", devToken);


    NSString * devTokenStr = [devToken hexadecimalString];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:devTokenStr forKey:_push_dev_token]; 
    [userDefaults synchronize];
    
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * user_email  = (NSString*) [userDefaults objectForKey:@"PortalUseremail"];
    
    BMS_Communication * bms_comm1; 
    bms_comm1  = [[BMS_Communication alloc] initWithObject:self
                                                  Selector:nil 
                                              FailSelector:nil
                                                 ServerErr:nil];
    
    //NSData * response_dat =
    [bms_comm1 BMS_sendPushRegistrationBlockWithUser:user_email
                                                                     AndPass:user_pass
                                                                       regId:devTokenStr];
    

    
    
   
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
	NSLog(@"Enter background "); 

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:viewController.app_stage forKey:@"ApplicationStage"];
    [userDefaults synchronize];
    
    
    NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];

    
    if (camInView != nil)
	{
        //Some camera is inview..
        //Don't reload.. So that later when we come back, we just need to reload
        
        
	}
    else if (viewController.app_stage == APP_STAGE_LOGGED_IN)
    {
        
        [viewController sendStatus:BACK_FRM_MENU_NOLOAD];
    }

        
	
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	
	NSLog(@"Enter foreground isMain? %d 01", [[NSThread currentThread] isMainThread]);
	
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	viewController.app_stage = [userDefaults integerForKey:@"ApplicationStage"];

    NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    
    
    if (camInView != nil)
	{
        //Some camera is inview..
        //How about don't do anything..
        
        
        NSLog(@"Some camera is in view.. do nothing");
        
        
	}
    else if (viewController.app_stage == APP_STAGE_LOGGED_IN)
    {
        //[self performSelectorOnMainThread:@selector(forceScan) withObject:nil waitUntilDone:YES];
        
        //20121114: phung: Need to force relogin, because while app in background many things can happen
        //   1. Wifi loss --> offline mode
        //   2. User switch on 3G
        //   3. Or simply no 3g nor 3g -->> offline mode 
        //   4. Or a remote camera has become unreachable.
        //  -->>> NEED to relogin to verify
        [self forceLogin]; 

        
    }
    else if (viewController.app_stage ==  APP_STAGE_SETUP)
    {
        //Do nothing -- stay at the current page
    }
    else
    {
         [self performSelectorOnMainThread:@selector(showInit) withObject:nil waitUntilDone:YES];
    }


    
   
    
}





- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

/*A bit mask of the UIInterfaceOrientation constants that indicate the orientations to use for the view controllers.*/

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    
	if (camInView != nil)
	{
		return  UIInterfaceOrientationMaskAllButUpsideDown;   
	}
//    return  UIInterfaceOrientationMaskPortrait;
    //test
    return  UIInterfaceOrientationMaskAllButUpsideDown;
}



#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}



//// IOS6 orientation stuff


@end
