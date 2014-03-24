//
//  AudioOutStreamer.h
//  MBP_ios
//
//  Created by NxComm on 5/10/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <CameraScanner/CameraScanner.h>
#import <H264MediaPlayer/PCMPlayer.h>

#define SOCKET_ID_SEND    200

@protocol AudioOutStreamerDelegate <NSObject>

- (void)cleanup;

@end

@interface AudioOutStreamer : NSObject  {
	AsyncSocket * sendingSocket; 
	NSMutableData * _pcm_data;
	PCMPlayer * pcmPlayer; 
	NSTimer * voice_data_timer; 
	
	NSString * device_ip;
	int device_port;
    BOOL hasStartRecordingSound; 
}

@property (nonatomic, strong) NSMutableData *pcm_data;
@property (nonatomic, retain) PCMPlayer * pcmPlayer;
@property (nonatomic) NSInteger bufferLength;
@property (nonatomic, assign) id<AudioOutStreamerDelegate> audioOutStreamerDelegate;

-(id) initWithDeviceIp:(NSString *) ip andPTTport: (int) port;

- (void) connectToAudioSocket;
- (void) disconnectFromAudioSocket;
- (void) sendAudioPacket:(NSTimer *) timer_exp;
- (void) startRecordingSound;

@end
