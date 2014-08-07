//
//  CameraAlert.h
//  MBP_ios
//
//  Created by NxComm on 9/10/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <CameraScanner/CameraScanner.h>

#define DEBUG_CAM_ALERT_DB 0 

@interface CameraAlert : NSObject {
    
    sqlite3 * database; 
    NSInteger rcvTimeStamp; 
    NSString * cameraMacNoColon; 
    NSString * cameraName; 
    NSString * alertType; 
    NSString * alertVal; 
    NSString * alertTime;
    
    //especially for server announcement 
    NSString * server_url;
    
}

@property (nonatomic, assign, readonly) NSInteger rcvTimeStamp; 
@property (nonatomic, copy) NSString *cameraMacNoColon;
@property (nonatomic, copy) NSString *cameraName;
@property (nonatomic, copy) NSString *alertType;
@property (nonatomic, copy) NSString *alertVal;
@property (nonatomic, copy) NSString *alertTime;
@property (nonatomic, copy) NSString *server_url;
@property (nonatomic, copy) NSString *registrationID;

-(id) initWithTimeStamp:(NSInteger) timeStamp database:(sqlite3 *) db; 
-(id) initWithTimeStamp1:(NSInteger) timeStamp;

+(void) reloadBlankTableIfNeeded;
+( NSArray * ) getAllAlertForCamera:(NSString *) macWithColon;
+( BOOL ) insertAlertForCamera:(CameraAlert *) camAlert;
+(void) clearAllAlertForCamera:(NSString *) macWithColon ;
+(void) clearAllAlerts;

@end
