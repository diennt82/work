//
//  CamerasViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"

@interface CamerasViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *camChannels;
@property (nonatomic, assign) id parentVC;
@property (nonatomic) BOOL waitingForUpdateData;

- (id)initWithDelegate:(id<ConnectionMethodDelegate>)delegate parentVC:(id)parentVC;
- (void)camerasReloadData;

@end
