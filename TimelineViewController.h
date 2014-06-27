//
//  TimelineViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
//#import "PlaybackViewController.h"
#import "UIImageView+WebCache.h"
#import "TimelineActivityCell.h"

@protocol TimelineVCDelegate <NSObject>

- (void)stopStreamToPlayback;
//@optional
//- (void) refreshTableView;

@end
#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]


@interface TimelineViewController : UITableViewController
{
    NSArray *aryDatePrefix;
    IBOutlet TimelineActivityCell * activityCell;
}
@property(nonatomic, retain) IBOutlet TimelineActivityCell * activityCell;

@property (nonatomic, assign) id<TimelineVCDelegate> timelineVCDelegate;
@property (nonatomic, assign) CamChannel *camChannel;
@property (nonatomic, retain) NSMutableArray *eventArrayTestData;
@property (nonatomic, assign) UINavigationController *navVC;
@property (nonatomic, assign) id parentVC;

- (void)loadEvents: (CamChannel *)camChannel;
-(void)getExtraEvent_bg;

@end
