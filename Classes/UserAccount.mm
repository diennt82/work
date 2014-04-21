//
//  UserAccount.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "UserAccount.h"
#import "MBP_iosAppDelegate.h"

@interface UserAccount()

@property (nonatomic, retain) BMS_JSON_Communication *jsonComm;
@property (nonatomic, assign) id<UserAccountDelegate> delegate;

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:@selector(getCamListSuccess:)
                                                      FailSelector:@selector(getCamListFailure:)
                                                         ServerErr:@selector(getCamListServerUnreachable)];
    NSDictionary *responseDict = [self.jsonComm getAllDevicesBlockedWithApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
    
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


-(void) readCameraListAndUpdate
{
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:nil
                                                      FailSelector:nil
                                                         ServerErr:nil];
    
    NSUserDefaults *userDefaluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *responseDict = [self.jsonComm getAllDevicesBlockedWithApiKey:[userDefaluts objectForKey:@"PortalApiKey"]];
    
    if (responseDict != nil)
    {
        [self getCamListSuccess:responseDict];
    }
    else
    {
        [self getCamListServerUnreachable];
        NSLog(@"Error - getCamListSuccess - responseDict = nil");
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
    NSLog(@"responseDict.count = %d", responseDict.count);
    
    NSInteger status = [[responseDict objectForKey:@"status"] intValue];
    
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
        
        if (_delegate != nil)
        {
            [_delegate finishStoreCameraListData:camProfiles success:TRUE];
        }
        else
        {
            NSLog(@"Error - delegate = nil");
        }
    }
    else
    {
        NSLog(@"Error - body content status: %d", status);
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error",nil, [NSBundle mainBundle],
                                                           @"Get Camera list Error", nil);
        
        NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error_msg",nil, [NSBundle mainBundle],
                                                            @"Server error: Invalid response", nil);
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        //ERROR condition
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:msg
                              message:msg1
                              delegate:nil
                              cancelButtonTitle:ok
                              otherButtonTitles:nil];
        [alert show];
        [alert release];

        if (_delegate)
        {
            [_delegate finishStoreCameraListData:nil success:FALSE];
        }
    }
}

-(void) getCamListFailure:(NSDictionary *)error_response
{
    NSLog(@"UserAccount - getCamListFailure with error code:%d", [[error_response objectForKey:@"status"] intValue]);
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error",nil, [NSBundle mainBundle],
                                                       @"Get Camera list Error", nil);
    
    NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error_msg",nil, [NSBundle mainBundle],
                                                        @"Server error: %@", nil);
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:msg
						  message:[NSString stringWithFormat:msg1, [error_response objectForKey:@"message"]]
						  delegate:nil
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
    if (_delegate)
    {
        [_delegate finishStoreCameraListData:nil success:FALSE];
    }
}

- (void)getCamListServerUnreachable
{
	NSLog(@"UserAccount - getCamListServerUnreachable");
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error",nil, [NSBundle mainBundle],
                                                       @"Get Camera list Error", nil);
    
    NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error_msg1",nil, [NSBundle mainBundle],
                                                        @"Server unreachable", nil);
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);

	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:msg
						  message:msg1
						  delegate:nil
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
    
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
        NSInteger modelID        = [[camEntry objectForKey:@"device_model_id"] integerValue];
        
        if ([camMac length] != 12 )
        {
            camMac = @"00:00:00:00:00:00";
        }
        else {
            camMac = [Util add_colon_to_mac:camMac];
        }
        
        NSString *updatedAt          = [camEntry objectForKey:@"updated_at"];
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
        
        CamProfile *cp = [[[CamProfile alloc]initWithMacAddr:camMac] autorelease];

        cp.camProfileID = deviceID;
        cp.modelID      = modelID;
        cp.last_comm    = updatedAt;
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

        [camList addObject:cp];
        
        NSLog(@"Log - device_model_id: %d, camMac: %@, Fw: %@, local_ip: %@, reg: %@ and isAvailable: %@", modelID, camMac, fwVersion, localIp, registrationID, isAvailable);
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

@end
