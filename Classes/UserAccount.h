//
//  UserAccount.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Hubble Connected Ltd. All rights reserved.
//

#define API_KEY @"API_KEY"
#define CAMERA_STATE_UNKNOWN       -1
#define CAMERA_STATE_FW_UPGRADING   0
#define CAMERA_STATE_IS_AVAILABLE   1
#define CAMERA_STATE_REGISTED_LOGGED_USER 2

@protocol UserAccountDelegate <NSObject>

- (void)finishStoreCameraListData:(NSMutableArray *)arrayCamProfile success:(BOOL)success;

@end

@interface UserAccount : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userPass;
@property (nonatomic, copy) NSString *apiKey;

- (id)initWithUser:(NSString *)user
          password:(NSString *)pass
            apiKey:(NSString *)apiKey
   accountDelegate:(id<UserAccountDelegate>)delegate;

- (NSMutableArray *)parse_camera_list:(NSArray *)raw;
- (void)sync_online_and_offline_data:(NSMutableArray *)online_list;
- (void)query_snapshot_from_server:(NSArray *)cam_profiles;

- (NSString *)query_cam_ip_online:(NSString *)mac_no_colon;
- (void)readCameraListAndUpdate;
- (BOOL)checkCameraIsAvailable:(NSString *)mac_w_colon;
- (NSInteger)checkAvailableAndFWUpgradingWithCamera:(NSString *)mac_w_colon;

@end
