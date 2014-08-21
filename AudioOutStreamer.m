//
//  AudioOutStreamer.m
//  MBP_ios
//
//  Created by NxComm on 5/10/12.
//  Copyright 2012 Hubble Connected Ltd. All rights reserved.
//

#import <CameraScanner/CameraScanner.h>
#import "AudioOutStreamer.h"

@interface AudioOutStreamer()

@property (nonatomic, strong) AsyncSocket *sendingSocket;
@property (nonatomic, strong) NSTimer *voiceDataTimer;
@property (nonatomic, copy) NSString *deviceIp;
@property (nonatomic) int devicePort;
@property (nonatomic) BOOL hasStartRecordingSound;

@end

@implementation AudioOutStreamer

#define SENDING_SOCKET_TAG 1009
#define SOCKET_ID_SEND 200

- (id)initWithDeviceIp:(NSString *)ip andPTTport:(int)port
{
	self = [super init];
    if (self) {
        self.deviceIp = [NSString stringWithString:ip];
        self.devicePort = port;
        self.hasStartRecordingSound = NO;
    }
    
	return self; 
}

- (void)dealloc
{
    [_voiceDataTimer invalidate];
}

- (void)startRecordingSound
{
    @synchronized(self)
    {
        if ( !_pcmPlayer ) {
            DLog(@"Start recording!!!.******");
            
            // Start the player to playback & record
            self.pcmPlayer = [[PCMPlayer alloc] init];
            self.pcmData = [[NSMutableData alloc] init];
            
            [_pcmPlayer Play:YES]; //initialize
            DLog(@"Check self.pcmPlayer is %@", _pcmPlayer);
            
            [[_pcmPlayer player] setPlay_now:NO]; // disable playback
            DLog(@"check self.pcmPlayer.recorder %@", _pcmPlayer.recorder);
            
            [_pcmPlayer.recorder startRecord];
            
            self.hasStartRecordingSound = YES;
        }
    }
}

// Connect to the audio streaming socket to stream recorded data TO device
- (void)connectToAudioSocket
{
	if ( !_hasStartRecordingSound) {
        [self startRecordingSound];
    }
    
	self.sendingSocket = [[AsyncSocket alloc] initWithDelegate:self];
	[_sendingSocket setUserData:SOCKET_ID_SEND];
	
    DLog(@"pTT to: %@:%d", _deviceIp, _devicePort);
    
	// Non-blocking connect
    [_sendingSocket connectToHost:_deviceIp onPort:_devicePort withTimeout:5 error:nil];
}

- (void)disconnectFromAudioSocket
{   
	// disconnect
	if ( _pcmPlayer ) {
         DLog(@"pcmPlayer stop & release "); 
        [[_pcmPlayer player] setPlay_now:NO];
		[_pcmPlayer.recorder stopRecord];
		[_pcmPlayer Stop];
	}

	[NSTimer scheduledTimerWithTimeInterval:0.5f
                                      target:self
                                    selector:@selector(disconnectSocket:)
                                    userInfo:nil
                                     repeats:YES];
}

- (void)disconnectSocket:(NSTimer *)timer
{
    DLog(@"disconnectSocket, bufLen: %d", _bufferLength);
    
    if ( _bufferLength == 0 ) {
        [_pcmPlayer.recorder.inMemoryAudioFile flush];
        self.pcmPlayer = nil;
        
        if ( _voiceDataTimer) {
            [_voiceDataTimer invalidate];
            self.voiceDataTimer = nil;
        }
        
        if ( _sendingSocket ) {
            if ( [_sendingSocket isConnected] ) {
                [_sendingSocket setDelegate:nil];
                [_sendingSocket disconnect];
            }
            
            self.sendingSocket = nil;
        }
        
        if( _pcmData ) {
            self.pcmData = nil;
        }
        
        [timer invalidate];
        [self.audioOutStreamerDelegate cleanup];
    }
}

- (void)sendAudioPacket:(NSTimer *)timerExp
{
	// read 2kb everytime
	self.bufferLength = [_pcmPlayer.recorder.inMemoryAudioFile readBytesPCM:_pcmData withLength:3*1024]; //2*1024
	[_sendingSocket writeData:_pcmData withTimeout:2 tag:SENDING_SOCKET_TAG];
}

#pragma mark - TCP socket delegate funcs

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	DLog(@"didConnectToHost Finished");
    
    // Start sending the first 2Kb of data per 0.128 sec
    self.voiceDataTimer = [NSTimer scheduledTimerWithTimeInterval:0.125
                                                           target:self
                                                         selector:@selector(sendAudioPacket:)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	DLog(@"AudioOutStreamer- connection failed with error: %@, : %d, : %@", [sock unreadData], [err code], err);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Initializing Push-to-talk failed"
                                                    message:err.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	if ( _sendingSocket && ![_sendingSocket isConnected] ) {
		[self disconnectFromAudioSocket];
	}
}

@end
