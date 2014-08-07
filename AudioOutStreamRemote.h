//
//  AudioOutStreamRemote.h
//  BlinkHD_ios
//
//  Created by Developer on 3/14/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CameraScanner/CameraScanner.h>
#import <H264MediaPlayer/PCMPlayer.h>

@protocol AudioOutStreamRemoteDelegate <NSObject>

- (void)closeTalkbackSession;
- (void)reportHandshakeFaild:(BOOL)isFailed;
- (void)didDisconnecteSocket;

@end

@interface AudioOutStreamRemote : NSObject

@property (nonatomic, strong) NSMutableData *pcmData;
@property (nonatomic, strong) PCMPlayer *pcmPlayer;
@property (nonatomic, strong) NSMutableData *dataRequest;

@property (nonatomic, copy) NSString *relayServerIP;
@property (nonatomic, weak) id<AudioOutStreamRemoteDelegate> audioOutStreamRemoteDelegate;

@property (nonatomic) NSInteger relayServerPort;
@property (nonatomic) NSInteger bufferLength;
@property (nonatomic) BOOL isDisconnected;
@property (nonatomic) BOOL isHandshakeSuccess;

- (id)initWithRemoteMode;
- (void)connectToAudioSocketRemote;
- (void)startRecordingSound;
- (void)disconnectFromAudioSocketRemote;

@end