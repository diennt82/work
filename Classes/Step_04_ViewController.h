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

#define CONF_CAM_BTN_TAG 1002
#define TAG_BTN_SKIP     1003

@interface Step_04_ViewController : UIViewController
{    
    NSString * homeWifiSSID;
    NSString * cameraMac;
}

@property (retain, nonatomic) IBOutlet UIView *progressView;
@property (nonatomic, retain) NSString * cameraName;
@property (nonatomic, retain) CamProfile *camProfile;

@end
