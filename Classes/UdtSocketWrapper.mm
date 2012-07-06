//
//  UdtSocketWrapper.m
//  MBP_ios
//
//  Created by NxComm on 7/5/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "UdtSocketWrapper.h"


@implementation UdtSocketWrapper
@synthesize udt_socket,local_port;

-(id) init
{
	[super init];
	self.local_port = -1; 
	return self; 
}

-(id) initWithLocalPort:(int) localPort
{
	[super init];
	self.local_port = localPort; 
	return self; 
}

// typedef int UDTSOCKET; it's an int anyway..

- (int) createUdtStreamSocket
{
	int retVal =  UDT::startup();
	
	
	if (retVal == UDT::ERROR)
	{
		NSLog(@"startup UDT error"); 
	}
	
	udt_socket = UDT::socket(AF_INET, SOCK_STREAM, 0);  
	int timeout = 5000; 
	setsockopt(udt_socket, 0, UDT_SNDTIMEO,(void*) &timeout , sizeof(int));
	setsockopt(udt_socket, 0, UDT_RCVTIMEO,(void*) &timeout , sizeof(int));
	
	if (self.local_port > 0)
	{

		//get the local address to bind to...
		struct addrinfo hints, *local;
		
		memset(&hints, 0, sizeof(struct addrinfo));
		
		hints.ai_flags = AI_PASSIVE;
		hints.ai_family = AF_INET;
		hints.ai_socktype = SOCK_STREAM;
		
		NSString * port_str = [NSString stringWithFormat:@"%d", self.local_port]; 
		
		if (0 != getaddrinfo(NULL, [port_str UTF8String], &hints, &local))
		{
			NSLog(@"ERROR while binding: invalid local address");
			return -1;
		}
		
		//try to bind now .. 
		if (UDT::ERROR == UDT::bind(udt_socket, local->ai_addr, local->ai_addrlen))
		{
			//cout << "bind: " << UDT::getlasterror().getErrorMessage() << endl;
			NSLog(@"ERROR while binding - api");
			return -2;
		}
		else {
			NSLog(@"SOCKET UDT: bind to local port:%@ ok", port_str);
			
		}

		//bind ok
	}
	
	
	return 0;
}





-(int) connectViaUdtSock:(struct in_addr *) ip port:(int) port
{
	
	int retVal; 
	
	
	///convert from string & int to sockaddr -- 
	sockaddr remote_sock_addr; 
	sockaddr_in * saddr = (sockaddr_in*) &remote_sock_addr; 
	saddr->sin_family = AF_INET; 
	saddr->sin_addr.s_addr = ip->s_addr;
	saddr->sin_port = htons(port);
	bzero(saddr->sin_zero, 8);
	
	retVal = UDT::connect(udt_socket, &remote_sock_addr, sizeof(remote_sock_addr));
	
	if (retVal == UDT::ERROR)
	{
		NSLog(@"Failed to connect to server: %d:%d", ip->s_addr, port); 
		return -2; 
	}
	
	//get the localPortNumber
	int localPortNumber ; 
	sockaddr localSockAddr; 
	int addr_size = sizeof(localSockAddr);
	
	retVal = UDT::getsockname(udt_socket, &localSockAddr, &addr_size ); 
	if (retVal == UDT::ERROR)
	{
		NSLog(@"Failed to get local port"); 
		return -3; 
	}
	
	localPortNumber = ntohs(((sockaddr_in*)&localSockAddr)->sin_port); 
	
	
	return localPortNumber; //connected to server thru this local port
}

-(void) close
{
	UDT::close(udt_socket); 
}

-(int) sendDataViaUdt:(NSData *) data
{
	int retVal; 
	
	retVal = UDT::send(udt_socket, (char*)[data bytes], [data length],0);
	
	return retVal; 
}



-(int) recvDataViaUdt:(NSMutableData *) responseData dataLen:(int) len 
{
	int retVal; 
	if (responseData == nil)
	{
		return -1; //response data has to be initialized before this
	}
	
	[responseData setLength:len]; 
	char * recvData = (char*) [responseData mutableBytes]; 
	
	
	retVal = UDT::recv(udt_socket, recvData, len,0); 
	
	
	if (retVal <0)
	{
		NSLog(@"recv error");
	}
	else if (retVal < len)
	{
		//NSLog(@"recvd less than expected: %d < %d", retVal, len);
	}
	
	
	
	return retVal; 
}

+ (struct in_addr *) getIpfromHostName:(NSString *) hostname
{
	struct hostent *remoteHostEnt = gethostbyname([hostname UTF8String]);
	struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];
	
	//char *sRemoteInAddr = inet_ntoa(*remoteInAddr);
	//return [NSString stringWithUTF8String:sRemoteInAddr]; 
	
	return remoteInAddr;
}


@end
