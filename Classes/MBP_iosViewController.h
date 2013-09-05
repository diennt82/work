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




#import "MBP_InitialSetupViewController.h"
#import "AsyncSocket.h"
#import "AviRecord.h"

#import "CamProfile.h"
#import "CamChannel.h"
//#import "PCMPlayer.h"
#import "PublicDefine.h"

#import "HttpCommunication.h"
#import "ConnectionMethodDelegate.h"
#import "MBP_LoginOrRegistration.h"
#import "MBP_Streamer.h"

#import "AudioOutStreamer.h"
#import "MBP_MenuViewController.h"
#import "RemoteConnection.h"
#import "StunCommunication.h"
#import "ScanForCameraProtocol.h"
#import "DashBoard_ViewController.h"

#import "CameraAlert.h"
#import "Bonjour.h"


#define DIRECTION_V_NON  0x01
#define DIRECTION_V_UP   0x02
#define DIRECTION_V_DN   0x04
#define DIRECTION_V_MASK 0xF0

#define DIRECTION_H_NON 0x10
#define DIRECTION_H_LF  0x20
#define DIRECTION_H_RT  0x40
#define DIRECTION_H_MASK 0x0F

#define CURRENT_VIEW_MODE_MULTI 0x11
#define CURRENT_VIEW_MODE_SINGLE 0x12

@class DashBoard_ViewController; 
@class MBP_CamView;
@class CamProfile;

#define DIRECT_MODE_NEXT_BTN 311

#define ALERT_PUSH_RECVED_RESCAN_AFTER 200
#define ALERT_PUSH_RECVED_RELOGIN_AFTER 201
#define ALERT_PUSH_SERVER_ANNOUNCEMENT 203


#define _streamingSSID @"string_Streaming_SSID"
#define _triggeredByVox @"bool_Vox_Trigger"
#define CAM_IN_VEW @"string_Camera_Mac_Being_Viewed"


#define APP_STAGE_INIT 1
#define APP_STAGE_LOGGED_IN 2
#define APP_STAGE_SETUP 3



/// sendStatus: 
#define SETUP_CAMERA            1
#define LOGIN                   2
#define SCAN_CAMERA             3
#define AFTER_ADD_RELOGIN       4
#define AFTER_DEL_RELOGIN       5
#define BACK_FRM_MENU_NOLOAD    6
#define FRONT_PAGE              7
#define LOGIN_FAILED_OR_LOGOUT  8
#define SCAN_BONJOUR_CAMERA     9




@interface MBP_iosViewController : UIViewController <BonjourDelegate,ConnectionMethodDelegate,UIActionSheetDelegate,ScanForCameraNotifier>
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
	
	AviRecord* iRecorder;
    
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
    
    IBOutlet UIImageView * splashScreen;
    IBOutlet UIImageView * sunBackground;
 
    
    UIAlertView * pushAlert; 
    
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
@property (nonatomic, retain) IBOutlet UIImageView * sunBackground;
@property (nonatomic, assign) id<BonjourDelegate> bonjourDelegate;
//@property (nonatomic,retain) IBOutlet MBP_MainMenuView * mainMenuView;

//@property (nonatomic,retain) HttpCommunication *comm;


@property (nonatomic) BOOL toTakeSnapShot, recordInProgress;
@property (nonatomic, retain) NSString * bc_addr, *own_addr;

@property (nonatomic, retain) NSArray * channel_array; 
@property (nonatomic, retain) NSMutableArray * restored_profiles ;
@property (nonatomic) int app_stage; 


//@property (nonatomic, retain) NSTimer * fullScreenTimer, *alertTimer; 


- (void) initialize ;
- (void) scan_for_devices;
+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip;
+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip ipasLong:(long *) _ownip;

- (BOOL) restoreConfigData;

-(void) startShowingCameraList;

//delegate

- (void)sendStatus:(int) status;

-(BOOL) pushNotificationRcvedInForeground:(CameraAlert *) camAlert;
@end

