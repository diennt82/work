//
//  Setup_04_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CameraScanner/CameraScanner.h>

#import "WifiEntry.h"
//#import "WifiListParser.h"
#import "DisplayWifiList_VController.h"
#import "UARTPeripheral.h"
#import "BLEConnectionManager.h"

#define CONF_CAM_BTN_TAG 1002
#if 1
#define SENDING_SERVER_AUTH      1
#define SENDING_SERVER_AUTH_DONE 2
#else
#define SENDING_MASTER_KEY 1
#define SENDING_MASTER_KEY_DONE 2
#endif

#define ALERT_ASK_FOR_RETRY_BLE 4

@interface EditCamera_VController : UIViewController<BLEConnectionManagerDelegate>
{
    //IBOutlet UIView * camName;
    
    NSString * homeWifiSSID; 
    NSString * cameraMac; 
	NSString * cameraName;

    UIAlertView *_alertView;
    BOOL _isShowingProcess;
    int stage;
}

@property (retain, nonatomic) NSTimer *timerTimeoutConnectBLE;

@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) NSString * cameraMac, * cameraName;

//- (IBAction)handleButtonPress:(id)sender;
@end
