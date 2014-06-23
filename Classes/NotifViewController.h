//
//  NotifViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import <CameraScanner/CameraScanner.h>
#import "CameraMenuViewController.h"
#import "MenuViewController.h"

@interface NotifViewController : UIViewController{

    BMS_JSON_Communication *jsonComm;
}

@property(nonatomic, retain) id <ConnectionMethodDelegate> notifDelegate;

@property (nonatomic, retain)     NSString * cameraMacNoColon;
@property (nonatomic, retain)     NSString * cameraName;
@property (nonatomic, retain)     NSString * alertType;
@property (nonatomic, retain)     NSString * alertVal;
@property (nonatomic, retain)     NSString * alertTime;
@property (nonatomic, retain)     NSString * server_url;
@property (nonatomic, retain)     NSString * registrationID;

@property (nonatomic, assign) CamChannel *camChannel;
@property (assign, nonatomic) id parentVC;


- (IBAction)ignoreTouchAction:(id)sender;
- (void)cancelTaskDoInBackground;

@end
