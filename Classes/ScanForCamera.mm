//
//  ScanForCamera.m
//  MBP_ios
//
//  Created by NxComm on 5/4/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "ScanForCamera.h"


@implementation ScanForCamera

@synthesize  bc_addr, own_addr, deviceScanInProgress; 
@synthesize next_profile_index; 
@synthesize scan_results; 
@synthesize notifier;

- (id) init
{
	[super init];
	next_profile_index = 0; 
	bc_addr = @"";
	own_addr = @"";
	self.scan_results = [[NSMutableArray alloc]init];
    self.notifier = nil; 
	return self;
}

-(id) initWithNotifier:(id<ScanForCameraNotifier>) caller
{
    [super init];
	next_profile_index = 0; 
	bc_addr = @"";
	own_addr = @"";
	self.scan_results = [[NSMutableArray alloc]init];
    self.notifier = caller; 
	return self;
}


- (void) dealloc
{
	[super	 dealloc];
	[bc_addr release];
	[own_addr release]; 
	[scan_results release];
	
}

//// OLD and NOT USED
- (void) scan_for_devices
{
	
	///GET IP here 
	NSString * bc = @"";
	NSString * own = @"";
	[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
	self.bc_addr = [NSString stringWithString:bc];
	self.own_addr = [NSString stringWithString:own];
	
	
	NSString *str =  AIBALL_QUERY_REQUEST_STRING;
	NSString * my_ip_str = self.own_addr;
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
	
		
	NSData* bytes = [str dataUsingEncoding:NSUTF8StringEncoding];
	
	
	@synchronized (self)
	{
		deviceScanInProgress = YES;
	}
	
	//NSLog(@"broadcast addr: %@ self:%@", self.bc_addr, self.own_addr);
	
	self.next_profile_index = 0;
	[ self.scan_results removeAllObjects];
	
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
	[udpSSock sendData:bytes toHost:self.bc_addr port:10000 withTimeout:1 tag:1];
	//[udpSSock sendData:bytes toHost:@"192.168.1.102" port:10000 withTimeout:1 tag:1];
	
}




// scan for a specific device
// @mac : mac address with colon eg: 11:22:33:44:55:66
- (void) scan_for_device:(NSString*) mac
{
	
	///GET IP here 
	NSString * bc = @"";
	NSString * own = @"";
	[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
	self.bc_addr = [NSString stringWithString:bc];
	self.own_addr = [NSString stringWithString:own];
	
	
	NSString *str =  AIBALL_QUERY_REQUEST_STRING;
	NSString * my_ip_str = self.own_addr;
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
	
	//add mac address
	str = [str	stringByAppendingString:[mac lowercaseString]]; 
	
	NSLog(@"scan 1 dev req: %@", str);
	
	NSData* bytes = [str dataUsingEncoding:NSUTF8StringEncoding];
	
	
	@synchronized (self)
	{
		deviceScanInProgress = YES;
	}
	
	//NSLog(@"broadcast addr: %@ self:%@", self.bc_addr, self.own_addr);
	
	self.next_profile_index = 0;
	[ self.scan_results removeAllObjects];
	
	AsyncUdpSocket * udpSock = [[AsyncUdpSocket alloc] initIPv4];
	[udpSock setDelegate:self];
	
	BOOL status;
	status = [udpSock bindToPort:10001 error:nil];

	[udpSock receiveWithTimeout:4 tag:1];
	
	//NSLog(@"buff size: %d", [udpSock maxReceiveBufferSize]);
	
	/* Sending socket */
	AsyncUdpSocket * udpSSock = [[AsyncUdpSocket alloc] initWithDelegate:self];
	
	
	// Broadcast 
	[udpSSock enableBroadcast:YES error: nil];
	[udpSSock sendData:bytes toHost:self.bc_addr port:10000 withTimeout:1 tag:1];

	
}




- (void) scan_for_devices_done
{

	@synchronized (self)
	{
		deviceScanInProgress = NO;
	}
    
    [self scan_done_notify];
}

-(void) scan_done_notify
{
    NSArray * outArray; 
    if (self.notifier != nil)
    {
        if (scan_results == nil)
        {
            outArray =[[NSArray alloc]init];
        }
        else {	
            outArray = [[NSArray alloc]initWithArray:scan_results
                                           copyItems:NO];
        }
        
        [self.notifier scan_done:outArray];
     }
    else {
        NSLog(@"Scan Done without notifier"); 
    }
}

- (BOOL) getResults:(NSArray **) out_Array
{
	if (deviceScanInProgress == YES	)
	{
		return FALSE; 
	}
	if (scan_results == nil)
	{
		*out_Array =[[NSArray alloc]init];
	}
	else {	
		*out_Array = [[NSArray alloc]initWithArray:scan_results copyItems:NO];
	}
	
	return TRUE;
	
}

-(void) cancel
{
    self.notifier = nil; 
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
	NSLog(@"UDP Socket error: %d  localhost:%@", error.code, [sock localHost]);
	
}






/**
 * Called when the socket has received the requested datagram.
 * Under normal circumstances, you simply return YES from this method.
 **/
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
	
	NSString * data_str ; 
	
	data_str = [NSString stringWithUTF8String:(char*)[data bytes]];
	
	NSLog(@"000 rcv fr: %@ : msg: %@", host, data_str);
	
	/* verify signature */
	if ([data_str hasPrefix:@"Mot-Cam"])
	{
		CamProfile * newProfile = [CamProfile alloc];
		
		//NSLog(@"rcv fr: %@", host);
		
		[newProfile initWithResponse:data_str andHost:host];
		
		
		BOOL isFound  = NO;
		int i;
		for (i =0; i < self.next_profile_index; i++)
		{
			CamProfile * bb = (CamProfile *)[self.scan_results objectAtIndex:i];
			
			if ( [bb.mac_address isEqualToString:newProfile.mac_address])
			{
				isFound = YES; 
				break;
			}
		}
		
		if (isFound == NO)
		{
			
			
			[self.scan_results insertObject:newProfile atIndex:self.next_profile_index];
			self.next_profile_index++;
		}
		else {
			[newProfile release];
		}
		
		
		
	}
	
	if (self.next_profile_index <64)
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
	NSLog(@"RCV data err: %x (%@)", [error code], [error localizedDescription]);
	
	/* close socket */
	[sock close];
	
	
    [self scan_for_devices_done]; 
   
}

/**
 * Called when the socket is closed.
 * A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
}



@end
