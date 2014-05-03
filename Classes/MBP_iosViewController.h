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



@interface MBP_iosViewController : UIViewController <BonjourDelegate, ConnectionMethodDelegate,UIActionSheetDelegate,ScanForCameraNotifier>
{

	
	
    //NOT USED - TO BE REMOVED
 
	
	int currentDirUD, lastDirUD;
	int delay_update_lastDir_count;	
	int currentDirLR,lastDirLR;
	int delay_update_lastDirLR_count;
	
	int melody_index;
	//UIAlertView * alert;

    
    ///IN USED
   // IBOutlet MBP_MainMenuView * mainMenuView;
    
    SystemSoundID soundFileObject;
    
	IBOutlet UIView * progressView; 
    
	BOOL toTakeSnapShot ;
	BOOL recordInProgress;
	
	int iMaxRecordSize;
	NSString * iFileName;
	
	NSString * bc_addr;
	NSString * own_addr;

    
    NSArray * channel_array; 
	NSMutableArray * restored_profiles ; 

    
    IBOutlet UIView * backgroundView; 
    IBOutlet UIView * statusDialogView;
    IBOutlet UILabel * statusDialogLabel;
    IBOutlet UITextView * statusDialogText;

    
    UIAlertView * pushAlert;
    CameraAlert * latestCamAlert;
    
    DashBoard_ViewController * dashBoard;
    
    int app_stage; 

	int nextCameraToScanIndex;
    
    Bonjour * _bonjourBrowser;
    BOOL isRebinded;
    NSArray * bonjourList;
    NSThread * bonjourThread;
    

}

@property (nonatomic, retain) IBOutlet UIView * progressView;
@property (nonatomic, retain) IBOutlet UIImageView * splashScreen;
@property (nonatomic, assign) id<BonjourDelegate> bonjourDelegate;
//@property (nonatomic,retain) IBOutlet MBP_MainMenuView * mainMenuView;

//@property (nonatomic,retain) HttpCommunication *comm;


@property (nonatomic) BOOL toTakeSnapShot, recordInProgress;
@property (nonatomic, retain) NSString * bc_addr, *own_addr;

@property (nonatomic, retain) NSArray * channel_array; 
@property (nonatomic, retain) NSMutableArray * restored_profiles ;
@property (nonatomic) int app_stage;

@property (nonatomic, retain) CameraAlert *camAlert;

@property (nonatomic, retain) MenuViewController *menuVC;
//@property (nonatomic, retain) NSTimer * fullScreenTimer, *alertTimer; 


- (void) initialize ;
- (void) scan_for_devices;
+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip;
+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip ipasLong:(long *) _ownip;

- (BOOL) restoreConfigData;

-(void) startShowingCameraList:(NSNumber *) option;

//delegate

- (void)sendStatus:(int) status;

-(BOOL) pushNotificationRcvedInForeground:(CameraAlert *) camAlert;
-(BOOL) pushNotificationRcvedServerAnnouncement:(NSString *) custom_message andUrl:(NSString *) custom_url;
@end

