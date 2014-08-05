//
//  PushNotificationAlert.h
//  BlinkHD_ios
//
//  Created by Developer on 4/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraAlert.h"

@interface PushNotificationAlert : UIAlertView
@property (nonatomic, retain) CameraAlert * camAlert;
@end
