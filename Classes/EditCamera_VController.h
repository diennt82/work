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
#import "WifiListParser.h"
#import "DisplayWifiList_VController.h"
#import "UARTPeripheral.h"
#import "BLEManageConnect.h"

#define CONF_CAM_BTN_TAG 1002

@interface EditCamera_VController : UIViewController<UITextViewDelegate, BLEManageConnectDelegate>
{
    IBOutlet UIView * camName;
    
    NSString * homeWifiSSID; 
    NSString * cameraMac; 
	NSString * cameraName;
     HttpCommunication *  comm;
    UIAlertView *_alertView;
    BOOL _isShowingProcess;
    NSString *_result_received;
    NSTimer *_timeout;
    NSTimer *_getWifiListTimer;
    BOOL _waitingResponse;
}
@property (nonatomic, retain) NSTimer *timeout;
@property (nonatomic, retain) NSTimer *getWifiListTimer;

//string received from delegate
@property (nonatomic, retain) NSString *result_received;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) NSString * cameraMac, * cameraName;
@property (nonatomic, retain) IBOutlet UIView *statusDialog;
@property (nonatomic, retain) IBOutlet UILabel *statusLable;

- (IBAction)handleButtonPress:(id)sender;
-(void) queryWifiList;


//callback
-(void) setWifiResult:(NSArray *) wifiList;
@end
