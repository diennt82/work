//
//  CameraMenuViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "ConnectionMethodDelegate.h"

@interface CameraMenuViewController : UIViewController

@property (nonatomic, assign) id<ConnectionMethodDelegate> cameraMenuDelegate;
@property (nonatomic, retain) CamChannel *camChannel;

@end
