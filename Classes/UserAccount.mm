//
//  UserAccount.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "UserAccount.h"
#import "MBP_iosAppDelegate.h"

@implementation UserAccount

@synthesize   userName,  userPass;
@synthesize delegate; 
@synthesize  bms_comm;

-(id) initWithUser:(NSString*)user AndPass:(NSString*) pass WithListener:(id <ConnectionMethodDelegate>) d; 
{
	[super init];
	self.userName = user;
	self.userPass = pass;
	self.delegate = d; 

	return self; 
}


-(void) dealloc
{
    [userName release];
    [userPass release];
    [bms_comm release];
    [super dealloc];
    
}

-(void) query_camera_list_blocked
{ 
    //NSLog(@"UserAccount: query_camera_list_blocked");
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
    
    //NSLog(@"UserAccount: query_camera_list_blocked END");
}

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


-(void) query_camera_list
{
	
   
    
	self.bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(getCamListSuccess:) 
											FailSelector:@selector(getCamListFailure:) 
											   ServerErr:@selector(getCamListServerUnreachable)];
	
	//call get camlist query here 
	[self.bms_comm BMS_getCameraListWithUser:self.userName AndPass:self.userPass];
    
    
    
}

-(void) getCamListSuccess:(NSData*) responseData
{

	
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];


	NSMutableArray * cam_profiles;
	cam_profiles = [self parse_camera_list:raw_data];
	
	//NSLog(@"after parsing total cam: %d", [cam_profiles count]);
	
	
	/* 20120913: DONT query snapshot from online 
    [self query_snapshot_from_server:cam_profiles];*/
	
    
    /* 20121001: Dont query disabled alerts here will do it when the list is opened 
    //query disabled alerts ----- Wait for the registration id 
    if(cam_profiles != nil && [cam_profiles count] >0)
    {
        for (int i=0; i<[cam_profiles count]; i++)
        {
            [self query_disabled_alert_list:[cam_profiles objectAtIndex:i] ]; 
        }
        
    }
   */
    
	/* sync_online_and_offline_data*/
	[self sync_online_and_offline_data:cam_profiles];
	
	[delegate sendStatus:3];
	
}


/******* NOT USED : OBSOLETE *********/
-(void) query_disabled_alert_list:(CamProfile *) cp
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



-(void) getCamListFailure:(NSHTTPURLResponse*) error_response
{
	NSLog(@"Loging failed with error code:%d", [error_response statusCode]);
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Get Camera list Error"
						  message:[NSString stringWithFormat:@"Server error: %@", [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]] 
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[delegate sendStatus:8];
	return;
}	
- (void)getCamListServerUnreachable
{
	NSLog(@"Loging failed : server unreachable");
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Get Camera list Error"
						  message:@"Server unreachable"
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[delegate sendStatus:8];
}

#define CAM_LIST_ENTRY_NUM_TOKEN 5
#define TOTAL_CAM @"Total_Cameras="
#define CAM_NAME @" Cam = "
#define MAC      @" Mac = "
#define LAST_COMM @"last_comm_from_cam = "
#define TIME_DIFF @" time_up_to_request = "
#define LOCAL_IP @" local_ip = "

-(NSMutableArray *) parse_camera_list:(NSString*) raw
{
	
	NSString * total_cam_str;
	NSMutableArray * cam_list; 
	NSArray * token_list;
	int total_cam; 
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
		if ([cam_entry_tokens count] != CAM_LIST_ENTRY_NUM_TOKEN)
		{
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
			
			
			NSString * time_diff = [cam_entry_tokens objectAtIndex:3];
			time_diff =[time_diff substringFromIndex:[TIME_DIFF length]];
			int time_diff_ = [time_diff  intValue];
            
            NSString * local_ip = [cam_entry_tokens  objectAtIndex:4];
              
            local_ip = [local_ip substringFromIndex:[LOCAL_IP length]]; 
			
            cp = [[CamProfile alloc]initWithMacAddr:cam_mac];
            cp.last_comm = last_comm;
            cp.minuteSinceLastComm = time_diff_; 
            cp.name = cam_name;
           
            
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
            

			
			[cam_list addObject:cp];
		}
		i++;
	} 
	
	
	
	
	return cam_list;
}

-(void) sync_online_and_offline_data:(NSMutableArray *) online_profiles
{
	SetupData * offline_data = nil;
	offline_data = [[SetupData alloc] init];
	
	if ([offline_data restore_session_data] == TRUE)
	{
				
	}
	else {
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



@end
