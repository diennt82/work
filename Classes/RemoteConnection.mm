//
//  RemoteConnection.m
//  MBP_ios
//
//  Created by NxComm on 6/26/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "RemoteConnection.h"
#import "STUN_Communication.h"

@implementation RemoteConnection

@synthesize mChannel; 




- (void) dealloc
{
	if (mChannel != nil)
	{
		[mChannel release];
	}
	[super dealloc]; 
}

/* Caller & success & faillure is fixed from now. 
 Any error along the way can be reported wth fail-function 
 otherwise success() will be called at the end with the updated channel 
 */
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
	
	// Kick off by quering the stream mode
	//
	BMS_Communication * bms_comm; 
	
	NSString * mac = [Util strip_colon_fr_mac:ch.profile.mac_address];

	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(getStreamSuccessWithResponse:) 
											FailSelector:@selector(getStreamFailedWithError:) 
											   ServerErr:@selector(getStreamFailedServerUnreachable)];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
	
	[bms_comm BMS_getStreamModeWithUser:user_email 
						 AndPass:user_pass 
						 macAddr:mac ];
	
	return TRUE; 
}





- (void) getStreamSuccessWithResponse:(NSData*) responseData
{
  
    
    
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	NSLog(@"getStream response: %@", raw_data);
	
	//Move on -- dont signal caller 
	if ( raw_data != nil && [raw_data hasPrefix:STREAMING_MODE])
	{
		NSRange m_range = {[STREAMING_MODE length], 1};
		int streamMode = [[raw_data substringWithRange:m_range] intValue];
		
		switch (streamMode) {
			case STREAM_MODE_UPNP:
			case STREAM_MODE_MANUAL_PRT_FWD:
			{
				BMS_Communication * bms_comm; 
				
				self.mChannel.communication_mode = COMM_MODE_UPNP;
				
				NSString * mac = [Util strip_colon_fr_mac:mChannel.profile.mac_address];
				
				bms_comm = [[BMS_Communication alloc] initWithObject:self
															Selector:@selector(getPortSuccessWithResponse:) 
														FailSelector:@selector(getPortFailedWithError:) 
														   ServerErr:@selector(getPortFailedServerUnreachable)];
				
				NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
				NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
				
				
				[bms_comm BMS_getHTTPRmtPortWithUser:user_email 
											AndPass:user_pass 
											macAddr:mac ];
			
				break;
			}
			case STREAM_MODE_STUN:
			{
				NSLog(@"GOing to STUN"); 
				self.mChannel.communication_mode = COMM_MODE_STUN;
				STUN_Communication * stunConn;
				
				
				stunConn = [[STUN_Communication alloc]init]; 
				if ([stunConn connectToRemoteCamera:mChannel
											 callback:_caller
											 Selector:_Success_SEL
										 FailSelector:_Failure_SEL])
				{
					//the process started successfuly
				}
				else 
				{
					NSLog(@"Start remote connection Failed!!!"); 
					[_caller performSelector:_Failure_SEL withObject:nil ];
				}		
				
				
				
				break; 
			}
                
            case STREAM_MODE_RELAY2:
            {

                NSLog(@"Switch to STUN relay 2 From here ");
                STUN_Communication * stunConn;
				stunConn = [[STUN_Communication alloc]init];

                //change comm mode
                self.mChannel.communication_mode  = COMM_MODE_STUN_RELAY2;
                
          
                
                if ([stunConn connectToStunRelay2:mChannel
                                           callback:_caller
                                           Selector:_Success_SEL
                                       FailSelector:_Failure_SEL])
				{
					//the process started successfuly
				}
				else
				{
					NSLog(@"Start remote connection Failed!!!");
					[_caller performSelector:_Failure_SEL withObject:nil ];
				}
                
                              
                break;
            }
			default:
				break;
		}
		
	}
	
	
	
	
	
}
- (void) getStreamFailedWithError:(NSHTTPURLResponse*) error_response
{
	
    
    
    
	NSLog(@" failed with error code:%d", [error_response statusCode]);
	
//	//ERROR condition
//	UIAlertView *alert = [[UIAlertView alloc]
//						  initWithTitle:@"Get Stream Mode Error"
//						  message:[NSString stringWithFormat:@"Server error: %@", [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]]
//						  delegate:self
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
    
    self.mChannel.remoteConnectionError =  [error_response statusCode];
    //Pass some info back to caller
	[_caller performSelector:_Failure_SEL withObject:nil ];
	return;
}



- (void) getStreamFailedServerUnreachable
{

	NSLog(@" failed : server unreachable");
	
	//ERROR condition
//	UIAlertView *alert = [[UIAlertView alloc]
//						  initWithTitle:@"Get Stream Mode Error"
//						  message:@"Server unreachable"
//						  delegate:self
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
    self.mChannel.remoteConnectionError =  REQUEST_TIMEOUT;
	[_caller performSelector:_Failure_SEL withObject:nil ];
	return;
}




- (void) getPortFailedWithError:(NSHTTPURLResponse*) error_response
{

	NSLog(@"failed with error code:%d", [error_response statusCode]);
	
//	//ERROR condition
//	UIAlertView *alert = [[UIAlertView alloc]
//						  initWithTitle:@"Get Upnp/manual Ports Error"
//						  message:[NSString stringWithFormat:@"Server error: %@", [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]]
//						  delegate:self
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
    self.mChannel.remoteConnectionError =  [error_response statusCode];
    //Pass some info back to caller
	[_caller performSelector:_Failure_SEL withObject:nil ];
	return;
	
}
- (void) getPortFailedServerUnreachable
{
	NSLog(@" failed : server unreachable");
	
	//ERROR condition
//	UIAlertView *alert = [[UIAlertView alloc]
//						  initWithTitle:@"Get Upnp/manual Ports Error"
//						  message:@"Server unreachable"
//						  delegate:self
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil];
//	[alert show];
//	[alert release];

    self.mChannel.remoteConnectionError =  REQUEST_TIMEOUT;

	[_caller performSelector:_Failure_SEL withObject:nil ];
	return;
	
}



-(void) getPortSuccessWithResponse:(NSData*) responseData
{
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	NSLog(@"getPort response: %@", raw_data);

	if (raw_data != nil && [raw_data hasPrefix:TOTAL_PORTS])
	{
		NSArray * tokens = [raw_data componentsSeparatedByString:BR_TAG];
		
		
		
		//get the PTT port only 
		NSString * ptt_str = [tokens objectAtIndex:2]; 
		int ptt_port = -1; 
		if ([ptt_str hasPrefix:PTT_PRT])
		{
			ptt_port = [[ptt_str substringFromIndex:[PTT_PRT  length]] intValue]; 
			
		}
		
		NSLog(@"getPort set PTT port to: %d", ptt_port);
		//set the PTT port
		mChannel.profile.ptt_port = ptt_port;
		
	}
	else
    {
		
		NSLog(@"getPort Failed to set PTT port");
		
	}

	//Next: viewCam Request
	
	BMS_Communication * bms_comm; 
	
	NSString * mac = [Util strip_colon_fr_mac:mChannel.profile.mac_address];
	
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(viewRmtSuccessWithResponse:) 
											FailSelector:@selector(viewRmtFailedWithError:) 
											   ServerErr:@selector(viewRmtFailedServerUnreachable)];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
	
	[bms_comm BMS_viewRmtCamWithUser:user_email 
								 AndPass:user_pass 
								 macAddr:mac ];
	
	
}


- (void) viewRmtFailedWithError:(NSHTTPURLResponse*) error_response
{
	
	NSLog(@"failed with error code:%d", [error_response statusCode]);
	
	//ERROR condition
//	UIAlertView *alert = [[UIAlertView alloc]
//						  initWithTitle:@"View Remote Error"
//						  message:[NSString stringWithFormat:@"Server error: %@", [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]]
//						  delegate:self
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
    //Pass some info back to caller
        self.mChannel.remoteConnectionError =  [error_response statusCode];
	[_caller performSelector:_Failure_SEL withObject:nil ];
	return;
	
}

- (void) viewRmtFailedServerUnreachable
{
	NSLog(@" failed : server unreachable");
	
	//ERROR condition
//	UIAlertView *alert = [[UIAlertView alloc]
//						  initWithTitle:@"View Remote Error"
//						  message:@"Server unreachable"
//						  delegate:self
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
    
    self.mChannel.remoteConnectionError =  REQUEST_TIMEOUT;
	[_caller performSelector:_Failure_SEL withObject:nil ];
	return;
}



#define CAM_IP @"Camera_IP="
#define CAM_PORT @"Camera_Port="
#define SS_KEY @"SessionAutenticationKey="


-(void) viewRmtSuccessWithResponse:(NSData*) responseData
{
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	NSLog(@"viewRmt response: %@", raw_data);
	
	if (raw_data != nil && [raw_data hasPrefix:CAM_IP])
	{
		NSArray * tokens = [raw_data componentsSeparatedByString:BR_TAG];
		
		//tmp_user_email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
		//extract the  ip 
		NSString * ip_str = [[tokens objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ; 
		
		ip_str = [ip_str substringFromIndex:[CAM_IP length]]; 
		
		//extract the port 
		int port = -1; 
		NSString * port_str = [[tokens objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ; 
		port_str = [port_str substringFromIndex:[CAM_PORT length]]; 
		port = [port_str intValue];
		
		//extract the ss key
		NSString * sskey = nil; 
		sskey =[[tokens objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		sskey = [sskey substringFromIndex:[SS_KEY length]]; 
		
		NSLog(@"sskey len : %d", [sskey length]); 
		//Bit different from android app -- set the sskey to channel, ip, port to profile 
		
		mChannel.remoteViewKey = [NSString stringWithString:sskey];
		mChannel.profile.ip_address = ip_str;
		mChannel.profile.port = port; 
		
		//Ready to setup the camera channel
		[_caller performSelector:_Success_SEL withObject:mChannel ];
		
	}
	else
	{
		
		[_caller performSelector:_Failure_SEL withObject:nil ];

	}
	
}

#pragma  mark -
#pragma  mark UDT relay 




-(UdtSocketWrapper * ) connectToUDTRelay: (CamChannel *) ch 
{
    
    //1. Send HTTP query to get relay security
    BMS_Communication * bms_comm; 
    bms_comm  = [[BMS_Communication alloc] initWithObject:self
                                                 Selector:@selector(getRelaySecSuccessWithResponse:) 
                                             FailSelector:@selector(getRelaySecFailedWithError:) 
                                                ServerErr:@selector(getRelaySecFailedServerUnreachable)];
    
    NSString * mac = [Util strip_colon_fr_mac:ch.profile.mac_address];	
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    
    NSData * response_dat = [bms_comm BMS_getRelaySecBlockedWithUser:user_email AndPass:user_pass macAddr:mac];
    
    if (response_dat == nil)
    {
        NSLog(@"error getting Relay key from BMS"); 
        return nil;
    }
    
    
    NSString *relaySecInfo = [[[NSString alloc] initWithData:response_dat encoding: NSUTF8StringEncoding] autorelease];
    //Macaddress:mac<br>Secret_key:key-(64 bytes)
    NSLog(@"relaySecInfo:%@",relaySecInfo );
    
    NSArray * tokens = [relaySecInfo componentsSeparatedByString:@"<br>"];
    NSString * secKey_ = (NSString *) [tokens objectAtIndex:1]; 
    NSArray * tokens2 = [secKey_ componentsSeparatedByString:@":"];
    NSString * relay_sk = (NSString *) [tokens2 objectAtIndex:1]; 
     NSLog(@"relay_sk:%@",relay_sk);
    
    if (relay_sk == nil)
    {
        NSLog(@"error extracting Relay key from BMS"); 
        return nil;
    }
    
    
    NSString * relayToken = [ch calculateRelayToken:relay_sk withUserPass:[user_email stringByAppendingFormat:@":%@",user_pass]];
    
    ch.relayToken = relayToken; 
     NSLog(@"relayToken:%@",relayToken);
    
    STUN_Communication * stunConn;
    
    
    stunConn = [[STUN_Communication alloc]init]; 
    
    return [stunConn connectToStunRelay:ch];
     
}


-(void) getRelaySecSuccessWithResponse:(NSData*) responseData
{
    
}
- (void) getRelaySecFailedWithError:(NSHTTPURLResponse*) error_response
{
    
}
- (void) getRelaySecFailedServerUnreachable
{
    
}


@end
