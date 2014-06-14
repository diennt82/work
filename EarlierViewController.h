//
//  EarlierViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "TimelineViewController.h"

@interface EarlierViewController : UIViewController

@property (nonatomic, retain) TimelineViewController *timelineVC;
@property (nonatomic, assign) CamChannel *camChannel;
@property (nonatomic, assign) UINavigationController *nav;

- (id)initWithCamChannel:(CamChannel *)camChannel;
- (id)initWithParentVC:(id)parentVC camChannel: (CamChannel *)camChannel;

@end
