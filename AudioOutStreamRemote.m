//
//  AudioOutStreamRemote.m
//  BlinkHD_ios
//
//  Created by Developer on 3/14/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "AudioOutStreamRemote.h"

@interface AudioOutStreamRemote()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSTimer *timerVoiceData;
@property (nonatomic, strong) AsyncSocket *sendingSocket;
@property (nonatomic, copy) NSString *sentPath;

@property (nonatomic) BOOL hasStartRecordingSound;

@end

@implementation AudioOutStreamRemote

#define SENDING_SOCKET_TAG 1009
#define REMOTE_TIMEOUT 30
#define SOCKET_ID_SEND 200

- (id)initWithRemoteMode
{
    self = [super init];
    
    if (self) {
        self.hasStartRecordingSound = NO;
        self.isDisconnected = YES;
        
        DLog(@"Create AudioOutStreamer & start recording now");
        DLog(@"PTT remote -IP: %@,  Port: %d", _relayServerIP, _relayServerPort);
    }
    
    return self;
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
            
            [_pcmPlayer Play:YES]; // initialize
            DLog(@"Check self.pcmPlayer is %@", _pcmPlayer);
            
            [[_pcmPlayer player] setPlay_now:NO]; // disable playback
            DLog(@"check self.pcmPlayer.recorder %@", _pcmPlayer.recorder);
            
            [self.pcmPlayer.recorder startRecord];
            self.hasStartRecordingSound = YES;
        }
    }
}

// Connect to the audio streaming socket to stream recorded data TO device
- (void)connectToAudioSocketRemote
{
	if ( !_hasStartRecordingSound ) {
        [self startRecordingSound];
    }
    
    if ( _sendingSocket ) {
        if ( [_sendingSocket isConnected] ) {
            [_sendingSocket setDelegate:nil];
            [_sendingSocket disconnect];
        }
        
        _sendingSocket = nil;
    }
    
    self.sendingSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [_sendingSocket setUserData:SOCKET_ID_SEND];
	
    DLog(@"pTT to: %@:%d", _relayServerIP, _relayServerPort);
    
	// Non-blocking connect
    [_sendingSocket connectToHost:_relayServerIP onPort:_relayServerPort withTimeout:REMOTE_TIMEOUT error:nil];
}

- (void)sendAudioPacket:(NSTimer *)timerExp
{
	// read 4kb everytime
	self.bufferLength = [self.pcmPlayer.recorder.inMemoryAudioFile readBytesPCM:_pcmData
                                                                     withLength:4*1024]; //2*1024

    [_sendingSocket writeData:_pcmData withTimeout:2 tag:SENDING_SOCKET_TAG];
	
    if ( !_sentPath ) {
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.sentPath = [cachesDirectory stringByAppendingPathComponent:@"sent_data.bat"];
    }
    
    if ( !_fileManager ) {
        self.fileManager = [NSFileManager defaultManager];
        [_fileManager removeItemAtPath:_sentPath error:nil];
    }
    
    if ( ![_fileManager fileExistsAtPath:_sentPath] ) {
        DLog (@"File not found");
        [_fileManager createFileAtPath:_sentPath contents:nil attributes:nil];
    }
    
    if ( !_fileHandle  ) {
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_sentPath];
    }
    
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:_pcmData];
}

#pragma mark TCP socket delegate funcs

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	DLog(@"didConnectToHost Finished");
    self.isDisconnected = NO;
    
    // Start handshake
    [self startHandshaking];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    self.isDisconnected = YES;
    
    if ( _fileHandle ) {
        [_fileHandle closeFile];
        self.fileHandle = nil;
    }
    
	DLog(@"AudioOutStreamer- connection failed with error: %@, : %d, : %@", [sock unreadData], [err code], err);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Initializing Push-to-talk failed")
                                                    message:err.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:LocStr(@"Ok"), nil];
    [alert show];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	if ( _sendingSocket && ![_sendingSocket isConnected] ) {
        [self disconnectFromAudioSocketRemote];
	}
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // Waiting for get handshake response
    DLog(@"didWriteDataWithTag");
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // Get handshake response
    DLog(@"TAG: %ld, data: %@", tag, data);
    
    const unsigned char bytes[] = {01, 07, 00, 00, 00, 00, 00};
    NSData *expectedData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    DLog(@"%@", expectedData);
    
    const unsigned char bytes2[] = {01, 07, 00, 02, 00, 00, 00};
    NSData *unexpectedData = [NSData dataWithBytes:bytes2 length:sizeof(bytes2)];
    DLog(@"%@", unexpectedData);
    
    if ([data isEqualToData:expectedData]) {
        DLog(@"Equal Expected data");
        self.isHandshakeSuccess = YES;
        self.timerVoiceData = [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04
                                                            target:self
                                                          selector:@selector(sendAudioPacket:)
                                                          userInfo:nil
                                                           repeats:YES];
    }
    
    if ([data isEqualToData:unexpectedData]) {
        DLog(@"Equal Unexpected data");
        
        self.isHandshakeSuccess = NO;
        DLog(@"AudioOutStreamRemote - handshake failed with error");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocStr(@"Handshake")
                                                        message:LocStr(@"Handshake failed!")
                                                       delegate:nil
                                              cancelButtonTitle:LocStr(@"Ok")
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [_audioOutStreamRemoteDelegate reportHandshakeFaild:!_isHandshakeSuccess];
}

#pragma mark - Methods

- (void)startHandshaking
{
    DLog(@"Start handshaking: %d", _dataRequest.length);// Start handshaking
    self.isDisconnected = NO;
    [_sendingSocket writeData:_dataRequest withTimeout:REMOTE_TIMEOUT tag:SENDING_SOCKET_TAG];
    [_sendingSocket readDataToLength:7 withTimeout:REMOTE_TIMEOUT tag:SENDING_SOCKET_TAG];

}

- (void)cleanDataUp:(NSTimer *)timer
{
    DLog(@"-- clean data up ....");
    
    if ( _bufferLength == 0 ) {
        [_pcmPlayer.recorder.inMemoryAudioFile flush];
        self.pcmPlayer = nil;
        
        
        if ( _timerVoiceData ) {
            [_timerVoiceData invalidate];
            self.timerVoiceData = nil;
        }
        
        if ( _sendingSocket ) {
            if ( [_sendingSocket isConnected] ) {
                [_sendingSocket setDelegate:nil];
                [_sendingSocket disconnect];
            }
            
            self.sendingSocket = nil;
        }
        
        if ( _pcmData ) {
            _pcmData = nil;
        }
        
        [timer invalidate];
        
        DLog(@"\nClean data up successfully.");
    }
}

- (void)disconnectFromAudioSocketRemote
{
	if ( _pcmPlayer ) {
        DLog(@"pcmPlayer stop & release ");
        [[_pcmPlayer player] setPlay_now:NO];
		[_pcmPlayer.recorder stopRecord];
		[_pcmPlayer Stop];
	}
    
	[NSTimer scheduledTimerWithTimeInterval:0.5f
                                     target:self
                                   selector:@selector(disconnectSocketRemote:)
                                   userInfo:nil
                                    repeats:YES];
    
    self.isDisconnected = YES;
}

- (void)disconnectSocketRemote:(NSTimer *)timer
{
    DLog(@"disconnectSocketRemoteRemote, bufLen: %d", self.bufferLength);
    
    if ( _bufferLength == 0 ) {
        [timer invalidate];
        
        [_pcmPlayer.recorder.inMemoryAudioFile flush];
        self.pcmPlayer = nil;
        
        if ( _timerVoiceData ) {
            [_timerVoiceData invalidate];
            self.timerVoiceData = nil;
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
        
        if ( _fileHandle ) {
            [_fileHandle closeFile];
            self.fileHandle = nil;
        }
        
        if (_audioOutStreamRemoteDelegate) {
            [_audioOutStreamRemoteDelegate didDisconnecteSocket];
        }
        else {
            DLog(@"%s _audioOutStreamRemoteDelegate == nil", __FUNCTION__);
        }
    }
}

@end
