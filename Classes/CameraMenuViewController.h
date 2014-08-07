//
//  CameraMenuViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "ConnectionMethodDelegate.h"

@interface CameraMenuViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableViewCell *tableViewCell;
@property (nonatomic, weak) id<ConnectionMethodDelegate> cameraMenuDelegate;
@property (nonatomic, weak) CamChannel *camChannel;
@property (nonatomic, copy) NSString *cameraName;

@end
