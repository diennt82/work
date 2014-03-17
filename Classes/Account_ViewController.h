//
//  Account_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraAlert.h"

@interface Account_ViewController : UIViewController
{
    IBOutlet UITableViewCell * userEmailCell,
          * versionCell;
    IBOutlet UITableView * accountInfo;
    
    IBOutlet UIActivityIndicatorView * progress;
    
    NSString *_newPass;
    NSString *_newPassConfirm;
}

@property (nonatomic, assign) id parentVC;

@end
