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

- (void)syncOnlineAndOfflineData:(NSMutableArray *)onlineList;
- (void)readCameraListAndUpdate;
- (BOOL)checkCameraIsAvailable:(NSString *)macWithColon;
- (NSInteger)checkAvailableAndFWUpgradingWithCamera:(NSString *)macWithColon;

@end
