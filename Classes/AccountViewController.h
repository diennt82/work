//
//  AccountViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController

@property (nonatomic, assign) IBOutlet UITableView *accountInfo;
@property (nonatomic, assign) IBOutlet UITableViewCell *userEmailCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *versionCell;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *progress;

@property (nonatomic, assign) id parentVC;

@end
