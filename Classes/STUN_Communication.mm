//
//  STUN_Communication.m
//  MBP_ios
//
//  Created by NxComm on 7/4/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "STUN_Communication.h"

#define DEBUG 0

@implementation STUN_Communication
@synthesize mChannel;


-(UdtSocketWrapper *)connectToStunRelay: (CamChannel *) ch
{
    if (ch.profile.mac_address == nil)
	{
		return nil; 
	}
	
	mChannel = ch; 
	[mChannel retain];
    
    NSMutableData * messageToStun, * response_data ;
    
    if (ch.relayToken == nil)
    {
        NSLog(@"ERROR relay token is nil"); 
        return nil; 
    }
    messageToStun = [[NSMutableData alloc] initWithData:[ch.relayToken dataUsingEncoding:NSUTF8StringEncoding]];

    // start STUN communication process..
    UdtSocketWrapper * udt_wrapper = [[ UdtSocketWrapper alloc] init];
    int localPort, response_len = 50 ; 
    [udt_wrapper createUdtStreamSocket];
    
    
    struct in_addr * server_ip = [UdtSocketWrapper getIpfromHostName:STUN_RELAY_SERVER_IP];

    localPort = [udt_wrapper connectViaUdtSock:server_ip
                                          port:STUN_RELAY_SERVER_PORT];
    NSLog(@"sock connected at port: %d",localPort );
    
    [udt_wrapper sendDataViaUdt:(NSData *) messageToStun]; 
    
    
    response_data = [[NSMutableData alloc] initWithLength:response_len]; 
    response_len = [udt_wrapper recvDataViaUdt:response_data 
                                       dataLen:response_len];
    if (response_len > 3)
    {
        NSRange  response_range= NSMakeRange(0,3);
        NSData * response_dat = [response_data subdataWithRange:response_range];
        NSString * tag = [[[NSString alloc] initWithData:response_dat encoding: NSUTF8StringEncoding] autorelease];
        
        if ([tag isEqualToString:@"&&&"])
        {
            //Connect  To camera Succeeded
            response_range= NSMakeRange(0,15);
            response_dat = [response_data subdataWithRange:response_range];

            NSLog(@"Relay Success tag: %@", tag); 
            return udt_wrapper;
        }
        else if ([tag isEqualToString:@"###"]) {
            //Relay ERROR 
            response_range= NSMakeRange(0,15);
            response_dat = [response_data subdataWithRange:response_range];
            tag = [[[NSString alloc] initWithData:response_dat encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"Relay error tag: %@", tag); 
            
            return nil;
        }
        else if ([tag isEqualToString:@"@@@"]) {
            //other ERROR 
             response_range= NSMakeRange(0,15); 
            response_dat = [response_data subdataWithRange:response_range];
            tag = [[[NSString alloc] initWithData:response_dat encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"Relay error  tag: %@", tag); 
            return nil;
        }

        
    }
    
    
    return nil; 
    
}

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
	
	//kick off by querying IsCamReady.. This can take looonng time.. 
	retry_getting_camera_availability = 20;
	
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
	
   
    isCamAvaiTimer =
    [NSTimer scheduledTimerWithTimeInterval:20
                                     target:self
                                   selector:@selector(isCamAvaiTimeOut:)
                                   userInfo:nil
                                    repeats:NO]; 
	
	return TRUE;
}


-(void) processSecInfo_bg:(CamChannel *) mChannel_
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    if (mChannel_.secretKey != nil && mChannel_.channID != nil)
    {
#if DEBUG
        // encryption stuff
        NSLog(@"channID: %@", mChannel_.channID);
#endif
        
        NSData * _encChan = [mChannel_ getEncChannId];
        
#if  DEBUG
        NSString * encChan =@"";
        for (int i =0; i< [ _encChan length]; i ++)
        {
            encChan = [NSString  stringWithFormat:@"%@ %02x", encChan,
                       ((uint8_t *)[_encChan bytes]) [i] ];
        }
        
        NSLog(@"Enc chan: %@", encChan);
#endif
        
        NSData * _encMac = [mChannel_ getEncMac];
        NSMutableData * messageToStun, * response_data ;
        
        messageToStun = [[NSMutableData alloc] initWithData:_encMac];
        [messageToStun appendData:_encChan];
        
        
        // start STUN communication process..
        UdtSocketWrapper * udt_wrapper = [[ UdtSocketWrapper alloc] init];
        int localPort, response_len = 80 ;
        [udt_wrapper createUdtStreamSocket];
        
        
        struct in_addr * server_ip = [UdtSocketWrapper getIpfromHostName:STUN_SERVER_IP];
        
#if DEBUG
        NSLog(@"sock created: %d serverip: %d",socket ,
              server_ip->s_addr);
#endif
        localPort = [udt_wrapper connectViaUdtSock:server_ip
                                              port:STUN_SERVER_PORT];
#if DEBUG
        NSLog(@"sock connected at port: %d",localPort );
#endif
        
        [udt_wrapper sendDataViaUdt:(NSData *) messageToStun];
        
        
        response_data = [[NSMutableData alloc] initWithLength:response_len];
        response_len = [udt_wrapper recvDataViaUdt:response_data
                                           dataLen:response_len];
        
        //try decrypt
        if (response_len == 80) // rcv enough data
        {
            NSData * plain_response;
            plain_response = [mChannel_ decryptServerMessage:(NSData*) response_data];
            
            NSRange errRange = {0, 4};
            NSData * errCode  = [plain_response subdataWithRange:errRange];
            
            NSRange camIpRange = {4,8};
            NSData * camIp = [plain_response subdataWithRange:camIpRange];
            
            NSRange camPortRange = {12, 4};
            NSData *camPort = [plain_response subdataWithRange:camPortRange];
            
            NSRange skRange = {16,64};
            NSData * sskey = [plain_response subdataWithRange:skRange];
            
            
            NSString * _errCode = [[NSString alloc] initWithData:errCode encoding:NSUTF8StringEncoding];
            NSScanner  * hexVal = [NSScanner scannerWithString:_errCode];
            uint error_code =  -1;
            [hexVal scanHexInt:&error_code];
            
            
            if (error_code != 200)
            {
                //TODO: process if error code is not 200
                //ERROR out
                [_caller performSelector:_Failure_SEL withObject:nil ];
            }
            NSString * str = [[NSString alloc] initWithData:camIp encoding:NSUTF8StringEncoding];
            hexVal = [NSScanner scannerWithString:str];
            uint cam_ip = -1 ;
            [hexVal scanHexInt:&cam_ip];
            
            mChannel_.profile.ip_address = [CamChannel convertIntToIpStr:cam_ip];
            
            
            
            str = [[NSString alloc] initWithData:camPort encoding:NSUTF8StringEncoding];
            hexVal = [NSScanner scannerWithString:str];
            uint cam_prt = -1 ;
            [hexVal scanHexInt:&cam_prt];
            mChannel.profile.port = cam_prt;
            
            str = [[NSString alloc] initWithData:sskey encoding:NSUTF8StringEncoding];
            
            mChannel_.remoteViewKey = str;
            mChannel_.localUdtPort = localPort; //store this port # for use later
            
            
            [_caller performSelectorOnMainThread:_Success_SEL withObject:mChannel_ waitUntilDone:NO];
            
        }
        else
        {
            NSLog(@"ERROR can't rcv enough data to decrypt");
            [_caller performSelectorOnMainThread:_Failure_SEL withObject:nil waitUntilDone:NO];
        }
        
        
        
    }
    else
    {
        //ERROR out
        [_caller performSelectorOnMainThread:_Failure_SEL withObject:nil waitUntilDone:NO];
    }
    
	

    
    
    
    
    [pool drain];
}





-(BOOL)  isConnectingOnSymmetricNat
{
    //prepare message
    NSMutableData * messageToSever, * response_data;
    int localPort, response_len = 128 ;
    NSString* firstMessage =  nil , * secondMessage = nil;
    
    messageToSever = [[NSMutableData alloc] initWithData:[SYM_NAT_CHECK_MSG dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    //Open socket to server
    // start UDT communication process..
    UdtSocketWrapper * udt_wrapper = [[ UdtSocketWrapper alloc] initWithLocalPort:SYM_NAT_CHECK_LOCAL_PORT];
    [udt_wrapper createUdtStreamSocket];
    
    // Bind to a port
    
    // Send first message
    
    // Recv server response
    
    struct in_addr * server_ip = [UdtSocketWrapper getIpfromHostName:SYM_NAT_CHECK_SERVER_1];
    
    localPort = [udt_wrapper connectViaUdtSock:server_ip
                                          port:SYM_NAT_CHECK_SERVER1_PORT];
    NSLog(@"sock 1 connected at port: %d",localPort );
    
    [udt_wrapper sendDataViaUdt:(NSData *) messageToSever];
    
    response_data = [[NSMutableData alloc] initWithLength:response_len];
    response_len = [udt_wrapper recvDataViaUdt:response_data
                                       dataLen:response_len];
    
    if ( response_len > 0)
    {
        NSLog(@"response: %@", [[NSString alloc] initWithData:response_data encoding:NSUTF8StringEncoding]);
     
        firstMessage = [[NSString alloc] initWithData:response_data encoding:NSUTF8StringEncoding];
    }
    
    
    [udt_wrapper close];
    [udt_wrapper release];
    
    
    // Open socket to server2
    response_len = 128;
    udt_wrapper = [[ UdtSocketWrapper alloc] initWithLocalPort:SYM_NAT_CHECK_LOCAL_PORT];
    [udt_wrapper createUdtStreamSocket];
    server_ip = [UdtSocketWrapper getIpfromHostName:SYM_NAT_CHECK_SERVER_2];
    
    // Bind to the SAME port: done in UdtWrapperSocket initWithLocalPort..
    
    // Send second message
    
    // Recv second message
    
    localPort = [udt_wrapper connectViaUdtSock:server_ip
                                          port:SYM_NAT_CHECK_SERVER1_PORT];
    NSLog(@"sock 2 connected at port: %d",localPort );
    
    [udt_wrapper sendDataViaUdt:(NSData *) messageToSever];
    
    response_data = [[NSMutableData alloc] initWithLength:response_len];
    response_len = [udt_wrapper recvDataViaUdt:response_data
                                       dataLen:response_len];
    
    if ( response_len > 0)
    {
        NSLog(@"response 2: %@", [[NSString alloc] initWithData:response_data encoding:NSUTF8StringEncoding]);
        
        secondMessage = [[NSString alloc] initWithData:response_data encoding:NSUTF8StringEncoding];
    }
    
    if (firstMessage != nil && secondMessage != nil)
    {
        
        // Parse both message
        NSString * firstMessageIp, * firstMessagePort, *secondMessageIp, *secondMessagePort;
        
        NSArray * token = [firstMessage componentsSeparatedByString:@"::"];
        firstMessageIp = (NSString*)[token objectAtIndex:0];
        firstMessagePort = (NSString*)[token objectAtIndex:1];
        
        token = [secondMessage componentsSeparatedByString:@"::"];
        secondMessageIp = (NSString*)[token objectAtIndex:0];
        secondMessagePort = (NSString*)[token objectAtIndex:1];
        
        // Compare IP and port values
        if (![firstMessageIp isEqualToString:secondMessageIp])
        {
            NSLog(@"Local ip are different");
        }
        
        if ([firstMessagePort isEqualToString:secondMessagePort])
        {
            return TRUE;
        }
    }
    else
    {
         NSLog(@"Failed to get response from nat[x] server");
    }
    
    //return FALSE;
    
    //FOR NOW _ FORCE RELay
    return TRUE;
}


#pragma mark -
#pragma mark Timer Callbacks

-(void)isCamAvaiTimeOut:(NSTimer *) exp
{
#if DEBUG
    NSLog(@"20sec timeout -- ");
#endif
    //20sec has timeout stop the task now..
    retry_getting_camera_availability = -1;
    
}

#pragma mark -
#pragma mark Callbacks 



- (void) availSuccessWithResponse:(NSData*) responseData
{
    
    if (mChannel.stopStreaming == TRUE)
    {
        [_caller performSelector:_Failure_SEL withObject:nil ];
        return ;
    }
    
    
    
    if ([isCamAvaiTimer isValid])
    {
        [isCamAvaiTimer invalidate];
    }
    
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	NSLog(@"isavail response: %@", raw_data);
	
	// if success means camera is available 
	//Next, get the security info
    
    
    
    if (mChannel.profile.isNewerThan08_038 &&
        ([self isConnectingOnSymmetricNat]))
    {
        //Check SYM NAT
        NSLog(@"connecting over SYMMETRIC NAT >>>>>>>>>RELAY 2>>>>>");
        
        //change comm mode
        mChannel.communication_mode  = COMM_MODE_STUN_RELAY2;
        
        
        BMS_Communication * bms_comm;
        
        bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                    Selector:@selector(viewCamRelaySuccessWithResponse:)
                                                FailSelector:@selector(viewCamRelayFailedWithError:)
                                                   ServerErr:@selector(viewCamRelayFailedServerUnreachable)];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
        NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
        
        
        [bms_comm BMS_viewCamRelayWithUser:user_email
                                   AndPass:user_pass
                                   macAddr:mChannel.profile.mac_address];
        
        
        
        
    }
    else
    {
        
        NSLog(@"app is NOT behind Sym-nat OR camera version is < 08_039"); 
    
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
	
}
- (void) availFailedWithError:(NSHTTPURLResponse*) error_response
{
	
	NSLog(@" failed with error code:%d", [error_response statusCode]);
	
    if (mChannel.stopStreaming == TRUE)
    {
        [_caller performSelector:_Failure_SEL withObject:nil ];
        return ;
    }    
	// if success means camera is NOT available 
	retry_getting_camera_availability--;
	if (retry_getting_camera_availability <=0)
	{
		//Pass some info back to caller
		[_caller performSelector:_Failure_SEL withObject:nil ];
	}
	else //retry 
	{
        
        
        [NSThread sleepForTimeInterval:1.0]; 
        
        
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
	if (mChannel.stopStreaming == TRUE)
    {
        [_caller performSelector:_Failure_SEL withObject:nil ];
        
        NSLog(@"isavail server unreachable --- STOP Streaming" );

        return ;
    }
    
	NSLog(@" failed : server unreachable");
	// if success means camera is NOT available 
	retry_getting_camera_availability--;
	if (retry_getting_camera_availability <=0)
	{
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


-(void) viewCamRelaySuccessWithResponse: (NSData*) responseData
{
    
    if (mChannel.stopStreaming == TRUE)
    {
        [_caller performSelector:_Failure_SEL withObject:nil ];
        return ;
    }
	
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
    
	NSLog(@"[Main Thread] ViewRelay2 response: %@", raw_data);
    if ( raw_data != nil && [raw_data hasPrefix:RELAY_SSKEY])
	{
        NSArray * tokens = [raw_data componentsSeparatedByString:@"<br>"];
        

		NSString * chann_id = nil, * session_key = nil ;
        
        session_key = (NSString *) [tokens objectAtIndex:1];
        NSArray * sskey_tokens = [session_key componentsSeparatedByString:@"="];

        session_key = (NSString *) [sskey_tokens objectAtIndex:1];
        session_key  = [session_key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        chann_id = (NSString *) [tokens objectAtIndex:2];
        NSArray * chann_id_tokens = [chann_id componentsSeparatedByString:@"="];

        chann_id = (NSString *) [chann_id_tokens objectAtIndex:1];
        chann_id  = [chann_id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        		
		if (session_key != nil && chann_id != nil)
		{
			mChannel.remoteViewKey  = session_key;
			mChannel.channID = chann_id;
            
            NSLog(@"[Main Thread] ViewRelay2 sskey: %@ & channid: %@|||||", session_key, chann_id);

            
            [_caller performSelectorOnMainThread:_Success_SEL withObject:mChannel waitUntilDone:NO];
            
        }
        else
		{
			//ERROR out
			[_caller performSelector:_Failure_SEL withObject:nil ];
		}
    }
    

    
    
    
}

-(void) viewCamRelayFailedWithError:(NSHTTPURLResponse*) error_response
{
    if (mChannel.stopStreaming == TRUE)
    {
        [_caller performSelector:_Failure_SEL withObject:nil ];
        return ;
    }
    
	[_caller performSelector:_Failure_SEL withObject:nil ];
}




-(void) viewCamRelayFailedServerUnreachable
{
    if (mChannel.stopStreaming == TRUE)
    {
        [_caller performSelector:_Failure_SEL withObject:nil ];
        return ;
    }
	
	[_caller performSelector:_Failure_SEL withObject:nil ];

}





- (void) getSecSuccessWithResponse:(NSData*) responseData
{
    
    if (mChannel.stopStreaming == TRUE)
    {
        [_caller performSelector:_Failure_SEL withObject:nil ];
        return ;
    }
	
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	NSLog(@"[Main Thread] getSec response: %@", raw_data);
	
#if 1 // USE BG thread to handle these...
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
    
    
            [self performSelectorInBackground:@selector(processSecInfo_bg:) withObject:mChannel];
        }
        else
		{
			//ERROR out
			[_caller performSelector:_Failure_SEL withObject:nil ];
		}
    }
    
    
#else
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
			
			// encryption stuff
			NSLog(@"channID: %@", chann_id);
			

			NSData * _encChan = [mChannel getEncChannId];

#if 0 // DEBUG 
			NSString * encChan =@"";
			for (int i =0; i< [ _encChan length]; i ++)
			{
				encChan = [NSString  stringWithFormat:@"%@ %02x", encChan, 
						   ((uint8_t *)[_encChan bytes]) [i] ];
			}
				
			NSLog(@"Enc chan: %@", encChan);
#endif 
						   
			NSData * _encMac = [mChannel getEncMac];
			NSMutableData * messageToStun, * response_data ; 
			
			messageToStun = [[NSMutableData alloc] initWithData:_encMac];
			[messageToStun appendData:_encChan]; 
			
			
			// start STUN communication process..
			UdtSocketWrapper * udt_wrapper = [[ UdtSocketWrapper alloc] init];
			int localPort, response_len = 80 ; 
			[udt_wrapper createUdtStreamSocket];
			 

			struct in_addr * server_ip = [UdtSocketWrapper getIpfromHostName:STUN_SERVER_IP];
			

			NSLog(@"sock created: %d serverip: %d",socket , 
				  server_ip->s_addr);
			localPort = [udt_wrapper connectViaUdtSock:server_ip
							   port:STUN_SERVER_PORT];
			NSLog(@"sock connected at port: %d",localPort );
			
			[udt_wrapper sendDataViaUdt:(NSData *) messageToStun]; 
			
			
			response_data = [[NSMutableData alloc] initWithLength:response_len]; 
			response_len = [udt_wrapper recvDataViaUdt:response_data 
										dataLen:response_len];
			
			//try decrypt 
			if (response_len == 80) // rcv enough data
			{
				NSData * plain_response; 
				plain_response = [self.mChannel decryptServerMessage:(NSData*) response_data];
				
				NSRange errRange = {0, 4};
				NSData * errCode  = [plain_response subdataWithRange:errRange];
				
				NSRange camIpRange = {4,8}; 
				NSData * camIp = [plain_response subdataWithRange:camIpRange];
				
				NSRange camPortRange = {12, 4}; 
				NSData *camPort = [plain_response subdataWithRange:camPortRange];
				
				NSRange skRange = {16,64};
				NSData * sskey = [plain_response subdataWithRange:skRange]; 
				
				
				NSString * _errCode = [[NSString alloc] initWithData:errCode encoding:NSUTF8StringEncoding];
				NSScanner  * hexVal = [NSScanner scannerWithString:_errCode]; 
				uint error_code =  -1; 
				[hexVal scanHexInt:&error_code];
#if 0 //Debug	
				NSLog(@"errCode: %@ --Int --> %d",_errCode, error_code ); 
#endif
				
				
				if (error_code != 200)
				{
					//TODO: process if error code is not 200 
					//ERROR out
					[_caller performSelector:_Failure_SEL withObject:nil ];
				}
				NSString * str = [[NSString alloc] initWithData:camIp encoding:NSUTF8StringEncoding];
				hexVal = [NSScanner scannerWithString:str]; 
				uint cam_ip = -1 ;
				[hexVal scanHexInt:&cam_ip];
				
				mChannel.profile.ip_address = [CamChannel convertIntToIpStr:cam_ip]; 

				
				
				str = [[NSString alloc] initWithData:camPort encoding:NSUTF8StringEncoding];
				hexVal = [NSScanner scannerWithString:str]; 
				uint cam_prt = -1 ;
				[hexVal scanHexInt:&cam_prt];
				mChannel.profile.port = cam_prt;
		
				str = [[NSString alloc] initWithData:sskey encoding:NSUTF8StringEncoding];
 
				self.mChannel.remoteViewKey = str; 
				self.mChannel.localUdtPort = localPort; //store this port # for use later
				
				
				[_caller performSelector:_Success_SEL withObject:self.mChannel ];
				
			}
			else
			{
				NSLog(@"ERROR can't rcv enough data to decrypt"); 
				[_caller performSelector:_Failure_SEL withObject:nil ];
			}

			
			
		}
		else
		{
			//ERROR out
			[_caller performSelector:_Failure_SEL withObject:nil ];
		}

	}
#endif
	

	
}
- (void) getSecFailedWithError:(NSHTTPURLResponse*) error_response
{

    if (mChannel.stopStreaming == TRUE)
    {
        [_caller performSelector:_Failure_SEL withObject:nil ];
        return ;
    }
    

	
	[_caller performSelector:_Failure_SEL withObject:nil ];
}
- (void) getSecFailedServerUnreachable
{
    if (mChannel.stopStreaming == TRUE)
    {
        [_caller performSelector:_Failure_SEL withObject:nil ];
        return ;
    }
    

	
	[_caller performSelector:_Failure_SEL withObject:nil ];
}






@end
