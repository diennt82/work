//
//  UserAccount.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMS_Communication.h"
#import "CamProfile.h"
#import "Util.h"
#import "SetupData.h"
#import "ConnectionMethodDelegate.h"

@interface UserAccount : NSObject {

	NSString * userName;
	NSString * userPass; 
	
	id <ConnectionMethodDelegate> delegate; 	
}

-(id) initWithUser:(NSString*)user AndPass:(NSString*) pass WithListener:(id <ConnectionMethodDelegate>) d;

-(void) query_camera_list;
//Get cam list callbacks
-(void) getCamListSuccess:(NSData*) raw_data;
-(void) getCamListFailure:(NSHTTPURLResponse*) error_response; 
- (void)getCamListServerUnreachable; 

-(NSMutableArray *) parse_camera_list:(NSString*) raw;

-(void) sync_online_and_offline_data:(NSMutableArray *) online_list;

@end
