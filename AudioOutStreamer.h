//
//  AudioOutStreamer.h
//  MBP_ios
//
//  Created by NxComm on 5/10/12.
//  Copyright 2012 Hubble Connected Ltd. All rights reserved.
//

#import <H264MediaPlayer/PCMPlayer.h>

@protocol AudioOutStreamerDelegate <NSObject>

- (void)cleanup;

@end

@interface AudioOutStreamer : NSObject

@property (nonatomic, strong) NSMutableData *pcmData;
@property (nonatomic, retain) PCMPlayer * pcmPlayer;
@property (nonatomic, assign) id<AudioOutStreamerDelegate> audioOutStreamerDelegate;
@property (nonatomic) NSInteger bufferLength;

- (id)initWithDeviceIp:(NSString *)ip andPTTport:(int)port;
- (void)connectToAudioSocket;
- (void)disconnectFromAudioSocket;
- (void)sendAudioPacket:(NSTimer *)timerExp;
- (void)startRecordingSound;

@end
