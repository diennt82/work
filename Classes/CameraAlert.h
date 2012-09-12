//
//  CameraAlert.h
//  MBP_ios
//
//  Created by NxComm on 9/10/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface CameraAlert : NSObject {
    
    sqlite3 * database; 
    NSInteger rcvTimeStamp; 
    NSString * cameraMacNoColon; 
    NSString * cameraName; 
    NSString * alertType; 
    NSString * alertVal; 
    NSString * alertTime; 
    
}

@property (nonatomic, assign, readonly) NSInteger rcvTimeStamp; 
@property (nonatomic, retain)     NSString * cameraMacNoColon; 
@property (nonatomic, retain)     NSString * cameraName; 
@property (nonatomic, retain)     NSString * alertType; 
@property (nonatomic, retain)     NSString * alertVal; 
@property (nonatomic, retain)     NSString * alertTime; 


-(id) initWithTimeStamp:(NSInteger) timeStamp database:(sqlite3 *) db; 

-(id) initWithTimeStamp1:(NSInteger) timeStamp;

+(void) reloadBlankTableIfNeeded;
+( NSArray * ) getAllAlertForCamera:(NSString *) macWithColon;
+( BOOL ) insertAlertForCamera:(CameraAlert *) camAlert;


@end
