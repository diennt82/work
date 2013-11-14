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

@end

@implementation UserAccount

@synthesize   userName,userPass;
@synthesize delegate;

- (id) initWithUser:(NSString *)user andPass:(NSString *)pass andApiKey: (NSString *)apiKey andListener:(id <ConnectionMethodDelegate>) d
{
    self = [super init];
	self.userName = user;
	self.userPass = pass;
    self.apiKey = apiKey;
	self.delegate = d;
    
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
        
        NSLog(@"camlist4: %@", dataArr);
        
        NSMutableArray * cam_profiles;
        CamProfile *cp;
        
        cam_profiles = [self parse_camera_list:dataArr];
        
        if(cam_profiles != nil && [cam_profiles count] >0)
        {
            for (int i=0; i<[cam_profiles count]; i++)
            {
                cp = (CamProfile *)[cam_profiles objectAtIndex:i];
                if (cp.mac_address != nil &&
                    [cp.mac_address isEqualToString:[mac_w_colon uppercaseString]] &&
                    cp.ip_address != nil )
                {
                    localIp = cp.ip_address;
                    break;
                }
            }
        }
    }
    
    return localIp;
}

-(void) query_camera_list_blocked
{
    [self readCameraListAndUpdate];
    
    if (delegate != nil)
    {
        [delegate sendStatus:SCAN_BONJOUR_CAMERA];
    }
    //NSLog(@"UserAccount: query_camera_list_blocked END");
}


-(void) readCameraListAndUpdate
{
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:@selector(getCamListSuccess:)
                                                      FailSelector:@selector(getCamListFailure:)
                                                         ServerErr:@selector(getCamListServerUnreachable)];
    NSUserDefaults *userDefaluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *responseDict = [NSDictionary dictionaryWithDictionary:[self.jsonComm getAllDevicesBlockedWithApiKey:[userDefaluts objectForKey:@"PortalApiKey"]]];
    if (responseDict != nil)
    {
        [self getCamListSuccess:responseDict];
    }
    else
    {
        [self getCamListServerUnreachable] ;
    }
}

-(void) query_snapshot_from_server:(NSArray *) cam_profiles
{
    
}



-(void) getCamListSuccess:(NSDictionary *)responseData
{
    if (responseData) {
        NSLog(@"responseData.count = %d", responseData.count);
    }
    
    NSInteger status = [[responseData objectForKey:@"status"] intValue];
    
    if (status == 200)
    {
        NSArray *dataArr = [NSArray arrayWithArray:[responseData objectForKey:@"data"]];
        
        NSMutableArray *camProfiles = nil;
        
        if (dataArr.count > 0) {
            //[camProfiles = [NSMutableArray alloc] init];
            camProfiles = [self parse_camera_list:dataArr];
            NSLog(@"camlist5 count: %d", dataArr.count);
        }

        [self sync_online_and_offline_data:camProfiles];
    }
    else
    {
        NSLog(@"body content status = %d", status);
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
                              delegate:self
                              cancelButtonTitle:ok
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [delegate sendStatus:8];
        return;
    }
}

-(void) query_stream_mode_for_cam:(CamProfile *) cp
{
    
}

-(void) getCamListFailure:(NSDictionary *)error_response
{
    NSLog(@"Loging failed with error code:%d", [[error_response objectForKey:@"status"] intValue]);
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
						  delegate:self
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[delegate sendStatus:8];
	return;
}

- (void)getCamListServerUnreachable
{
	NSLog(@"Loging failed : server unreachable");
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
						  delegate:self
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[delegate sendStatus:8];
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
    if (dataArr) {
        NSLog(@"dataArr.count = %d", dataArr.count);
    }
    
    NSMutableArray *camList = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *camEntry in dataArr)
	{
        NSString * camName = [camEntry objectForKey:@"name"];
        NSString * camMac = [camEntry objectForKey:@"registration_id"];
        NSLog(@"camMac = %@", camMac);
        if ([camMac length] != 12 )
        {
            camMac = @"00:00:00:00:00:00";
        }
        else {
            camMac = [Util add_colon_to_mac:camMac];
        }
        
//			NSString * last_comm = [cam_entry_tokens objectAtIndex:2];
//			last_comm = [last_comm substringFromIndex:[LAST_COMM length]];
        
        NSString *updatedAt = [camEntry objectForKey:@"updated_at"];
        
        NSString * localIp = [[camEntry objectForKey:@"device_location"] objectForKey:@"local_ip"];
        
        NSString * isAvailable = [camEntry objectForKey:@"is_available"];
        //NSString * codec = nil;
        //NSString * str;
        NSString * fwVersion = [[camEntry objectForKey:@"device_firmware"] objectForKey:@"version"];
        
        CamProfile *cp = [[[CamProfile alloc]initWithMacAddr:camMac] autorelease];

        cp.last_comm = updatedAt;
        cp.name = camName;
        
        if([isAvailable intValue] == 1)
        {
            cp.minuteSinceLastComm = 1;
        } else {
            cp.minuteSinceLastComm = 24*60;
        }
        
        NSLog(@"local ip %@", localIp);
        if ([localIp isEqual:[NSNull null]])
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
        cp.fw_version = fwVersion;
        
        NSLog(@" Fw:%@", fwVersion);

        [camList addObject:cp];
	}
	
	return camList;
}

- (void)sync_online_and_offline_data:(NSMutableArray *) online_profiles
{
    //NSLog(@"aaaaaaaa");
    SetupData *offline_data = [[[SetupData alloc] init] autorelease];
	
	if ([offline_data restore_session_data] == TRUE)
	{
        NSLog(@"has offline data ");
	}
	else
    {
		//
		NSLog(@"No offline data ");
	}
    
	if (offline_data.configured_cams == nil)
	{
		NSLog(@"No online data, Clear offline data");
		[offline_data.configured_cams release];
		[offline_data.channels release];
		
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
		for (int i =0; i<[channels count]; i++)
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
