//
//  CamerasViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CamerasViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *camChannels;
@property (nonatomic, weak) id parentVC;
@property (nonatomic) BOOL waitingForUpdateData;

- (void)camerasReloadData;

@end
