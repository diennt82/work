//
//  AudioOutStreamRemote.m
//  BlinkHD_ios
//
//  Created by Developer on 3/14/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#define SENDING_SOCKET_TAG 1009
#define REMOTE_TIMEOUT 30

#import "AudioOutStreamRemote.h"

@interface AudioOutStreamRemote()

@property (retain, nonatomic) NSFileManager *fileManager;
@property (retain, nonatomic) NSFileHandle *fileHandle;
@property (retain, nonatomic) NSString *sentPath;
@property (retain, nonatomic) NSTimer *timerVoiceData;
@property (retain, nonatomic) AsyncSocket *sendingSocket;

@end

@implementation AudioOutStreamRemote

@synthesize pcmPlayer;
@synthesize pcm_data = _pcm_data;

- (id)initWithRemoteMode
{
    self = [super init];
    
    if (self)
    {
        hasStartRecordingSound = FALSE;
        self.isDisconnected = TRUE;
        
        NSLog(@"Create AudioOutStreamer & start recording now");
        NSLog(@"PTT remote -IP: %@,  Port: %d", _relayServerIP, _relayServerPort);
    }
    
    return self;
}

-(void) dealloc
{
    [pcmPlayer release];
    [_fileManager release];
    [_fileHandle release];
    [_sendingSocket release];
    [super dealloc];
}

- (void) startRecordingSound
{
    @synchronized(self)
    {
        if (self.pcmPlayer == nil)
        {
            NSLog(@"Start recording!!!.******");
            /* Start the player to playback & record */
            self.pcmPlayer = [[PCMPlayer alloc] init];
            _pcm_data = [[NSMutableData alloc] init];
            
            [self.pcmPlayer Play:TRUE];//initialize
            NSLog(@"Check self.pcmPlayer is %@", self.pcmPlayer);
            [[self.pcmPlayer player] setPlay_now:FALSE];//disable playback
            NSLog(@"check self.pcmPlayer.recorder %@", self.pcmPlayer.recorder);
            [self.pcmPlayer.recorder startRecord];
            
            hasStartRecordingSound = TRUE;
        }
    }
    
}

/* Connect to the audio streaming socket to stream recorded data TO device */
- (void) connectToAudioSocketRemote
{
	if (hasStartRecordingSound == FALSE)
    {
        [self startRecordingSound];
    }
    
    if (_sendingSocket != nil)
    {
        if ([_sendingSocket isConnected] == YES)
        {
            [_sendingSocket setDelegate:nil];
            [_sendingSocket disconnect];
        }
        
        [_sendingSocket release];
        _sendingSocket = nil;
    }
    
    self.sendingSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [_sendingSocket setUserData:SOCKET_ID_SEND];
	
	NSString* ip = _relayServerIP;
	NSInteger port = _relayServerPort;
    
    NSLog(@"pTT to: %@:%d", ip, port);
    
	//Non-blocking connect
    [_sendingSocket connectToHost:ip onPort:port withTimeout:REMOTE_TIMEOUT error:nil];
}

- (void) sendAudioPacket:(NSTimer *) timer_exp
{
	
	// read 4kb everytime
	self.bufferLength = [self.pcmPlayer.recorder.inMemoryAudioFile readBytesPCM:_pcm_data
                                                                     withLength:4*1024]; //2*1024

    [_sendingSocket writeData:_pcm_data withTimeout:2 tag:SENDING_SOCKET_TAG];
	
    //NSLog(@"AudioOutStreamer - sendAudioPacket: %@", _pcm_data);

    if (_sentPath == nil)
    {
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.sentPath = [cachesDirectory stringByAppendingPathComponent:@"sent_data.bat"];
    }
    
    if (_fileManager == nil)
    {
        self.fileManager = [NSFileManager defaultManager];
        [_fileManager removeItemAtPath:_sentPath error:nil];
    }
    
    if ([_fileManager fileExistsAtPath:_sentPath] == NO)
    {
        NSLog (@"File not found");
        [_fileManager createFileAtPath:_sentPath contents:nil attributes:nil];
    }
    
    if (_fileHandle == nil)
    {
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_sentPath];
    }
    
    [_fileHandle seekToEndOfFile];
    
    [_fileHandle writeData:_pcm_data];
}



#pragma mark TCP socket delegate funcs

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"didConnectToHost Finished");
    self.isDisconnected = FALSE;
    
    // Start handshake
    [self startHandshaking];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    self.isDisconnected = TRUE;
    
    if (_fileHandle != nil)
    {
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
    
	NSLog(@"AudioOutStreamer- connection failed with error: %@, : %d, : %@", [sock unreadData],
		  [err code], err);
    
    UIAlertView *_alert = [[UIAlertView alloc]
                           initWithTitle:@"Initializing Push-to-talk failed"
                           message:err.localizedDescription
                           delegate:self
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
    [_alert show];
    [_alert release];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	if (_sendingSocket != nil && [_sendingSocket isConnected] == NO)
	{
        [self disconnectFromAudioSocketRemote];
	}
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // Waiting for get handshake response
   // NSLog(@"didWriteDataWithTag");
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // Get handshake response
    NSLog(@"TAG: %ld, data: %@", tag, data);
    
    const unsigned char bytes[] = {01, 07, 00, 00, 00, 00, 00};
    NSData *expectedData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    NSLog(@"%@", expectedData);
    
    const unsigned char bytes2[] = {01, 07, 00, 02, 00, 00, 00};
    NSData *unexpectedData = [NSData dataWithBytes:bytes2 length:sizeof(bytes2)];
    NSLog(@"%@", unexpectedData);
    
    if ([data isEqualToData:expectedData])
    {
        NSLog(@"Equal Expected data");
        self.isHandshakeSuccess = TRUE;
        
        self.timerVoiceData = [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04
                                                            target:self
                                                          selector:@selector(sendAudioPacket:)
                                                          userInfo:nil
                                                           repeats:YES];
    }
    
    if ([data isEqualToData:unexpectedData])
    {
        NSLog(@"Equal Unexpected data");
        
        self.isHandshakeSuccess = FALSE;
        NSLog(@"AudioOutStreamRemote - handshake failed with error");
        
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:@"Handshake"
                               message:@"Handshake failed!"
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
    
    [_audioOutStreamRemoteDelegate reportHandshakeFaild:!_isHandshakeSuccess];
}

#pragma mark - Methods

- (void)startHandshaking
{
    NSLog(@"Start handshaking: %d", _dataRequest.length);// Start handshaking
    self.isDisconnected = FALSE;
    [_sendingSocket writeData:_dataRequest withTimeout:REMOTE_TIMEOUT tag:SENDING_SOCKET_TAG];
    [_sendingSocket readDataToLength:7 withTimeout:REMOTE_TIMEOUT tag:SENDING_SOCKET_TAG];

}

- (void)cleanDataUp: (NSTimer *)timer
{
    NSLog(@"-- clean data up ....");
    
    if (self.bufferLength == 0)
    {
        [self.pcmPlayer release];
        self.pcmPlayer = nil;
        
        [self.pcmPlayer.recorder.inMemoryAudioFile flush];
        
        if (_timerVoiceData != nil)
        {
            [_timerVoiceData invalidate];
            self.timerVoiceData = nil;
        }
        
        if (_sendingSocket != nil)
        {
            if ([_sendingSocket isConnected] == YES)
            {
                [_sendingSocket setDelegate:nil];
                [_sendingSocket disconnect];
            }
            [_sendingSocket release];
            _sendingSocket = nil;
        }
        
        if(_pcm_data != nil) {
            [_pcm_data release];
            _pcm_data = nil;
        }
        
        [timer invalidate];
        
        NSLog(@"\nClean data up successfully.");
    }
}

- (void)disconnectFromAudioSocketRemote
{
    //disconnect
	if (self.pcmPlayer != nil)
	{
        NSLog(@"pcmPlayer stop & release ");
        [[self.pcmPlayer player] setPlay_now:FALSE];
		[self.pcmPlayer.recorder stopRecord];
		[self.pcmPlayer Stop];
	}
    
	[NSTimer scheduledTimerWithTimeInterval:0.5f
                                     target:self
                                   selector:@selector(disconnectSocketRemote:)
                                   userInfo:nil
                                    repeats:YES];
    
    self.isDisconnected = TRUE;
}

- (void)disconnectSocketRemote: (NSTimer *)timer
{
    NSLog(@"disconnectSocketRemoteRemote, bufLen: %d", self.bufferLength);
    
    if (self.bufferLength == 0)
    {
        [timer invalidate];
        
        [self.pcmPlayer release];
        self.pcmPlayer = nil;
        
        [self.pcmPlayer.recorder.inMemoryAudioFile flush];
        
        if (_timerVoiceData != nil)
        {
            [_timerVoiceData invalidate];
            self.timerVoiceData = nil;
        }
        
        if (_sendingSocket != nil)
        {
            if ([_sendingSocket isConnected] == YES)
            {
                [_sendingSocket setDelegate:nil];
                [_sendingSocket disconnect];
            }
            
            [_sendingSocket release];
            _sendingSocket = nil;
        }
        
        if(_pcm_data != nil) {
            [_pcm_data release];
            _pcm_data = nil;
        }
        
        if (_fileHandle != nil)
        {
            [_fileHandle closeFile];
            _fileHandle = nil;
        }
        
        if (_audioOutStreamRemoteDelegate)
        {
            if ([_audioOutStreamRemoteDelegate respondsToSelector:@selector(didDisconnecteSocket)]) {
                [_audioOutStreamRemoteDelegate didDisconnecteSocket];
            }
        }
        else
        {
            NSLog(@"%s _audioOutStreamRemoteDelegate == nil", __FUNCTION__);
        }
    }
}

@end
