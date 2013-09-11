//
//  UdtSocketWrapper.h
//  MBP_ios
//
//  Created by NxComm on 7/5/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#include <sys/types.h>
#include <netdb.h>
#include <arpa/inet.h>

#import "udt.h"
@interface UdtSocketWrapper : NSObject {

	UDTSOCKET udt_socket;
	int local_port; 
	
}

@property (nonatomic) UDTSOCKET udt_socket;
@property (nonatomic) int local_port; 



//+ (NSString *) getIpfromHostName:(NSString *) hostname;
+ (struct in_addr *) getIpfromHostName:(NSString *) hostname;

-(id) initWithLocalPort:(int) localPort;

- (int) createUdtStreamSocket;
//-(int) connectViaUdtSock:(UDTSOCKET *)sock toServer:(NSString *) ip port:(int) port;
-(int) connectViaUdtSock:(struct in_addr *) ip port:(int) port;
-(int) sendDataViaUdt:(NSData *) data;
-(int) recvDataViaUdt:(NSMutableData *) responseData dataLen:(int) len ;

-(BOOL) isOpen; 

-(void) close;


@end
