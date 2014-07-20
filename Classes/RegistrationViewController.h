//
//  RegistrationViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
#import "GAI.h"

#define TAG_ALERT_VIEW_NETWORK_NOT_REACHABLE 157
#define TAG_ALERT_VIEW_3G                    257
#define TAG_ALERT_VIEW_CAMERA_WIFI           357

#define _Use3G              @"use3GToConnect"

@interface RegistrationViewController : GAITrackedViewController

@property (nonatomic, assign)  id<ConnectionMethodDelegate> delegate;
+ (NSInteger )checkNetworkConnectionCallback:(id)d;

@end
