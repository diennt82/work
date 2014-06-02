//
//  MBP_iosAppDelegate.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_iosAppDelegate.h"
#import "PublicDefine.h"
#import "SetupData.h"
#import "KISSMetricsAPI.h"
#import "EarlierNavigationController.h"


@implementation MBP_iosAppDelegate

//@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

//Kiran Patel Git Hub Sync Test / Branch Test

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    /*nguyendang_20130719
        - Add Google Analytics Delegates to this project.
     */
    

    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }

    handling_PN = FALSE;
    
#if 1
    [KISSMetricsAPI sharedAPIWithKey:@"ff38140e358fdc343bb97297de4963291eec47d5"];
    
    [[KISSMetricsAPI sharedAPI] identify:@"85FF7C5E-3412-4AAC-9B07-5491AD022B4F"];
    
    // include some info about the type of device, operating system, and version of your app
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIDevice currentDevice].model, @"Model",
                          [UIDevice currentDevice].systemName, @"System Name",
                          [UIDevice currentDevice].systemVersion, @"System Version",
                          //[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"My App Version",CFBundleShortVersionString
                          [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], @"My App Version",
                          nil];

    [[KISSMetricsAPI sharedAPI] recordEvent:@"Launched App" withProperties:info];
#else
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    
    //UA-ID_INSTANCE is taken from the account analytics on google analytics
    //id<GAITracker> tracker =
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-42134835-2"];
#endif
    // !!!: Use the next line only during TEST - appstore release: need to comment this line
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    
  
    //Add testflight app token - For remote login & crash reporting
    //[TestFlight takeOff:@"4574de50-f54d-4414-a803-fc460426c915"];
    
    NSArray *names = [UIFont fontNamesForFamilyName:@"Proxima Nova"];
    NSLog(@"names: %@",names);
    
    //[[UINavigationBar appearance] setTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"back"]]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:252/255.f green:0 blue:7/255.f alpha:1]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor colorWithRed:16/255.f green:16/255.f blue:16/255.f alpha:1],
                                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.f]
                                                            }];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor blackColor], NSForegroundColorAttributeName,
                                                          [UIFont fontWithName:@"HelveticaNeue-Light" size:17], NSFontAttributeName,
                                                          nil]
                                                forState:UIControlStateNormal];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    // Check condition use STUN or not
    [self registerDefaultsFromSettingsBundle];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger app_stage = [userDefaults integerForKey:@"ApplicationStage"];
    
    /*
     * User kill app when SETUP camera
     */
    
    if (app_stage == APP_STAGE_SETUP)
    {
        viewController.app_stage = APP_STAGE_LOGGED_IN ;
        [userDefaults setInteger:viewController.app_stage forKey:@"ApplicationStage"];
    }
    
    /*
     * User kill app when app in view a Camera
     */
    
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    //[_window setRootViewController:viewController];
    _window.rootViewController = [[EarlierNavigationController alloc] initWithRootViewController:viewController];
    [_window makeKeyAndVisible];
    
#if TARGET_IPHONE_SIMULATOR == 0

    NSSetUncaughtExceptionHandler(&HandleException);
    
    struct sigaction signalAction;
    memset(&signalAction, 0, sizeof(signalAction));
    signalAction.sa_handler = &HandleSignal;
    
    sigaction(SIGABRT, &signalAction, NULL);
    sigaction(SIGILL, &signalAction, NULL);
    sigaction(SIGBUS, &signalAction, NULL);
    
     NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *logPath = [cachesDirectory stringByAppendingPathComponent:@"application.log"];
    
    [self createANewAppLog:logPath decumentDirectory:cachesDirectory];
    
	freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
	NSLog(@"Log location: %@",logPath);
#endif
    
    [CameraAlert reloadBlankTableIfNeeded];

    NSString *serverName = [userDefaults stringForKey:@"name_server"];
    
    if (serverName == nil ||
        ![serverName hasPrefix:@"http"])
    {
        serverName = @"https://api.hubble.in";
    }
    
    if (![serverName hasSuffix:@"/v1"])
    {
        serverName = [serverName stringByAppendingString:@"/v1"];
    }
    
    [BMS_JSON_Communication setServerInput:serverName];

    return YES;
}

void HandleException(NSException *exception) {
    NSLog(@"App crashing with exception: %@", exception);
    //Save somewhere that your app has crashed.
    checkingApplicationCrashed();
}

void HandleSignal(int signal) {
    NSLog(@"We received a signal: %d", signal);
    checkingApplicationCrashed();
    //Save somewhere that your app has crashed.
}

void checkingApplicationCrashed()
{
    BOOL success;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSError * error;
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0];
    
    NSString *appCrashedLog = [documentDirectory stringByAppendingPathComponent:@"application_crash.log"];
    
    NSString *defaultLogPath = [documentDirectory stringByAppendingPathComponent:@"application.log"];
  
    success = [fileManager copyItemAtPath:defaultLogPath toPath:appCrashedLog error:&error];
    
    if (success)
    {
        NSLog(@"Save log crashed!");
    }
}

- (void)createANewAppLog: (NSString *)appLogPath decumentDirectory: (NSString *)docDirectory
{
    NSString *appLog0 = [docDirectory stringByAppendingPathComponent:@"application0.log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = FALSE;
    NSError *error;
    
    if ([[fileManager attributesOfItemAtPath:appLogPath error:&error] fileSize] > 5000000)//5000000) // 5MB
    {
        if ([fileManager fileExistsAtPath:appLog0])
        {
            success = [fileManager removeItemAtPath:appLog0 error:&error];
            
            if (success)
            {
                NSLog(@"Remove app log 0 success");
            }
            else
            {
                NSLog(@"Remove app log 0 error: %@", [error localizedDescription]);
            }
        }
        
        success = [fileManager copyItemAtPath:appLogPath toPath:appLog0 error:&error];
        
        if (success)
        {
            NSLog(@"Copy success");
            
            success = [fileManager removeItemAtPath:appLogPath error:&error];
            
            if (success)
            {
                NSLog(@"Remove app log success");
            }
            else
            {
                NSLog(@"Remove app log err: %@", [error localizedDescription]);
            }
        }
        else
        {
            NSLog(@"Copy error: %@", [error localizedDescription]);
        }
    }
}

- (void)registerDefaultsFromSettingsBundle
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle)
    {
        //NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences)
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key)
        {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [defaultsToRegister release];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"AppDelegate - didReceiveRemoteNotification: %@", userInfo);
    //clear status notification 
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    if (userInfo)
    {
        NSString * str2 = (NSString *) [userInfo objectForKey:@"alert"];
        if ([str2 isEqualToString:ALERT_GENERIC_SERVER_INFO])
        {
            
            //Server Custom message
            NSString * str3 = (NSString *) [userInfo objectForKey:@"message"];
            NSString * str7 = (NSString *) [userInfo objectForKey:@"url"];
            
            if ( [application applicationState] == UIApplicationStateActive)
            {
                //App is running now
                [viewController pushNotificationRcvedServerAnnouncement:str3 andUrl:str7];
            }
            

            
        }
        else if ([str2 isEqualToString:@"1"] ||
                 [str2 isEqualToString:@"2"]  ||
                 [str2 isEqualToString:@"3"] ||
                 [str2 isEqualToString:@"4"])
        {
            
            
            NSString * str3 = (NSString *) [userInfo objectForKey:@"mac"];
            NSString * str4 = (NSString *) [userInfo objectForKey:@"val"];
            NSString * str5 = (NSString *) [userInfo objectForKey:@"time"];
            NSString * str6 = (NSString *) [userInfo objectForKey:@"cameraname"];
            NSString * str8 = (NSString *) [userInfo objectForKey:@"ftp_url"]; //Motion url
            
            //4 44334C31A004 20130914055827490 2013-09-14T05:59:05+00:00 Camera-31a004
            //NSLog(@"%@ %@ %@ %@ %@ %@",  str2, str3, str4 , str5, str6, str8);
            
            if (str2 == nil ||
                str3 == nil ||
                str4 == nil ||
                str5 == nil ||
                str6 == nil)
            {
                NSLog(@"NIL info.. silencely return");
                return;
            }
            
            int rcvTimeStamp = [[NSDate date] timeIntervalSince1970];
            CameraAlert * camAlert = [[CameraAlert alloc]initWithTimeStamp1:rcvTimeStamp];// autorelease];
            //set other values
            camAlert.cameraMacNoColon = [str3 substringWithRange:NSMakeRange(6, 12)];
            
            camAlert.cameraName = str6;
            camAlert.alertType = str2;
            camAlert.alertTime =str5;
            camAlert.alertVal = str4;
            camAlert.registrationID = str3;
            
            
            if (str8 != nil)
            {
                camAlert.server_url = str8;
                NSLog(@"motion url is :%@", camAlert.server_url);
            }
            
            BOOL shouldStoreAlert = TRUE;
            
            
            //Next few lines: ORDER MATTERS
            if ( [application applicationState] == UIApplicationStateActive)
            {
                //App is running now
                shouldStoreAlert = [viewController pushNotificationRcvedInForeground: camAlert];
            }
            else if ( [application applicationState] == UIApplicationStateInactive)
            {
                NSLog(@"UIApplicationStateInactive");
                
                [self performSelectorOnMainThread:@selector(activateNotificationViewController:) withObject:camAlert waitUntilDone:YES];
                handling_PN = TRUE;
            }
            else
            {
                // TODO: handle exception
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str6
                                                                message:str2
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
//            if (shouldStoreAlert && [CameraAlert insertAlertForCamera:camAlert] == TRUE)
//            {
//                NSLog(@"Alert inserted successfully");
//            }
        }
        //[camAlert release]; camAlert leak memory but I can't release it.
    }

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //delegate is called when app is active
    //in case app in background, must click to active it.
    UIApplicationState state = [application applicationState];
    
    if (state == UIApplicationStateActive)
    {
        //enable remote push notification
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}


- (void)activateNotificationViewController: (CameraAlert *)camAlert
{
    self.becomeActiveByNotificationFlag = TRUE;
    viewController.camAlert = camAlert;
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:viewController
                                   selector:@selector(showNotificationViewController:)
                                   userInfo:nil
                                    repeats:NO];
}


-(void) showInit
{
    NSLog(@"MBP_isoAppDelegate - show LoginVC as the first init");
    //[viewController sendStatus:FRONT_PAGE];
    [viewController sendStatus:LOGIN];
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
                    [savedData release];
                    
                    return TRUE; 
                }
            }
                
        }
        
        
        
        
	}
    
    [savedData release];
    
    return FALSE; 
}

+ (NSString *)GetUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    UIPasteboard *appPasteBoard = [UIPasteboard pasteboardWithName:@"Monitoreverywhere_HD" create:YES];
	appPasteBoard.persistent = YES;
    if ([appPasteBoard string] == nil) {
        [appPasteBoard setString:[MBP_iosAppDelegate GetUUID]];
    }
    
    
    NSString *uuidString = [appPasteBoard string];
    //NSString *uuidString = [MBP_iosAppDelegate GetUUID];
    NSLog(@"uuidString: %@", uuidString);
    
    NSString *applicationName = NSBundle.mainBundle.infoDictionary  [@"CFBundleDisplayName"];
    applicationName = [applicationName stringByAppendingFormat:@"-%@", [UIDevice currentDevice].name];
    NSLog(@"Application name: %@", applicationName);
    
    NSString *swVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil] autorelease];
   
//    //API
    NSDictionary *responseDict = [jsonComm registerAppBlockedWithName:applicationName
                                                        andDeviceCode:uuidString
                                                   andSoftwareVersion:swVersion
                                                            andApiKey:apiKey];
    
    
    NSString *appId = [[responseDict objectForKey:@"data"] objectForKey:@"id"];
    
    //NSLog(@"My token is: %@", devToken);
    
    
    NSString * devTokenStr = [devToken hexadecimalString];

    [userDefaults setObject:devTokenStr forKey:_push_dev_token];
    [userDefaults setObject:appId forKey:@"APP_ID"];
    [userDefaults synchronize];
    
    
    NSString * certType = @"1"; // for testflight
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if ( [bundleIdentifier isEqualToString:@"com.binatonetelecom.hubble"])
    {
        certType = @"0";
    }
    
                
    
    NSDictionary *responseRegNotifn = [jsonComm registerPushNotificationsBlockedWithAppId:appId
                                                                      andNotificationType:@"apns"
                                                                           andDeviceToken:devTokenStr
                                                                                andApiKey:apiKey
                                                                              andCertType:certType];
    
    
    
    NSLog(@"Log - push status = %d", [[responseRegNotifn objectForKey:@"status"] intValue]);
     
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    NSLog(@"applicationWillResignActive: %d", viewController.app_stage);
    
    if (viewController.app_stage == APP_STAGE_SETUP)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:viewController.app_stage forKey:@"ApplicationStage"];
        [userDefaults synchronize];
    }
    
    // Workaround: MFMailComposeViewController does not dismiss keyboard when application enters background
    UITextView *dummyTextView = [[[UITextView alloc] init] autorelease];
    [self.window.rootViewController.presentedViewController.view addSubview:dummyTextView];
    [self.window endEditing:YES];
    [dummyTextView becomeFirstResponder];
    [dummyTextView resignFirstResponder];
    [dummyTextView removeFromSuperview];
    // End of workaround
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize]; // Synchnize to get setting from System settings
	viewController.app_stage = [userDefaults integerForKey:@"ApplicationStage"];
    
    NSLog(@"MBP_iosAppDelegate - viewController.app_stage: %d", viewController.app_stage);
    
   
    if (handling_PN == TRUE)
    {
        NSLog(@"handling PN, we may be in view");
        if ([userDefaults objectForKey:CAM_IN_VEW] != nil )
        {
            NSLog(@"A camera is in view.Stop it");
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:CAM_IN_VEW];
            [userDefaults setBool:TRUE forKey:HANDLE_PN];
            [userDefaults synchronize];
            
            
        }
        
        
        
    }
    else  if ([userDefaults objectForKey:CAM_IN_VEW] != nil )
    {
        NSLog(@"A camera is in view. Do nothing");
    }
    else if (viewController.app_stage == APP_STAGE_LOGGED_IN)
    {
        //20121114: phung: Need to force relogin, because while app in background many things can happen
        //   1. Wifi loss --> offline mode
        //   2. User switch on 3G
        //   3. Or simply no 3g nor 3g -->> offline mode
        //   4. Or a remote camera has become unreachable.
        //  -->>> NEED to relogin to verify
        
        if (self.becomeActiveByNotificationFlag == TRUE)
        {
            self.becomeActiveByNotificationFlag = FALSE;
        }
        else
        {
            //Do nothing here : to return to the last page.
            //
            
        }
    }
    else if (viewController.app_stage == APP_STAGE_LOGGING_IN || viewController.app_stage == APP_STAGE_INIT)
    {
        [userDefaults setBool:FALSE forKey:_AutoLogin];
        [userDefaults synchronize];
    }

}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    NSLog(@"applicationWillTerminate");
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
    return  UIInterfaceOrientationMaskPortrait;
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
    [_window release];
    [super dealloc];
}




//// IOS6 orientation stuff


@end
