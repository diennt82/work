//
//  MBP_MenuViewController.h
//  MBP_ios
//
//  Created by NxComm on 5/11/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
#import "HttpCommunication.h"
#import "BMS_Communication.h"
#import "CameraPassword.h"

#define MAIN_MENU_TAG 1001
#define CAM_MENU_TAG  1002

#define _to_SubMenu @"bool_shouldGoToSubStg"
#define _is_Loggedin @"bool_isLoggedIn"
#define _UserName   @"str_userName"
#define _UserPass   @"str_userPass"
#define _DeviceIp @"str_deviceIp"
#define _DevicePort @"int_devicePort"
#define _DeviceMac @"str_deviceMac"
#define _DeviceName @"str_deviceName"
#define _DeviceInLocal @"bool_devInLocal"
#define _DeviceMac_out @"str_deviceMac_out"
#define _DeviceName_out @"str_deviceName_out"
#define _tempUnit @"int_tempUnit"


#define _VOX_DICT_KEY @"Sound Sensitivity Settings:" // need to match plist string- 
#define _NAME_DICT_KEY @"Camera Name:"
#define _VOL_DICT_KEY @"Camera Volume:"
#define _BR_DICT_KEY @"Camera Brightness:"
#define _TEMP_DICT_KEY @"Temperature Unit:"
#define _VIDEO_DICT_KEY @"Video Quality:" 


#define ALERT_CHANGE_NAME 1
#define ALERT_CHANGE_ANGLE 4

#define DIALOG_IS_NOT_REACHABLE 1
#define DIALOG_CANT_RENAME 2
#define ALERT_NAME_CANT_BE_EMPTY 3

#define ALERT_REMOVE_CAM 5

#define ALERT_REMOVE_CAM_LOCAL 6
#define ALERT_REMOVE_CAM_REMOTE 7

#define ALERT_MANUAL_FWD_MODE  8
#define ALERT_UPNP_OK     9
#define ALERT_UPNP_NOT_OK 10
#define ALERT_UPNP_RUNNING 11
#define ALERT_EMPTY_PORTS 12
#define ALERT_INVALID_PORTS 13


#define VOL_LEVEL_PICKER 100
#define BRIGHTNESS_LEVEL_PICKER 101
#define VOX_LEVEL_PICKER 102
#define TEMP_UNIT_PICKER 103
#define VQ_PICKER        104

@interface MBP_MenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

	NSArray * mainMenuItems; 
	IBOutlet UITableView * mainMenu;
	IBOutlet UITableView * cameraMenu;
	IBOutlet UIPickerView * mPickerView;
	
	IBOutlet UIView * manualFWDView; 
	IBOutlet UIView * manualFWDSubView; 
	IBOutlet UIButton * manualFWDCancel; 
	IBOutlet UIButton * manualFWDChange; 
	IBOutlet UITextField * manualFWDprt80;
	IBOutlet UITextField * manualFWDprt51108; 
	IBOutlet UISegmentedControl * manualOrAuto; 
	
	
	NSArray *cameraMenuItems;
	NSMutableDictionary * cameraMenuItemValues;
	
	id <ConnectionMethodDelegate> delegate;
	
	BOOL isDirectMode; 
	
	BOOL isLoggedIn ; 
	NSString * userName; 
	NSString * userPass; 
	NSString * deviceIp; 
	int devicePort; 
	NSString * deviceMac;
	NSString * deivceName; 
	BOOL deviceInLocal; 
	NSString * httpUserName, * httpUserPass; 

	HttpCommunication * dev_comm; 
	
	
	NSArray * levels;
	NSArray * voxlevels;
	NSArray * temperature;
	NSArray * videoQuality;
	
	int volLevel; 
	int brightLevel; 
	int voxLevel;
	int tempunit; 
	int videoQ;
	
}
@property (nonatomic, retain) IBOutlet UIPickerView * mPickerView;
@property (nonatomic,retain) IBOutlet UITableView * mainMenu;
@property (nonatomic,retain) IBOutlet UITableView * cameraMenu;

@property (nonatomic,retain) NSArray * mainMenuItems; 
@property (nonatomic, retain) NSArray *cameraMenuItems;
@property (nonatomic, retain) NSMutableDictionary *cameraMenuItemValues;


@property (nonatomic, retain) IBOutlet UIView * manualFWDView, *manualFWDSubView; 
@property (nonatomic, retain) IBOutlet UIButton * manualFWDCancel; 
@property (nonatomic, retain) IBOutlet UIButton * manualFWDChange; 
@property (nonatomic, retain) IBOutlet UITextField * manualFWDprt80;
@property (nonatomic, retain) IBOutlet UITextField * manualFWDprt51108; 
@property (nonatomic, retain) IBOutlet UISegmentedControl * manualOrAuto; 

- (id)initWithNibName:(NSString *)nibNameOrNil 
				bundle:(NSBundle *)nibBundleOrNil 
	  withConnDelegate:(id<ConnectionMethodDelegate>) d 
			modeDirect:(BOOL) isDirect;
-(void) readPreferenceData;

- (void) setupSubMenu;
- (void) updateVoxStatus;
- (void) updateBrightnessLvl;
- (void) updateTemperatureConversion;
- (void) updateVolumeLvl;
- (void) updateVQ;


-(void) onSetVolumeLevel:(int) level;
-(void) onSetBrightnessLevel:(int) level;
-(void) onSetVoxLevel:(int) level;
-(void) onSetTempUnit:(int) unit;
-(void) onSetVideoQuality:(int) vq;

-(void) onViewAngle;
- (void) viewAnglePopup ;
-(void)onName;
-(void)onInformation;
-(void)onVol;
-(void) onBright;
-(void) onVox;
-(void) onTemp;
-(void) onVQ;

- (void) showDialog:(int) dialogType;
-(void) onRemoveCamera;
-(void) onCheckUPnpStatus;
-(void) onManualPortFwd;

-(void) onCameraRemoveRemote;
-(void) onCameraRemoveLocal;

- (void) askForNewName;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void) onCameraNameChanged:(NSString*) newName;

-(void) changeNameSuccessWithResponse:(NSData *) responsedata;
-(void) changeNameFailedWithError:(NSHTTPURLResponse*) error_response;
-(void) changeNameFailedServerUnreachable;

-(void) removeCamSuccessWithResponse:(NSData *) responsedata;
-(void) removeCamFailedWithError:(NSHTTPURLResponse*) error_response;
-(void) removeCamFailedServerUnreachable;

-(IBAction) handleButtonPress:(id)sender;


@end
