//
//  UserAccount.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "UserAccount.h"


@implementation UserAccount


-(id) initWithUser:(NSString*)user AndPass:(NSString*) pass WithListener:(id <ConnectionMethodDelegate>) d; 
{
	[super init];
	userName = user;
	userPass = pass;
	delegate = d; 
	return self; 
}

-(void) query_camera_list
{
	BMS_Communication * bms_comm; 
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(getCamListSuccess:) 
											FailSelector:@selector(getCamListFailure:) 
											   ServerErr:@selector(getCamListServerUnreachable)];
	
	//TODO call get camlist query here 
	[bms_comm BMS_getCameraListWithUser:userName AndPass:userPass];
}

-(void) getCamListSuccess:(NSData*) responseData
{
	
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];

	NSLog(@"getcam response: %@", raw_data);
	NSMutableArray * cam_profiles;
	cam_profiles = [self parse_camera_list:raw_data];
	
	NSLog(@"after parsing total cam: %d", [cam_profiles count]);
	
	
	/*TODO: query snapshot from online */
	
	/* sync_online_and_offline_data*/
	[self sync_online_and_offline_data:cam_profiles];
	
	
	[delegate sendStatus:3];
	
}
-(void) getCamListFailure:(NSHTTPURLResponse*) error_response
{
	NSLog(@"Loging failed with error code:%d", [error_response statusCode]);
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Get Camera list Error"
						  message:[NSString stringWithFormat:@"Server error code: %d", [error_response statusCode]] 
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

#define CAM_LIST_ENTRY_NUM_TOKEN 4
#define TOTAL_CAM @"Total_Cameras="
#define CAM_NAME @" Cam = "
#define MAC      @" Mac = "
#define LAST_COMM @"last_comm_from_cam = "
#define TIME_DIFF @" time_up_to_request = "

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
	

	NSLog(@"tok list count:%d", [token_list count] -2);
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
	
	NSLog(@"total: %@ int:%d", total_cam_str, total_cam);
	int i = 1; 
	NSString * cam_entry; 
	NSArray * cam_entry_tokens; 
	CamProfile * cp; 
	
	while (i < ([token_list count] -1) )
	{
		
		cam_entry = [token_list objectAtIndex:i];
		NSLog(@"cam-entry: %@", cam_entry);
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
			
			cp = [[CamProfile alloc]initWithMacAddr:cam_mac];
			cp.last_comm = last_comm;
			cp.minuteSinceLastComm = time_diff_; 
			cp.name = cam_name;
			
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
	NSLog(@"after saving session data");
	
	

	
}



@end
