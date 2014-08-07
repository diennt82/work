//
//  MBP_iosAppDelegate.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MonitorCommunication/MonitorCommunication.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "MBP_iosViewController.h"
#import "NSData+Conversion.h"
#import "CameraAlert.h"
#import "GAI.h"

#define _push_dev_token @"PUSH_NOTIFICATION_DEVICE_TOKEN"

@class MBP_iosViewController;

@interface MBP_iosAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, weak) IBOutlet MBP_iosViewController *viewController;
@property (nonatomic) BOOL becomeActiveByNotificationFlag;

@end

