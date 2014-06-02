//
//  Step_10_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MonitorCommunication/MonitorCommunication.h>

#import "define.h"
#import "Step_12_ViewController.h"
#import "Step_11_ViewController.h"
#import "Step_02_ViewController.h"
#import "ConnectionMethodDelegate.h"

@class ScanForCamera;


#define SEND_CONF_SUCCESS 1
#define SEND_CONF_ERROR 2

#define SETUP_CAMERAS_UNCOMPLETE 0
#define SETUP_CAMERAS_COMPLETE 1
#define SETUP_CAMERAS_FAIL 2

//Master_key=BC0B87B2832B67FF58F11749F19C4915D4B876C2505D9CC7D0D06F79653C8B11
#define MASTER_KEY @"Master_key="

//#define 

@interface Step_10_ViewController : GAITrackedViewController
{

    int num_scan_time;
    BOOL should_stop_scanning; 


    NSString *cameraMac, *master_key;
    
    BOOL should_retry_silently ;
    
    //member to dismiss when disDisAppearView
    UIAlertView *_alertChooseConfig;    
    
    id<ConnectionMethodDelegate> delegate;
}

@property (retain, nonatomic) IBOutlet UIView *ib_viewGuild;
@property (retain, nonatomic) IBOutlet UIScrollView *ib_scollViewGuide;
@property (retain, nonatomic) IBOutlet UIButton *ib_resumeSetup;

@property (nonatomic, assign)  id<ConnectionMethodDelegate> delegate;
@property (nonatomic, retain) NSString *cameraMac,  *master_key;

@property (nonatomic, assign) NSString * errorCode;
@property (nonatomic, retain) NSString *stringUDID;
@property (nonatomic, retain) NSString *stringAuth_token;



-(IBAction)registerCamera:(id)sender;

- (void) wait_for_camera_to_reboot:(NSTimer *)exp;


- (void) setupCompleted;
- (void)  setupFailed;

@end
