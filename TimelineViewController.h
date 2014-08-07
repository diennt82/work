//
//  TimelineViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>

@protocol TimelineVCDelegate <NSObject>

- (void)stopStreamPlayback;
- (void)startStreamPlayback;

@end

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface TimelineViewController : UITableViewController

@property (nonatomic, weak) id<TimelineVCDelegate> timelineVCDelegate;
@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, strong) CamChannel *camChannel;

- (void)loadEvents:(CamChannel *)camChannel;

@end
