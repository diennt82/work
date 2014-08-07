//
//  EarlierViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "TimelineViewController.h"

@interface EarlierViewController : UIViewController

@property (nonatomic, strong) TimelineViewController *timelineVC;
@property (nonatomic, strong) CamChannel *camChannel;

- (id)initWithCamChannel:(CamChannel *)camChannel;
- (id)initWithParentVC:(UIViewController *)parentVC camChannel:(CamChannel *)camChannel;

@end
