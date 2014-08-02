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

#define DIRECTION_V_NON  0x01
#define DIRECTION_V_UP   0x02
#define DIRECTION_V_DN   0x04
#define DIRECTION_V_MASK 0xF0

#define DIRECTION_H_NON 0x10
#define DIRECTION_H_LF  0x20
#define DIRECTION_H_RT  0x40
#define DIRECTION_H_MASK 0x0F

#define CURRENT_VIEW_MODE_MULTI     0x11
#define CURRENT_VIEW_MODE_SINGLE    0x12

@class DashBoard_ViewController; 
@class MBP_CamView;
@class CamProfile;

#define DIRECT_MODE_NEXT_BTN 311

#define ALERT_PUSH_RECVED_RESCAN_AFTER  200
#define ALERT_PUSH_RECVED_RELOGIN_AFTER 201
#define ALERT_PUSH_SERVER_ANNOUNCEMENT  203
#define ALERT_PUSH_RECVED_NON_MOTION    204

#define _triggeredByVox @"bool_Vox_Trigger"

#define APP_STAGE_INIT          1
#define APP_STAGE_LOGGING_IN    2
#define APP_STAGE_LOGGED_IN     3
#define APP_STAGE_SETUP         4

#define STAY_AT_CAMERA_LIST 0xcabe

@interface MBP_iosViewController : UIViewController <BonjourDelegate,ConnectionMethodDelegate,UIActionSheetDelegate,ScanForCameraNotifier>

@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIImageView *splashScreen;

@property (nonatomic, retain) NSArray *channelArray;
@property (nonatomic, retain) NSMutableArray *restoredProfilesArray;
@property (nonatomic, retain) CameraAlert *camAlert;
@property (nonatomic, retain) MenuViewController *menuVC;

@property (nonatomic, assign) id<BonjourDelegate> bonjourDelegate;
@property (nonatomic, copy) NSString *bcAddr;
@property (nonatomic, copy) NSString *ownAddr;
@property (nonatomic) BOOL toTakeSnapShot;
@property (nonatomic) BOOL recordInProgress;
@property (nonatomic) int app_stage;

+ (void)getBroadcastAddress:(NSString **)bcast AndOwnIp:(NSString**)ownip;
+ (void)getBroadcastAddress:(NSString **)bcast AndOwnIp:(NSString**)ownip ipasLong:(long *)ownip;

- (void)initialize;
- (void)scan_for_devices;
- (void)startShowingCameraList:(NSNumber *) option;
- (void)sendStatus:(int) status;
- (BOOL)restoreConfigData;
- (BOOL)pushNotificationRcvedInForeground:(CameraAlert *)camAlert;
- (BOOL)pushNotificationRcvedServerAnnouncement:(NSString *)customMessage andUrl:(NSString *)customUrl;

@end

