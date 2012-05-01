//
//  MBP_Streamer.m
//  MBP_ios
//
//  Created by NxComm on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_Streamer.h"
#import "Util.h"
#import "PublicDefine.h"

@implementation MBP_Streamer

@synthesize videoImage, device_ip, device_port;
@synthesize responseData, listenSocket;

- (id) initWithIp:(NSString *) ip andPort:(int) port
{
	self.device_ip = ip;
	self.device_port = port; 
	NSLog(@"init with %@:%d", self.device_ip, self.device_port);
	return self;
	
}
- (void) setVideoView:(UIImageView *) view
{
	self.videoImage = view;
}
- (void) startStreaming
{
	NSLog(@"connect to %@:%d", self.device_ip, self.device_port);
	
	/* adjust resolution :QQVGA*/
	[self performSelectorInBackground:@selector(requestURLSync_bg:) 
						   withObject:[Util getVideoModeURL:0]];
	
	initialFlag = 1;
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];	
	//Non-blocking connect
    [listenSocket connectToHost:self.device_ip 
						 onPort:self.device_port
					withTimeout:3
						  error:nil];
	
}

- (void) receiveData
{

	NSString *getReq = [NSString stringWithFormat:@"%@Authorization: Basic %@\r\n\r\n",
						AIBALL_GET_STREAM_ONLY_REQUEST, [Util getCredentials]];
	NSData *getReqData = [getReq dataUsingEncoding:NSUTF8StringEncoding];
	
	[listenSocket writeData:getReqData withTimeout:2 tag:1];
	[listenSocket readDataWithTimeout:2 tag:1];	
	responseData = [[NSMutableData alloc] init];
}

- (void) stopStreaming
{
	//NSLog(@"stop streaming : %p", listenSocket);
	if(listenSocket != nil) {
		[listenSocket disconnect];
		[listenSocket setDelegate:nil];
		[listenSocket release];
		listenSocket = nil;
	}
	
	if(responseData != nil) {
		[responseData release];
		responseData = nil;
	}
	
	
	initialFlag = 0;
	

	
	
}

- (void) dealloc
{
	[listenSocket release];
	[responseData release];
	[device_ip release];
	[videoImage release];
	[super dealloc];
}


#pragma mark - 
#pragma mark TCP delegate 


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	//NSLog(@"stream only get data");
	[listenSocket readDataWithTimeout:1 tag:tag];
	
	NSString *strBoundary = BOUNDARY_STRING;
	NSData *boundaryString = [strBoundary dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString *strDoubleReturn = @"\r\n\r\n";
	NSData *doubleReturnString = [strDoubleReturn dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableData* buffer;
	
	
	if(initialFlag) {
		
		
		//process data
		NSString* initialResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSRange range = [initialResponse rangeOfString:AUTHENTICATION_ERROR];
		if(range.location != NSNotFound) {
			return;
		}
		[initialResponse release];
		// truncate the http header
		[responseData appendData:data];
		int pos = [Util offsetOfBytes:responseData searchPattern:doubleReturnString];
		if(pos < 0) return;
		
		initialFlag = 0;
		NSRange range0 = {pos + 4, [responseData length] - pos - 4};
		NSData* tmpData = [responseData subdataWithRange:range0];
		
		buffer = [[NSMutableData alloc] init];
		[buffer appendData:tmpData];
	} else {
		buffer = [[NSMutableData alloc] init];
		[buffer appendData:responseData];
		[buffer appendData:data];	
	}
	
	
	
	int length = [buffer length];	
	
	int index = 0;
	int totalOffset = 0;
	
	while(1) {
		NSRange range = {totalOffset, length - totalOffset};
		NSData* ptr = [buffer subdataWithRange:range];
		int endPos = [Util offsetOfBytes:ptr searchPattern:boundaryString];
		
		
		if(endPos >= 0) {
			// there is a match for the end boundary
			// we have the entire data chunk ready
			if(endPos > 0) {
				
				/* Try to find the boundary into the body */
				NSRange range1 = {0, endPos};
				NSData* data = [ptr subdataWithRange:range1];
				int dl = [data length];
			    //Byte* p1 = (Byte*)[data bytes];
				
				index = endPos + [boundaryString length];
				totalOffset += index;
				int startIndex = [Util offsetOfBytes:data searchPattern:doubleReturnString];
				
				/* Start of body in HTTP response
				 - there is nothing else but JPEG image
				 */
				if(startIndex >= 0) {
					NSRange range2 = {startIndex + 4, dl - startIndex - 4};
					NSData* imageData = [data subdataWithRange:range2];
					//---------- UPDATE image in profile---

					[self.videoImage setImage:[UIImage imageWithData:imageData]];
					
				} else {
					/* Looks like we have an empty HTTP response */
					// DO nothing with it for now 
				}
			} else {
				// for initial condition
				// we will skip the boundary
				index = [boundaryString length];
				totalOffset = index;
			}
		} else {
			// no match
			// break the loop and wait for the next data chunk
			[responseData setLength:[ptr length]];
			[responseData setData:ptr];
			//[ptr release];
			break;
		}
	}
	
	[buffer release];
	
	
}


- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"Mini Streamer- connection failed");

	[self.videoImage setImage:[UIImage imageNamed:@"video_error.png"]];
	
	
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	//NSLog(@"Mini Streamer- connected to host: %@", host);
	[self receiveData];
	
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	
}



#pragma mark -
#pragma mark HTTP Request 



- (void ) requestURLSync_bg:(NSString*)url {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	//incase of demo, don't send the request
	
	{
		//NSLog(@"url : %@", url);
		
		/* use a small value of timeout in this case */
		[self requestURLSync:url withTimeOut:IRABOT_HTTP_REQ_TIMEOUT];
	}
	
	[pool release];
}

/* Just use in background only */
- (NSString * ) requestURLSync:(NSString*)url withTimeOut:(NSTimeInterval) timeout 
{
	
	//NSLog(@"send request: %@", url);
	
	NSURLResponse* response;
	NSError* error = nil;
	NSData *dataReply = nil;
	NSString * stringReply = nil;
	
	
	@synchronized(self)
	{
		
		// Create the request.
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:timeout];
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [Util getCredentials]];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		
		
		if (error != nil)
		{
			//NSLog(@"error: %@\n", error);
		}
		else {
			
			// Interpret the response
			stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
			[stringReply autorelease];
		}
		
		
	}
	
	
	return stringReply ;
}




@end
