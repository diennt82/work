//
//  MBP_iosViewController.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIScreen.h>
#import <UIKit/UIColor.h>
#import <Foundation/NSRunLoop.h>
#import <CameraScanner/CameraScanner.h>

#import "PublicDefine.h"
#import "ConnectionMethodDelegate.h"
#import "CameraAlert.h"
#import "MenuViewController.h"
#import "TimelineDatabase.h"
#import "NotifViewController.h"
#import "PushNotificationAlert.h"

#define ALERT_PUSH_RECVED_RESCAN_AFTER              200
#define ALERT_PUSH_RECVED_RELOGIN_AFTER             201
#define ALERT_PUSH_SERVER_ANNOUNCEMENT              203
#define ALERT_PUSH_RECVED_SOUND_TEMP_HI_TEMP_LO     204
#define ALERT_PUSH_RECVED_MULTIPLE                  205
#define ALERT_PUSH_RECVED_REMOVE_CAM                206
#define ALERT_PUSH_RECVED_PASSWORD_CHANGED          207

#define APP_STAGE_INIT          1
#define APP_STAGE_LOGGING_IN    2
#define APP_STAGE_LOGGED_IN     3
#define APP_STAGE_SETUP         4

#define STAY_AT_CAMERA_LIST 0xcabe

@interface MBP_iosViewController : UIViewController </*BonjourDelegate, */ConnectionMethodDelegate,UIActionSheetDelegate /*,ScanForCameraNotifier*/>
{
    SystemSoundID soundFileObject;
    NSArray * channel_array; 
	NSMutableArray * restored_profiles ;
    int app_stage;
    BOOL isRebinded;
    
    //int nextCameraToScanIndex;
    //Bonjour * _bonjourBrowser;
    //NSArray * bonjourList;
    //NSThread * bonjourThread;
}

@property (nonatomic, retain) IBOutlet UIImageView * splashScreen;

@property (nonatomic, retain) NSArray * channel_array; 
@property (nonatomic, retain) NSMutableArray * restored_profiles ;
@property (nonatomic) int app_stage;

@property (nonatomic, retain) CameraAlert *camAlert;
@property (nonatomic, retain) PushNotificationAlert * pushAlert;
@property (nonatomic, retain) MenuViewController *menuVC;

+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip;
+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip ipasLong:(long *) _ownip;

//- (void) initialize ;
//- (BOOL) restoreConfigData;
//-(void) startShowingCameraList:(NSNumber *) option;
//- (void) scan_for_devices;
//delegate
//- (void)sendStatus:(int) status;

- (void)pushNotificationRcvedInForeground:(CameraAlert *) camAlert;
- (BOOL)pushNotificationRcvedServerAnnouncement:(NSString *) custom_message andUrl:(NSString *) custom_url;

@end

