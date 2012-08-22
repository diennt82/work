//
//  CamChannel.h
//  MBP_ios
//
//  Created by NxComm on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamProfile.h"
#import "Util.h"



#define CONFIGURE_STATUS_NOT_ASSIGNED 0x100
#define CONFIGURE_STATUS_AWAITING_FOR_ASSIGNMENT 0x101
#define CONFIGURE_STATUS_ASSIGNED 0x102


#define COMM_MODE_LOCAL 1
#define COMM_MODE_UPNP 2
#define COMM_MODE_STUN 3

@class CamProfile;
@interface CamChannel : NSObject {

	int channel_index;
	UIImageView * channel_view;
	CamProfile * profile;
	int channel_configure_status;
	
	//session Key : for both HTTP & STUN 
	NSString * remoteViewKey; 
	int communication_mode; 
	//remote HTTP stuff
	NSTimer *  remoteViewTimer; 
	
	//remote STUN Stuff
	NSString * channID;
	NSString * secretKey; 
	int localUdtPort; 
    
    //remote STun RElay Stuff
    NSString * relayToken; 
	
	
}

@property (nonatomic, retain) CamProfile * profile;
@property (nonatomic) int channel_configure_status, channel_index;
@property (nonatomic, retain) NSString * remoteViewKey; 
@property (nonatomic, retain) NSTimer * remoteViewTimer;
@property (nonatomic, retain) NSString * channID, *secretKey, *relayToken;
@property (nonatomic) int localUdtPort, communication_mode; 


+(NSString*) convertIntToIpStr:(uint ) ip;
+(CamChannel *) restoreFromData: (NSData *) data;

- (id) initWithChannelIndex:(int) index;
- (BOOL) setCamProfile:(CamProfile *) cp;

- (BOOL) setConfigure;
- (void) setUnConfigure;
- (void) reset;

- (NSMutableData *) getBytes;
-(void) startViewTimer:(id) caller select:(SEL) sel;
-(void) abortViewTimer; 

-(NSData *) getEncChannId;
-(NSData *) getEncMac;
-(NSData *) decryptServerMessage:(NSData *) encrypted_data; 

-(NSString*) calculateRelayToken:(NSString *) relaySk 
                    withUserPass: (NSString *) user_colon_pass;
@end
