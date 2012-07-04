//
//  STUN_Communication.h
//  MBP_ios
//
//  Created by NxComm on 7/4/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <udt.h>
#import "CamChannel.h"
#import "BMS_Communication.h"

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
