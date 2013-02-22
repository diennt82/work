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
#import "STUN_Communication.h"

@implementation MBP_Streamer

@synthesize videoImage, device_ip, device_port, remoteViewKey, remoteView;
@synthesize responseData, listenSocket;
@synthesize pcmPlayer;

@synthesize takeSnapshot,recordInProgress;
@synthesize currentZoomLevel, hasStoppedByCaller, communication_mode;
@synthesize local_port;

@synthesize udtSocket;
@synthesize  disableAudio;

@synthesize  recTimeLabel, recTimer;

@synthesize mFrameUpdater,mTempUpdater;
@synthesize  currentOrientation;
@synthesize  streamingChannel;
@synthesize  stillReading;

- (id) initWithIp:(NSString *) ip andPort:(int) port handler:(id<StreamerEventHandler>) handler
{
	[super init];
    
	self.device_ip = ip;
	self.device_port = port;
	//NSLog(@"init with %@:%d", self.device_ip, self.device_port);
	self.remoteView = FALSE;
	self.remoteViewKey = nil;
	self.local_port = 0;
	mHandler = handler;
	hasStoppedByCaller = FALSE;
	disableAudio = NO;
    
	self.streamingChannel = nil;
	self.currentOrientation = UIInterfaceOrientationPortrait;
	return self;
    
}



- (void) dealloc
{
	NSLog(@"Streamer released called");
	[self stopStreaming];
	//[pcmPlayer release];
    
    
	[listenSocket release];
	[responseData release];
	[device_ip release];
    
    
    
	[udtSocket release];
    
    
    
	[recTimer release];
	[streamingChannel  release] ;
	[super dealloc];
}





- (void) setVideoView:(UIImageView *) view
{
	self.videoImage = view;
}

#pragma mark -
#pragma mark  HTTP stream


#pragma mark NSURLConnection Delegate functions
/****** NSURLConnection Delegate functions ******/



- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"did recv auth challenge: %@", challenge);
	
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    //	NSLog(@"did recv response");
	int statusCode = [((NSHTTPURLResponse*) response) statusCode];
	NSLog(@"did recv response: code: %d", statusCode);
    
    
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
	//NSLog(@"response: %@", txt);
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"failed with error: %@", error);
    
}



- (void) startStreaming
{
	NSLog(@"connect to %@:%d", self.device_ip, self.device_port);
    
	/**** REset some variables */
    
	reconnectLimits = 3;
    
	takeSnapshot = NO;
	if (recordInProgress == YES)
	{
		[self stopRecording];
	}
	recordInProgress = NO;
    
	self.currentZoomLevel = 5.0;
    
    
    
    //Connection test
    if (self.remoteView == TRUE && self.remoteViewKey != nil)
    {
        
        NSError* error= nil;
        NSHTTPURLResponse * response = nil;
        NSString * http_cmd = [NSString stringWithFormat:@"http://%@:%d/?%@%@%@",
                               self.device_ip, self.device_port,
                               AVSTREAM_UDT_REQ,AVSTREAM_PARAM_1, self.remoteViewKey];
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
															timeoutInterval:DEFAULT_TIME_OUT];
        [theRequest setHTTPMethod:@"GET"];
        
        NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [Util getDFCredentials]];
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        
        NSString * body = [[NSString alloc] initWithData:theRequest.HTTPBody encoding:NSUTF8StringEncoding ];
        
        NSLog(@"Test POST  cmd: %@", body);
        
        body  =  [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:http_cmd] encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"body 2 : %@, err:%d", body, [error code]);
   
#if 0
        //use delegate funcs
        [[NSURLConnection alloc] initWithRequest:theRequest
                                        delegate:self
                                startImmediately:TRUE];

#else

        NSData * dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
        
        
        NSLog(@"status code: %d",  [response statusCode]);
        NSString *myString = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
        
        NSLog(@"reply: %@", myString);
        
        //if (response != nil)
        {
            
            int statusCode = [(NSHTTPURLResponse*) response statusCode];
            
            if ( (statusCode == 401) || (statusCode == 601) )
            {
                NSLog(@"get status 401 or 601 -->>>>>>");
                [mHandler statusReport:REMOTE_STREAM_SSKEY_MISMATCH andObj:nil];
                
                return;
                
            }
            
        }
    
        
        
        
#endif 
        
    }

    

	initialFlag = 1;
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
	//Non-blocking connect
	[listenSocket connectToHost:self.device_ip
                         onPort:self.device_port
                    withTimeout:5
                          error:nil];
    
}
//same as startStreaming for now, however may change later.. keep it separate.
-(void) reConnect
{
    
	//stop streaming first
	[self stopStreaming];
    
	NSLog(@"reConnect .. to camera: %@:%d",self.device_ip, self.device_port );
	/**** REset some variables */
	takeSnapshot = NO;
	if (recordInProgress == YES)
	{
		[self stopRecording];
	}
	recordInProgress = NO;
    
	self.currentZoomLevel = 5.0;
    
    
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
    

    //
    //	NSString *getReq = [NSString stringWithFormat:@"%@Authorization: Basic %@\r\n\r\n", AIBALL_GET_REQUEST, [Util getCredentials]];
    
    //GET /?action=appletvastream HTTP/1.1\r\nAuthorization: Basic xxxxx\r\n\r\n    
	NSString *getReq = [NSString stringWithFormat:@"%@%@\r\n",
                        AVSTREAM_REQUEST,
                        AVSTREAM_PARAM_2 ];
	if (self.remoteView == TRUE && self.remoteViewKey != nil)
	{
		getReq = [NSString stringWithFormat:@"%@%@%@%@\r\n",
                  AVSTREAM_REQUEST, AVSTREAM_PARAM_1,self.remoteViewKey,
                  AVSTREAM_PARAM_2 ];
	}
    
    //Attach Basic authen:
    getReq = [getReq stringByAppendingFormat:@"Authorization: Basic %@\r\n\r\n",[Util getDFCredentials] ];
    
    
	NSLog(@"getReq: %@", getReq);
    
	NSData *getReqData = [getReq dataUsingEncoding:NSUTF8StringEncoding];
    
    
       
    
	[listenSocket writeData:getReqData withTimeout:2 tag:1];
	[listenSocket readDataWithTimeout:5.0 tag:1];
	responseData = [[NSMutableData alloc] init];
    
	if ( pcmPlayer == nil)
	{
		/* Start the player to playback & record */
		pcmPlayer = [[PCMPlayer alloc] init];
		[[pcmPlayer player] setPlay_now:FALSE];
		[pcmPlayer Play:FALSE];
        
	}
	else {
		[[pcmPlayer player] setPlay_now:FALSE];
        
	}
}

- (void) stopStreaming
{
	if (self.videoImage != nil)
	{
        UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (infOrientation == UIInterfaceOrientationLandscapeLeft || infOrientation == UIInterfaceOrientationLandscapeRight)
        {
            [self.videoImage setImage:[UIImage imageNamed:@"homepage.png"]];
        }
        else if (infOrientation == UIInterfaceOrientationPortrait || infOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self.videoImage setImage:[UIImage imageNamed:@"homepage_p.png"]];
        }
	}
    
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
    
    
    
    
	if (pcmPlayer != nil)
	{
		/* kill the audio player */
		[[pcmPlayer player] setPlay_now:FALSE];
		[pcmPlayer Stop];
		[pcmPlayer release];
		pcmPlayer = nil;
	}
    
    
    
	if (udtStreamerThd != nil)
	{
		if ([udtStreamerThd isExecuting])
		{
			NSLog(@"streamerThrd is running --stop it now");
			[udtStreamerThd cancel];
            
            
//            int waitCount = 5; //5sec
//            while (![udtStreamerThd isFinished] && (waitCount -- > 0) )
//            {
//                [NSThread sleepForTimeInterval:1.0];
//                NSLog(@"streamer wait %d ", waitCount); 
//            }
            
            
            //udtStreamerThd = nil;
		}
        
		if (readTimeoutThrd!= nil && [readTimeoutThrd isExecuting])
		{
			NSLog(@"readTimeoutThrd is running --stop it now");
			[readTimeoutThrd cancel];
            
            
//            int waitCount = 5; //5sec
//            while ([readTimeoutThrd isExecuting] && (waitCount -- > 0) )
//            {
//                [NSThread sleepForTimeInterval:1.0];
//                NSLog(@"readTO wait %d ", waitCount); 
//            }
            
            //readTimeoutThrd = nil;
		}
        
        
        
		NSString * msg = nil;
		msg = [NSString stringWithFormat:@"%@%@",
               STUN_CMD_PART, CLOSE_STUN_SESSION];
		NSData * msg_ = [[NSData alloc] initWithBytes:[msg UTF8String] length:[msg length]];
        
        
		if ([udtSocket isOpen])
		{
			NSLog(@"Send close session.. & close sock");
			[udtSocket sendDataViaUdt:msg_];
			[udtSocket close];
		}
		else {
			NSLog(@"udtSocket already close -- ");
		}
        
        
	}
    
}

#pragma mark -
#pragma mark  UDT stream

/* called from background thread*/
-(void) updateImage:(UIImage *) img
{
    [self.videoImage setImage:img];
    
    
}

-(void) switchToUdtRelayServer
{
    //TODO signal cameraview to change message..

    [mHandler statusReport:SWITCHING_TO_RELAY_SERVER andObj:nil];
    
#if 1
    //BG
    [self performSelectorInBackground:@selector(tryConnectingToStunRelay_bg:) withObject:self.streamingChannel];
    
    
#else
	RemoteConnection * relayConn = [[RemoteConnection alloc]init];
    
	if (streamingChannel == nil)
	{
		NSLog(@"Streaming channel is NIL in RELAY mode ... ERROR");
		return;
	}
	self.udtSocket= [relayConn connectToUDTRelay:self.streamingChannel];
#endif
    
}
-(void) tryConnectingToStunRelay_bg:(CamChannel *) mChannel 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    NSLog(@"[BG thread] tryConnectingToStunRelay_bg"); 
    
    RemoteConnection * relayConn = [[RemoteConnection alloc]init];
    
	if (streamingChannel == nil)
	{
		NSLog(@"Streaming channel is NIL in RELAY mode ... ERROR");
		return;
	}
    UdtSocketWrapper * udtSocket_ =[relayConn connectToUDTRelay:mChannel];
    
    [self performSelectorOnMainThread:@selector(connectedToStunRelay:)
                           withObject:udtSocket_ waitUntilDone:NO];
     NSLog(@"[BG thread] tryConnectingToStunRelay_bg DONE");
    [pool drain];
    
}

-(void) connectedToStunRelay:(UdtSocketWrapper * ) socket
{
    self.udtSocket = socket;

	if (self.udtSocket == nil)
	{
		NSLog(@"Fail to open relay socket ");
        
		[self sendStatusStoppedWithErrOnMainThread:nil];
		return;
	}
	responseData = [[NSMutableData alloc] init];
    
	if ( pcmPlayer == nil)
	{
		/* Start the player to playback & record */
		pcmPlayer = [[PCMPlayer alloc] init];
		[[pcmPlayer player] setPlay_now:FALSE];
		[pcmPlayer Play:FALSE];
        
	}
	else {
		[[pcmPlayer player] setPlay_now:FALSE];
        
	}
    
   
    
    
    [self performSelectorOnMainThread:@selector(sendStatusConnectedReportOnMainThread:)
                           withObject:nil
                        waitUntilDone:YES];
    
    
	NSLog(@"Streaming channel in RELAY mode ... Starting");
    
    
    
    
    
	readTimeoutThrd = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(readTimeoutCheck:)
                                                object:self];
    
	[readTimeoutThrd start];
    
    
    
	udtStreamerThd = [[NSThread alloc] initWithTarget:self
                                             selector:@selector(readVideoDataFromSocket:)
                                               object:self];
    
	[udtStreamerThd start];
    
    
    
#if 1
    
    NSLog(@"keepAliveThrd starting..  ");
    
	NSThread * keepAliveThrd = [[NSThread alloc] initWithTarget:self
                                                       selector:@selector(keepAlive:)
                                                         object:self];
    
	[keepAliveThrd start];
#endif ///TODO check wth servers
    

}

- (void) startUdtStream
{
    
    
	/**** REset some variables */
    
	reconnectLimits = 3;
    
	takeSnapshot = NO;
	if (recordInProgress == YES)
	{
		[self stopRecording];
	}
	recordInProgress = NO;
	self.currentZoomLevel = 5.0;
    
	initialFlag = 1;
    
	udtSocket = [[UdtSocketWrapper alloc]initWithLocalPort:self.local_port];
	[udtSocket createUdtStreamSocket];
        
	
    responseData = [[NSMutableData alloc] init];
    
    [self performSelectorInBackground:@selector(tryConnectToUDT_bg:) withObject:udtSocket];
}


-(void) tryConnectToUDT_bg:(UdtSocketWrapper*) udtSocket_
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    int localPort = -1 ;
    
	struct in_addr * server_ip = [UdtSocketWrapper getIpfromHostName:self.device_ip];

    
#if 0 //DBG only
    NSLog(@"[BG thread] Debug 601 error "); 
    server_ip = [UdtSocketWrapper getIpfromHostName:@"192.168.1.101"];
    
    self.device_port = 2345;
    
#endif
    
	NSLog(@"[BG thread] tryConnectToUDT_bg: connect to %@:%d from localport: %d server_ip:%d",
          self.device_ip, self.device_port ,
          self.local_port, server_ip->s_addr);

    
    
	NSDate * now = [NSDate date];
	NSDate * timeout = [NSDate dateWithTimeInterval:25.0 sinceDate:now];
	//The receiver is earlier in time than anotherDate, NSOrderedAscending.
	while ([now compare:timeout] ==   NSOrderedAscending)
	{
     

		localPort = [udtSocket_ connectViaUdtSock:server_ip
                                            port:self.device_port];


		NSLog(@"[BG thread] tryConnectToUDT_bg: localPort = %d", localPort);
		if (localPort > 0)
		{
			break;
		}
        
        //If it is cancelled
        if (streamingChannel.stopStreaming == TRUE)
        {
            break; 
        }
        
		now = [NSDate date];
        
	}
    NSNumber* localPort_ = [NSNumber numberWithInt:localPort];
   
    [self performSelectorOnMainThread:@selector(connectedToUDTPort:) withObject:localPort_ waitUntilDone:NO];
    
    [pool drain];
    
}

-(void) connectedToUDTPort:(NSNumber*) localPort_
{

    
    //If it is cancelled
    if (streamingChannel.stopStreaming == TRUE)
    {
        NSLog(@"connectedToUDTPort but user canceled");
        return; 
    }
    
    int localPort = [localPort_ integerValue] ;
    
    if (localPort < 0 ) ///// STUN RELAY /////////
	{
        
		//Still fail after retries --- Go for relay now
		NSLog(@"RELAY RELAY RELAY");
		[self switchToUdtRelayServer ];
		return;
	}
	else ///// STUN direct /////////
    {
       
        if (local_port != localPort)
        {
            NSLog(@"connecting port is different from localport: %d %d", local_port, localPort);
        }
        NSString * msg = nil;
        msg = [NSString stringWithFormat:@"%@%@%@",
               AVSTREAM_UDT_REQ, AVSTREAM_PARAM_1,self.remoteViewKey];
        NSData * msg_ = [[NSData alloc] initWithBytes:[msg UTF8String] length:[msg length]];
        
        [udtSocket sendDataViaUdt:msg_];
   
#pragma mark FORCE RELAY
#if 0

        //sleep for 5 sec 
        [NSThread sleepForTimeInterval:5.0];
        msg = [NSString stringWithFormat:@"%@%@",
               STUN_CMD_PART, CLOSE_STUN_SESSION];
        msg_ = [[NSData alloc] initWithBytes:[msg UTF8String] length:[msg length]];
        
        
        if ([udtSocket isOpen])
        {
            [udtSocket sendDataViaUdt:msg_];
            [udtSocket close];
        }
        
        NSLog(@"Force  RELAY");
		[self switchToUdtRelayServer ];

        
#else
        
        
        
        if ( pcmPlayer == nil)
        {
            /* Start the player to playback & record */
            pcmPlayer = [[PCMPlayer alloc] init];
            [[pcmPlayer player] setPlay_now:FALSE];
            [pcmPlayer Play:FALSE];
            
        }
        else {
            [[pcmPlayer player] setPlay_now:FALSE];
            
        }
        
        [self performSelectorOnMainThread:@selector(sendStatusConnectedReportOnMainThread:)
                               withObject:nil
                            waitUntilDone:YES];
        
        
        
        readTimeoutThrd = [[NSThread alloc] initWithTarget:self
                                                  selector:@selector(readTimeoutCheck:)
                                                    object:self];
        
        [readTimeoutThrd start];
        
        udtStreamerThd = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(readVideoDataFromSocket:)
                                                   object:self];
        
        [udtStreamerThd start];
#endif 
        
    }
    
    
}


-(void) sendStatusConnectedReportOnMainThread:(NSObject *) obj
{
	[mHandler statusReport:CONNECTED_TO_CAMERA andObj:obj];
    
}

-(void) sendStatusStartedReportOnMainThread:(NSObject *) obj
{
	[mHandler statusReport:STREAM_STARTED andObj:obj];
    
}

- (void) sendStatusStoppedWithErrOnMainThread:(NSObject *) obj
{
	[mHandler statusReport:REMOTE_STREAM_STOPPED_UNEXPECTEDLY andObj:obj];
}

- (void) sendStatusSSkeyErrorOnMainThread:(NSObject *) obj
{
	[mHandler statusReport:REMOTE_STREAM_SSKEY_MISMATCH andObj:obj];
}

-(void) sendStatusStoppedReportOnMainThread:(NSObject *) obj
{
	[mHandler statusReport:STREAM_STOPPED andObj:obj];
}

-(BOOL) isSskeyMismatch: (NSMutableData *) data len:(int) data_len
{
    NSRange range = {0, data_len};
    NSData * myData = [data subdataWithRange:range];
    
    
    NSString *myString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    
    if ( [myString hasPrefix:@"401" ] ||
         [myString hasPrefix:@"601"])
    {
        return TRUE;
    }
    
    return FALSE; 
    
}


#define READ_16K_DATA 16*1024

-(void) readVideoDataFromSocket:(MBP_Streamer *) streamer
{
	NSLog(@"STUN Main readVideoDataFromSocket enter: 01");
    
	UdtSocketWrapper * socket = streamer.udtSocket;//grap the opened socket
    
	NSString *strBoundary = BOUNDARY_STRING;
	NSData *boundaryString = [strBoundary dataUsingEncoding:NSUTF8StringEncoding];
    
	NSString *strDoubleReturn = @"\r\n\r\n";
	NSData *doubleReturnString = [strDoubleReturn dataUsingEncoding:NSUTF8StringEncoding];
    
    
	NSMutableData* data, *buffer;
	int bytesRead = -1;
    NSData* ptr;
    BOOL firstSuccessRead = FALSE; 
    
    
	data = [[NSMutableData alloc]initWithLength:READ_16K_DATA]; //16k
    
	
    
	BOOL exitedUnexpectedly = FALSE;
	int ignore_err_count = 4; // ~20 sec
	//while (i -- >=0)
	while (![[NSThread currentThread] isCancelled])
	{
        
        
		if (streamer.streamingChannel.stopStreaming == TRUE)
		{
			break;
		}
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        
		//read
		bytesRead = [socket recvDataViaUdt:data dataLen:READ_16K_DATA];
		if (bytesRead <0)
		{
			NSLog(@"bytesRead:%d ignoreCount:%d", bytesRead, ignore_err_count);
			if (ignore_err_count -- < 0)
			{
                
				exitedUnexpectedly = TRUE;
				//STream has stopped due to some connection error
				[self performSelectorOnMainThread:@selector(sendStatusStoppedWithErrOnMainThread:)
                                       withObject:nil
                                    waitUntilDone:YES];
                
				break;
			}
			else
			{
				//return to read again
				[NSThread sleepForTimeInterval:1.0];
				continue;
			}
            
            
            
		}
        
        if (firstSuccessRead == FALSE)
        {
            [self performSelectorOnMainThread:@selector(sendStatusStartedReportOnMainThread:)
                                   withObject:nil
                                waitUntilDone:YES];
            firstSuccessRead = TRUE;
        }
        
        if ([self isSskeyMismatch:data len:bytesRead])
        {
            NSLog(@"aaa sskey mismatch"); 
            [self performSelectorOnMainThread:@selector(sendStatusSSkeyErrorOnMainThread:)
                                   withObject:nil
                                waitUntilDone:YES];
            break; 
        }
        
        
        
        
		//Kick this timeout
		streamer.stillReading = TRUE;
        
		//Refresh
		ignore_err_count = 4;
        
		if ( bytesRead > READ_16K_DATA)
		{
			continue;
		}
		[data setLength:bytesRead];
        
        
        
        
        //NSLog(@"bytesRead:%d initialFlag: %d, res_len: %d",bytesRead, initialFlag, [responseData length]);

        
		//NSRange dbg_range = {0, 22};
		//		NSData * dbg_data = [data subdataWithRange:dbg_range];
		//		NSString * raw_data = [[[NSString alloc] initWithData:dbg_data encoding: NSUTF8StringEncoding] autorelease];
		//		NSLog(@"rawdata :%@", raw_data);
        
		if(initialFlag) {
            
			// truncate the http header
			[responseData appendData:data];
			int pos = [Util offsetOfBytes:responseData searchPattern:doubleReturnString];
			if(pos < 0)
			{
				NSLog(@"pos <0");
				continue;
                
			}
            
			initialFlag = 0;
			NSRange range0 = {pos + 4, [responseData length] - pos - 4};
			NSData* tmpData = [responseData subdataWithRange:range0];
            
			buffer = [[NSMutableData alloc] init];
			[buffer appendData:tmpData];
            
		}
        else
        {
            
            
            
			buffer = [[NSMutableData alloc] init];
			[buffer appendData:responseData];
			[buffer appendData:data];
		}
        
        
        

        
		int length = [buffer length];
        
		int index = 0;
		int totalOffset = 0;
        
        
		while(1) {
			NSRange range = {totalOffset, length - totalOffset};
			ptr = [buffer subdataWithRange:range];
			int endPos = [Util offsetOfBytes:ptr searchPattern:boundaryString];
			//NSLog(@"endPos=%d", endPos);
            
    
            
            
			if(endPos >= 0) {
				// there is a match for the end boundary
				// we have the entire data chunk ready
#if 1 // DEBUG MEM ALLOC LEAK
                
				if(endPos > 0) {
                    
                    index = endPos + [boundaryString length];
					totalOffset += index;
                    
                    
					/* Try to find the boundary into the body */
					NSRange range1 = {0, endPos};
					NSData* data_1 = [ptr subdataWithRange:range1];
					int dl = [data_1 length];
					//Byte* p1 = (Byte*)[data bytes];
                    
                    
					int startIndex = [Util offsetOfBytes:data_1 searchPattern:doubleReturnString];
                    
					/* Start of body in HTTP response
                     
					 */
					if(startIndex >= 0) {
                        
						NSRange range2 = {startIndex + 4, dl - startIndex - 4};
						NSData* actualData = [data_1 subdataWithRange:range2];
						Byte* actualDataPtr = (Byte*)[actualData bytes];
						int audioLength = (actualDataPtr[1] << 24) + (actualDataPtr[2] << 16) + (actualDataPtr[3] << 8) + actualDataPtr[4];
						int imageIndex = (actualDataPtr[5] << 24) + (actualDataPtr[6] << 16) + (actualDataPtr[7] << 8) + actualDataPtr[8];
                        
                        
                        
						Byte resetAudioBufferCount = actualDataPtr[10];
						int temperature = (actualDataPtr[11]<<24) | (actualDataPtr[12]<<16) |
                        (actualDataPtr[13]<<8 )|   actualDataPtr[14];
                        
						//Update temperature
						if (self.mTempUpdater != nil)
						{
							[self.mTempUpdater updateTemperature:temperature];
						}
                        
						int avdata_offset = 10 + 4 + 1 ; //old data + temperature + 1
                        
                        
                        
#if defined(IBALL_AUDIO_SUPPORT	)
						if( (disableAudio == NO) &&  audioLength > 0 )
						{
							NSRange range3 = {avdata_offset, audioLength};
							NSData* audioData = [actualData subdataWithRange:range3];
#ifdef IRABOT_PCM_AUDIO_SUPPORT
							NSData* decodedPCM = audioData;
                            
#else
							NSMutableData* decodedPCM = [[NSMutableData alloc] init];
							[ADPCMDecoder Decode:audioData outData:decodedPCM];
#endif
                            
                            
							if(self.recordInProgress)
							{
								[iRecorder GetAudio:decodedPCM resetAudioBufferCount:resetAudioBufferCount];
							}
                            
                            
							[self performSelectorOnMainThread:@selector(PlayPCM:)
                                                   withObject:decodedPCM
                                                waitUntilDone:YES];
							//[self PlayPCM:decodedPCM];
                            
#if !defined(IRABOT_PCM_AUDIO_SUPPORT)
							[decodedPCM release];
#endif
                            //[audioData release];
                            
                            
						}
#endif /* IBALL_AUDIO_SUPPORT */
                        
                        
                      
                        
						NSRange range4 = {avdata_offset + audioLength,
							[actualData length] - avdata_offset - audioLength};
						NSData* imageData =  [actualData subdataWithRange:range4];
                        
                                     
						UIImage *image = [UIImage imageWithData:imageData];
#if 1
                        image = [self adaptToCurrentOrientation:image];
                    
						if (self.currentZoomLevel < 5.0f)
						{
                            //currentZoomLevel = 1,2,3,4.. smaller means more magnified
                            
                            CGFloat newDeltaWidth =   image.size.width*( self.currentZoomLevel*0.1);
                            CGFloat newDeltaHeight =  image.size.height*( self.currentZoomLevel*0.1);
                            CGRect newRect = CGRectZero;
                            newRect.origin.x = - newDeltaWidth/2;
                            newRect.origin.y = - newDeltaHeight/2;
                            
                            newRect.size.width =  image.size.width +newDeltaWidth;
                            newRect.size.height = image.size.height +newDeltaHeight;
                            
                            //NSLog(@"newsize :%f, %f %f %f", newRect.size.width, newRect.size.height,
                            //	 newDeltaWidth, newDeltaHeight);
                            image = [self imageWithImage:image scaledToRect:newRect];
                            
						}
                        
                        //NSLog(@"post image to image view <0");
                        
						
                        
                        [self performSelectorOnMainThread:@selector(updateImage:) withObject:image waitUntilDone:YES];
                        
                        
                        
						//[streamer.videoImage setImage:[UIImage imageWithData:imageData]];
                        
                        
						if (self.takeSnapshot == YES)
						{
							[self saveSnapShot:image];
							self.takeSnapshot = NO;
						}
                        
                        
                        
						if (self.recordInProgress == YES)
						{
                            
							[iRecorder GetImage:imageData imgIndex:imageIndex];
							if([iRecorder GetCurrentRecordSize] >= iMaxRecordSize) {
								[self stopRecording];
								//[self startRecording];
							}
                            
						}
#else
                        NSLog(@"Do post image"); 
                        
#endif
                    

                        //[image release];
						
                        //[imageData release];
                        
                        //[actualData release];
                        
					}
					else
                    {
                        
						NSLog(@"startindex <0");
						/* Looks like we have an empty HTTP response */
						// DO nothing with it for now
					}
                    
                    
                    
                    
                    //[data_1 release];
				}
                else // endPos == 0
                {
					// for initial condition
					// we will skip the boundary
					index = [boundaryString length];
					totalOffset = index;
				}
#else
                index = endPos + [boundaryString length];
                totalOffset += index;             
#endif
              
			}
			else //endPos < 0
			{
				// no match
				// break the loop and wait for the next data chunk
				[responseData setLength:[ptr length]];
				[responseData setData:ptr];
                
                //NSLog(@"response data len: %d", [responseData length]);
               
                
                
				break;
			}
            
            
            
            
		} //while (1)
  
  
        
		[buffer release];
        
        
        [pool drain];

        
	} //While (thread is running)
    
    
	if (!exitedUnexpectedly)
	{
		[self performSelectorOnMainThread:@selector(sendStatusStoppedReportOnMainThread:)
                               withObject:nil
                            waitUntilDone:YES];
	}
    
	NSLog(@"STUN Main readVideoDataFromSocket exit");
    
    [data release];
    
        
	//arrive here -- means exit
	[NSThread exit];
}



-(void) readTimeoutCheck:(MBP_Streamer *) streamer
{
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UdtSocketWrapper * socket = streamer.udtSocket;//grap the opened socket
    
	NSLog(@"readTimeoutCheck enter: 01");
    
	while ([socket isOpen]) //This check is not really effective??
	{
        
		[NSThread sleepForTimeInterval:10.0];
        
		if (streamer.stillReading == FALSE)
		{
			if (socket != nil && [socket isOpen])
			{
				NSLog(@"readTimeoutCheck: TIMEOUT! close sock");
				[socket close];
				break;
			}
		}
		else
		{
			streamer.stillReading = FALSE;
		}
	}
    
    
    
	NSLog(@"readTimeoutCheck exit: 01");
    
    
    
	[pool drain];
	//arrive here -- means exit
	[NSThread exit];
    
}
-(void) keepAlive:(MBP_Streamer *) streamer
{
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSLog(@"keepAlive enter: 01");
    
	UdtSocketWrapper * socket = streamer.udtSocket;//grap the opened socket
    
	NSString * hello = @"hello";
	int count = 1, data_sent  = -1 ;
	NSString * hello_msg;
	while ([socket isOpen])
	{
		hello_msg = [hello stringByAppendingFormat:@"%d", count];
		count ++;
        
        NSData * data = [hello_msg dataUsingEncoding:NSUTF8StringEncoding];
        data_sent = [socket sendDataViaUdt: data ];
        
		//NSLog(@"sent: %@ datasent:%d", hello_msg, data_sent);
        
		//there is no way to check wether socket is opened -- simply to send data thru it .. if error -assume it's closed
		if (data_sent <0)
		{
			break;
		}
        
		[NSThread sleepForTimeInterval:1.5];
	}
    
	NSLog(@"keepAlive exit: 01");
    
    
    
	[pool drain];
	//arrive here -- means exit
	[NSThread exit];
    
}

#pragma mark -
#pragma mark Audio Playback

- (void) PlayPCM:(NSData*)pcm
{
    
	//Start play back
	[[pcmPlayer player] setPlay_now:TRUE];
    
	[pcmPlayer WritePCM:(unsigned char *)[pcm bytes] length:[pcm length]];
}



#pragma mark -
#pragma mark TCP delegate


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
	[mHandler statusReport:STREAM_STARTED andObj:nil];
    
	
	[listenSocket readDataWithTimeout:10.0 tag:tag];
    
	NSString *strBoundary = BOUNDARY_STRING;
	NSData *boundaryString = [strBoundary dataUsingEncoding:NSUTF8StringEncoding];
    
	NSString *strDoubleReturn = @"\r\n\r\n";
	NSData *doubleReturnString = [strDoubleReturn dataUsingEncoding:NSUTF8StringEncoding];
    
	NSMutableData* buffer;
    
    
	if(initialFlag) {
        
        
		//process data
		NSString* initialResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSRange range = [initialResponse rangeOfString:AUTHENTICATION_ERROR];
        
        if (initialResponse == nil)
        {
            
             NSLog(@"initialResponse = nil... ");
            
        }
        
		if( (initialResponse!= nil) &&
            (range.location != NSNotFound)
           )
		{
            // auth error ->>>>>>> force re-connect
            NSLog(@"auth ERROR-- stop streaming ");
            
            NSLog(@"error response: %@", initialResponse); 
            [self stopStreaming];
            
            if (self.remoteView == TRUE && self.remoteViewKey != nil)
            {
               [mHandler statusReport:REMOTE_STREAM_SSKEY_MISMATCH andObj:nil];
            }
            else
            {
                [mHandler statusReport:STREAM_STOPPED_UNEXPECTEDLY andObj:nil];
            }

			return;
		}
		[initialResponse release];
        
		// truncate the http header
		[responseData appendData:data];
		int pos = [Util offsetOfBytes:responseData searchPattern:doubleReturnString];
		if(pos < 0) {
            NSLog(@"pos < 0 ");
            return;
        }
    
		initialFlag = 0;
		NSRange range0 = {pos + 4, [responseData length] - pos - 4};
		NSData* tmpData = [responseData subdataWithRange:range0];
        
		buffer = [[NSMutableData alloc] init];
		[buffer appendData:tmpData];
	}
	else
	{
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
                 
				 */
				if(startIndex >= 0) {
                    
					NSRange range2 = {startIndex + 4, dl - startIndex - 4};
					NSData* actualData = [data subdataWithRange:range2];
					Byte* actualDataPtr = (Byte*)[actualData bytes];
					int audioLength = (actualDataPtr[1] << 24) + (actualDataPtr[2] << 16) + (actualDataPtr[3] << 8) + actualDataPtr[4];
					int imageIndex = (actualDataPtr[5] << 24) + (actualDataPtr[6] << 16) + (actualDataPtr[7] << 8) + actualDataPtr[8];
                    
                    
                    
					Byte resetAudioBufferCount = actualDataPtr[10];
					int temperature = (actualDataPtr[11]<<24) | (actualDataPtr[12]<<16) |
                    (actualDataPtr[13]<<8 )|   actualDataPtr[14];
                    
					//Update temperature
					if (self.mTempUpdater != nil)
					{
						[self.mTempUpdater updateTemperature:temperature];
					}
                    
                    
					int avdata_offset = 10 + 4 + 1 ; //old data + temperature + 1
                    
                    
                    
#ifdef IBALL_AUDIO_SUPPORT
					if( (disableAudio == NO) && audioLength > 0 )
					{
						NSRange range3 = {avdata_offset, audioLength};
						NSData* audioData = [actualData subdataWithRange:range3];
#ifdef IRABOT_PCM_AUDIO_SUPPORT
						NSData* decodedPCM = audioData;
                        
#else
						NSMutableData* decodedPCM = [[NSMutableData alloc] init];
						[ADPCMDecoder Decode:audioData outData:decodedPCM];
#endif
                        
                        
						if(self.recordInProgress)
						{
							[iRecorder GetAudio:decodedPCM resetAudioBufferCount:resetAudioBufferCount];
						}
						//NSLog(@"decoded audio len: %d", [decodedPCM length]);
                        
                        
						[self PlayPCM:decodedPCM];
                        
#if !defined(IRABOT_PCM_AUDIO_SUPPORT)
						[decodedPCM release];
#endif
                        
                        
                        
					}
#endif /* IBALL_AUDIO_SUPPORT */
                    
					NSRange range4 = {avdata_offset + audioLength,
						[actualData length] - avdata_offset - audioLength};
					NSData* imageData = [actualData subdataWithRange:range4];
					UIImage *image = [UIImage imageWithData:imageData];
                    
                    
					image = [self adaptToCurrentOrientation:image];
                    
					if (self.currentZoomLevel < 5.0f)
					{
						//currentZoomLevel = 1,2,3,4.. smaller means more magnified
                        
						CGFloat newDeltaWidth =   image.size.width*( self.currentZoomLevel*0.1);
						CGFloat newDeltaHeight =  image.size.height*( self.currentZoomLevel*0.1);
						CGRect newRect = CGRectZero;
						newRect.origin.x = - newDeltaWidth/2;
						newRect.origin.y = - newDeltaHeight/2;
                        
						newRect.size.width =  image.size.width +newDeltaWidth;
						newRect.size.height = image.size.height +newDeltaHeight;
                        
						//NSLog(@"newsize :%f, %f %f %f", newRect.size.width, newRect.size.height,
						//	 newDeltaWidth, newDeltaHeight);
						image = [self imageWithImage:image scaledToRect:newRect];
                        
					}
                    
                    //NSLog(@"setVideo Image" );
					[self.videoImage setImage:image];
                    
					//[self.videoImage setImage:[UIImage imageWithData:imageData]];
                    
                    
					if (self.takeSnapshot == YES)
					{
						[self saveSnapShot:image];
						self.takeSnapshot = NO;
					}
                    
                    
                    
					if (self.recordInProgress == YES)
					{
                        
						[iRecorder GetImage:imageData imgIndex:imageIndex];
						if([iRecorder GetCurrentRecordSize] >= iMaxRecordSize) {
							[self stopRecording];
							//[self startRecording];
						}
                        
					}
                    
                    
					//[actualData release];
				}
				else {
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
	NSLog(@"Streamer- connection failed with error:%d:%@" ,
          [err code], err);
    

	[self.videoImage setImage:[UIImage imageNamed:@"homepage.png"]];
    
    
    //Check for session key mismatch
    if ([err code] == 401 ||
        [err code] == 601 )
    {
        NSLog(@"Streamer- sskey mismatch");
        [mHandler statusReport:REMOTE_STREAM_SSKEY_MISMATCH andObj:nil];
        return;
    }
    
    
	if (hasStoppedByCaller == TRUE)
	{
		//simply return
		return;
	}
    
	NSLog(@"Streamer- AsyncSocketReadTimeoutError");
	reconnectLimits --;
	if (reconnectLimits  > 0)
	{
		[self reConnect];
	}
    
    
	if (reconnectLimits <=1)
	{
		reconnectLimits = 3; //keep retrying ...
        
        
		if (self.remoteView == TRUE)
		{
			NSLog(@"Streamer-REMOTE send message : STREAM_STOPPED_UNEXPECTEDLY");
			[mHandler statusReport:REMOTE_STREAM_STOPPED_UNEXPECTEDLY andObj:nil];
		}
		else
		{
			NSLog(@"Streamer- send message : STREAM_STOPPED_UNEXPECTEDLY");
			[mHandler statusReport:STREAM_STOPPED_UNEXPECTEDLY andObj:nil];
		}
        
	}
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"Streamer- connected to camera: %@", host);
	[mHandler statusReport:CONNECTED_TO_CAMERA andObj:nil];
    
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
                                                                cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
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




#pragma mark -
#pragma mark SnapShot

- (void) saveSnapShot:(UIImage *) image
{
#if 0
	NSString *savedImagePath = [Util getSnapshotFileName];
    
	/* get it as PNG format */
	NSData *imageData = UIImagePNGRepresentation(image);
	[imageData writeToFile:savedImagePath atomically:NO];
#else
    
	/* save to photo album */
	UIImageWriteToSavedPhotosAlbum(image,
                                   self,
                                   @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:),
                                   nil);
    
#endif
    
    
    
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	NSString *message;
	NSString *title;
	//self.statusLabel.text = @"";
    
	if (!error)
	{
		title = @"Snapshot";
		message = @"saved to Photo Album";
        
	}
	else
	{
		title = @"Error";
		message = [error description];
		NSLog(@"Error when writing file to image library: %@", [error localizedDescription]);
		NSLog(@"Error code %d", [error code]);
        
	}
	UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
	[alert show];
	[alert release];
    
}


#pragma mark -
#pragma mark Video Recording




-(void) toggleRecording
{
	if (self.recordInProgress == YES)
	{
		NSLog(@"Stop recording");
        
		[self stopRecording];
		self.recordInProgress = NO;
        
	}
	else
	{
		NSLog(@"start recording");
		self.recordInProgress = YES;
		[self startRecording];
	}
}

- (void) showClock:(NSTimer *) exp {
    
	NSDate * startDate = (NSDate *) exp.userInfo;
    
    
    
	NSTimeInterval ellapseSec = abs([startDate timeIntervalSinceNow]);
    
	//NSLog(@"showClock ellapseSec:%0.2f",ellapseSec);
    
	NSInteger hours = ellapseSec / 3600;
	NSInteger remainder = ((NSInteger)ellapseSec)% 3600;
	NSInteger minutes = remainder / 60;
	NSInteger seconds = remainder % 60;
    
	//recTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    
	[self.recTimeLabel performSelectorOnMainThread:@selector(setText:)
                                        withObject: [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds] waitUntilDone:YES];
    
	//NSLog(@" recTimeLabel.text: %@", [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds]); 
}

- (void) startRecording
{
    
    
	iMaxRecordSize = [Util getMaxRecordSize] * 1024 * 1024;
    
	iFileName = [Util getRecordFileName];
    
	NSLog(@"Recording started: %@ max:%d",iFileName, iMaxRecordSize);
    
	if(iRecorder == NULL) {
		iRecorder = [[AviRecord alloc] init];
	}
	//[iRecorder Init:iFileName];
    
	[iRecorder InitWithFilename:iFileName video_width:320 video_height:240];
    
    
	NSDate * now = [NSDate date];
	self.recTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self 
                                                   selector:@selector(showClock:) 
                                                   userInfo:now 
                                                    repeats:YES];
    
	[iFileName retain];
}

- (void) stopRecording
{
	if (self.recTimer != nil && 
        [self.recTimer isValid])
	{
		[self.recTimer invalidate]; 
        
	}
    
    
	[iRecorder Close];
    
	if (iFileName != nil)
	{
		//[self saveVideoToAlbum:iFileName];
        
        
		NSLog(@"Don't Saving to album now"); 
        
		[self videoSavedToPhotosAlbum:nil didFinishSavingWithError:nil contextInfo:nil];
        
		[iFileName release];
	}
}

-(void) saveVideoToAlbum:(NSString *) fileName
{
	//Save the video
	if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileName))
	{
		NSLog(@"Saving to album now"); 
		UISaveVideoAtPathToSavedPhotosAlbum(fileName, self,@selector(videoSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
	}
	else
	{
		NSLog(@"can't save to album"); 
	}
    
}

- (void)videoSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	NSString *title = @"Video";
    
	NSArray* items = [iFileName componentsSeparatedByString:@"/"];
    
	NSString * shortName = (NSString *)[items lastObject]; 
    
	NSString * message = [NSString stringWithFormat:@"saved as %@", shortName];
    
    
	if (!error)
	{
		//message = @"saved to Photo Album";
        
	}
	else {
		title = @"Error";
		message = [error description];
	}
    
    
	UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message 
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark Image scaling 

- (UIImage*)imageWithImage:(UIImage*)image scaledToRect:(CGRect)newRect
{
	UIGraphicsBeginImageContext(image.size);
    
	[image drawInRect:newRect];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}





#pragma mark -
#pragma mark Orientation changed 
-(void) switchToOrientation:(UIInterfaceOrientation)orientation
{
  
    
    
	self.currentOrientation = orientation;
    
    
    
    if (self.currentOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.currentOrientation == UIInterfaceOrientationLandscapeRight)
	{
        
        NSLog(@"Streamer switch to Landscape orientation");
        
	}
	else if (self.currentOrientation == UIInterfaceOrientationPortrait ||
             self.currentOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        
        NSLog(@"Streamer switch to portrait orientation");
    }
}

-(UIImage *) adaptToCurrentOrientation:(UIImage *) orig
{
    
	if (self.currentOrientation == UIInterfaceOrientationLandscapeLeft || 
        self.currentOrientation == UIInterfaceOrientationLandscapeRight) 
	{
        
        
		return orig; 
        
	}
	else if (self.currentOrientation == UIInterfaceOrientationPortrait ||
             self.currentOrientation == UIInterfaceOrientationPortraitUpsideDown) 
	{
		//NSLog(@"Portrait view");
        
        
		// NSLog(@"Portrait view orig size: %0.2f %0.2f ", orig.size.width, orig.size.height );
		float new_height = orig.size.height;
		float hw_ratio = (float)orig.size.height/(float)orig.size.width;
        
		float new_width = hw_ratio *new_height ;
        
		float new_x =( (float)orig.size.width - new_width)/2;
        
        
		//!! watchout: autoreleased 
		UIImage* newImage = [self imageByCropping:orig toRect:CGRectMake(new_x, 0, new_width, new_height)] ;
      
        
		return  newImage; 
        
	}
    
    
	return orig; 
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect

{
    
	//create a context to do our clipping in
    
	UIGraphicsBeginImageContext(rect.size);
    
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
    
    
    
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
	CGContextClipToRect( currentContext, clippedRect);
    
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
    
	CGRect drawRect = CGRectMake(rect.origin.x * -1,
                                 rect.origin.y * -1,
                                 imageToCrop.size.width,
                                 imageToCrop.size.height);
    
	//draw the image to our clipped context using our offset rect
    
	//CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
	[imageToCrop drawInRect:drawRect];
    
    
    
	//pull the image from our cropped context
    
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    
	//pop the context to get back to the default
    
	UIGraphicsEndImageContext();
    
	//Note: this is autoreleased
    
	return cropped;
    
}

@end
