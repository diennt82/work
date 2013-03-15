//
//  BMS_Communication.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "BMS_Communication.h"
#import "AiBallBase64Encoding.h"


@implementation BMS_Communication

@synthesize  obj; 

- (id)  initWithObject: (id) caller Selector:(SEL) success FailSelector: (SEL) fail ServerErr:(SEL) serverErr
{
	[super init];
	obj = caller; 
	selIfSuccess = success;
	selIfFailure = fail;
	selIfServerFail = serverErr;
	
	return self; 
}

/* Non Blocking function - */
- (BOOL)BMS_loginWithUser:(NSString*) user_email AndPass:(NSString*) user_pass
{
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", USR_LOGIN_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", USR_LOGIN_PARAM_1, user_email];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", USR_LOGIN_PARAM_2, user_pass];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", USR_LOGIN_PARAM_3, @"iOS_app"];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", USR_LOGIN_PARAM_4, @"iPhone"];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%d", USR_LOGIN_PARAM_5,[user_pass length]];

	//NSLog(@"login query:%@", http_cmd);
	

	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
				
		
	}
	
	return TRUE;
	
}

- (BOOL)BMS_registerWithUserId:(NSString*) user_id AndPass:(NSString*) user_pass AndEmail:(NSString *) user_email
{
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", USR_REG_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", USR_REG_PARAM_1, user_email];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", USR_REG_PARAM_2, user_pass];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", USR_REG_PARAM_3, user_id];

	
	NSLog(@"reg query:%@", http_cmd);
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
}

- (BOOL)BMS_getCameraListWithUser:(NSString *) user_email AndPass:(NSString*) user_pass;
{
//	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
//	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_CAM_LIST_CMD];
//	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_CAM_LIST_PARAM_1, user_email];

    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_CAM_LIST4_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_CAM_LIST_PARAM_1, user_email];

	
	//NSLog(@"getCamlist query:%@", http_cmd);
	

	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
}



- (BOOL)BMS_addCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac camName:(NSString*) name
{
 	NSString * mac_ = [Util strip_colon_fr_mac:mac];
	
    NSString* escapedName = [name
                             stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", ADD_CAM_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", ADD_CAM_PARAM_1, user_email];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", ADD_CAM_PARAM_2, user_pass];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", ADD_CAM_PARAM_3, mac_];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", ADD_CAM_PARAM_4, escapedName];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%d", ADD_CAM_PARAM_5,[user_pass length]];
	
	NSLog(@"addCam query:%@", http_cmd);
	

	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
	
}



- (BOOL)BMS_camNameWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac camName:(NSString*) name
{
 	NSString * mac_ = [Util strip_colon_fr_mac:mac];
	
	NSString* escapedName = [name   
							stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
	
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", UPDATE_CAM_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", UPDATE_CAM_PARAM_1, user_email];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", UPDATE_CAM_PARAM_2, mac_];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", UPDATE_CAM_PARAM_3, escapedName];
	
	NSLog(@"changeName query:%@", http_cmd);
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
	
}

- (BOOL)BMS_delCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac
{
	NSString * mac_ = [Util strip_colon_fr_mac:mac];
	

	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", DEL_CAM_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", DEL_CAM_PARAM_1, user_email];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", DEL_CAM_PARAM_2, mac_];

	
	NSLog(@"delName query:%@", http_cmd);
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
	
	
}

- (BOOL)BMS_getStreamModeWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac 
{
	
	NSString * mac_ = [Util strip_colon_fr_mac:mac];
	
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_STREAM_MODE_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_STREAM_MODE_PARAM_1, mac_];
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	//Stored for used later.
    basicAuthenUser = user_email;
    basicAuthenPass = user_pass;
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
}


- (BOOL)BMS_getHTTPRmtPortWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac 
{
	NSString * mac_ = [Util strip_colon_fr_mac:mac];
	
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_PORT_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_PORT_PARAM_1, mac_];
	
	
	NSLog(@"getPort query:%@", http_cmd);
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
}



- (BOOL)BMS_viewRmtCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac 
{
	
	NSString * mac_ = [Util strip_colon_fr_mac:mac];
	
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", VIEW_CAM_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", VIEW_CAM_PARAM_1, user_email];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", VIEW_CAM_PARAM_2, mac_];
	
	
	NSLog(@"viewRmt query:%@", http_cmd);
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
	
}



- (BOOL)BMS_isCamAvailableWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac 
{
	NSString * mac_ = [Util strip_colon_fr_mac:mac];
	
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", IS_CAM_AVAIL];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", IS_CAM_AVAIL_PARAM_1, mac_];

	
	
	NSLog(@"isCamAvail query:%@", http_cmd);
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
	
}
- (BOOL)BMS_getSecInfoWithUser:(NSString*) user_email AndPass:(NSString*) user_pass  
{

	
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_SECURITY_INFO];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_SECURITY_INFO_PARAM_1, user_email];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_SECURITY_INFO_PARAM_2, user_pass];
	
	
	
	NSLog(@"getSec query:%@", http_cmd);
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
}


- (BOOL)BMS_resetUserPassword:(NSString*) user_email
{
    
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", RESET_USER_PASSWORD_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", RESET_USER_PASSWORD_PARAM_1, user_email];
	
    
	NSLog(@"reset query:%@", http_cmd);
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
}



-(BOOL) BMS_getRelaySecWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) macWithColon 
{
    
    NSString * mac_ = [Util strip_colon_fr_mac:macWithColon];

    
    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_RELAY_KEY];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_RELAY_KEY_PARAM_1, mac_];

	
	NSLog(@"getRelayS query:%@", http_cmd);
	
	
	if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;

    
}


-(BOOL) BMS_sendCmdViaServeNonBlockedWithUser:(NSString*) user_email
                                        AndPass:(NSString*) user_pass
                                        macAddr:(NSString *) macWithColon
                                        channId:(NSString*) channelId
                                        command:(NSString *)core_command
{
    
 
    NSString * mac_ = [Util strip_colon_fr_mac:macWithColon];
    
    NSString * udt_command  = [NSString stringWithFormat:@"action=command&command=%@", core_command];
    
    udt_command = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)udt_command, NULL,
                                                                      CFSTR(":/?#[]@!$&’()*+,;="),
                                                                      kCFStringEncodingUTF8) ;
    
    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", SEND_CTRL_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", SEND_CTRL_CMD_PARAM_1, mac_];
    http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", SEND_CTRL_CMD_PARAM_2, channelId];
    http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", SEND_CTRL_CMD_PARAM_3,udt_command];
    
	
	NSLog(@"1 send udt query:%@", http_cmd);
    
    
    
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];

        url_connection = [[NSURLConnection alloc] initWithRequest:theRequest
														 delegate:nil //so that it will not call delegate function
												 startImmediately:TRUE];
		

    }
    
   
    
    return TRUE;
    
    
}



#pragma mark - 
#pragma mark Blocked queries


- (NSData *)BMS_getCameraListBlockedWithUser:(NSString *) user_email AndPass:(NSString*) user_pass
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
//    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
//	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_CAM_LIST_CMD];
//	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_CAM_LIST_PARAM_1, user_email];

    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_CAM_LIST4_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_CAM_LIST_PARAM_1, user_email];
	
	//NSLog(@"getCamlist query:%@", http_cmd);
	
 
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
}



- (NSData *)BMS_getCameraSnapshotBlockedWithUser:(NSString *) user_email 
                                         AndPass:(NSString*) user_pass 
                                         macAddr:(NSString *) macWithColon 
{
    NSString * mac_ = [Util strip_colon_fr_mac:macWithColon];
    
    
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_IMG_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_IMG_PARAM_1, mac_];
    
	
	//NSLog(@"getCamlist query:%@", http_cmd);
	
    
	
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
    
}




- (NSData *) BMS_getRelaySecBlockedWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) macWithColon 
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * mac_ = [Util strip_colon_fr_mac:macWithColon];
    
    
    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_RELAY_KEY];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_RELAY_KEY_PARAM_1, mac_];
    
	
	NSLog(@"getRelayS query:%@", http_cmd);
	
    NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }

}

- (NSData *) BMS_sendCmdViaServeBlockedWithUser:(NSString*) user_email 
                                        AndPass:(NSString*) user_pass 
                                        macAddr:(NSString *) macWithColon 
                                        channId:(NSString*) channelId 
                                        command:(NSString *)core_command
{
    
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * mac_ = [Util strip_colon_fr_mac:macWithColon];
    
    
    NSString * udt_command  = [NSString stringWithFormat:@"action=command&command=%@", core_command];
    
    udt_command = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)udt_command, NULL,
                                                                       CFSTR(":/?#[]@!$&’()*+,;="),
                                                                       kCFStringEncodingUTF8) ;
    

    
    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", SEND_CTRL_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", SEND_CTRL_CMD_PARAM_1, mac_];
    http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", SEND_CTRL_CMD_PARAM_2, channelId];
    http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", SEND_CTRL_CMD_PARAM_3,udt_command];
    
	
	NSLog(@"2 send udt query:%@", http_cmd);
    
    

	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
    

    
    
}



- (NSData *) BMS_sendPushRegistrationBlockWithUser:(NSString*) user_email 
                                           AndPass:(NSString*) user_pass 
                                             regId:(NSString *) regId
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
        
    
    NSString * http_cmd1 = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@", PUSH_REG_CMD];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", PUSH_REG_CMD_PARAM_1, user_email];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", PUSH_REG_CMD_PARAM_2, regId];

    
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd1]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
    

}



- (NSData *) BMS_sendPushUnRegistrationBlockWithUser:(NSString*) user_email 
                                             AndPass:(NSString*) user_pass 
                                               regId:(NSString *) regId
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    
    
    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", PUSH_UNREG_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", PUSH_UNREG_CMD_PARAM_1, regId];

    	
	NSLog(@"send unreg query:%@", http_cmd);
    
    
    
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }

}




- (NSData *) BMS_getDisabledAlertBlockWithUser:(NSString*) user_email 
                                           AndPass:(NSString*) user_pass 
                                             regId:(NSString *) regId
                                         ofMac:(NSString *) macWColon
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * _mac = [Util strip_colon_fr_mac:macWColon]; 
    
    NSString * http_cmd1 = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@", GET_DISABLED_ALERTS_CMD];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", GET_DISABLED_ALERTS_CMD_PARAM_1, regId];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", GET_DISABLED_ALERTS_CMD_PARAM_2,_mac ];
    
    
	
	NSLog(@"send query:%@", http_cmd1);
    
    
    
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd1]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
    
    
}




- (NSData *) BMS_enabledAlertBlockWithUser:(NSString*) user_email 
                                   AndPass:(NSString*) user_pass 
                                     regId:(NSString *) regId
                                     ofMac:(NSString *) macWColon
                                 alertType:(NSString *) alertType
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * _mac = [Util strip_colon_fr_mac:macWColon]; 
    
    NSString * http_cmd1 = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@", ENABLE_ALERTS_CMD];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", ENABLE_ALERTS_CMD_PARAM_1, regId];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", ENABLE_ALERTS_CMD_PARAM_2,_mac ];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", ENABLE_ALERTS_CMD_PARAM_3,alertType ];
    
    
	
	NSLog(@"send query:%@", http_cmd1);
    
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd1]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
    
    
}

- (NSData *) BMS_disabledAlertBlockWithUser:(NSString*) user_email 
                                   AndPass:(NSString*) user_pass 
                                     regId:(NSString *) regId
                                     ofMac:(NSString *) macWColon
                                 alertType:(NSString *) alertType
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * _mac = [Util strip_colon_fr_mac:macWColon]; 
    
    NSString * http_cmd1 = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@", DISABLE_ALERTS_CMD];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", DISABLE_ALERTS_CMD_PARAM_1, regId];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", DISABLE_ALERTS_CMD_PARAM_2,_mac ];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", DISABLE_ALERTS_CMD_PARAM_3,alertType ];
    
    
	
	NSLog(@"send query:%@", http_cmd1);
    
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd1]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
    
    
}





- (NSData *) BMS_getDisabledAlertBlockWithUser_1:(NSString*) user_email 
                                       AndPass:(NSString*) user_pass 
                                         ofMac:(NSString *) macWColon
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * _mac = [Util strip_colon_fr_mac:macWColon]; 
    
    NSString * http_cmd1 = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@", GET_DISABLED_ALERTS_U_CMD];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", GET_DISABLED_ALERTS_U_CMD_PARAM_1, user_email];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", GET_DISABLED_ALERTS_U_CMD_PARAM_2,_mac ];
    	
	NSLog(@"send query:%@", http_cmd1);
    
    	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd1]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
    
    
}


- (NSData *) BMS_enabledAlertBlockWithUser_1:(NSString*) user_email 
                                   AndPass:(NSString*) user_pass 
                                     ofMac:(NSString *) macWColon
                                 alertType:(NSString *) alertType
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * _mac = [Util strip_colon_fr_mac:macWColon]; 
    
    NSString * http_cmd1 = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@", ENABLE_ALERTS_U_CMD];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", ENABLE_ALERTS_U_CMD_PARAM_1, user_email];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", ENABLE_ALERTS_U_CMD_PARAM_2,_mac ];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", ENABLE_ALERTS_U_CMD_PARAM_3,alertType ];
    
    
	
	NSLog(@"send query:%@", http_cmd1);
    
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd1]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
    
    
}



- (NSData *) BMS_disabledAlertBlockWithUser_1:(NSString*) user_email 
                                    AndPass:(NSString*) user_pass 
                                      ofMac:(NSString *) macWColon
                                  alertType:(NSString *) alertType
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * _mac = [Util strip_colon_fr_mac:macWColon]; 
    
    NSString * http_cmd1 = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@", DISABLE_ALERTS_U_CMD];
	http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", DISABLE_ALERTS_U_CMD_PARAM_1, user_email];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", DISABLE_ALERTS_U_CMD_PARAM_2,_mac ];
    http_cmd1 = [http_cmd1 stringByAppendingFormat:@"%@%@", DISABLE_ALERTS_U_CMD_PARAM_3,alertType ];
    
    
	
	NSLog(@"send query:%@", http_cmd1);
    
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd1]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest 
                                          returningResponse:&response 
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil; 
    }
    else
    {
        return dataReply; 
    }
    
    
}




- (NSData *)BMS_getStreamModeBlockedWithUser:(NSString *) user_email AndPass:(NSString*) user_pass  macAddr:(NSString *) mac 
{
    
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
      
    NSString * mac_ = [Util strip_colon_fr_mac:mac];
	
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_STREAM_MODE_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_STREAM_MODE_PARAM_1, mac_];
	
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest
                                          returningResponse:&response
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil;
    }
    else
    {
        return dataReply;
    }
}

- (NSData *)BMS_getRemoteStatusBlockedOf:(NSString*) cmd
                                withUser:(NSString *) user_email
                                 andPass:(NSString*) user_pass
                                 macAddr:(NSString *) mac
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * mac_ = [Util strip_colon_fr_mac:mac];
	
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", cmd];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", IS_CAM_AVAILABLE_ONLOAD_CMD_PARAM_1, mac_];
	
	
	//NSLog(@" query:%@", http_cmd);
	
    
	NSString* plain = [NSString stringWithFormat:@"%@:%@",
					   user_email, user_pass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	NSString * portalCred = [NSString base64StringFromData:plainData length:[plainData length]];
	
	
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:20];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
        
        error = nil;
        dataReply = [NSURLConnection sendSynchronousRequest:theRequest
                                          returningResponse:&response
                                                      error:&error];
        
	}
    
    if ( (dataReply == nil)||  (error != nil))
    {
        return nil;
    }
    else
    {
        return dataReply;
    }
}


#pragma mark - 

#pragma mark NSURLConnection Delegate functions
/****** NSURLConnection Delegate functions ******/



- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"did recv auth challenge: %@", challenge);
	
    NSLog(@"user/pass is : %@/%@", basicAuthenUser, basicAuthenPass);

    //REtry ?? or die??
    NSURLCredential * cred =
        [NSURLCredential credentialWithUser:basicAuthenUser
                   password:basicAuthenPass
                persistence:NSURLCredentialPersistenceForSession];
    
    
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{

	httpResponse = (NSHTTPURLResponse*)response;
	
	int responseStatusCode = [httpResponse statusCode];
	

	if (responseStatusCode == 200)
	{

		responseData = [[NSMutableData alloc] init];	
	}
	else {
        
        if ([obj respondsToSelector:selIfFailure])
        {
            [obj performSelector:selIfFailure withObject:httpResponse];
        }
        else
        {
            NSLog(@"Failed to call selIfFailure..silence return");
        }
		
		responseData = nil;
	}

	

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (responseData != nil)
	{
		[responseData appendData:data];
	}
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{

	if (responseData != nil)
	{
		//NSString *txt = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];

		if (self.obj == nil)
        {
            NSLog(@"obj = nil "); 

        }
        if ([self.obj respondsToSelector:selIfSuccess])
        {
            [self.obj performSelector:selIfSuccess withObject:responseData ];
        }
        else
        {
            NSLog(@"Failed to call selIfSuccess..silence return");
        }
		
		
	
	}
	// NSLog(@"connectionDidFinishLoading END "); 
   
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"failed with error: %@", error); 
	
	if ([self.obj respondsToSelector:selIfServerFail])
    {
       [self.obj performSelector:selIfServerFail withObject:nil ];
    }
    else
    {
        NSLog(@"Failed to call selIfServerFail..silence return");
    }
	
	
}



+(NSString*) getLocalizedMessageForError:(int) err
{
    NSString * result = @"Unknown error";
    
    
    switch(err)
    {
            
        case 404:
            result = NSLocalizedStringWithDefaultValue(@"bms_error_404",nil, [NSBundle mainBundle],
                                                       @"Server is temporarily not available", nil);
            break;
        case 601:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_601",nil, [NSBundle mainBundle],
                                                       @"Invalid command passed. Please check the query.", nil);
            break;
        case 602:
            result = NSLocalizedStringWithDefaultValue(@"bms_error_602",nil, [NSBundle mainBundle],
                                                       @"Required parameter(s) are missing.", nil);
            break;
        case 603:
            result = NSLocalizedStringWithDefaultValue(@"bms_error_603",nil, [NSBundle mainBundle],
                                                       @"Length of the parameter is out of expected boundaries.", nil);
            break;
        case 611:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_611",nil, [NSBundle mainBundle],
                                                       @"Camera does not exist.", nil);
            break;
        case 612:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_612",nil, [NSBundle mainBundle],
                                                      @"Unable to communicate with the camera.", nil);
            break;
        case 613:
            result = NSLocalizedStringWithDefaultValue(@"bms_error_613",nil, [NSBundle mainBundle],
                                                       @"Unable to communicate with the camera.", nil);
            break;
        case 614:
            result = NSLocalizedStringWithDefaultValue(@"bms_error_614",nil, [NSBundle mainBundle],
                                                       @"Camera is not ready for streaming", nil);
            break;
        case 621:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_621",nil, [NSBundle mainBundle],
                                                      @"Email Id is not registered.", nil);
            break;
        case 622:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_622",nil, [NSBundle mainBundle],
                                                      @"Email Id registed but not activated.", nil);
            break;
        case 623:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_623",nil, [NSBundle mainBundle],
                                                      @"Email Id is already activated.", nil);
            break;
        case 624:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_624",nil, [NSBundle mainBundle],
                                                      @"Activation failed. Either user is not registered or the activation period is expired. Please register again.", nil);
            break;
        case 625:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_625",nil, [NSBundle mainBundle],
                                                      @"Activation failed. Invalid activation key.", nil);
            break;
        case 626:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_626",nil, [NSBundle mainBundle],
                                                      @"Authentication failed, either Email Id or Password is invalid.", nil);
            break;
        case 627:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_627",nil, [NSBundle mainBundle],
                                                      @"Camera is not associated with any user (email id).", nil);
            break;
        case 628:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_628",nil, [NSBundle mainBundle],
                                                      @"Email is already registered", nil);
            break;
        case 636:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_636",nil, [NSBundle mainBundle],
                                                      @"Username is already registered", nil);
            break;
        case 699:
            result =NSLocalizedStringWithDefaultValue(@"bms_error_699",nil, [NSBundle mainBundle],
                                                      @"Unhandled exception occured, please contact administrator.", nil);
            break;
        default:
            result =[NSString stringWithFormat:
                     NSLocalizedStringWithDefaultValue(@"bms_error_unknown",nil, [NSBundle mainBundle],
                                                       @"Unknown error - %d", nil)
                     , err];
            break;
            
    }
    return result;
    
}

@end
