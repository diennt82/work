//
//  AudioOutStreamer.h
//  MBP_ios
//
//  Created by NxComm on 5/10/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "Util.h"
#import "PublicDefine.h"
#import "AsyncSocket.h"
#import <H264MediaPlayer/H264MediaPlayer.h>

#define SOCKET_ID_SEND    200

@interface AudioOutStreamer : NSObject  {
	AsyncSocket * sendingSocket; 
	NSMutableData * pcm_data;
	PCMPlayer * pcmPlayer; 
	NSTimer * voice_data_timer; 
	
	NSString * device_ip;
	int device_port; 
}


@property (nonatomic, retain) PCMPlayer * pcmPlayer; 

-(id) initWithDeviceIp:(NSString *) ip andPTTport: (int) port;

- (void) connectToAudioSocket;
- (void) disconnectFromAudioSocket;
- (void) sendAudioPacket:(NSTimer *) timer_exp;

@end
