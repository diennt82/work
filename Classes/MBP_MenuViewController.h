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
#define _DeviceMac_out @"str_deviceMac_out"
#define _DeviceName_out @"str_deviceName_out"
#define _tempUnit @"int_tempUnit"


#define _VOX_DICT_KEY @"Sound Sensitivity Settings:" // need to match plist string- 
#define _NAME_DICT_KEY @"Camera Name:"
#define _VOL_DICT_KEY @"Camera Volume:"
#define _BR_DICT_KEY @"Camera Brightness:"
#define _TEMP_DICT_KEY @"Temperature Unit:"
#define _VIDEO_DICT_KEY @"Video Quality:" 



@interface MBP_MenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

	NSArray * mainMenuItems; 
	IBOutlet UITableView * mainMenu;
	IBOutlet UITableView * cameraMenu;
	
	NSArray *cameraMenuItems;
	NSMutableDictionary * cameraMenuItemValues;
	
	id <ConnectionMethodDelegate> delegate;
	
	
	BOOL isLoggedIn ; 
	NSString * userName; 
	NSString * userPass; 
	NSString * deviceIp; 
	int devicePort; 
	NSString * deviceMac;
	NSString * deivceName; 
	NSString * httpUserName, * httpUserPass; 

	HttpCommunication * dev_comm; 
}

@property (nonatomic,retain) IBOutlet UITableView * mainMenu;
@property (nonatomic,retain) IBOutlet UITableView * cameraMenu;

@property (nonatomic,retain) NSArray * mainMenuItems; 
@property (nonatomic, retain) NSArray *cameraMenuItems;
@property (nonatomic, retain) NSMutableDictionary *cameraMenuItemValues;


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
@end
