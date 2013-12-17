//
//  CamerasViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"

@interface CamerasViewController : UITableViewController

@property (assign, nonatomic) MenuViewController *parentVC;
@property (retain, nonatomic) NSMutableArray *camChannels;

@end
