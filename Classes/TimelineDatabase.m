//
//  TimelineDatabase.m
//  BlinkHD_ios
//
//  Created by Admin on 24/4/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "TimelineDatabase.h"
#import "EventInfo.h"
#import "NSData+Base64.h"

@implementation TimelineDatabase

static TimelineDatabase *sharedInstance = nil;

//TODO: need to re-create

+ (TimelineDatabase *)getSharedInstance
{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance reloadBlankTableIfNeeded];
    }
    return sharedInstance;
}

- (void)reloadBlankTableIfNeeded
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    self.databasePath = [documentDirectory stringByAppendingPathComponent:@".t_history_v1.sqlite"];
    success = [fileManager fileExistsAtPath:_databasePath];
    
    if (success) {
        NSLog(@"No need to reload t_history");
        return;
    }

    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"t_history_v1.sqlite"];
#if DEBUG_CAM_ALERT_DB
    NSLog(@"defaultDBPath: %@", defaultDBPath);
#endif
    
    success = [fileManager copyItemAtPath:defaultDBPath toPath:_databasePath error:&error];
    if (!success) {
        NSAssert1(0,@"Failed to create writable database file with message: %@", [error localizedDescription]);
    }
}

/*
 camera_events (event_id text primary key, camera_udid text not null, camera_owner_id text not null,  event_alert text not null,  event_value text, event_alert_name text, event_ts integer, event_data  text );
 */
- (int)saveEventWithId:(NSString *)event_id event_text:(NSString *)etext event_value:(NSString *)eValue event_name:(NSString *)eName
              event_ts:(int)eTimeStamp event_data:(NSString *)eData camera_udid:(NSString *)udid owner_id:(NSString *)username
{
    sqlite3* database;
    
    int retVal = -1 ;
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into camera_events (event_id,camera_udid, camera_owner_id, event_alert, event_value, event_alert_name,event_ts, event_data ) values(\"%@\",\"%@\", \"%@\", \"%@\", \"%@\",\"%@\",%d, \"%@\")",
                               event_id,udid, username, etext, eValue,eName, eTimeStamp, eData];
        
        const char *stmt = [insertSQL UTF8String];
        
        // NSLog(@"statement: %s",stmt);
        
        sqlite3_stmt *statement ;
        if (sqlite3_prepare_v2(database, stmt, -1, &statement, NULL) == SQLITE_OK) {
            int ret =sqlite3_step(statement);
            if ( ret == SQLITE_DONE ) {
                retVal = 0;
            }
            else if (ret == SQLITE_CONSTRAINT) {
                //duplicate entry -- fine, we know ..
                //NSLog(@"ADD event: event %@ - %@  exits -  OK", event_id,eName );
                retVal = 1;
            }
            else {
                NSLog(@"ADD alert to database error : %d",ret);
                retVal = -1;
            }
            
            sqlite3_finalize(statement);
        }
    }
    
    sqlite3_close(database);
    
    return retVal;
}

- (NSMutableArray *)getEventsForCamera:(NSString *)camera_udid
{
    sqlite3 *database;
    sqlite3_stmt *statement;
    
    NSMutableArray *retval = [[[NSMutableArray alloc] init] autorelease];
    const char *dbpath = [_databasePath UTF8String];

    NSString *insertSQL = [NSString stringWithFormat:@"select * from  camera_events where camera_udid='%@' ORDER BY event_ts DESC", camera_udid];
    
    const char *stmt = [insertSQL UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *event_id = (char *)sqlite3_column_text(statement, 0);
                //camera_udid : no need to get 1
                // camera_owner_id: no need to get 2
                char *event_alert = (char *)sqlite3_column_text(statement, 3);
                char *event_value = (char *)sqlite3_column_text(statement, 4);
                char *event_alert_name = (char *)sqlite3_column_text(statement, 5);
                int event_unix_ts = sqlite3_column_int(statement,6);
                char *event_data = (char *)sqlite3_column_text(statement, 7);
                
                //NSLog(@"%s: event_unix_ts: %d", __FUNCTION__, event_unix_ts);
                
                EventInfo *eventInfo = [[EventInfo alloc] init];
                eventInfo.alertName = [[[NSString alloc] initWithUTF8String:event_alert_name] autorelease];
                eventInfo.value      = [[[NSString alloc] initWithUTF8String:event_value] autorelease];
                eventInfo.eventID = [[[[NSString alloc] initWithUTF8String:event_id] autorelease] integerValue];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                
                NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:event_unix_ts];
                NSString *eventDate_str = [dateFormatter stringFromDate:eventDate];
                [dateFormatter release];
                
                eventInfo.timeStamp = eventDate_str;
                eventInfo.alert = [[[[NSString alloc] initWithUTF8String:event_alert] autorelease] integerValue];
                
                NSString *event_data_str = [[[NSString alloc] initWithUTF8String:event_data] autorelease];
                NSData *event_data_d = [NSData dataFromBase64String:event_data_str];
                
                NSError *e;
                NSArray *clipsInEvent = [NSJSONSerialization JSONObjectWithData:event_data_d
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&e];
                if ( clipsInEvent ) {
                    ClipInfo *clipInfo = [[ClipInfo alloc] init];
                    clipInfo.urlImage = [clipsInEvent[0] objectForKey:@"image"];
                    clipInfo.urlFile = [clipsInEvent[0] objectForKey:@"file"];
                    
                    eventInfo.clipInfo = clipInfo;
                    [clipInfo release];
                }
                
                [retval addObject:eventInfo];
                [eventInfo release];
            }
            
            sqlite3_finalize(statement);
        }
    }
    
    sqlite3_close(database);
    
    return retval;
}

- (BOOL)deleteEventsForCamera:(NSString *)camera_udid limitedDate:(NSInteger)limitedDate
{
    sqlite3 *database;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        //NSString *delSQL = [NSString stringWithFormat:@"delete from  camera_events where camera_udid='%@' AND event_ts < %d", camera_udid, limitedDate];
        NSString *delSQL = [NSString stringWithFormat:@"delete from  camera_events where camera_udid='%@'", camera_udid];
        
        const char *stmt = [delSQL UTF8String];
        NSLog(@"statement: %s", stmt);
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, stmt, -1, &statement, NULL) == SQLITE_OK) {
            int ret =sqlite3_step(statement);
            
            if ( ret != SQLITE_DONE ) {
                NSLog(@"remove events to database error : %d", ret);
            }
            else {
                NSLog(@"remove events to database OK");
            }
            
            sqlite3_finalize(statement);
        }
    }
    
    sqlite3_close(database);
    
    return FALSE;
}

- (void)clearEventForUserName:(NSString *)username
{
    sqlite3 *database;
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"delete from  camera_events where camera_owner_id='%@'", username];
        
        const char *stmt = [insertSQL UTF8String];
        
        //NSLog(@"statement: %s",stmt);
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, stmt, -1, &statement, NULL) == SQLITE_OK) {
            int ret =sqlite3_step(statement);
            if ( ret != SQLITE_DONE ) {
                NSLog(@"remove events to database error : %d",ret);
            }
            else {
                NSLog(@"remove events to database OK");
            }
            
            sqlite3_finalize(statement);
        }
        
    }
    
    sqlite3_close(database);
}

- (void)deleteEventWithID:(NSString *)strEventId
{
    sqlite3 *database;
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"delete from  camera_events where event_id='%@'", strEventId];
        
        const char *stmt = [insertSQL UTF8String];
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, stmt, -1, &statement, NULL) == SQLITE_OK) {
            int ret = sqlite3_step(statement);
            if ( ret != SQLITE_DONE ) {
                NSLog(@"remove events to database error : %d",ret);
            }
            else {
                NSLog(@"remove events to database OK");
            }
            
            sqlite3_finalize(statement);
        }
        
    }
    
    sqlite3_close(database);
}

@end
