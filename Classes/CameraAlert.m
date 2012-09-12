//
//  CameraAlert.m
//  MBP_ios
//
//  Created by NxComm on 9/10/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "CameraAlert.h"
#import "Util.h"
@implementation CameraAlert


@synthesize rcvTimeStamp; 
@synthesize cameraMacNoColon; 
@synthesize cameraName; 
@synthesize alertType; 
@synthesize alertVal; 
@synthesize alertTime; 

static sqlite3_stmt *init_statement = nil;

-(id) initWithTimeStamp:(NSInteger) timeStamp database:(sqlite3 *) db
{
    self = [super init]; 
    
    
    rcvTimeStamp = timeStamp;
    database = db; 
    if (init_statement == nil)
    {
        const char * sql_stmt = "SELECT cameraMacNoColon FROM history WHERE rcvTimeStamp=?";
        
        if (sqlite3_prepare_v2(database, sql_stmt, -1, &init_statement, NULL) != SQLITE_OK)
        {
            NSAssert1(0,@"Error failed to prepare statment with message:%s", sqlite3_errmsg(database)); 
        }
        sqlite3_bind_int(init_statement, 1, rcvTimeStamp);
        if (sqlite3_step(init_statement))
        {
            char * text = (char *)sqlite3_column_text(init_statement, 1);
            self.cameraMacNoColon = [NSString stringWithUTF8String:text];
        }
        else 
        {
            self.cameraMacNoColon = @"112233445566";
        }
        
        sqlite3_reset(init_statement);
        
    }
    
    
    
    return self;

}

-(id) initWithTimeStamp1:(NSInteger) timeStamp 
{
    self = [super init]; 
    
    
    rcvTimeStamp = timeStamp;
    database = nil; 
    
    return self;
    
}



+(void) reloadBlankTableIfNeeded
{
    BOOL success;
    NSFileManager * fileManager = [NSFileManager defaultManager]; 
    
    
    NSError * error; 
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0]; 
    
    NSString *writableDBPath = [documentDirectory stringByAppendingPathComponent:@"alert_history.splite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    if (success) 
    {
        NSLog(@"No need to reload"); 
        return;
    }
    
    
    
    NSString * defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"alert_history.splite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error]; 
    if (!success)
    {
        NSAssert1(0,@"Failed to create writable database file with message: %@", [error localizedDescription]); 
    }
    
    
    
}


//TODO: Insert api

+( BOOL) insertAlertForCamera:(CameraAlert  *) camAlert 
{

    
    // history(rcvTimeStamp integer primary key, cameraMacNoColon varchar(12), cameraName varchar, alertType varchar, alertTime varchar, alertVal varchar);
    //INSERT INTO Persons VALUES (...)
    
    
    int timeStamp = [[NSDate date] timeIntervalSince1970]; ; 
    
 
    
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0]; 
    NSString *writableDBPath = [documentDirectory stringByAppendingPathComponent:@"alert_history.splite"];
    sqlite3 * database; 

    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK)
    {
        //set other values
        NSString * _stmt = [NSString stringWithFormat:@"INSERT INTO history VALUES (%d,%@,%@,%@,%@,%@)",
                            timeStamp,camAlert.cameraMacNoColon,  camAlert.cameraName,
                            camAlert.alertType,camAlert.alertTime,  camAlert.alertVal  ]; 
        
        
        const char * stmt = [_stmt UTF8String]; 
        sqlite3_stmt * statement ; 
        if (sqlite3_prepare_v2(database, stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) != SQLITE_DONE)
            {
                NSLog(@"ADD alert to database error"); 
            }
            else {
                NSLog(@"ADD alert to database OK"); 
            }
            
            sqlite3_reset(statement);
        }
        
    }
    
    
    return TRUE; 
}


+( NSArray * ) getAllAlertForCamera:(NSString *) macWithColon 
{
    
    NSMutableArray * alerts = [[NSMutableArray alloc] init]; 
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0]; 
    NSString *writableDBPath = [documentDirectory stringByAppendingPathComponent:@"alert_history.splite"];
     sqlite3 * database; 
    NSString * _mac = [Util strip_colon_fr_mac:macWithColon]; 
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK)
    {
        NSString * _stmt = [NSString stringWithFormat:@"SELECT * from history where cameraMacNoColon='%@'", _mac]; 
        
        const char * stmt = [_stmt UTF8String]; 
        sqlite3_stmt * statement ; 
        if (sqlite3_prepare_v2(database, stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                int rcvTimeStamp = sqlite3_column_int(statement, 0); 
                
                CameraAlert * camAlert = [[CameraAlert alloc]initWithTimeStamp:rcvTimeStamp database:database];
                //set other values
                camAlert.cameraMacNoColon = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement,1)];
                camAlert.cameraName = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement,2)];
                camAlert.alertType = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement,3)];
                camAlert.alertTime = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement,4)];
                camAlert.alertVal = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement,5)];
                
                
                [alerts addObject:camAlert];
                [camAlert release]; 
            }
        }
        
    }
    
    
    return alerts; 
}






@end
