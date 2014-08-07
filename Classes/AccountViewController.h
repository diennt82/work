//
//  AccountViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *accountInfo;
@property (nonatomic, weak) IBOutlet UITableViewCell *userEmailCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *versionCell;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *progress;

@property (nonatomic, weak) id parentVC;

@end
