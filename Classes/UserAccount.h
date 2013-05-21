//
//  UserAccount.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//


#import "BMS_Communication.h"
#import "CamProfile.h"
#import "Util.h"
#import "SetupData.h"
#import "ConnectionMethodDelegate.h"



@interface UserAccount : NSObject
{

	NSString * userName;
	NSString * userPass; 
    BMS_Communication * bms_comm; 
	
	id <ConnectionMethodDelegate> delegate;
}
@property (nonatomic,assign) id <ConnectionMethodDelegate> delegate;
@property (nonatomic,retain) NSString * userName, * userPass;
@property (nonatomic,retain) BMS_Communication * bms_comm;


-(id) initWithUser:(NSString*)user AndPass:(NSString*) pass WithListener:(id <ConnectionMethodDelegate>) d;
-(void) query_camera_list_blocked;

//Get cam list callbacks
-(void) getCamListSuccess:(NSData*) raw_data;
-(void) getCamListFailure:(NSHTTPURLResponse*) error_response; 
- (void)getCamListServerUnreachable; 


-(NSMutableArray *) parse_camera_list:(NSString*) raw;

-(void) sync_online_and_offline_data:(NSMutableArray *) online_list;

-(void) query_snapshot_from_server:(NSArray *) cam_profiles;

-(void) query_disabled_alert_list:(NSArray *) cam_profiles;
-(NSString *) query_cam_ip_online:(NSString *) mac_no_colon;
-(void) readCameraListAndUpdate;

@end
