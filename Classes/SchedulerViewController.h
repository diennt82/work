//
//  SchedulerViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchedulerViewController : UITableViewController

@property (nonatomic) NSInteger numberOfColumn;

- (void)reloadDataInTableView;

@end
