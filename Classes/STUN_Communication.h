//
//  STUN_Communication.h - Handle communication while setting up with STUN server 
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

#define STUN_SERVER_IP @"udt.monitoreverywhere.com"
#define STUN_SERVER_PORT 8000

#define STUN_RELAY_SERVER_IP @"relay.monitoreverywhere.com"
#define STUN_RELAY_SERVER_PORT 44444


#define STUN_CMD_PART @"action=command&command="
#define CLOSE_STUN_SESSION @"close_session"



#define CHANNEL_ID @"ChannelID:"
#define SEC_KEY    @"Secret_key:"
#define CHANNEL_ID_LEN 12


@interface STUN_Communication : NSObject {

	id  _caller; 
	SEL _Success_SEL; 
	SEL _Failure_SEL;

	CamChannel *mChannel;

	  NSTimer * isCamAvaiTimer;
	
	int retry_getting_camera_availability; 
}

@property (nonatomic, retain) CamChannel * mChannel; 


//- (id) initWithObject: (id) caller Selector: (SEL) success FailSelector: (SEL) fail ServerErr:(SEL) serverErr;

-(BOOL) connectToRemoteCamera: (CamChannel *) ch 
					 callback: (id) caller 
					 Selector: (SEL) success 
				 FailSelector: (SEL) fail; 

-(UdtSocketWrapper *)connectToStunRelay: (CamChannel *) ch;





- (void) availFailedWithError:(NSHTTPURLResponse*) error_response;
- (void) availSuccessWithResponse:(NSData*) responseData;
- (void) availFailedServerUnreachable;


- (void) getSecSuccessWithResponse:(NSData*) responseData;
- (void) getSecFailedWithError:(NSHTTPURLResponse*) error_response;
- (void) getSecFailedServerUnreachable;



@end
