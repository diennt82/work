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
    
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationType) (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
    
    
       
    NSDictionary * userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]; 
    if (userInfo)
    {
        NSLog(@" Checking launchOptions"); 
        
        NSString * str2 = (NSString *) [userInfo objectForKey:@"alert"]; 
        NSString * str3 = (NSString *) [userInfo objectForKey:@"mac"]; 
        NSString * str4 = (NSString *) [userInfo objectForKey:@"val"]; 
        NSString * str5 = (NSString *) [userInfo objectForKey:@"time"]; 
        NSLog(@" %@ %@ %@", str2, str3, str4); 
    }
    
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Remote push rcv while running");
    
    NSLog(@" Checking userInfo"); 
   
    if (userInfo)
    {
        NSString * str2 = (NSString *) [userInfo objectForKey:@"alert"]; 
        NSString * str3 = (NSString *) [userInfo objectForKey:@"mac"]; 
        NSString * str4 = (NSString *) [userInfo objectForKey:@"val"]; 
        NSString * str5 = (NSString *) [userInfo objectForKey:@"time"]; 
        NSLog(@"%@ %@ %@ %@",  str2, str3, str4 , str5);  
        
        
        
        
        if ( [application applicationState] == UIApplicationStateActive)
        {
            //App is running now
            
        }
        
        if ( [application applicationState] == UIApplicationStateInactive)
        {
#if 0
            NSLog(@"LOGIN from appdelegate"); 
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setBool:TRUE forKey:_AutoLogin];
			[userDefaults synchronize];
            
            
			[viewController performSelectorOnMainThread:@selector(show_login_or_reg:)
                                             withObject:nil
                                          waitUntilDone:NO]; 
#else
            NSLog(@"Send status"); 
            [self performSelectorOnMainThread:@selector(forceLogin) withObject:nil waitUntilDone:YES]; 
            
#endif 
        }
        
        
#if 0
        
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
    const void *devTokenBytes = [devToken bytes];
    NSLog(@"My token is: %@", devToken);
    
    //self.registered = YES;
    //[self sendProviderDeviceToken:devTokenBytes]; // custom method
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
#if 0
	

	
	
	if (viewController.shouldReloadWhenEnterBG == TRUE	)
	{
		[viewController dismissModalViewControllerAnimated:NO];
			
	
		
		NSLog(@"reload view--"); 
		//if (viewController.shouldReloadWhenEnterBG == TRUE	)
		//{
			//Go back to first page 
		//	[viewController viewDidLoad];
		//}
		
		
			
	}
#endif
		
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	
	NSLog(@"Enter foreground - do nothing.. "); 
	
			
		
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
