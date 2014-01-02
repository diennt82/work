//
//  TimelineViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>

@protocol TimelineVCDelegate <NSObject>

- (void)stopStreamToPlayback;

@end

@interface TimelineViewController : UITableViewController

@property (nonatomic, assign) id<TimelineVCDelegate> timelineVCDelegate;
@property (nonatomic, assign) CamChannel *camChannel;
@property (nonatomic, retain) NSMutableArray *eventArrayTestData;
@property (nonatomic, assign) UINavigationController *navVC;
@property (nonatomic, assign) id parentVC;

- (void)loadEvents: (CamChannel *)camChannel;

@end
