//
//  AudioOutStreamRemote.h
//  BlinkHD_ios
//
//  Created by Developer on 3/14/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CameraScanner/CameraScanner.h>
#import <H264MediaPlayer/PCMPlayer.h>

#define SOCKET_ID_SEND    200

@protocol AudioOutStreamRemoteDelegate <NSObject>

- (void)closeTalkbackSession;
- (void)reportHandshakeFaild:(BOOL)isFailed;
- (void)didDisconnecteSocket;

@end

@interface AudioOutStreamRemote : NSObject
{
	//AsyncSocket * sendingSocket;
	NSMutableData * _pcm_data;
	PCMPlayer * pcmPlayer;
	
    BOOL hasStartRecordingSound;
}

@property (nonatomic, retain) NSString * relayServerIP;
@property (nonatomic) NSInteger relayServerPort;
@property (nonatomic, strong) NSMutableData *pcm_data;
@property (nonatomic, retain) PCMPlayer * pcmPlayer;
@property (nonatomic) NSInteger bufferLength;
@property (nonatomic, assign) id<AudioOutStreamRemoteDelegate> audioOutStreamRemoteDelegate;

@property (nonatomic, retain) NSMutableData *dataRequest;

@property (nonatomic) BOOL isDisconnected;
@property (nonatomic) BOOL isHandshakeSuccess;

- (id)initWithRemoteMode;
- (void)connectToAudioSocketRemote;
- (void)startRecordingSound;
- (void)disconnectFromAudioSocketRemote;

@end