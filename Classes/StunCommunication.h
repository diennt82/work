//
//  StunCommunication.h
//  MBP_ios
//
//  Created by NxComm on 7/12/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "HttpCommunication.h"
#import "BMS_Communication.h"
#import "UdtSocketWrapper.h"

#define STUN_COMMAND_PART @"action=command&command="

@interface StunCommunication : NSObject
{
	NSString * device_ip; 
	int device_port;
	int local_port; 
	
	NSURLConnection * url_connection; 
	NSMutableData *responseData;
	
	UIAlertView * myAlert; 
	
}

@property (retain, nonatomic) NSString * device_ip; 
@property  int device_port, local_port; 

-(id)initWithIp:(NSString *) device_ip port:(int) rport lPort:(int) lport;  

- (void) sendCommand:(NSString *) command;
- (NSString *) sendCommandAndBlock:(NSString *)command;

- (NSData * ) sendCommandThruUdtServer:(NSString *) command withMac:(NSString *) mac AndChannel:(NSString*) chann;
- (void ) sendCommandThruUdtServerNonBlock:(NSString *) command withMac:(NSString *) mac AndChannel:(NSString*) chann;
- (NSData * ) sendCloseSessionThruBMS:(NSString *) mac AndChannel:(NSString*) chann forRelay:(BOOL) isRelay;

@end
