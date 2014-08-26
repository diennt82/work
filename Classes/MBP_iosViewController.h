//
//  MBP_iosViewController.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 Hubble Connected Ltd. All rights reserved.
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

#define APP_STAGE_INIT          1
#define APP_STAGE_LOGGING_IN    2
#define APP_STAGE_LOGGED_IN     3
#define APP_STAGE_SETUP         4

@interface MBP_iosViewController : UIViewController <BonjourDelegate,ConnectionMethodDelegate,UIActionSheetDelegate,ScanForCameraNotifier>

@property (nonatomic, weak) IBOutlet UIImageView *splashScreen;

@property (nonatomic, strong) NSArray *channelArray;
@property (nonatomic, strong) NSMutableArray *restoredProfilesArray;
@property (nonatomic, strong) CameraAlert *camAlert;
@property (nonatomic, strong) MenuViewController *menuVC;

@property (nonatomic, weak) id<BonjourDelegate> bonjourDelegate;
@property (nonatomic, copy) NSString *bcAddr;
@property (nonatomic, copy) NSString *ownAddr;
@property (nonatomic) BOOL toTakeSnapShot;
@property (nonatomic) BOOL recordInProgress;
@property (nonatomic) int app_stage;

+ (void)getBroadcastAddress:(NSString **)bcast AndOwnIp:(NSString**)ownip;
+ (void)getBroadcastAddress:(NSString **)bcast AndOwnIp:(NSString**)ownip ipasLong:(long *)ownip;

- (void)initialize;
- (void)sendStatus:(int) status;
- (BOOL)pushNotificationRcvedInForeground:(CameraAlert *)camAlert;
- (BOOL)pushNotificationRcvedServerAnnouncement:(NSString *)customMessage andUrl:(NSString *)customUrl;

@end

