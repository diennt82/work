//
//  MenuCameraViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/19/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "ConnectionMethodDelegate.h"

@interface MenuCameraViewController : UITableViewController

@property (nonatomic, retain) CamChannel *camChannel;

@property (nonatomic, assign) id<ConnectionMethodDelegate> menuCamerasDelegate;

@end
