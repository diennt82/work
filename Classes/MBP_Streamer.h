//
//  MBP_Streamer.h
//  MBP_ios
//
//  Created by NxComm on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "AsyncSocket.h"

@interface MBP_Streamer : NSObject {

	UIImageView * videoImage;
	
	
	AsyncSocket * listenSocket;
	NSMutableData * responseData;
	int initialFlag ;
	NSString * device_ip;
	int device_port;
	
	
}
@property (nonatomic) int device_port;
@property (nonatomic,retain) NSString * device_ip;
@property (nonatomic,retain) UIImageView * videoImage;
@property (nonatomic, retain) AsyncSocket * listenSocket;
@property (nonatomic, retain) NSMutableData * responseData;


- (id) initWithIp:(NSString *) ip andPort:(int) port;
- (void) setVideoView:(UIImageView *) view;
- (void) startStreaming;
- (void) stopStreaming;


- (NSString * ) requestURLSync:(NSString*)url withTimeOut:(NSTimeInterval) timeout;
- (void ) requestURLSync_bg:(NSString*)url;


@end
