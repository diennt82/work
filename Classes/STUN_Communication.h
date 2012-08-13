//
//  STUN_Communication.h
//  MBP_ios
//
//  Created by NxComm on 7/4/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#include <sys/types.h>
#include <netdb.h>
#include <arpa/inet.h>

#import <udt.h>
#import "CamChannel.h"
#import "BMS_Communication.h"
#import "UdtSocketWrapper.h"

#define STUN_SERVER_IP @"monitoreverywhere.com"
#define STUN_SERVER_PORT 8000

#define STUN_RELAY_SERVER_IP @"23.23.180.23"
#define STUN_RELAY_SERVER_PORT 44444


#define STUN_CMD_PART @"action=command&command="
#define CLOSE_STUN_SESSION @"close_session"


@interface STUN_Communication : NSObject {

	id  _caller; 
	SEL _Success_SEL; 
	SEL _Failure_SEL;

	CamChannel *mChannel;

	 
	
	int retry_getting_camera_availability; 
}

@property (nonatomic, retain) CamChannel * mChannel; 


//- (id) initWithObject: (id) caller Selector: (SEL) success FailSelector: (SEL) fail ServerErr:(SEL) serverErr;

-(BOOL) connectToRemoteCamera: (CamChannel *) ch 
					 callback: (id) caller 
					 Selector: (SEL) success 
				 FailSelector: (SEL) fail; 



- (void) queryEncCameraInfoFromStunServer;


- (void) availFailedWithError:(NSHTTPURLResponse*) error_response;
- (void) availSuccessWithResponse:(NSData*) responseData;
- (void) availFailedServerUnreachable;


- (void) getSecSuccessWithResponse:(NSData*) responseData;
- (void) getSecFailedWithError:(NSHTTPURLResponse*) error_response;
- (void) getSecFailedServerUnreachable;



@end
