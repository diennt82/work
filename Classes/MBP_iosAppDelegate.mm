//
//  MBP_iosAppDelegate.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 Hubble Connected Ltd. All rights reserved.
//

#import <Crittercism.h>

#import "MBP_iosAppDelegate.h"
#import "PublicDefine.h"
#import "SetupData.h"
#import "EarlierNavigationController.h"

@interface MBP_iosAppDelegate ()

@property (nonatomic, assign) BOOL handling_PN;

@end

@implementation MBP_iosAppDelegate

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Enable remote crash reporting
    [Crittercism enableWithAppID: @"53d6a3761787842dba000001"];

    // Setup global L&F
#ifdef VTECH
    UIColor *themeTintColor = [UIColor colorWithRed:11/255.f green:41/255.0f blue:109/255.f alpha:1];
#else
    UIColor *themeTintColor = [UIColor colorWithRed:252/255.f green:0 blue:7/255.f alpha:1];
#endif
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7+
        _window.tintColor = themeTintColor;
    }

    [[UINavigationBar appearance] setTintColor:themeTintColor];

    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }
    
    self.handling_PN = NO;
    
    // Initialize Analytics
    
    // include some info about the type of device, operating system, and version of your app
    /*
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIDevice currentDevice].model, @"Model",
                          [UIDevice currentDevice].systemName, @"System Name",
                          [UIDevice currentDevice].systemVersion, @"System Version",
                          //[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"My App Version",CFBundleShortVersionString
                          [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], @"My App Version",
                          nil];
     */
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;

    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-51500380-2"];

    _window.rootViewController = [[EarlierNavigationController alloc] initWithRootViewController:_viewController];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger app_stage = [userDefaults integerForKey:@"ApplicationStage"];
    
    // Check if user killed app during SETUP camera
    if (app_stage == APP_STAGE_SETUP) {
        _viewController.app_stage = APP_STAGE_LOGGED_IN ;
        [userDefaults setInteger:_viewController.app_stage forKey:@"ApplicationStage"];
    }
    
    // Handled when user kills app when app in view a Camera
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [_window makeKeyAndVisible];
    
    // Check condition use STUN or not
    [self registerDefaultsFromSettingsBundle];
    
    [CameraAlert reloadBlankTableIfNeeded];

    NSString *serverName = [userDefaults stringForKey:@"name_server"];
    
    if (serverName == nil || ![serverName hasPrefix:@"http"]) {
        serverName = @"https://api.hubble.in";
    }
    
    if (![serverName hasSuffix:@"/v1"]) {
        serverName = [serverName stringByAppendingString:@"/v1"];
    }
    
    [BMS_JSON_Communication setServerInput:serverName];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DLog(@"AppDelegate - didReceiveRemoteNotification: %@", userInfo);
    
    // Clear status notification
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    if (userInfo) {
        NSString *alertTitle = (NSString *) [userInfo objectForKey:@"alert"];
        if ([alertTitle isEqualToString:ALERT_GENERIC_SERVER_INFO]) {
            // Server Custom message
            NSString *alertMessage = (NSString *) [userInfo objectForKey:@"message"];
            NSString *alertURL = (NSString *) [userInfo objectForKey:@"url"];
            
            if ( [application applicationState] == UIApplicationStateActive) {
                // App is running now
                [_viewController pushNotificationRcvedServerAnnouncement:alertMessage andUrl:alertURL];
            }
        }
        else if ([alertTitle isEqualToString:@"1"] ||
                 [alertTitle isEqualToString:@"2"]  ||
                 [alertTitle isEqualToString:@"3"] ||
                 [alertTitle isEqualToString:@"4"])
        {
            NSString *alertMessage = (NSString *)[userInfo objectForKey:@"mac"];
            NSString *alertVal = (NSString *)[userInfo objectForKey:@"val"];
            NSString *alertTime = (NSString *)[userInfo objectForKey:@"time"];
            NSString *cameraName = (NSString *)[userInfo objectForKey:@"cameraname"];
            NSString *eventURL = (NSString *)[userInfo objectForKey:@"ftp_url"]; //Motion url
            
            if ( !alertTitle || !alertMessage || !alertVal || !alertTime || !cameraName ) {
                DLog(@"NIL info.. silently return");
                return;
            }
            
            int rcvTimeStamp = [[NSDate date] timeIntervalSince1970];
            CameraAlert *camAlert = [[CameraAlert alloc]initWithTimeStamp1:rcvTimeStamp];// autorelease];

            //set other values
            camAlert.cameraMacNoColon = [alertMessage substringWithRange:NSMakeRange(6, 12)];
            camAlert.cameraName = cameraName;
            camAlert.alertType = alertTitle;
            camAlert.alertTime =alertTime;
            camAlert.alertVal = alertVal;
            camAlert.registrationID = alertMessage;
            
            if ( eventURL ) {
                camAlert.server_url = eventURL;
                DLog(@"motion url is :%@", camAlert.server_url);
            }
            
            BOOL shouldStoreAlert = YES;
            
            // Next few lines: ORDER MATTERS
            if ( [application applicationState] == UIApplicationStateActive) {
                // App is running now
                shouldStoreAlert = [_viewController pushNotificationRcvedInForeground: camAlert];
            }
            else if ( [application applicationState] == UIApplicationStateInactive) {
                DLog(@"UIApplicationStateInactive");
                
                [self performSelectorOnMainThread:@selector(activateNotificationViewController:) withObject:camAlert waitUntilDone:YES];
                self.handling_PN = YES;
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:cameraName
                                                                message:alertTitle
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // Delegate is called when app is active in case app in background, must click to active it.
    UIApplicationState state = [application applicationState];
    
    if (state == UIApplicationStateActive) {
        // Enable remote push notification
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // use registerUserNotificationSettings
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
            // use registerForRemoteNotifications
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }
#else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    UIPasteboard *appPasteBoard = [UIPasteboard pasteboardWithName:@"Monitoreverywhere_HD" create:YES];
	appPasteBoard.persistent = YES;
    if ( ![appPasteBoard string] ) {
        [appPasteBoard setString:[MBP_iosAppDelegate GetUUID]];
    }

    NSString *uuidString = [appPasteBoard string];
    DLog(@"uuidString: %@", uuidString);
    
    NSString *applicationName = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    applicationName = [applicationName stringByAppendingFormat:@"-%@", [UIDevice currentDevice].name];
    DLog(@"Application name: %@", applicationName);
    
    NSString *swVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    NSDictionary *responseDict = [jsonComm registerAppBlockedWithName:applicationName
                                                        andDeviceCode:uuidString
                                                   andSoftwareVersion:swVersion
                                                            andApiKey:apiKey];
    
    NSString *appId = [[responseDict objectForKey:@"data"] objectForKey:@"id"];
    NSString *devTokenStr = [devToken hexadecimalString];
    
    [userDefaults setObject:devTokenStr forKey:_push_dev_token];
    [userDefaults setObject:appId forKey:@"APP_ID"];
    [userDefaults synchronize];
    
    NSString *certType = @"1"; // for testflight
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if ( [bundleIdentifier isEqualToString:@"com.binatonetelecom.hubble"]) {
        certType = @"0";
    }
    
    NSDictionary *responseRegNotifn = [jsonComm registerPushNotificationsBlockedWithAppId:appId
                                                                      andNotificationType:@"apns"
                                                                           andDeviceToken:devTokenStr
                                                                                andApiKey:apiKey
                                                                              andCertType:certType];
    
    DLog(@"Log - push status = %d", [[responseRegNotifn objectForKey:@"status"] intValue]);
     
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    DLog(@"Error in registration. Error: %@", err);
}

/*
 * Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
 * Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
    DLog(@"applicationWillResignActive: %d", _viewController.app_stage);
    
    if (_viewController.app_stage == APP_STAGE_SETUP) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:_viewController.app_stage forKey:@"ApplicationStage"];
        [userDefaults synchronize];
    }
    
    // Workaround: MFMailComposeViewController does not dismiss keyboard when application enters background
    UITextView *dummyTextView = [[UITextView alloc] init];
    [self.window.rootViewController.presentedViewController.view addSubview:dummyTextView];
    [self.window endEditing:YES];
    [dummyTextView becomeFirstResponder];
    [dummyTextView resignFirstResponder];
    [dummyTextView removeFromSuperview];
    // End of workaround
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize]; // Synchronize to get setting from System settings
	_viewController.app_stage = [userDefaults integerForKey:@"ApplicationStage"];
    
    DLog(@"MBP_iosAppDelegate - viewController.app_stage: %d", _viewController.app_stage);

    if (_handling_PN) {
        DLog(@"handling PN, we may be in view");
        if ( [userDefaults objectForKey:CAM_IN_VEW] ) {
            DLog(@"A camera is in view.Stop it");
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:CAM_IN_VEW];
            [userDefaults setBool:YES forKey:HANDLE_PN];
            [userDefaults synchronize];
        }
    }
    else if ([userDefaults objectForKey:CAM_IN_VEW] ) {
        DLog(@"A camera is in view. Do nothing");
    }
    else if (_viewController.app_stage == APP_STAGE_LOGGED_IN) {
        //20121114: phung: Need to force relogin, because while app in background many things can happen
        //   1. Wifi loss --> offline mode
        //   2. User switch on 3G
        //   3. Or simply no 3g nor 3g -->> offline mode
        //   4. Or a remote camera has become unreachable.
        //  -->>> NEED to relogin to verify
        
        if ( _becomeActiveByNotificationFlag ) {
            self.becomeActiveByNotificationFlag = NO;
        }
        else {
            //Do nothing here : to return to the last page.
        }
    }
    else if (_viewController.app_stage == APP_STAGE_LOGGING_IN || _viewController.app_stage == APP_STAGE_INIT) {
        [userDefaults setBool:NO forKey:AUTO_LOGIN_KEY];
        [userDefaults synchronize];
    }
}

/*
 * Called when the application is about to terminate.
 * See also applicationDidEnterBackground:.
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    DLog(@"applicationWillTerminate");
}

/*
 * A bit mask of the UIInterfaceOrientation constants that indicate the orientations 
 * to use for the view controllers.
 */
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
	if ( camInView ) {
		return  UIInterfaceOrientationMaskAllButUpsideDown;   
	}
    return  UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Private methods

+ (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (void)activateNotificationViewController:(CameraAlert *)camAlert
{
    self.becomeActiveByNotificationFlag = YES;
    _viewController.camAlert = camAlert;
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:_viewController
                                   selector:@selector(showNotificationViewController:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)registerDefaultsFromSettingsBundle
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if (!settingsBundle) {
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DLog(@"applicationDidReceiveMemoryWarning from app delegate");
}

@end
