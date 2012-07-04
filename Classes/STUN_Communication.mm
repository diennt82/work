//
//  STUN_Communication.m
//  MBP_ios
//
//  Created by NxComm on 7/4/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "STUN_Communication.h"


@implementation STUN_Communication
@synthesize mChannel;

-(BOOL) connectToRemoteCamera: (CamChannel *) ch 
					 callback: (id) caller 
					 Selector: (SEL) success 
				 FailSelector: (SEL) fail
{
	if (ch.profile.mac_address == nil)
	{
		return FALSE; 
	}
	
	mChannel = ch; 
	[mChannel retain]; 
	
	_caller = caller ;
	_Success_SEL = success; 
	_Failure_SEL = fail; 
	
	//kick off by querying IsCamReady...
	retry_getting_camera_availability = 8; 
	
	BMS_Communication * bms_comm; 
	
	NSString * mac = [Util strip_colon_fr_mac:ch.profile.mac_address];
	
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(availSuccessWithResponse:) 
											FailSelector:@selector(availFailedWithError:) 
											   ServerErr:@selector(availFailedServerUnreachable)];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
	
	[bms_comm BMS_isCamAvailableWithUser:user_email 
								AndPass:user_pass 
								macAddr:mac ];
	
	
	return TRUE;
}



#pragma mark -
#pragma mark Callbacks 



- (void) availSuccessWithResponse:(NSData*) responseData
{
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	NSLog(@"isavail response: %@", raw_data);
	
	// if success means camera is available 
	//Next, get the security info
	
	
	BMS_Communication * bms_comm; 
	
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(getSecSuccessWithResponse:) 
											FailSelector:@selector(getSecFailedWithError:) 
											   ServerErr:@selector(getSecFailedServerUnreachable)];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
	
	[bms_comm BMS_getSecInfoWithUser:user_email 
								 AndPass:user_pass ];
	
	
	
}
- (void) availFailedWithError:(NSHTTPURLResponse*) error_response
{
	
	NSLog(@" failed with error code:%d", [error_response statusCode]);
	
	// if success means camera is NOT available 
	retry_getting_camera_availability--;
	if (retry_getting_camera_availability <=0)
	{
		//ERROR condition
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Get Camera Status Error"
							  message:[NSString stringWithFormat:@"Server error code: %@", [Util get_error_description:[error_response statusCode]]] 
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		//Pass some info back to caller
		[_caller performSelector:_Failure_SEL withObject:nil ];
	}
	else //retry 
	{
		BMS_Communication * bms_comm; 
		
		NSString * mac = [Util strip_colon_fr_mac:mChannel.profile.mac_address];
		
		bms_comm = [[BMS_Communication alloc] initWithObject:self
													Selector:@selector(availSuccessWithResponse:) 
												FailSelector:@selector(availFailedWithError:) 
												   ServerErr:@selector(availFailedServerUnreachable)];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
		NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
		
		
		[bms_comm BMS_isCamAvailableWithUser:user_email 
									 AndPass:user_pass 
									 macAddr:mac ];
		
		
	}

	return;
}
- (void) availFailedServerUnreachable
{
	
	NSLog(@" failed : server unreachable");
	// if success means camera is NOT available 
	retry_getting_camera_availability--;
	if (retry_getting_camera_availability <=0)
	{
		//ERROR condition
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Get Camera Status Error"
							  message:@"Server unreachable"
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[_caller performSelector:_Failure_SEL withObject:nil ];
	}
	else //retry 
	{
		BMS_Communication * bms_comm; 
		
		NSString * mac = [Util strip_colon_fr_mac:mChannel.profile.mac_address];
		
		bms_comm = [[BMS_Communication alloc] initWithObject:self
													Selector:@selector(availSuccessWithResponse:) 
												FailSelector:@selector(availFailedWithError:) 
												   ServerErr:@selector(availFailedServerUnreachable)];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
		NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
		
		
		[bms_comm BMS_isCamAvailableWithUser:user_email 
									 AndPass:user_pass 
									 macAddr:mac ];
		
		
	}
	
	
	
	return;
}


#define CHANNEL_ID @"ChannelID:"
#define SEC_KEY    @"Secret_key:"
#define CHANNEL_ID_LEN 12

- (void) getSecSuccessWithResponse:(NSData*) responseData
{
	
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	NSLog(@"getSec response: %@", raw_data);
	
	//Move on -- dont signal caller 
	if ( raw_data != nil && [raw_data hasPrefix:CHANNEL_ID])
	{
		NSString * chann_id = nil, * secret_key = nil ; 
		NSRange cRange = {[CHANNEL_ID length], CHANNEL_ID_LEN};
		chann_id = [raw_data substringWithRange:cRange];
		
		NSRange sRange = [raw_data rangeOfString:SEC_KEY];
		if (sRange.location != NSNotFound)
		{
			int ssKey_start = sRange.location + [SEC_KEY length]; 
			secret_key = [raw_data substringFromIndex:ssKey_start];
		}
		
		
		if (secret_key != nil && chann_id != nil)
		{
			mChannel.secretKey  = secret_key; 
			mChannel.channID = chann_id; 
			
			//TODO: encryption stuff
			NSLog(@"channID: %@", chann_id);
			
			NSString * encChan =@"";
			NSData * _encChan = [mChannel getEncChannId];
			for (int i =0; i< [ _encChan length]; i ++)
			{
				encChan = [NSString  stringWithFormat:@"%@ %02x", encChan, 
						   ((uint8_t *)[_encChan bytes]) [i] ];
			}
				
			NSLog(@"Enc chan: %@", encChan);
						   
			
			
			//TODO: start STUN communication process..
			
		}
		else
		{
			//ERROR out
			[_caller performSelector:_Failure_SEL withObject:nil ];
		}

	}		
	
	
	
}
- (void) getSecFailedWithError:(NSHTTPURLResponse*) error_response
{

	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Get Security Info Error"
						  message:[NSString stringWithFormat:@"Server error code: %@", [Util get_error_description:[error_response statusCode]]]
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[_caller performSelector:_Failure_SEL withObject:nil ];
}
- (void) getSecFailedServerUnreachable
{
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Get Security Info Error"
						  message:@"Server unreachable"
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[_caller performSelector:_Failure_SEL withObject:nil ];
}

@end
