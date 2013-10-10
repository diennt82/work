//
//  UserAccount.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "UserAccount.h"
#import "MBP_iosAppDelegate.h"
#import "RemoteConnection.h"

@interface UserAccount()

@property (nonatomic, retain) BMS_JSON_Communication *jsonComm;

@end

@implementation UserAccount

@synthesize   userName,userPass;
@synthesize delegate; 
@synthesize  bms_comm;

#if JSON_FLAG
- (id) initWithUser:(NSString *)user andPass:(NSString *)pass andApiKey: (NSString *)apiKey andListener:(id <ConnectionMethodDelegate>) d
{
    [super init];
	self.userName = user;
	self.userPass = pass;
    self.apiKey = apiKey;
	self.delegate = d;
    
	return self;
}

#else
-(id) initWithUser:(NSString*)user AndPass:(NSString*) pass WithListener:(id <ConnectionMethodDelegate>) d; 
{
	[super init];
	self.userName = user;
	self.userPass = pass;
	self.delegate = d; 

	return self; 
}
#endif

-(void) dealloc
{
    [self.jsonComm release];
    [userName release];
    [userPass release];
    [bms_comm release];
    [self.apiKey release];
    [super dealloc];
    
}

#if JSON_FLAG
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

#else
-(NSString *) query_cam_ip_online:(NSString *) mac_w_colon
{
    
    NSString * localIp = nil ;
    
    self.bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                     Selector:@selector(getCamListSuccess:)
                                                 FailSelector:@selector(getCamListFailure:)
                                                    ServerErr:@selector(getCamListServerUnreachable)];
    NSData  * responseData = [self.bms_comm BMS_getCameraListBlockedWithUser:userName AndPass:self.userPass];
    
    if (responseData != nil)
    {
        
        NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
        
        NSLog(@"camlist4: %@", raw_data);
        
        NSRange br_range = [raw_data rangeOfString:@"<br>"];
        
        if ( br_range.location  ==  NSNotFound )
        {
            NSLog(@"camlist4: ERROR response");
            return nil; 
        }
        
        
        NSMutableArray * cam_profiles;
        CamProfile *cp;

        //cam_profiles = [self parse_camera_list:raw_data];
        
        
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
#endif

-(void) query_camera_list_blocked
{
    [self readCameraListAndUpdate];
    
    if (delegate != nil)
    {
        [delegate sendStatus:SCAN_BONJOUR_CAMERA];
    }
    //NSLog(@"UserAccount: query_camera_list_blocked END");
}


#if JSON_FLAG
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

#else
-(void) readCameraListAndUpdate
{
    self.bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                     Selector:@selector(getCamListSuccess:)
                                                 FailSelector:@selector(getCamListFailure:)
                                                    ServerErr:@selector(getCamListServerUnreachable)];
    NSData  * responseData = [self.bms_comm BMS_getCameraListBlockedWithUser:userName AndPass:self.userPass];
    
    if (responseData != nil)
    {
        [self getCamListSuccess:responseData];
    }
    else
    {
        [self getCamListServerUnreachable] ;
    }
}

#endif


-(void) query_snapshot_from_server:(NSArray *) cam_profiles
{
    
    ////set dummy selectors here -- these will not be called since we r using BLOCKED functions
	self.bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                     Selector:@selector(getCamListSuccess:) 
                                                 FailSelector:@selector(getCamListFailure:) 
                                                    ServerErr:@selector(getCamListServerUnreachable)];
    CamProfile *cp =nil;
    NSData * snapShotData = nil; 
    UIImage * snapShotImg = nil; 
    for (int i =0; i<[cam_profiles count]; i++)
    {
        cp = (CamProfile *)[cam_profiles objectAtIndex:i];
        
        if (cp == nil)
        {
            continue;
        }
        //call get camlist query here 
        snapShotData = [self.bms_comm BMS_getCameraSnapshotBlockedWithUser:self.userName 
                                                    AndPass:self.userPass
                                                    macAddr:cp.mac_address];
        if (snapShotData != nil)
        {
            //NSLog(@"UserAccount: rcv pic for cam: %@", cp.name); 
            snapShotImg = [UIImage imageWithData:snapShotData];
            cp.profileImage = snapShotImg;
        }
        else 
        {
            //failed to get snapshot for this camera
        }
        
        // reset
        snapShotData = nil; 
    }
    
    
}



-(void) getCamListSuccess:(NSDictionary *)responseData
{
    if (responseData) {
        NSLog(@"responseData.count = %d", responseData.count);
    }
    
    NSArray *dataArr;
    NSMutableArray *camProfiles = nil;
    NSInteger status = [[responseData objectForKey:@"status"] intValue];
    
    if (status == 200) {
        dataArr = [NSArray arrayWithArray:[responseData objectForKey:@"data"]];
        
        if (dataArr.count > 0) {
#if JSON_FLAG
            //[camProfiles = [NSMutableArray alloc] init];
            camProfiles = [self parse_camera_list:dataArr];
            NSLog(@"camlist5 count: %d", dataArr.count);
#endif
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
    
#if (JSON_FLAG == 0)
    NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];

    NSLog(@"camlist5: %@", raw_data);
    NSRange br_range = [raw_data rangeOfString:@"<br>"];
    
    if ( br_range.location  ==  NSNotFound )
    {
        NSLog(@"Camlist response ERROR");

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
#endif
//	NSMutableArray * cam_profiles;
//	cam_profiles = [self parse_camera_list:dataArr];
//    
//	// sync_online_and_offline_data
//	[self sync_online_and_offline_data:cam_profiles];	
}



-(void) query_stream_mode_for_cam:(CamProfile *) cp
{
    
    //NSLog(@" query_stream_mode_for_cam : %@",cp.name);
    BMS_Communication * bms_alerts = [[BMS_Communication alloc] initWithObject:self
                                                                      Selector:nil
                                                                  FailSelector:nil
                                                                     ServerErr:nil];

    //call get camlist query here
	NSData* responseData = [bms_alerts BMS_getStreamModeBlockedWithUser:self.userName
                                                                 AndPass:self.userPass
                                                                   macAddr:cp.mac_address];
    
    
    NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	//NSLog(@"getStream response: %@", raw_data);
	
	//Move on -- dont signal caller
	if ( raw_data != nil && [raw_data hasPrefix:STREAMING_MODE])
	{
		NSRange m_range = {[STREAMING_MODE length], 1};
		int streamMode = [[raw_data substringWithRange:m_range] intValue];
		
		switch (streamMode) {
			case STREAM_MODE_UPNP:
			case STREAM_MODE_MANUAL_PRT_FWD:
			{
				
                responseData = [bms_alerts BMS_getRemoteStatusBlockedOf:IS_CAM_AVAILABLE_UPNP_CMD
                                                               withUser:self.userName
                                                                andPass:self.userPass
                                                                macAddr:cp.mac_address];
                raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
                NSLog(@"[UPNP]cam %@ isCam avaiil response: %@", cp.mac_address, raw_data);
                if ( raw_data != nil)
                {
                    NSArray * tokens = [raw_data componentsSeparatedByString:@":"];

                    if ([tokens count] >=2 )
                    {
                        NSString * status = (NSString*) [tokens objectAtIndex:1];
                        status = [status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                  
                        if ([status hasPrefix:@"AVAILABLE"] ||
                            [status hasPrefix:@"BUSY"])
                        {
                            cp.minuteSinceLastComm = 1; 
                        }
                        else
                        {
                            cp.minuteSinceLastComm = 24*60;
                        }
                    }
                    else
                    {
                        cp.minuteSinceLastComm = 24*60;

                    }
                    
                }
                else
                {
                    cp.minuteSinceLastComm = 24*60;
                }
                
				               
				break;
			}
			case STREAM_MODE_STUN:
			{
                
                responseData = [bms_alerts BMS_getRemoteStatusBlockedOf:IS_CAM_AVAILABLE_ONLOAD_CMD
                                                               withUser:self.userName
                                                                andPass:self.userPass
                                                                macAddr:cp.mac_address];
                raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
                NSLog(@"[STUN]cam %@ isCam avaiil response: %@",cp.mac_address,  raw_data);

                if ( raw_data != nil)
                {
                    NSArray * tokens = [raw_data componentsSeparatedByString:@":"];
                    if ([tokens count] >=2 )
                    {
                        NSString * status = (NSString*) [tokens objectAtIndex:1];
                        status = [status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if ([status hasPrefix:@"AVAILABLE"] ||
                            [status hasPrefix:@"BUSY"])
                        {
                            cp.minuteSinceLastComm = 1;
                        }
                        else
                        {
                            cp.minuteSinceLastComm = 24*60;
                        }
                    }
                    else
                    {
                        cp.minuteSinceLastComm = 24*60;
                        
                    }
                    
                }
                else
                {
                    cp.minuteSinceLastComm = 24*60;
                }
				
				break; 
			}
			default:
				break;
		}
		
	}
	
	
	
}


/******* NOT USED : OBSOLETE *********/
-(void) query_disabled_alert_list_:(CamProfile *) cp
{

     NSLog(@" query_disabled_alert_list camera: %@",cp.name); 
    //All enabled - default
    cp.soundAlertEnabled = TRUE;
    cp.tempHiAlertEnabled = TRUE;
    cp.tempLoAlertEnabled = TRUE;

    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * device_token = (NSString *)[userDefaults objectForKey:_push_dev_token]; 
    
    BMS_Communication * bms_alerts = [[BMS_Communication alloc] initWithObject:self
                                                                      Selector:nil 
                                                                  FailSelector:nil 
                                                                     ServerErr:nil];
	
	//call get camlist query here 
	NSData* responseData = [bms_alerts BMS_getDisabledAlertBlockWithUser:self.userName 
                                                                 AndPass:self.userPass 
                                                                   regId:device_token 
                                                                   ofMac:cp.mac_address];
                            
                            
    NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"response: %@", raw_data); 
//    Response:
//    ""<br>mac=[mac address]
//    <br>cameraname=[camera name]
//    <br>Total_disabled_alerts=[count]
//    <br>alert=<alert>
//    <br>alert=<alert>
//    <br>alert=<alert>
    NSArray * token_list;

	token_list = [raw_data componentsSeparatedByString:@"<br>"];
    if ([token_list count] > 4)
    {
        int alertCount; 
        
        NSArray * token_list_1 = [[token_list objectAtIndex:3] componentsSeparatedByString:@"="];
        
        alertCount = [[token_list_1 objectAtIndex:1] intValue]; 
        NSLog(@"Alert disabled is: %d", alertCount); 
        
        int i = 0;
        NSString * disabledAlert;
        while (i < alertCount)
        {
            token_list_1 = [[token_list objectAtIndex:(i+4)] componentsSeparatedByString:@"="];
            
            disabledAlert= [token_list_1 objectAtIndex:1] ;
            disabledAlert = [disabledAlert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
             NSLog(@"disabledAlert disabled is:%@--> %@",[token_list objectAtIndex:(i+4)],  disabledAlert); 
            
            if ( [disabledAlert isEqualToString:ALERT_TYPE_SOUND])
            {
                NSLog(@"Set sound  for cam: %@", cp.mac_address);
                cp.soundAlertEnabled = FALSE;
               
            }
            else if ( [disabledAlert isEqualToString:ALERT_TYPE_TEMP_HI] )
            {
                NSLog(@"Set tempHiAlertEnabled  for cam: %@", cp.mac_address);
                cp.tempHiAlertEnabled = FALSE;
               
            }
            else if ([disabledAlert isEqualToString:ALERT_TYPE_TEMP_LO] )
            {
                NSLog(@"Set temp low  for cam: %@", cp.mac_address);
                 cp.tempLoAlertEnabled = FALSE;
            }
            
            i++;
        }
        
        
                
        
    }
    else
    {
        NSLog(@"Token list count <4 :%@, %@, %@, %@",[token_list objectAtIndex:0],
              [token_list objectAtIndex:1],
              [token_list objectAtIndex:2],
              [token_list objectAtIndex:3]); 
        
        
              
    }
                            
}
/******************************/


#if JSON_FLAG
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
#else
-(void) getCamListFailure:(NSHTTPURLResponse*) error_response
{
	NSLog(@"Loging failed with error code:%d", [error_response statusCode]);
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error",nil, [NSBundle mainBundle],
                                                          @"Get Camera list Error", nil);
    
    NSString * msg1 = NSLocalizedStringWithDefaultValue(@"Get_Camera_list_Error_msg",nil, [NSBundle mainBundle],
                                                       @"Server error: %@", nil);
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:msg
						  message:[NSString stringWithFormat:msg1, [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]] 
						  delegate:self
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[delegate sendStatus:8];
	return;
}
#endif

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

#if JSON_FLAG
- (NSMutableArray *)parse_camera_list:(NSArray *)dataArr
{
    if (dataArr) {
        NSLog(@"dataArr.count = %d", dataArr.count);
    }
    
    NSMutableArray *camList = [[NSMutableArray alloc] init];
    
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
        
        CamProfile *cp = [[CamProfile alloc]initWithMacAddr:camMac];

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
#else
/*
-(NSMutableArray *) parse_camera_list:(NSString*) raw
{
	
	NSString * total_cam_str;
	NSMutableArray * cam_list;
	NSArray * token_list;
	int total_cam;
    //one token_list is a line 
	token_list = [raw componentsSeparatedByString:@"<br>"];
	
	total_cam_str = [token_list objectAtIndex:0];
	total_cam_str = [total_cam_str substringFromIndex:[TOTAL_CAM length]];
	
	total_cam = [total_cam_str intValue];
	
    
	//NSLog(@"tok list count:%d", [token_list count] -2);
	//take into account the last empty token
	if (total_cam !=0 && total_cam !=( [token_list count] -2))
	{
		return nil;
		//STh is wrong
	}
	cam_list = [[NSMutableArray alloc] init];
	
	if (total_cam ==0)
	{
		
		return cam_list;
	}
	
    
	int i = 1;
	NSString * cam_entry;
	NSArray * cam_entry_tokens;
	CamProfile * cp;
	
	while (i < ([token_list count] -1) )
	{
		
		cam_entry = [token_list objectAtIndex:i];
        
		cam_entry_tokens = [cam_entry componentsSeparatedByString:@","];
		if ([cam_entry_tokens count] < CAM_LIST_ENTRY_NUM_TOKEN)
		{
            NSLog(@"error parsing camera list response"); 
		}
		else
		{
			NSString * cam_name = [cam_entry_tokens objectAtIndex:0];
			cam_name= [cam_name substringFromIndex:[CAM_NAME length]];
			
			NSString * cam_mac = [cam_entry_tokens objectAtIndex:1];
			cam_mac = [cam_mac substringFromIndex:[MAC length]];
			if ([cam_mac length] != 12 )
			{
				cam_mac =@"00:00:00:00:00:00";
			}
			else {
				cam_mac = [Util add_colon_to_mac:cam_mac];
			}
			
			
			NSString * last_comm = [cam_entry_tokens objectAtIndex:2];
			last_comm = [last_comm substringFromIndex:[LAST_COMM length]];
            
            NSString * local_ip = [cam_entry_tokens  objectAtIndex:8];
            local_ip = [local_ip substringFromIndex:[LOCAL_IP length]];
            
            
            NSString * is_Available = nil;
            NSString * codec = nil;
            NSString * str;
            NSString * fw_version = nil;
            

            //Server sometimes responses with malform data -- so we have to do it brute force way
            //Start from 8 becoz next item can be error
            for (int i = 8; i< cam_entry_tokens.count; i++)
            {
                str = (NSString *) [cam_entry_tokens objectAtIndex:i];
                if ([str hasPrefix:IS_AVAILABLE])
                {
                     is_Available = [str substringFromIndex:[IS_AVAILABLE length]];
                }
                else if ([str hasPrefix:CODEC])
                {
                    codec = [str substringFromIndex:[CODEC length]];
                }
                else if ([str hasPrefix:CAMERA_FW_VER])
                {
                    fw_version = [str substringFromIndex:[CAMERA_FW_VER length]];

                }
            }
             
           

		
                       
            
            cp = [[CamProfile alloc]initWithMacAddr:cam_mac];
            cp.last_comm = last_comm;
            
            cp.name = cam_name;
            
            if([is_Available intValue] == 1)
            {
                cp.minuteSinceLastComm = 1;
            } else {
                cp.minuteSinceLastComm = 24*60;
            }
            if ( (local_ip == nil) ||
                ([local_ip length] == 0) ||
                ([local_ip isEqualToString:@"null"] ) )
            {
                //garbage ip
            }
            else
            {
                cp.ip_address = local_ip ;
            }
            
            cp.codecs = codec;
            cp.fw_version = fw_version;
            
#if 1 //dbg
            
            NSLog(@"code:%@, Fw:%@", codec, fw_version); 
#endif
            
            
			
			[cam_list addObject:cp];
		}
		i++;
	}
	
	
	
	
	return cam_list;
}
 */
#endif

#if JSON_FLAG
- (void)sync_online_and_offline_data:(NSMutableArray *) online_profiles
{
    //NSLog(@"aaaaaaaa");
    SetupData * offline_data = nil;
	offline_data = [[SetupData alloc] init];
	
	if ([offline_data restore_session_data] == TRUE)
	{
        NSLog(@"has offline data ");
	}
	else
    {
		//
		NSLog(@"No offline data ");
	}
    
    NSMutableArray * offline_profiles = offline_data.configured_cams;
	
	
	if (online_profiles == nil)
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
	
	
	offline_profiles = online_profiles;
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
		
		
		NSMutableArray * channels = nil;
		channels = [[NSMutableArray alloc]init];
		CamChannel * ch;
		CamProfile * cp;
		for (int i =0; i<4; i++)
		{
			ch = [[CamChannel alloc]initWithChannelIndex:i];
			
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
#else
-(void) sync_online_and_offline_data:(NSMutableArray *) online_profiles
{
	SetupData * offline_data = nil;
	offline_data = [[SetupData alloc] init];
	
	if ([offline_data restore_session_data] == TRUE)
	{
				
	}
	else
    {
		//
		NSLog(@"No offline data ");
	}
	
	NSMutableArray * offline_profiles = offline_data.configured_cams;
	
	
	if (online_profiles == nil)
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
	
	
	offline_profiles = online_profiles;
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
		
		
		NSMutableArray * channels = nil;
		channels = [[NSMutableArray alloc]init];
		CamChannel * ch; 
		CamProfile * cp;
		for (int i =0; i<4; i++)
		{
			ch = [[CamChannel alloc]initWithChannelIndex:i];
			
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
	//NSLog(@"after saving session data");
	
	

	
}
#endif
@end
