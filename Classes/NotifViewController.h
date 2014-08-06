//
//  NotifViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>

#import "ConnectionMethodDelegate.h"

@interface NotifViewController : UIViewController

@property (nonatomic, retain) id<ConnectionMethodDelegate> notifDelegate;
@property (nonatomic, assign) CamChannel *camChannel;
@property (nonatomic, assign) id parentVC;
@property (nonatomic, copy) NSString *cameraMacNoColon;
@property (nonatomic, copy) NSString *cameraName;
@property (nonatomic, copy) NSString *alertType;
@property (nonatomic, copy) NSString *alertVal;
@property (nonatomic, copy) NSString *alertTime;
@property (nonatomic, copy) NSString *server_url;
@property (nonatomic, copy) NSString *registrationID;

- (IBAction)ignoreTouchAction:(id)sender;

@end
