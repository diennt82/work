//
//  TimelineDatabase.h
//  BlinkHD_ios
//
//  Created by Admin on 24/4/14.
//  Copyright (c) 2014 eBuyNow eCommerce Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface TimelineDatabase : NSObject

@property (nonatomic, strong) NSString *databasePath;

+ (TimelineDatabase *)getSharedInstance;

- (void)reloadBlankTableIfNeeded;
- (void)clearEventForUserName:(NSString *)username;
- (NSMutableArray *)getEventsForCamera:(NSString *)camera_udid;
- (BOOL)deleteEventsForCamera:(NSString *)camera_udid limitedDate:(NSInteger)limitedDate;

- (int)saveEventWithId:(NSString *)event_id event_text:(NSString *)etext event_value:(NSString *)eValue event_name:(NSString *)eName
              event_ts:(int)eTimeStamp event_data:(NSString *)eData camera_udid:(NSString *)udid owner_id:(NSString *)username;

- (void)deleteEventWithID:(NSString *)strEventId;

@end
