//
//  CameraNameViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraMenuViewController.h"

@interface CameraNameViewController : UITableViewController

@property (nonatomic, assign) CameraMenuViewController *parentVC;
@property (nonatomic, copy) NSString *cameraName;

@end
