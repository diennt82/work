//
//  MBP_DeviceScanViewController.m
//  MBP_ios
//
//  Created by NxComm on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_DeviceScanViewController.h"
#import "PublicDefine.h"
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"
#import "Util.h"

@implementation MBP_DeviceScanViewController


@synthesize channel1_btn;
@synthesize channel2_btn;
@synthesize channel3_btn;
@synthesize channel4_btn;

@synthesize camera1_view;
@synthesize camera2_view;
@synthesize camera3_view;
@synthesize camera4_view;

@synthesize scan_progress;
@synthesize scan_done_view;

@synthesize scan_results;
@synthesize channel1, channel2,channel3,channel4;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
*/
- (void)viewDidLoad {
    [super viewDidLoad];
 
	self.scan_done_view.hidden = YES;
	self.camera1_view.hidden = YES;
	self.camera2_view.hidden = YES;
	self.camera3_view.hidden = YES;
	self.camera4_view.hidden = YES;

	
	
	self.channel1 = [[CamChannel alloc] initWithChannelIndex:0];
	self.channel2 = [[CamChannel alloc] initWithChannelIndex:1];
	self.channel3 = [[CamChannel alloc] initWithChannelIndex:2];
	self.channel4 = [[CamChannel alloc] initWithChannelIndex:3];
	
	
}

/*
 // Override to allow orientations other than the default portrait orientation.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
	
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
	        (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
	
	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[scan_results release];
	[channel1_btn release];
    [channel2_btn release];
	[channel3_btn release];
    [channel4_btn release];

	
	[camera1_view release];
	[camera2_view release];
	[camera3_view release];
	[camera4_view release];
	[scan_progress release];
	
	[channel1 release];
	[channel2 release];
	[channel3 release];
	[channel4 release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Button handling 


- (IBAction) handleButtonPressed:(id) sender
{
	int sender_tag =  ((UIButton *) sender).tag;
	switch (sender_tag) {
			
		case SCAN_MENU_SCAN_BTN_TAG:
			//start background scan task
			[self scan_for_devices];
			break;
		case SCAN_MENU_CHANN1_BTN_TAG:
			[self.channel1 setConfigure];
			[self showAvailableCameras];
			break;
		
		case SCAN_MENU_CHANN2_BTN_TAG:
			[self.channel2 setConfigure];
			[self showAvailableCameras];
			break;
		case SCAN_MENU_CHANN3_BTN_TAG:
			[self.channel3 setConfigure];
			[self showAvailableCameras];

			break;
		case SCAN_MENU_CHANN4_BTN_TAG:
			[self.channel4 setConfigure];
			[self showAvailableCameras];
			
			break;
			
		case SCAN_MENU_SAVE_BTN_TAG:
			[self saveData];
			
		case SCAN_MENU_BACK_BTN_TAG:
			[self dismissModalViewControllerAnimated:YES];
			break;
		default:
			break;
	}
}


- (void) showAvailableCameras 
{

	for (int i = 0 ; i < next_profile_index; i++)
	{
		CamProfile * bb = (CamProfile *) [self.scan_results objectAtIndex:i];
		
		if (i == 0)
		{
			[self.camera1_view setImage:bb.profileImage];
			self.camera1_view.hidden = NO;
		}
		if (i == 1)
		{
			[self.camera2_view setImage:bb.profileImage];
			self.camera2_view.hidden = NO;
		}
		if (i == 2)
		{
			[self.camera3_view setImage:bb.profileImage];
			self.camera3_view.hidden = NO;
		}
		if (i == 3)
		{
			[self.camera4_view setImage:bb.profileImage];
			self.camera4_view.hidden = NO;
		}
		
	}
}

- (void) bindChanneltoCamera:(int) camIndex
{
	//NSLog(@"Bind cam: %d status: %x", camIndex, self.channel1.channel_configure_status);

	CamProfile * cp = (CamProfile *) [self.scan_results objectAtIndex:camIndex];
	
	if ( self.channel1.channel_configure_status == CONFIGURE_STATUS_AWAITING_FOR_ASSIGNMENT)
	{
		self.channel1.channel_configure_status = CONFIGURE_STATUS_ASSIGNED;
		self.channel1.profile = cp ;
		cp.isSelected = TRUE;
		[cp setChannel:self.channel1];
		
		self.channel1_btn.selected = YES;
		NSLog(@"Bind cam: %d, to channel 1", camIndex);
		
	}

	else if ( self.channel2.channel_configure_status == CONFIGURE_STATUS_AWAITING_FOR_ASSIGNMENT)
	{
		self.channel2.channel_configure_status = CONFIGURE_STATUS_ASSIGNED;
		self.channel2.profile = cp ;
		cp.isSelected = TRUE;
		[cp setChannel:self.channel2];
		
		self.channel2_btn.selected = YES;
		NSLog(@"Bind cam: %d, to channel 2", camIndex);
	
	}
	else if ( self.channel3.channel_configure_status == CONFIGURE_STATUS_AWAITING_FOR_ASSIGNMENT)
	{
		self.channel3.channel_configure_status = CONFIGURE_STATUS_ASSIGNED;
		self.channel3.profile = cp ;
		cp.isSelected = TRUE;
		[cp setChannel:self.channel3];
		
		self.channel3_btn.selected = YES;
		NSLog(@"Bind cam: %d, to channel 3", camIndex);
		


	}
	else if ( self.channel4.channel_configure_status == CONFIGURE_STATUS_AWAITING_FOR_ASSIGNMENT)
	{
		self.channel4.channel_configure_status = CONFIGURE_STATUS_ASSIGNED;
		self.channel4.profile = cp ;
		cp.isSelected = TRUE;
		[cp setChannel:self.channel4];
		
		self.channel4_btn.selected = YES;
		NSLog(@"Bind cam: %d, to channel 4", camIndex);

		
	}
}


#pragma mark -
#pragma mark Touches



//----- handle all touches here then propagate into directionview 

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch;
	CGPoint location ;	
	NSSet *allTouches = [event allTouches];
	
	[super touchesBegan:touches withEvent:event];
	
	//NSLog(@"began Touches count: %d", [allTouches count]);
	int i =0;
	
	for (i =0 ; i < [allTouches count]; i++)
	{
		touch = [ [allTouches allObjects] objectAtIndex:i] ;
		
		location = [touch locationInView:touch.view];
		
		switch (touch.view.tag) {
			case SCAN_MENU_CAM1_VIEW_TAG:
				
				[self bindChanneltoCamera:0];
				
				self.camera1_view.alpha = 0.5;
				self.camera1_view.userInteractionEnabled = NO;
				break;
			case SCAN_MENU_CAM2_VIEW_TAG:
				[self bindChanneltoCamera:1];
				
				self.camera2_view.alpha = 0.5;
				self.camera2_view.userInteractionEnabled = NO;
				
							
				break;
			case SCAN_MENU_CAM3_VIEW_TAG:
				[self bindChanneltoCamera:2];
				
				self.camera3_view.alpha = 0.5;
				self.camera3_view.userInteractionEnabled = NO;

				
			
				break;
			case SCAN_MENU_CAM4_VIEW_TAG:
				[self bindChanneltoCamera:3];
				
				self.camera4_view.alpha = 0.5;
				self.camera4_view.userInteractionEnabled = NO;
			
				
				break;
			default:
		
				[self.channel4 setUnConfigure];
				[self.channel2 setUnConfigure];
				[self.channel3 setUnConfigure];
				[self.channel1 setUnConfigure];
				break;
		}
		
		
		self.camera1_view.hidden = YES;
		self.camera2_view.hidden = YES;
		self.camera3_view.hidden = YES;
		self.camera4_view.hidden = YES;
		
	}
	
}


#pragma mark - 
#pragma mark Save to file



- (void) saveData
{
	NSString * filename; 
	int barker = DATA_BARKER;
	filename = [Util getDataFileName];
	
	FILE  * fd = fopen([filename UTF8String], "wb");
	fwrite(&barker, sizeof(barker), 1, fd);
	
	/* Write number of channel*/
	int numberOfChannel = 4;
	fwrite(&numberOfChannel, sizeof(int), 1, fd);
	
	NSMutableData * chann= nil;
	
	chann = [self.channel1 getBytes];
	char data_len = [chann length];
	fwrite(&data_len, sizeof(char), 1, fd);
	fwrite([chann bytes], 1, [chann length], fd);
	
	
	chann = [self.channel2 getBytes];
	data_len = [chann length];
	fwrite(&data_len, sizeof(char), 1, fd);
	fwrite([chann bytes], 1, [chann length], fd);
	
	chann = [self.channel3 getBytes];
	data_len = [chann length];
	fwrite(&data_len, sizeof(char), 1, fd);
	fwrite([chann bytes], 1, [chann length], fd);
	
	chann = [self.channel4 getBytes];
	data_len = [chann length];
	fwrite(&data_len, sizeof(char), 1, fd);
	fwrite([chann bytes], 1, [chann length], fd);
	
	fclose(fd);
	
	NSLog(@"write to file %@ done", filename);
	
}



#pragma mark -
#pragma mark Scan for device



- (void) scan_for_devices
{
		
	NSString *str =  AIBALL_QUERY_REQUEST_STRING;
	NSString * my_ip_str = [self getAddress];
	NSString * blank_str = @" ";
	int blank_chars = 0, i = 0;
	blank_chars = 16 - [my_ip_str length];
	if (blank_chars >0)
	{
		for (i = 0 ; i< blank_chars; i++)
		{
			my_ip_str= [my_ip_str stringByAppendingString:blank_str];
		}
	}
	
	str = [str stringByAppendingString:my_ip_str];
	str = [str substringToIndex:47];
	
	NSLog(@"scan req: %@", str);
	
	NSData* bytes = [str dataUsingEncoding:NSUTF8StringEncoding];
	
	
	
	self.scan_done_view.hidden = YES;
	self.camera1_view.hidden = YES;
	self.camera1_view.userInteractionEnabled = YES;
	self.camera1_view.alpha =1.0;
	self.camera2_view.hidden = YES;
	self.camera2_view.userInteractionEnabled = YES;
	self.camera2_view.alpha =1.0;
	self.camera3_view.hidden = YES;
	self.camera3_view.userInteractionEnabled = YES;
	self.camera3_view.alpha =1.0;
	self.camera4_view.hidden = YES;
	self.camera4_view.userInteractionEnabled = YES;
	self.camera4_view.alpha =1.0;
	
	self.channel1_btn.selected = NO;
	self.channel2_btn.selected = NO;
	self.channel3_btn.selected = NO;
	self.channel4_btn.selected = NO;
	[self.channel1 reset];
	[self.channel2 reset];
	[self.channel3 reset];
	[self.channel4 reset];
	
	
	
	
	[self.scan_progress startAnimating];
	
	bc_addr = [self getBroadcastAddress];
	
	next_profile_index = 0;
	self.scan_results = [NSMutableArray arrayWithCapacity:4]; 
	[self.scan_results removeAllObjects];
	
	AsyncUdpSocket * udpSock = [[AsyncUdpSocket alloc] initIPv4];
	[udpSock setDelegate:self];
	
	BOOL status;
	status = [udpSock bindToPort:10001 error:nil];
	//[udpSock enableBroadcast:YES error: nil];
	[udpSock receiveWithTimeout:5 tag:1];
	
	//NSLog(@"buff size: %d", [udpSock maxReceiveBufferSize]);
	
	/* Sending socket */
	AsyncUdpSocket * udpSSock = [[AsyncUdpSocket alloc] initWithDelegate:self];
	
	
	// Broadcast 
	[udpSSock enableBroadcast:YES error: nil];
	[udpSSock sendData:bytes toHost:bc_addr port:10000 withTimeout:1 tag:1];
	
}



- (BOOL) connect_to_cameras_and_record_images
{
	
	if (scan_index >= next_profile_index) 
	{
		//Multicam case: Not supported now
		NSLog(@"stop scanning now ");
		return FALSE;
		
	}
	
	initialFlag = 1;
	
	/* there are next_profile_index of cams around */
	
	CamProfile * camera = (CamProfile *)[self.scan_results objectAtIndex:scan_index];
	AsyncSocket * listenSocket = [[AsyncSocket alloc] initWithDelegate:self];	
	
	/* save this index to be used when we have the data and want to save */
	[listenSocket setUserData:scan_index];
	
	
	NSLog(@"connecting to : %@:%d", camera.ip_address, camera.port);
	
	//Non-blocking connect
    [listenSocket connectToHost:camera.ip_address 
						 onPort:camera.port
					withTimeout:3
						  error:nil];
	
	scan_index ++;
	
	return TRUE;
}

- (void) startReceivingVideoAudio: (AsyncSocket * ) listenSocket
{
	NSString *getReq = [NSString stringWithFormat:@"%@Authorization: Basic %@\r\n\r\n",
						AIBALL_GET_STREAM_ONLY_REQUEST, [Util getCredentials]];
	NSData *getReqData = [getReq dataUsingEncoding:NSUTF8StringEncoding];
	
	[listenSocket writeData:getReqData withTimeout:2 tag:1];
	[listenSocket readDataWithTimeout:2 tag:1];	
	responseData = [[NSMutableData alloc] init];
	
}

- (void) disconnectFromCamera: (AsyncSocket * ) listenSocket 
{
	
	if(responseData != nil) {
		[responseData release];
		responseData = nil;
	}
	
	
	initialFlag = 0;
	
	if(listenSocket != nil) {
		[listenSocket disconnect];
		[listenSocket setDelegate:nil];
		[listenSocket release];
		listenSocket = nil;
	}
	
	
}

#pragma mark -- TCP delegate

- (void)onSocket:(AsyncSocket *)listenSocket didReadData:(NSData *)data withTag:(long)tag
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
					int cam_index = (int)listenSocket.userData;
					CamProfile * camera = (CamProfile *)[self.scan_results objectAtIndex:cam_index];
					camera.profileImageData = [[NSData alloc] initWithData:imageData];
					camera.profileImage = [UIImage imageWithData:imageData];
					

					/* we are done now, disconnect */
					[self disconnectFromCamera:listenSocket];
					
					//[imageData autorelease];
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

}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@" connected to host: %@", host);
	
	[self startReceivingVideoAudio: sock];
	
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	
	/* try to connect to the next camera 
	   if failed, stop the activity view 
	 */
	if (![self connect_to_cameras_and_record_images])
	{
		[self.scan_progress stopAnimating];
		self.scan_done_view.hidden = NO;
		
	}

}


#pragma mark -- UDP delegate

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	//NSLog(@"UDP Socket sendDone  enable receiving %d", [sock localPort]);
	
	/* close socket */
	[sock close];
	
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
{
	NSLog(@"UDP Socket error: %d  localhost:%@", error, [sock localHost]);
	
}

/**
 * Called when the socket has received the requested datagram.
 * Under normal circumstances, you simply return YES from this method.
 **/
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
		
	NSString * data_str ; 
	
	data_str = [NSString stringWithUTF8String:[data bytes]];
	
	
	
	NSString* msg= [NSString stringWithFormat:@"RCV data from: %@ : %@", host, data_str];

	NSLog(@"%@",msg);
	
	
	/* verify signature */
	if ([data_str hasPrefix:@"Mot-Cam"])
	{
		CamProfile * newProfile = [CamProfile alloc];
		[newProfile initWithResponse:data_str andHost:host];
		
		
		BOOL isFound  = NO;
		int i;
		for (i =0; i < next_profile_index; i++)
		{
			CamProfile * bb = (CamProfile *)[self.scan_results objectAtIndex:i];
			
			if ( [bb.mac_address isEqualToString:newProfile.mac_address])
			{
				NSLog(@"duplicate entry fr mac: %@", bb.mac_address); 
				isFound = YES; 
				break;
			}
			else
			{
				//NSLog(@" %@ is not equal to %@", bb.mac_address, newProfile.mac_address);
				
			}

		}
		
		if (isFound == NO)
		{
			NSLog(@" insert %@", newProfile.mac_address);
			[self.scan_results insertObject:newProfile atIndex:next_profile_index];
			next_profile_index++;
		}
		else {
			[newProfile release];
		}
		
	}
	
	if (next_profile_index <5)
	{
		/* try again until we failed */
		[sock receiveWithTimeout:2 tag:1];
	}
	
	return YES;
}

/**
 * Called if an error occurs while trying to receive a requested datagram.
 * This is generally due to a timeout, but could potentially be something else if some kind of OS error occurred.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
	//NSLog(@"RCV data err: %x (%@)", [error code], [error localizedDescription]);
	
	/* close socket */
	[sock close];

	if ( next_profile_index == 0)
	{
		
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Scanning Failed"
							  message:@"No camera found, please make sure cameras are connected to the same network as this iphone/ipad" 
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self.scan_progress stopAnimating];
		
		
	}
	else
	{
		NSLog(@" found : %d cams", next_profile_index);
		
		for (int i = 0 ; i < next_profile_index; i++)
		{
			CamProfile * bb = (CamProfile *) [self.scan_results objectAtIndex:i];
			NSLog(@" mac %d: %@", i, bb.mac_address);
		}
		
		
		
		
		scan_index = 0;
		[self connect_to_cameras_and_record_images];
	}
}

/**
 * Called when the socket is closed.
 * A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
}
#import <sys/socket.h>
#import <netinet/in.h>
#import  "IpAddress.h"


-(NSString*)getAddress {
	
	InitAddresses();
	GetIPAddresses();
	GetHWAddresses();
	
	/* */
	int i;
	NSString *deviceIP;
	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;
		
		theAddr = ip_addrs[i];
		
		if (theAddr == 0) break;
		if (theAddr == localHost) continue;
		
		NSLog(@"%d %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i]);
	}
	deviceIP = [NSString stringWithFormat:@"%s", ip_names[1]];
	
	NSLog(@"device iP: %@", deviceIP);
	
	//this will get you the right IP from your device in format like 198.111.222.444. If you use the for loop above you will se that ip_names array will also contain localhost IP 127.0.0.1 that's why I don't use it. Eventualy this was code from mac that's why it uses arrays for ip_names as macs can have multiple IPs
	return deviceIP;//[NSString stringWithFormat:@"%s", ip_names[1]];
}


-(NSString*)getBroadcastAddress 
{
	
	InitAddresses();
	GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP;
	/* 
	 int i;
	 
	 for (i=0; i<MAXADDRS; ++i)
	 {
	 static unsigned long localHost = 0x7F000001;		// 127.0.0.1
	 unsigned long theAddr;
	 
	 theAddr = ip_addrs[i];
	 
	 if (theAddr == 0) break;
	 if (theAddr == localHost) continue;
	 
	 NSLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i], 
	 broadcast_addrs[i]);
	 }
	 
	 */
	deviceBroadcastIP = [NSString stringWithFormat:@"%s", broadcast_addrs[1]];
	
	//NSLog(@"broadcast iP: %@", deviceBroadcastIP);
	
	
	return deviceBroadcastIP;//[NSString stringWithFormat:@"%s", ip_names[1]];
}



@end
