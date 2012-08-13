//
//  RemoteConnection.h
//  MBP_ios
//
//  Created by NxComm on 6/26/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "CamChannel.h"
#import "CamProfile.h"
#import "BMS_Communication.h"

@interface RemoteConnection : NSObject {

	CamChannel *mChannel; 
	id  _caller; 
	SEL _Success_SEL; 
	SEL _Failure_SEL; 
	
	
}

@property (nonatomic, retain) CamChannel * mChannel; 


-(BOOL) connectToRemoteCamera: (CamChannel *) ch 
					 callback: (id) caller 
					 Selector: (SEL) success 
				 FailSelector: (SEL) fail; 


//-- Private --- // 



//--- Call backs -- //
- (void) getStreamSuccessWithResponse:(NSData*) responseData;
- (void) getStreamFailedWithError:(NSHTTPURLResponse*) error_response;
- (void) getStreamFailedServerUnreachable;

-(void) getPortSuccessWithResponse:(NSData*) responseData;
- (void) getPortFailedWithError:(NSHTTPURLResponse*) error_response;
- (void) getPortFailedServerUnreachable;


-(void) viewRmtSuccessWithResponse:(NSData*) responseData;
- (void) viewRmtFailedWithError:(NSHTTPURLResponse*) error_response;
- (void) viewRmtFailedServerUnreachable;

@end
