//
//  UserAccount.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <CameraScanner/CameraScanner.h>
#import <MonitorCommunication/MonitorCommunication.h>

#import "SetupData.h"

#define API_KEY @"API_KEY"
#define CAMERA_STATE_UNKNOWN       -1
#define CAMERA_STATE_FW_UPGRADING   0
#define CAMERA_STATE_IS_AVAILABLE   1
#define CAMERA_STATE_REGISTED_LOGGED_USER 2

@protocol UserAccountDelegate <NSObject>

- (void)finishStoreCameraListData: (NSMutableArray *)arrayCamProfile success: (BOOL)success;
//- (void)getCameraListError;

@end

@interface UserAccount : NSObject
{

	NSString * userName;
	NSString * userPass;
	
	//id <ConnectionMethodDelegate> delegate;
}
//@property (nonatomic,assign) id <ConnectionMethodDelegate> delegate;
@property (nonatomic,retain) NSString * userName, * userPass;

@property (nonatomic, retain) NSString *apiKey;
//@property (nonatomic, assign) id<UserAccountLoginDelegate> uaLoginDelegate;

//- (id) initWithUser:(NSString *)user andPass:(NSString *)pass andApiKey: (NSString *)apiKey andListener:(id <ConnectionMethodDelegate>) d;
- (id)initWithUser:(NSString *)user
          password:(NSString *)pass
            apiKey:(NSString *)apiKey
          listener:(id<UserAccountDelegate> ) d;

//Get cam list callbacks
//- (void)getCamListSuccess:(NSDictionary *)raw_data;
//-(void) getCamListFailure:(NSHTTPURLResponse*) error_response; 
//- (void)getCamListServerUnreachable; 

-(NSMutableArray *) parse_camera_list:(NSArray *)raw;

-(void) sync_online_and_offline_data:(NSMutableArray *) online_list;

-(void) query_snapshot_from_server:(NSArray *) cam_profiles;

//-(void) query_disabled_alert_list:(NSArray *) cam_profiles;
-(NSString *) query_cam_ip_online:(NSString *) mac_no_colon;
-(void) readCameraListAndUpdate;
- (BOOL)checkCameraIsAvailable:(NSString *) mac_w_colon;
- (NSInteger )checkAvailableAndFWUpgradingWithCamera:(NSString *) mac_w_colon;

@end
