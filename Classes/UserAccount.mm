//
//  UserAccount.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "UserAccount.h"
#import "MBP_iosAppDelegate.h"
#import "GAI.h"
#import "PublicDefine.h"
#import "define.h"

@interface UserAccount()

@property (nonatomic, retain) BMS_JSON_Communication *jsonComm;
@property (nonatomic, assign) id<UserAccountDelegate> delegate;
@property (nonatomic, retain) BMS_JSON_Communication *jsonCommBlocked;

@end

@implementation UserAccount

@synthesize   userName,userPass;
//@synthesize delegate;

- (id) initWithUser:(NSString *)user andPass:(NSString *)pass andApiKey: (NSString *)apiKey andListener:(id <ConnectionMethodDelegate>) d
{
    self = [super init];
	self.userName = user;
	self.userPass = pass;
    self.apiKey = apiKey;
	//self.delegate = d;
    
	return self;
}

- (id)initWithUser:(NSString *)user
          password:(NSString *)pass
            apiKey:(NSString *)apiKey
          listener:(id<UserAccountDelegate> ) d
{
    self = [super init];
    
    if (self)
    {
        self.userName = user;
        self.userPass = pass;
        self.apiKey = apiKey;
        self.delegate = d;
    }
    
	return self;
}


-(void) dealloc
{
    [_jsonComm release];
    [_jsonCommBlocked release];
    [userName release];
    [userPass release];
    [_apiKey release];
    [super dealloc];
    
}

- (NSString *)query_cam_ip_online:(NSString *) mac_w_colon
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * localIp = nil ;
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:@selector(getCamListSuccess:)
                                                      FailSelector:@selector(getCamListFailure:)
                                                         ServerErr:@selector(getCamListServerUnreachable)];
    NSDictionary *responseDict = [self.jsonComm getAllDevicesBlockedWithApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
    
    if (responseDict != nil)
    {
        NSArray *dataArr = [responseDict objectForKey:@"data"];
        
        //NSLog(@"camlist4: %@", dataArr);
        
        NSMutableArray * cam_profiles;
        CamProfile *cp;
        
        cam_profiles = [self parse_camera_list:dataArr];
        
        if(cam_profiles != nil && [cam_profiles count] >0)
        {
            for (int i=0; i<[cam_profiles count]; i++)
            {
                cp = (CamProfile *)[cam_profiles objectAtIndex:i];
                
                NSLog(@"CameraProfiles: %@, mac_w_colon: %@", cp, mac_w_colon);
                
                if (cp.mac_address != nil &&
                    [cp.mac_address isEqualToString:[mac_w_colon uppercaseString]] &&
                    cp.ip_address != nil &&
                    cp.minuteSinceLastComm == 1) // is_available = 1
                {
                    localIp = cp.ip_address;
                    [self sync_online_and_offline_data:cam_profiles];
                    break;
                }
            }
        }
    }
    
    return localIp;
}


- (BOOL)checkCameraIsAvailable:(NSString *) mac_w_colon
{
#if 1
    if (!_jsonCommBlocked)
    {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithCaller:self];
    }
    
    NSDictionary *responseDict = [_jsonCommBlocked getAllDevicesBlockedWithApiKey:_apiKey];
    
#else
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:@selector(getCamListSuccess:)
                                                      FailSelector:@selector(getCamListFailure:)
                                                         ServerErr:@selector(getCamListServerUnreachable)];
    NSDictionary *responseDict = [self.jsonComm getAllDevicesBlockedWithApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
#endif
    
    if (responseDict != nil)
    {
        NSArray *dataArr = [responseDict objectForKey:@"data"];
        
        NSMutableArray * cam_profiles;
        CamProfile *cp;
        
        cam_profiles = [self parse_camera_list:dataArr];
        
        if(cam_profiles != nil && [cam_profiles count] >0)
        {
            for (int i=0; i<[cam_profiles count]; i++)
            {
                cp = (CamProfile *)[cam_profiles objectAtIndex:i];
                
                NSLog(@"CameraProfiles: %@, mac_w_colon: %@", cp, mac_w_colon);

                if (cp.mac_address != nil &&
                    [cp.mac_address isEqualToString:[mac_w_colon uppercaseString]] &&
                    cp.minuteSinceLastComm == 1) // is_available = 1
                {
                    [self sync_online_and_offline_data:cam_profiles];
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (NSInteger )checkAvailableAndFWUpgradingWithCamera:(NSString *) mac_w_colon
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger state = CAMERA_STATE_UNKNOWN;
    
    
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:@selector(getCamListSuccess:)
                                                      FailSelector:@selector(getCamListFailure:)
                                                         ServerErr:@selector(getCamListServerUnreachable)];
    NSDictionary *responseDict = [self.jsonComm getAllDevicesBlockedWithApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
    
    if (responseDict != nil)
    {
        NSArray *dataArr = [responseDict objectForKey:@"data"];

        NSMutableArray * cam_profiles = [self parse_camera_list:dataArr];
        
        if(cam_profiles != nil && [cam_profiles count] >0)
        {
            for (int i = 0; i < [cam_profiles count]; i++)
            {
                CamProfile *cp = (CamProfile *)[cam_profiles objectAtIndex:i];
                
                NSLog(@"CameraProfiles: %@, mac_w_colon: %@", cp, mac_w_colon);
                
                if (cp.mac_address != nil &&
                    [cp.mac_address isEqualToString:[mac_w_colon uppercaseString]])
                {
                    //[self updatesBasicInfoForCamera];
                    
                    state = CAMERA_STATE_REGISTED_LOGGED_USER;
                    
//                    if (cp.minuteSinceLastComm == 1)
//                    {
//                        [self sync_online_and_offline_data:cam_profiles];
//                        state = CAMERA_STATE_IS_AVAILABLE;
//                    }
//                    else
//                    {
                        if (cp.fwTime)
                        {
                            NSDate *currentDate = [NSDate date];
                            
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            
                            NSDate *fwDate = [dateFormatter dateFromString:cp.fwTime]; //2013-12-31 07:38:35 +0000
                            [dateFormatter release];
                            
                            NSTimeInterval diff = [currentDate timeIntervalSinceDate:fwDate];
                            
                            if ((diff / 60 <= 5) && (cp.fwStatus == 1))
                            {
                                state = CAMERA_STATE_FW_UPGRADING;
                            }
                        //}
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
#if 1
    if (_jsonCommBlocked == nil)
    {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithCaller:self];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *udid       = [userDefaults objectForKey:CAMERA_UDID];
    NSString *hostSSID   = [userDefaults objectForKey:HOST_SSID];
    NSString *cameraName = [userDefaults objectForKey:CAMERA_NAME];
    
    NSDictionary *responseDict = [_jsonCommBlocked updateDeviceBasicInfoBlockedWithRegistrationId:udid
                                                                                       deviceName:cameraName
                                                                                         timeZone:nil
                                                                                             mode:nil
                                                                                  firmwareVersion:nil
                                                                                         hostSSID:hostSSID
                                                                                       hostRouter:nil
                                                                                        andApiKey:_apiKey];
    BOOL updateFailed = TRUE;
    
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            NSString *bodyKey = [[responseDict objectForKey:@"data"] objectForKey:@"host_ssid"];
            
            if (![bodyKey isEqual:[NSNull null]] && [bodyKey isEqualToString:hostSSID])
            {
                updateFailed = FALSE;
            }
        }
    }
    
    if (updateFailed)
    {
        NSLog(@"%s %@", __FUNCTION__, responseDict);
    }
    else
    {
        NSLog(@"%s successfully!", __FUNCTION__);
    }
#else
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
    
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            NSString *bodyKey = [[responseDict objectForKey:@"data"] objectForKey:@"host_ssid"];
            
            if (![bodyKey isEqual:[NSNull null]])
            {
                if ([bodyKey isEqualToString:hostSSID])
                {
                    updateFailed = FALSE;
                }
            }
        }
    }
    
    if (updateFailed)
    {
        NSLog(@"UserAccount - updatesBasicInfoForCamera: %@", responseDict);
    }
    else
    {
        NSLog(@"UserAccount - updatesBasicInforForCamera successfully!");
    }
#endif
}

-(void) readCameraListAndUpdate
{
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:nil
                                                      FailSelector:nil
                                                         ServerErr:nil];
    
    NSDictionary *responseDict = [_jsonComm getAllDevicesBlockedWithApiKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"PortalApiKey"]];
#if 0
    responseDict = nil;
    
    [NSThread sleepForTimeInterval:20];
#endif
    
    if (responseDict)
    {
        [self getCamListSuccess:responseDict];
    }
    else
    {
        [self getCamListServerUnreachable];
    }
}

-(void) query_snapshot_from_server:(NSArray *) cam_profiles
{
    
}

-(void) query_stream_mode_for_cam:(CamProfile *) cp
{
    
}

-(void) getCamListSuccess:(NSDictionary *)responseDict
{
    NSInteger status = [[responseDict objectForKey:@"status"] intValue];
    NSLog(@"%s status:%d", __FUNCTION__, status);
    
    if (status == 200)
    {
        NSArray *dataArr = [responseDict objectForKey:@"data"];
        
        NSMutableArray *camProfiles = nil;
        
        if (![dataArr isEqual:[NSNull null]] &&
            dataArr.count > 0)
        {
            camProfiles = [self parse_camera_list:dataArr];
            NSLog(@"Log - camlist6 count: %d", dataArr.count);
        }
        
        [self sync_online_and_offline_data:camProfiles];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *justRemovedMac = [userDefault objectForKey:CAM_MAC_JUST_REMOVED];
        if (justRemovedMac)
        {
            if ([justRemovedMac hasSuffix:CAM_JUST_REMOVED_SUFIX_MARK])
            {
                justRemovedMac = [justRemovedMac stringByReplacingOccurrencesOfString:CAM_JUST_REMOVED_SUFIX_MARK withString:@""];
            }
            else
            {
                justRemovedMac = nil;
            }
        }
        [userDefault setObject:justRemovedMac forKey:CAM_MAC_JUST_REMOVED];
        [userDefault synchronize];
        
        if (_delegate != nil)
        {
            [_delegate finishStoreCameraListData:camProfiles
                                         success:TRUE];
        }
        else
        {
            NSLog(@"Error - delegate = nil");
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getCamListFailure:responseDict];
        });
    }
}

-(void) getCamListFailure:(NSDictionary *)error_response
{
    NSLog(@"%s %@", __FUNCTION__, error_response);
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error",nil, [NSBundle mainBundle],
                                                       @"Get Camera list Error", nil);
    
    //NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error_msg",nil, [NSBundle mainBundle],
    //                                                    @"Server error: %@", nil);
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
    NSNumber *status = [error_response objectForKey:@"status"];
    NSString *message = [error_response objectForKey:@"message"];
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:msg
						  message:message//[NSString stringWithFormat:msg1, message]
						  delegate:nil
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
    if (_delegate)
    {
        [_delegate finishStoreCameraListData:[NSMutableArray arrayWithObjects:status, message, nil]
                                     success:FALSE];
    }
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"User Account"
                                                    withAction:message
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)getCamListServerUnreachable
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"User Account"
                                                    withAction:@"Get camera list error Server is unrachable"
                                                     withLabel:nil
                                                     withValue:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
    
    if (!isOffline)
    {
        if (_delegate)
        {
            [_delegate finishStoreCameraListData:nil
                                         success:FALSE];
        }
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

- (NSMutableArray *)parse_camera_list:(NSArray *)dataArr
{
    NSMutableArray *camList = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *camEntry in dataArr)
	{
        NSInteger deviceID       = [[camEntry objectForKey:@"id"] integerValue];
        NSString *camName        = [camEntry objectForKey:@"name"];
        NSString *registrationID = [camEntry objectForKey:@"registration_id"];
        NSString *camMac         = [camEntry objectForKey:@"mac_address"];
        NSString *snaps_url      = [camEntry objectForKey:@"snaps_url"];
        //NSInteger modelID        = [[camEntry objectForKey:@"device_model_id"] integerValue];
        
        if ([camMac length] != 12 )
        {
            camMac = @"00:00:00:00:00:00";
        }
        else {
            camMac = [Util add_colon_to_mac:camMac];
        }
        
        NSString *fwTime          = [camEntry objectForKey:@"firmware_time"];
        NSDictionary *deviceLocation = [camEntry objectForKey:@"device_location"];
        NSString *localIp = nil;
        
        if ([deviceLocation isEqual:[NSNull null]])
        {
            localIp = nil;
        }
        else
        {
            localIp = [deviceLocation objectForKey:@"local_ip"];
        }
        
        NSString *isAvailable   = [camEntry objectForKey:@"is_available"];
        NSString *fwVersion     = [camEntry objectForKey:@"firmware_version"];
        NSInteger fwStatus = [[camEntry objectForKey:@"firmware_status"] integerValue];
        NSString *hostSSID = [camEntry objectForKey:@"host_ssid"];
        
        CamProfile *cp = [[[CamProfile alloc]initWithMacAddr:camMac] autorelease];

        cp.camProfileID = deviceID;
        
        if ([fwTime isEqual:[NSNull null]])
        {
            cp.fwTime = nil;
        }
        else
        {
            cp.fwTime    = fwTime;
        }
        
        cp.name         = camName;
        
        if([isAvailable intValue] == 1)
        {
            cp.minuteSinceLastComm = 1;
        } else {
            cp.minuteSinceLastComm = 24*60;
        }

        if ([localIp isEqual:[NSNull null]] || localIp == nil)
        {
            NSLog(@"garbage ip");
        }
        else if (localIp.length == 0 || [localIp isEqualToString:@"null"])
        {
            NSLog(@"garbage ip");
        }
        else
        {
            cp.ip_address = localIp;
        }
         
        //cp.codecs = codec;
        cp.fw_version     = fwVersion;
        cp.registrationID = registrationID;
        cp.fwStatus = fwStatus;
        
        if (![hostSSID isEqual:[NSNull null]])
        {
            cp.hostSSID = hostSSID;
        }
        cp.snapUrl = snaps_url;
        [camList addObject:cp];
        
        NSLog(@"Log - fwStatus: %d, camMac: %@, Fw: %@, local_ip: %@, reg: %@, Avail: %@, host_ssid: %@", fwStatus, camMac, fwVersion, localIp, registrationID, isAvailable, hostSSID);
	}
	
	return camList;
}

- (void)sync_online_and_offline_data:(NSMutableArray *) online_profiles
{
    SetupData *offline_data = [[[SetupData alloc] init] autorelease];
	
	if ([offline_data restore_session_data] == TRUE)
	{
        NSLog(@"Has offline data ");
	}
	else
    {
		NSLog(@"No offline data ");
	}
    
    
    if (online_profiles == nil)
	{
		NSLog(@"No online data, Clear offline data");
		offline_data.configured_cams = nil;
		offline_data.channels = nil;
		
		offline_data.configured_cams = [[NSMutableArray alloc]init];//0 size
		
		//create 4 blank channels
		offline_data.channels = [[NSMutableArray alloc] init];
		CamChannel * ch;
		for (int i =0; i<4; i++)
		{
			ch = [[CamChannel alloc]initWithChannelIndex:i];
			[offline_data.channels addObject:ch];
		}
		
		//save channels & empty profiles
		[offline_data save_session_data];
		return;
	}
	
	
	NSMutableArray * offline_profiles = online_profiles;
    
	offline_data.configured_cams = online_profiles;

	//rebinding
	if (offline_data.configured_cams != nil &&
		offline_data.channels != nil)
	{
		NSMutableArray * channels = offline_data.channels;
		CamChannel * ch;
		CamProfile * cp;
		for (int i = 0; i<[channels count]; i++)
		{
			ch = [channels objectAtIndex:i];
			[ch reset];
		}
		
		for (int i=0; i<[offline_profiles count]; i++)
		{
			cp = [offline_profiles objectAtIndex:i];
            
			if (cp != nil)
			{
				for (int j=0; j<[channels count];j++)
				{
					ch = [channels objectAtIndex:j];
					if (ch.channel_configure_status == CONFIGURE_STATUS_NOT_ASSIGNED)
					{
						[ch setCamProfile:cp];
						[cp setChannel:ch];
						break;
						
					}
				}
			}
		}
	}
	else {
		NSLog(@"offline data: channels = nil or profile = nil");
		
		NSMutableArray *channels = [[[NSMutableArray alloc]init] autorelease];

		CamProfile * cp;
		for (int i =0; i<4; i++)
		{
			CamChannel *ch = [[[CamChannel alloc]initWithChannelIndex:i] autorelease];
			
			if (i<[offline_profiles count] && [offline_profiles objectAtIndex:i] != nil)
			{
				cp = [offline_profiles objectAtIndex:i];
				[ch setCamProfile:cp];
				[cp setChannel:ch];
			}
			
			[channels addObject:ch];
		}

		offline_data.channels = channels;
		
	}
	
	[offline_data save_session_data];
}

- (NSInteger )checkFwUpgrageStatusWithRegistrationId:(NSString *)regId currentFwVersion:(NSString *)currentFw
{
    NSInteger fwUpgradeStatus = FIRMWARE_UPGRADE_REBOOT;
    
    if (_jsonCommBlocked == nil)
    {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
    }
    
    NSDictionary *responseDict = [_jsonCommBlocked getDeviceBasicInfoBlockedWithRegistrationId:regId
                                                                                     andApiKey:_apiKey];
    
    //NSLog(@"%s response:%@", __FUNCTION__, responseDict);
    
    if (responseDict != nil)
    {
        NSInteger status = [[responseDict objectForKey:@"status"] intValue];
        
        if (status == 200)
        {
            NSDictionary *data = [responseDict objectForKey:@"data"];
            
            NSString *cameraMac = [regId substringWithRange:NSMakeRange(6, 12)];
            
            CamProfile *cp = [[CamProfile alloc] initWithMacAddr:[Util add_colon_to_mac:cameraMac]];
            
            cp.fwStatus = [[data objectForKey:@"firmware_status"] integerValue];
            
            id firmwareTime = [data objectForKey:@"firmware_time"];
            
            cp.fwTime   = [firmwareTime isEqual:[NSNull null]]?nil:firmwareTime;
            
            NSLog(@"\n firmware_status:%d, \n firmware_time:%@, \n is_available:%@, \n firmware_version:%@", cp.fwStatus, firmwareTime, [data objectForKey:@"is_available"], [data objectForKey:@"firmware_version"]);
            
            //If less than 5 mins since camera start upgrading
            
            if ([cp isFwUpgrading:[NSDate date]] == FALSE)
            {
                NSString *firmwareVersion = [data objectForKey:@"firmware_version"];
                
                if (firmwareVersion != nil && ![firmwareVersion isEqual:[NSNull null]])
                {
                    //if the version on server matches the version reported by FW earlier
                    if ([firmwareVersion compare:currentFw] == NSOrderedDescending)
                    //if ([firmwareVersion compare:currentFw] == NSOrderedSame)
                    {
                        if ([[data objectForKey:@"is_available"] boolValue])
                        {
                            fwUpgradeStatus = FIRMWARE_UPGRADE_SUCCEED;
                        }
                        else
                        {
                            fwUpgradeStatus = FIRMWARE_UPGRADE_REBOOT; // Waiting for camera is available.
                        }
                    }
                    else //Wrong FW  version
                    {
                        
                        fwUpgradeStatus = FIRMWARE_UPGRADE_FAILED;
                    }
                }
            }
            else
            {
                fwUpgradeStatus = FIRMWARE_UPGRADE_IN_PROGRESS;
            }
        }
        else
        {
            NSLog(@"%s response status:%d", __FUNCTION__, status);
        }
    }
    else
    {
        NSLog(@"%s response is nil", __FUNCTION__);
    }
    
    return fwUpgradeStatus;
}

- (void)sendToServerTheCommand:(NSString *) command
{
    if (!_jsonCommBlocked)
    {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithCaller:self];
    }
    
    NSString *stringUDID = [[NSUserDefaults standardUserDefaults] stringForKey:CAMERA_UDID];
    
    NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:stringUDID
                                                                             andCommand:command
                                                                              andApiKey:_apiKey];
    
    NSInteger errorCode = -1;
    NSString *errorMessage = @"";
    
    if (responseDict)
    {
        errorCode = [[responseDict objectForKey:@"status"] integerValue];
        
        if (errorCode == 200)
        {
            errorCode = [[[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"device_response_code"] integerValue];
        }
        else
        {
            errorMessage = [responseDict objectForKey:@"message"];
        }
    }
    
    NSLog(@"%s cmd:%@, error: %d, message:%@", __func__, command, errorCode, errorMessage);
}

- (NSInteger )checkStatusCamera:(NSString *)camRegId
{
    NSInteger deviceStatus = DEV_STATUS_UNKOWN;
    
    if (_jsonCommBlocked == nil)
    {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithCaller:self];
    }
    
    NSDictionary *responseDict = [_jsonCommBlocked checkStatusBlockedWithRegistrationId:camRegId apiKey:_apiKey];
    
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            deviceStatus = [[[responseDict objectForKey:@"data"] objectForKey:@"device_status"] integerValue];
        }
        else
        {
            NSLog(@"%s responseDict:%@", __FUNCTION__, responseDict);
        }
    }
    
    return deviceStatus;
}


@end
