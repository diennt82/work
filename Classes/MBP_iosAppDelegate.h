//
//  MBP_iosAppDelegate.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosViewController.h"
#import "NSData+Conversion.h"
#import "CameraAlert.h"
#import "GAI.h"
#import <MonitorCommunication/MonitorCommunication.h>


#define _push_dev_token @"PUSH_NOTIFICATION_DEVICE_TOKEN"

@class MBP_iosViewController;

@interface MBP_iosAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MBP_iosViewController *viewController;
    
    BOOL isFirstTime;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MBP_iosViewController *viewController;

@property (nonatomic) BOOL becomeActiveByNotificationFlag;

@end

