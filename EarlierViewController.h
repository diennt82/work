//
//  EarlierViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "MHTabBarController.h"
#import "TimelineViewController.h"

@interface EarlierViewController : UIViewController<MHTabBarControllerDelegate>
{
    MHTabBarController *_tabBarController;
}

@property (nonatomic, retain) TimelineViewController *timelineVC;
@property (nonatomic, assign) CamChannel *camChannel;
@property (nonatomic, assign) UINavigationController *nav;

- (id)initWithCamChannel: (CamChannel *)camChannel;

@end
