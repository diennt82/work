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
	
	//TODO: check if 3 selectors are present 
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
	
	//TODO: check if 3 selectors are present 
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
	
	//TODO: check if 3 selectors are present 
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
//		
		
		
		[obj performSelector:selIfSuccess withObject:responseData];
		

	
	}
	
   
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"failed with error: %@", error); 
	
	
	[obj performSelector:selIfServerFail withObject:nil ];
	
}


@end
