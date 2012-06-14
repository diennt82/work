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
@synthesize pcmPlayer;
@synthesize temperatureLabel; 
@synthesize takeSnapshot,recordInProgress;
@synthesize currentZoomLevel;

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
	
	/**** REset some variables */
	takeSnapshot = NO;
	recordInProgress = NO;
	[self stopRecording];
	currentZoomLevel = 5.0;
	
	
	
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

	NSString * camMac = [CameraPassword fetchBSSIDInfo];
	
	NSString *getReq = [NSString stringWithFormat:@"%@Authorization: Basic %@\r\n\r\n",
						AIBALL_GET_REQUEST, [Util getCameraCredentials:camMac]];
	NSData *getReqData = [getReq dataUsingEncoding:NSUTF8StringEncoding];
	
	[listenSocket writeData:getReqData withTimeout:2 tag:1];
	[listenSocket readDataWithTimeout:2 tag:1];	
	responseData = [[NSMutableData alloc] init];
	
	if ( pcmPlayer == nil)
	{
		/* Start the player to playback & record */
		pcmPlayer = [[PCMPlayer alloc] init];
		[[pcmPlayer player] setPlay_now:FALSE];
		[pcmPlayer Play];
		
	}
	else {
		[[pcmPlayer player] setPlay_now:FALSE];
		
	}
}

- (void) stopStreaming
{
	if (self.videoImage != nil)
	{
		[self.videoImage setImage:[UIImage imageNamed:@"homepage.png"]];
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
	
}

- (void) dealloc
{
	NSLog(@"Streamer released called");
	[self stopStreaming];
	//[super dealloc];
	[listenSocket release];
	[responseData release];
	[device_ip release];
// cant release as this is passed from outside	[videoImage release];

	[pcmPlayer release];
	[super dealloc];
}


#pragma mark -
#pragma mark Audio Playback

- (void) PlayPCM:(NSData*)pcm {
	
	//Start play back 
	[[pcmPlayer player] setPlay_now:TRUE];
	
	[pcmPlayer WritePCM:(unsigned char *)[pcm bytes] length:[pcm length]];
}



#pragma mark - 
#pragma mark TCP delegate 


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	//NSLog(@"stream only get data");
	[listenSocket readDataWithTimeout:3 tag:tag];
	
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
					[self.temperatureLabel setText:[NSString stringWithFormat:@"%d \u2103", temperature]];
					
					int avdata_offset = 10 + 4 + 1 ; //old data + temperature + 1 
					
					
					
#ifdef IBALL_AUDIO_SUPPORT	
					if( audioLength > 0 )
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
					
			
					

					if (currentZoomLevel < 5.0f)
					{
						//CGRect frame = camView.oneCamView.videoView.frame;
						
						CGFloat newDeltaWidth =   image.size.width*(5.0f - currentZoomLevel)*2;
						CGFloat newDeltaHeight =  image.size.height*(5.0f - currentZoomLevel)*2;
						CGRect newRect = CGRectZero;
						newRect.origin.x = - newDeltaWidth/2;
						newRect.origin.y = - newDeltaHeight/2;
						
						newRect.size.width =  image.size.width +newDeltaWidth;
						newRect.size.height = image.size.height +newDeltaHeight;
						
						//NSLog(@"newsize :%f, %f %f %f", newRect.size.width, newRect.size.height,
						//	  newDeltaWidth, newDeltaHeight);
						image = [self imageWithImage:image scaledToRect:newRect];
						
					}

					
					[self.videoImage setImage:[UIImage imageWithData:imageData]];
					

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
		message = @"saved to the photo album";
		
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
	
	
}

- (void) stopRecording
{

	
	[iRecorder Close];
	
	
	
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


@end
