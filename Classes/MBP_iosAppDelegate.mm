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
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	
	
#if TARGET_IPHONE_SIMULATOR == 0
	
	
	NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	NSString *logPath = [cachesDirectory stringByAppendingPathComponent:@"application.log"];
	
	freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
	NSLog(@"Log location: %@",logPath);
#endif
    
    NSLog(@"Checking alert database"); 
    [CameraAlert reloadBlankTableIfNeeded];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"clear the notification");
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
    NSLog(@" Checking userInfo"); 
    
    
    
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
        
        
        
#if 0     
        
        if ( [application applicationState] == UIApplicationStateInactive)
        {
            
            NSLog(@"Re login"); 
            [self performSelectorOnMainThread:@selector(forceLogin) withObject:nil waitUntilDone:YES];             
        }
        
                
        if ([self shouldAlertForThisMac:str3])
        {
            NSLog(@" should Alert for this mac!! "); 
            
            
            
            
        }
#endif 
        
        
    }

}


-(void) forceLogin
{
    [viewController sendStatus:2]; 
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

    NSLog(@"My token is: %@", devToken);


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
    
    NSData * response_dat = [bms_comm1 BMS_sendPushRegistrationBlockWithUser:user_email
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
	
	NSLog(@"Enter background"); 

		
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	
	NSLog(@"Enter foreground "); 
	
    
    NSLog(@"Re login"); 
    [self performSelectorOnMainThread:@selector(forceLogin) withObject:nil waitUntilDone:YES];   
			
		
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






@end
