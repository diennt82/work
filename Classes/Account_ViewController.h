//
//  Account_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraAlert.h"

@interface Account_ViewController : UIViewController
{
    IBOutlet UITableViewCell *userEmailCell, *versionCell;
    IBOutlet UITableView *accountInfo;
    IBOutlet UIActivityIndicatorView *progress;
}

@property (nonatomic, assign) id parentVC;

@end
