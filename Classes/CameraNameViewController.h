//
//  CameraNameViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MenuCameraViewController.h"
#import "CameraMenuViewController.h"

@interface CameraNameViewController : UITableViewController

@property (nonatomic, retain) NSString *cameraName;
@property (nonatomic, retain) CameraMenuViewController *parentVC;

@end
