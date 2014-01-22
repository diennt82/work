//
//  Step_10_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import <MonitorCommunication/MonitorCommunication.h>

#import "define.h"
#import "Step_12_ViewController.h"
#import "Step_11_ViewController.h"
#import "Step_02_ViewController.h"
#import "GuideAddCamera_ViewController.h"
#import "ConnectionMethodDelegate.h"
@class ScanForCamera;

#define HOME_SSID @"home_ssid"


#define SEND_CONF_SUCCESS 1
#define SEND_CONF_ERROR 2

#define SETUP_CAMERAS_UNCOMPLETE 0
#define SETUP_CAMERAS_COMPLETE 1
#define SETUP_CAMERAS_FAIL 2

//Master_key=BC0B87B2832B67FF58F11749F19C4915D4B876C2505D9CC7D0D06F79653C8B11
#define MASTER_KEY @"Master_key="

#define ALERT_ADDCAM_SERVER_UNREACH 1

//#define 

@interface Step_10_ViewController : UIViewController
{
    IBOutlet UIView * progressView; 
    IBOutlet UILabel * userNameLabel;
    IBOutlet UILabel * userEmailLabel;
    
    //IBOutlet UIView * setupFailView, *setupCompleteView;
    IBOutlet UILabel * cameraName; 
    
    IBOutlet UIView * cameraAddedView; 
    IBOutlet UILabel * homeSSID; //ONLY USED in NORMAL ADD CAM SEQUENCE
    
    int num_scan_time;
    BOOL should_stop_scanning; 

    ScanForCamera * scanner; 
    NSString *cameraMac, *master_key;
    
    BOOL should_retry_silently ;
    
    BOOL shouldStopScanning;
    NSTimer * timeOut;
    NSTimer *timeOutCheckWifiHome;
    
    //member to dismiss when disDisAppearView
    UIAlertView *_alertChooseConfig;    
    
    id<ConnectionMethodDelegate> delegate;
}

@property (nonatomic,assign) IBOutlet UILabel * homeSSID;
@property (nonatomic, assign) IBOutlet UIView * progressView; 
@property (nonatomic, assign) IBOutlet UILabel * userNameLabel;
@property (nonatomic, assign) IBOutlet UILabel * userEmailLabel,  * cameraName;

@property (nonatomic, assign)  id<ConnectionMethodDelegate> delegate;
//@property (nonatomic, assign) IBOutlet UIView * setupFailView, *setupCompleteView;

@property (nonatomic, retain) NSString *cameraMac,  *master_key; 
@property (nonatomic, retain) NSTimer * timeOut;
@property (nonatomic) BOOL shouldStopScanning;
@property (nonatomic, assign) NSString * errorCode;
@property (nonatomic, retain) NSString *stringUDID;
@property (nonatomic, retain) NSString *stringAuth_token;

-(IBAction) startConfigureCamera:(id)sender;

-(IBAction)registerCamera:(id)sender;

- (void) wait_for_camera_to_reboot:(NSTimer *)exp;
- (void) checkScanResult: (NSTimer *) expired;

- (void) setupCompleted;


- (void)  setupFailed;
@end
