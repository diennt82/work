//
//  TimelineViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
//#import "PlaybackViewController.h"


@protocol TimelineVCDelegate <NSObject>

- (void)stopStreamPlayback;
- (void)startStreamPlayback;

@end

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface TimelineViewController : UITableViewController

@property (nonatomic, assign) id<TimelineVCDelegate> timelineVCDelegate;
@property (nonatomic, assign) CamChannel *camChannel;
@property (nonatomic, retain) NSMutableArray *eventArrayTestData;
@property (nonatomic, assign) UIViewController *parentVC;

- (void)loadEvents:(CamChannel *)camChannel;

@end
