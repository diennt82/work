//
//  BMS_Communication.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "BMS_Communication.h"


@implementation BMS_Communication


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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
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
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:BMS_DEFAULT_TIME_OUT];
		
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@",portalCred];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
		
	}
	
	return TRUE;
}


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

		
		
		[obj performSelector:selIfSuccess withObject:responseData];
		

	
	}
	
   
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"failed with error: %@", error); 
	
	
	[obj performSelector:selIfServerFail withObject:nil ];
	
}


@end
