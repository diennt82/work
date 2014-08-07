//
//  Setup_04_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>

#import "WifiEntry.h"
#import "WifiListParser.h"
#import "Step_05_ViewController.h"

#define CONF_CAM_BTN_TAG 1002

@interface Step_04_ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, copy) NSString *cameraMac;
@property (nonatomic, copy) NSString *cameraName;

@end
