//
//  MBP_iosViewController.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConnectionMethodDelegate.h"
#import "CameraAlert.h"
#import "CongratHelpWindowPopup.h"

#define APP_STAGE_INIT          1
#define APP_STAGE_LOGGING_IN    2
#define APP_STAGE_LOGGED_IN     3
#define APP_STAGE_SETUP         4

#define STAY_AT_CAMERA_LIST 0xcabe

@interface MBP_iosViewController : UIViewController //</*BonjourDelegate, */ConnectionMethodDelegate,UIActionSheetDelegate /*,ScanForCameraNotifier*/>

@property (nonatomic) int app_stage;
@property (nonatomic, retain) CameraAlert *camAlert;

+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip;
+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip ipasLong:(long *) _ownip;

- (void)pushNotificationRcvedInForeground:(CameraAlert *) camAlert;
- (BOOL)pushNotificationRcvedServerAnnouncement:(NSString *) custom_message andUrl:(NSString *) custom_url;

//- (void) initialize ;
//- (BOOL) restoreConfigData;
//-(void) startShowingCameraList:(NSNumber *) option;
//- (void) scan_for_devices;
//delegate
//- (void)sendStatus:(int) status;

@end

