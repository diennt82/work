//
//  StunCommunication.m
//  MBP_ios
//
//  Created by NxComm on 7/12/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "StunCommunication.h"


@implementation StunCommunication

@synthesize local_port, device_port; 
@synthesize device_ip; 

-(id)initWithIp:(NSString *) _ip port:(int) rport lPort:(int) lport
{
	self.device_ip = _ip; 
	self.local_port= lport; 
	self.device_port = rport; 
	
	
	[super init]; 
	return self; 
}

- (void) sendCommand:(NSString *) command
{
	NSMutableData * response_data; 
	
	NSString * stun_cmd = [NSString stringWithFormat:@"%@%@",
						   STUN_COMMAND_PART,command];
	
	NSData * messageToStun = [[NSData alloc] initWithBytes:[stun_cmd cStringUsingEncoding:NSUTF8StringEncoding] 
													length:[stun_cmd length]  ];
	
	// start STUN communication process..
	UdtSocketWrapper * udt_wrapper = [[ UdtSocketWrapper alloc] initWithLocalPort:self.local_port];
	int localPort, response_len = 1024 ; 
	[udt_wrapper createUdtStreamSocket];
	
	
	struct in_addr * server_ip = [UdtSocketWrapper getIpfromHostName:self.device_ip];
	
	
	NSLog(@"sock created: %d serverip:%@ %d",socket ,self.device_ip, 
		  server_ip->s_addr);
	localPort = [udt_wrapper connectViaUdtSock:server_ip
										  port:self.device_port];
	
	NSLog(@"sock connected at port: %d",localPort );
	
	[udt_wrapper sendDataViaUdt:(NSData *) messageToStun]; 
	
	
	response_data = [[NSMutableData alloc] initWithLength:response_len]; 
	response_len = [udt_wrapper recvDataViaUdt:response_data 
									   dataLen:response_len];
	
	if (response_len > 0 ) 
	{
	
		NSRange dataRange = {0, response_len}; 
		NSData	 * str_data ; 
		str_data= [response_data subdataWithRange:dataRange];
		
		NSString * res_str = [[[NSString alloc] initWithData:str_data encoding:NSUTF8StringEncoding] autorelease];
		
		NSLog(@"response: %@", res_str );
	}
	
	
	[udt_wrapper close]; 
	
}


- (NSString *) sendCommandAndBlock:(NSString *)command
{
	return @""; 
}


@end
