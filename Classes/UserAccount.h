//
//  UserAccount.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#define API_KEY @"API_KEY"

#import "CamProfile.h"
#import "Util.h"
#import "SetupData.h"
#import "ConnectionMethodDelegate.h"

#import <MonitorCommunication/MonitorCommunication.h>

@interface UserAccount : NSObject
{

	NSString * userName;
	NSString * userPass;
	
	id <ConnectionMethodDelegate> delegate;
}
@property (nonatomic,assign) id <ConnectionMethodDelegate> delegate;
@property (nonatomic,retain) NSString * userName, * userPass;

@property (nonatomic, retain) NSString *apiKey;


-(id) initWithUser:(NSString*)user AndPass:(NSString*) pass WithListener:(id <ConnectionMethodDelegate>) d;
- (id) initWithUser:(NSString *)user andPass:(NSString *)pass andApiKey: (NSString *)apiKey andListener:(id <ConnectionMethodDelegate>) d;
-(void) query_camera_list_blocked;

//Get cam list callbacks
- (void)getCamListSuccess:(NSDictionary *)raw_data;
-(void) getCamListFailure:(NSHTTPURLResponse*) error_response; 
- (void)getCamListServerUnreachable; 

-(NSMutableArray *) parse_camera_list:(NSArray *)raw;

-(void) sync_online_and_offline_data:(NSMutableArray *) online_list;

-(void) query_snapshot_from_server:(NSArray *) cam_profiles;

//-(void) query_disabled_alert_list:(NSArray *) cam_profiles;
-(NSString *) query_cam_ip_online:(NSString *) mac_no_colon;
-(void) readCameraListAndUpdate;

@end
