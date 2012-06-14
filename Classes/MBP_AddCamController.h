//
//  MBP_AddCamController.h
//  MBP_ios
//
//  Created by NxComm on 5/2/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicDefine.h"
#import "ConnectionMethodDelegate.h"
#import "MBP_iosViewController.h"
#import "MBP_DeviceConfigureViewController.h"
#import "BMS_Communication.h"
#import "CameraPassword.h"
#import "ScanForCamera.h"
#import "CamProfile.h"

#define STEP_1_NEXT_BTN 100
#define STEP_2_NEXT_BTN 101
#define FINISH_BTN      103

#define	STEP_1_BACK_BTN 104
#define	STEP_2_BACK_BTN 105


#define SEND_CONF_SUCCESS 1
#define SEND_CONF_ERROR 2

//Master_key=BC0B87B2832B67FF58F11749F19C4915D4B876C2505D9CC7D0D06F79653C8B11
#define MASTER_KEY @"Master_key="

@class ScanForCamera;

@interface MBP_AddCamController : UIViewController <ConnectionMethodDelegate>{

	IBOutlet UIScrollView * step_1View; 
	IBOutlet UIScrollView * step_2View; 
	IBOutlet UIButton * connect; 
	IBOutlet UIActivityIndicatorView * progress; 
	IBOutlet UIView * progressView; 
	IBOutlet UIView * finishView; 


	id <ConnectionMethodDelegate> delegate;
	
	NSString * homeWifiSSID; 
	NSString * cameraMac; 
	NSString * cameraName;
	NSString * master_key; 
	ScanForCamera * scanner; 
	
	int num_scan_time; 
	BOOL task_cancelled ; 
}

@property (nonatomic, retain) IBOutlet UIScrollView * step_1View, * step_2View; 
@property (nonatomic, retain) IBOutlet UIButton * connect; 
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * progress;

@property (nonatomic, retain) NSString * homeWifiSSID, * cameraMac, * cameraName, *master_key;

@property (nonatomic, retain) IBOutlet UIView * progressView, * finishView; 


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) delegate;

- (IBAction) handleButtonPressed:(id) sender;

- (void) addCamSuccessWithResponse:(NSData*) responseData;
- (void) addCamFailedWithError:(NSHTTPURLResponse*) error_response;
- (void) addCamFailedServerUnreachable;
-(void) sendStatus:(int) status;
-(void ) extractMasterKey:(NSString*) raw;

- (void) checkScanResult: (NSTimer * )expired;
- (void) wait_for_camera_to_reboot:(NSTimer *)exp;
-(void) setupCompleted;
- (void)  setupFailed;

@end
