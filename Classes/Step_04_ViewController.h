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
#import "Step_05_ViewController.h"
#define CONF_CAM_BTN_TAG 1002

@interface Step_04_ViewController : UIViewController
{    
    NSString * homeWifiSSID;
    NSString * cameraMac;
	NSString * cameraName;
}

@property (retain, nonatomic) IBOutlet UIView *progressView;
@property (nonatomic, retain) NSString * cameraMac, * cameraName;

@end
