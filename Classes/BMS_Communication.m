//
//  BMS_Communication.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "BMS_Communication.h"


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

	NSLog(@"login query:%@", http_cmd);
	

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
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_CAM_LIST_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_CAM_LIST_PARAM_1, user_email];

	
	NSLog(@"getCamlist query:%@", http_cmd);
	

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
	
	NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", ADD_CAM_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", ADD_CAM_PARAM_1, user_email];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", ADD_CAM_PARAM_2, user_pass];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", ADD_CAM_PARAM_3, mac_];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", ADD_CAM_PARAM_4, name];
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
	
	
	NSLog(@"getStreamMode query:%@", http_cmd);
	
	
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
#pragma mark - 
#pragma mark Blocked queries


- (NSData *)BMS_getCameraListBlockedWithUser:(NSString *) user_email AndPass:(NSString*) user_pass
{
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", GET_CAM_LIST_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", GET_CAM_LIST_PARAM_1, user_email];
    
	
	NSLog(@"getCamlist query:%@", http_cmd);
	
 
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
    
	
	NSLog(@"getCamlist query:%@", http_cmd);
	
    
	
	
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
                                        command:(NSString *)udt_command
{
    
    NSData * dataReply;
	NSURLResponse * response;
    NSError* error = nil;
    
    NSString * mac_ = [Util strip_colon_fr_mac:macWithColon];
    
    
    NSString * http_cmd = [NSString stringWithFormat:@"%@%@",BMS_PHONESERVICE, BMS_CMD_PART];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@", SEND_CTRL_CMD];
	http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", SEND_CTRL_CMD_PARAM_1, mac_];
    http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", SEND_CTRL_CMD_PARAM_2, channelId];
    http_cmd = [http_cmd stringByAppendingFormat:@"%@%@", SEND_CTRL_CMD_PARAM_3,udt_command];
    
	
	NSLog(@"send udt query:%@", http_cmd);
    
    

	
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

    
	
	NSLog(@"send reg query:%@", http_cmd1);
    
    
    
	
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





#pragma mark - 

#pragma mark NSURLConnection Delegate functions
/****** NSURLConnection Delegate functions ******/



- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"did recv auth challenge: %@", challenge);
	
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
		[obj performSelector:selIfFailure withObject:httpResponse];
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
        
		
		[self.obj performSelector:selIfSuccess withObject:responseData];
		

	
	}
	// NSLog(@"connectionDidFinishLoading END "); 
   
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"failed with error: %@", error); 
	
	
	[self.obj performSelector:selIfServerFail withObject:nil ];
	
}


@end
