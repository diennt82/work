//
//  UserAccount.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>

#import "UserAccount.h"
#import "PublicDefine.h"
#import "SetupData.h"

@interface UserAccount()

@property (nonatomic, strong) BMS_JSON_Communication *jsonComm;
@property (nonatomic, weak) id<UserAccountDelegate> delegate;

@end

@implementation UserAccount

- (id)initWithUser:(NSString *)user
          password:(NSString *)pass
            apiKey:(NSString *)apiKey
   accountDelegate:(id<UserAccountDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.userName = user;
        self.userPass = pass;
        self.apiKey = apiKey;
        self.delegate = delegate;
    }
	return self;
}

//- (NSString *)query_cam_ip_online:(NSString *)mac_w_colon
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *localIp = nil ;
//    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
//                                                          Selector:@selector(getCamListSuccess:)
//                                                      FailSelector:@selector(getCamListFailure:)
//                                                         ServerErr:@selector(getCamListServerUnreachable)];
//    
//    NSDictionary *responseDict = [_jsonComm getAllDevicesBlockedWithApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
//    if (responseDict) {
//        NSArray *dataArr = responseDict[@"data"];
//        NSMutableArray *cam_profiles = [self parseCameraList:dataArr];
//        
//        if (cam_profiles && cam_profiles.count > 0) {
//            CamProfile *cp;
//            for (int i = 0; i < cam_profiles.count; i++) {
//                cp = (CamProfile *)cam_profiles[i];
//                DLog(@"CameraProfiles: %@, mac_w_colon: %@", cp, mac_w_colon);
//                
//                if (cp.mac_address &&
//                    [cp.mac_address isEqualToString:[mac_w_colon uppercaseString]] &&
//                    cp.ip_address &&
//                    cp.minuteSinceLastComm == 1) // is_available = 1
//                {
//                    localIp = cp.ip_address;
//                    [self syncOnlineAndOfflineData:cam_profiles];
//                    break;
//                }
//            }
//        }
//    }
//    
//    return localIp;
//}

- (BOOL)checkCameraIsAvailable:(NSString *)mac_w_colon
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:@selector(getCamListSuccess:)
                                                      FailSelector:@selector(getCamListFailure:)
                                                         ServerErr:@selector(getCamListServerUnreachable)];
    
    NSDictionary *responseDict = [_jsonComm getAllDevicesBlockedWithApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
    if (responseDict) {
        NSArray *dataArr = responseDict[@"data"];
        NSMutableArray *cam_profiles = [self parseCameraList:dataArr];
        
        if( cam_profiles && cam_profiles.count > 0 ) {
            CamProfile *cp;
            for (int i = 0; i < cam_profiles.count; i++) {
                cp = (CamProfile *)cam_profiles[i];
                DLog(@"CameraProfiles: %@, mac_w_colon: %@", cp, mac_w_colon);

                if (cp.mac_address &&
                    [cp.mac_address isEqualToString:[mac_w_colon uppercaseString]] &&
                    cp.minuteSinceLastComm == 1) // is_available = 1
                {
                    [self syncOnlineAndOfflineData:cam_profiles];
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (NSInteger)checkAvailableAndFWUpgradingWithCamera:(NSString *)mac_w_colon
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger state = CAMERA_STATE_UNKNOWN;
    
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:@selector(getCamListSuccess:)
                                                      FailSelector:@selector(getCamListFailure:)
                                                         ServerErr:@selector(getCamListServerUnreachable)];

    NSDictionary *responseDict = [_jsonComm getAllDevicesBlockedWithApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
    if (responseDict) {
        NSArray *dataArr = responseDict[@"data"];
        NSMutableArray *cam_profiles = [self parseCameraList:dataArr];
        
        if (cam_profiles && cam_profiles.count > 0) {
            for (int i = 0; i < cam_profiles.count; i++) {
                CamProfile *cp = (CamProfile *)cam_profiles[i];
                DLog(@"CameraProfiles: %@, mac_w_colon: %@", cp, mac_w_colon);
                
                if (cp.mac_address && [cp.mac_address isEqualToString:[mac_w_colon uppercaseString]]) {
                    state = CAMERA_STATE_REGISTED_LOGGED_USER;
                    if ( cp.fwTime ) {
                        NSDate *currentDate = [NSDate date];
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                        
                        NSDate *fwDate = [dateFormatter dateFromString:cp.fwTime]; //2013-12-31 07:38:35 +0000
                        
                        NSTimeInterval diff = [currentDate timeIntervalSinceDate:fwDate];
                        
                        if ( diff/60 <= 5 && cp.fwStatus == 1 ) {
                            state = CAMERA_STATE_FW_UPGRADING;
                        }
                    }
                    
                    break;
                }
            }
        }
    }
    
    return state;
}

- (void)updatesBasicInfoForCamera
{
    BMS_JSON_Communication *jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                    Selector:nil
                                                                                FailSelector:nil
                                                                                   ServerErr:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
    NSString *hostSSID  = [userDefaults objectForKey:HOST_SSID];
    
    NSDictionary *responseDict = [jsonCommBlocked updateDeviceBasicInfoBlockedWithRegistrationId:udid
                                                                                       deviceName:nil
                                                                                         timeZone:nil
                                                                                             mode:nil
                                                                                  firmwareVersion:nil
                                                                                         hostSSID:hostSSID
                                                                                       hostRouter:nil
                                                                                        andApiKey:apiKey];
    BOOL updateFailed = TRUE;
    
    if (responseDict) {
        if ([responseDict[@"status"] integerValue] == 200) {
            NSString *bodyKey = [responseDict[@"data"] objectForKey:@"host_ssid"];
            
            if (![bodyKey isEqual:[NSNull null]]) {
                if ([bodyKey isEqualToString:hostSSID]) {
                    updateFailed = FALSE;
                }
            }
        }
    }
    
    if (updateFailed) {
        NSLog(@"UserAccount - updatesBasicInfoForCamera: %@", responseDict);
    }
    else {
        NSLog(@"UserAccount - updatesBasicInforForCamera successfully!");
    }
}

- (void)readCameraListAndUpdate
{
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:nil
                                                      FailSelector:nil
                                                         ServerErr:nil];
    
    NSDictionary *responseDict = [_jsonComm getAllDevicesBlockedWithApiKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"PortalApiKey"]];
    
    if (responseDict) {
        [self getCamListSuccess:responseDict];
    }
    else {
        DLog(@"Error - getCamListSuccess - responseDict = nil");
        [self getCamListServerUnreachable];
    }
}

- (void)getCamListSuccess:(NSDictionary *)responseDict
{
    DLog(@"responseDict.count = %d", responseDict.count);
    NSInteger status = [responseDict[@"status"] intValue];
    
    if (status == 200) {
        NSArray *dataArr = responseDict[@"data"];
        NSMutableArray *camProfiles = nil;
        
        if (![dataArr isEqual:[NSNull null]] && dataArr.count > 0) {
            camProfiles = [self parseCameraList:dataArr];
            DLog(@"Log - camlist6 count: %d", dataArr.count);
        }
        
        [self syncOnlineAndOfflineData:camProfiles];
        
        if (_delegate) {
            [_delegate finishStoreCameraListData:camProfiles success:TRUE];
        }
        else {
            DLog(@"Error - delegate = nil");
        }
    }
    else {
        DLog(@"Error - body content status: %d", status);

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Camera list error")
                                                        message:LocStr(@"Server error: Invalid response")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:LocStr(@"Ok"), nil];
        [alert show];

        if (_delegate) {
            [_delegate finishStoreCameraListData:nil success:NO];
        }
    }
}

- (void)getCamListFailure:(NSDictionary *)errorResponse
{
    DLog(@"UserAccount - getCamListFailure with error code:%d", [errorResponse[@"status"] intValue]);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Camera list error")
                                                    message:[NSString stringWithFormat:LocStr(@"Server error: %@"), errorResponse[@"message"]]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:LocStr(@"Ok"), nil];
	[alert show];
	
    if (_delegate) {
        [_delegate finishStoreCameraListData:nil success:NO];
    }
}

- (void)getCamListServerUnreachable
{
	NSLog(@"UserAccount - getCamListServerUnreachable");
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Camera list error")
                                                    message:LocStr(@"Server unreachable")
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:LocStr(@"Ok"), nil];
	[alert show];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL isOffline = [userDefaults boolForKey:OFFLINE_MODE_KEY];
    
    if (!isOffline && _delegate) {
        [_delegate finishStoreCameraListData:nil success:FALSE];
    }
}

/*
 Response code 200 :
 Response msg :
 Cam = 0834, Mac = BC38D2404093, last_comm_from_cam = 2013-04-30 11:19:56, time_up_to_request = 19887, streaming_mode = 3, ipUpdatedDate = 2013-04-30 11:19:56, sysDate = 2013-05-14 06:47:54, Is_camera_Active = 0, local_ip = 192.168.1.44, camera_ip = 218.189.253.110, isAvailable = 0, codec = MJPEG, cameraFirmwareVersion = 0
 */

#define CAM_LIST_ENTRY_NUM_TOKEN 13
#define TOTAL_CAM     @"Total_Cameras="
#define CAM_NAME      @" Cam = "
#define MAC           @" Mac = "
#define LAST_COMM     @"last_comm_from_cam = "
#define TIME_DIFF     @" time_up_to_request = "
#define LOCAL_IP      @" local_ip = "
#define IS_AVAILABLE  @" isAvailable = "
#define CODEC         @" codec = "
#define CAMERA_FW_VER @" cameraFirmwareVersion = "

- (NSMutableArray *)parseCameraList:(NSArray *)dataArr
{
    NSMutableArray *camList = [[NSMutableArray alloc] init];
    
    for (NSDictionary *camEntry in dataArr) {
        NSInteger deviceID       = [camEntry[@"id"] integerValue];
        NSString *camName        = camEntry[@"name"];
        NSString *registrationID = camEntry[@"registration_id"];
        NSString *camMac         = camEntry[@"mac_address"];
        
        if ( camMac.length != 12 ) {
            camMac = @"00:00:00:00:00:00";
        }
        else {
            camMac = [Util add_colon_to_mac:camMac];
        }
        
        NSString *fwTime          = [camEntry objectForKey:@"firmware_time"];
        NSDictionary *deviceLocation = [camEntry objectForKey:@"device_location"];
        NSString *localIp = nil;
        
        if ( [deviceLocation isEqual:[NSNull null]] ) {
            localIp = nil;
        }
        else {
            localIp = deviceLocation[@"local_ip"];
        }
        
        NSString *isAvailable   = camEntry[@"is_available"];
        NSString *fwVersion     = camEntry[@"firmware_version"];
        NSInteger fwStatus = [camEntry[@"firmware_status"] integerValue];
        NSString *hostSSID = camEntry[@"host_ssid"];
        
        CamProfile *cp = [[CamProfile alloc] initWithMacAddr:camMac];
        cp.camProfileID = deviceID;
        
        if ([fwTime isEqual:[NSNull null]]) {
            cp.fwTime = nil;
        }
        else {
            cp.fwTime = fwTime;
        }
        
        cp.name = camName;
        
        if( [isAvailable intValue] == 1 ) {
            cp.minuteSinceLastComm = 1;
        }
        else {
            cp.minuteSinceLastComm = 24*60;
        }

        if ( !localIp || [localIp isEqual:[NSNull null]] ) {
            NSLog(@"garbage ip");
        }
        else if ( localIp.length == 0 || [localIp isEqualToString:@"null"] ) {
            NSLog(@"garbage ip");
        }
        else {
            cp.ip_address = localIp;
        }
         
        cp.fw_version     = fwVersion;
        cp.registrationID = registrationID;
        cp.fwStatus = fwStatus;
        
        if ( ![hostSSID isEqual:[NSNull null]] ) {
            cp.hostSSID = hostSSID;
        }

        [camList addObject:cp];
        
        DLog(@"Log - fwStatus: %d, camMac: %@, Fw: %@, local_ip: %@, reg: %@, Avail: %@, host_ssid: %@", fwStatus, camMac, fwVersion, localIp, registrationID, isAvailable, hostSSID);
	}
	
	return camList;
}

- (void)syncOnlineAndOfflineData:(NSMutableArray *)onlineProfiles
{
    SetupData *offlineData = [[SetupData alloc] init];
	
	if ( [offlineData restoreSessionData] ) {
        DLog(@"Has offline data ");
	}
	else {
		DLog(@"No offline data ");
	}
    
    if ( !onlineProfiles ) {
		DLog(@"No online data, Clear offline data");
		offlineData.configuredCams = [[NSMutableArray alloc] init];
		
		// create 4 blank channels
		offlineData.channels = [[NSMutableArray alloc] init];
        
		CamChannel *ch;
		for (int i = 0; i < 4; i++) {
			ch = [[CamChannel alloc] initWithChannelIndex:i];
			[offlineData.channels addObject:ch];
		}
		
		// save channels & empty profiles
		[offlineData saveSessionData];
	}
    else {
        NSMutableArray *offlineProfiles = onlineProfiles;
        offlineData.configuredCams = onlineProfiles;

        // rebinding
        if ( offlineData.configuredCams && offlineData.channels ) {
            NSMutableArray *channels = offlineData.channels;
            CamChannel *ch;
            for (int i = 0; i < channels.count; i++) {
                ch = channels[i];
                [ch reset];
            }
            
            CamProfile *cp;
            for (int i = 0; i < offlineProfiles.count; i++) {
                cp = offlineProfiles[i];
                if ( cp ) {
                    for (int j = 0; j < channels.count; j++) {
                        ch = channels[j];
                        if (ch.channel_configure_status == CONFIGURE_STATUS_NOT_ASSIGNED) {
                            [ch setCamProfile:cp];
                            [cp setChannel:ch];
                            break;
                        }
                    }
                }
            }
        }
        else {
            DLog(@"offline data: channels = nil or profile = nil");
            NSMutableArray *channels = [[NSMutableArray alloc] init];
            
            CamProfile *cp;
            for (int i = 0; i < 4; i++) {
                CamChannel *ch = [[CamChannel alloc] initWithChannelIndex:i];
                if ( i < offlineProfiles.count && offlineProfiles[i] ) {
                    cp = offlineProfiles[i];
                    [ch setCamProfile:cp];
                    [cp setChannel:ch];
                }
                
                [channels addObject:ch];
            }

            offlineData.channels = channels;
        }
        
        [offlineData saveSessionData];
    }
}

@end
