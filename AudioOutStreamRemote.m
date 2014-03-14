//
//  AudioOutStreamRemote.m
//  BlinkHD_ios
//
//  Created by Developer on 3/14/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#define SENDING_SOCKET_TAG 1009
#define REMOTE_TIMEOUT 30

#define TALKBACK_REMOTE_IP @"23.22.154.88"
#define TALKBACK_REMOTE_PORT 25000

#import "AudioOutStreamRemote.h"

@interface AudioOutStreamRemote()

@property (retain, nonatomic) NSFileManager *fileManager;
@property (retain, nonatomic) NSFileHandle *fileHandle;
@property (retain, nonatomic) NSString *sentPath;

@end

@implementation AudioOutStreamRemote

@synthesize pcmPlayer;
@synthesize pcm_data = _pcm_data;

- (id)initWithRemoteMode
{
    self = [super init];
    
    if (self)
    {
        device_ip   = TALKBACK_REMOTE_IP;
        device_port = TALKBACK_REMOTE_PORT;
        
        hasStartRecordingSound = FALSE;
        self.isDisconnected = TRUE;
        
        NSLog(@"Create AudioOutStreamer & start recording now");
        NSLog(@"PTT remote -IP: %@,  Port: %d", device_ip, device_port);
    }
    
    return self;
}

-(void) dealloc
{
    [pcmPlayer release];
    [_fileManager release];
    [_fileHandle release];
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
- (void) connectToAudioSocket
{
	if (hasStartRecordingSound == FALSE)
    {
        [self startRecordingSound];
    }
    
    if (sendingSocket == nil)
    {
        sendingSocket = [[AsyncSocket alloc] initWithDelegate:self];
        [sendingSocket setUserData:SOCKET_ID_SEND];
    }
	
	NSString* ip = device_ip;
	
	int port = device_port;
	
    
    NSLog(@"pTT to: %@:%d",device_ip, port);
    
	//Non-blocking connect
    [sendingSocket connectToHost:ip onPort:port withTimeout:REMOTE_TIMEOUT error:nil];
}

- (void) sendAudioPacket:(NSTimer *) timer_exp
{
	
	/* read 2kb everytime */
	self.bufferLength = [self.pcmPlayer.recorder.inMemoryAudioFile readBytesPCM:_pcm_data
                                                                     withLength:2*1024]; //2*1024
	[sendingSocket writeData:_pcm_data withTimeout:2 tag:SENDING_SOCKET_TAG];
	
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
        // Start handshake
    self.isDisconnected = FALSE;
    [sendingSocket writeData:_dataRequest withTimeout:REMOTE_TIMEOUT tag:SENDING_SOCKET_TAG];
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    self.isDisconnected = TRUE;
    self.isHandshakeSuccess = FALSE;
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
	if ( sendingSocket != nil && [sendingSocket isConnected] == NO)
	{
		[self stopRecordingSound];
	}
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // Waiting for get handshake response
    [sendingSocket readDataToLength:7 withTimeout:REMOTE_TIMEOUT tag:SENDING_SOCKET_TAG];
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
        
        voice_data_timer = [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04
                                                            target:self
                                                          selector:@selector(sendAudioPacket:)
                                                          userInfo:nil
                                                           repeats:YES];
    }
    
    if ([data isEqualToData:unexpectedData])
    {
        NSLog(@"Equal Unexpected data");
        [self stopRecordingSound];
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
}

- (void)stopRecordingSound
{
    if (self.pcmPlayer != nil)
	{
        NSLog(@"pcmPlayer stop & release ");
        [[self.pcmPlayer player] setPlay_now:FALSE];
		[self.pcmPlayer.recorder stopRecord];
		[self.pcmPlayer Stop];
	}
    
	[NSTimer scheduledTimerWithTimeInterval:0.5f
                                     target:self
                                   selector:@selector(cleanDataUp:)
                                   userInfo:nil
                                    repeats:YES];
    
}

- (void)cleanDataUp: (NSTimer *)timer
{
    if (self.bufferLength == 0)
    {
        [self.pcmPlayer release];
        self.pcmPlayer = nil;
        
        [self.pcmPlayer.recorder.inMemoryAudioFile flush];
        
        if (voice_data_timer != nil)
        {
            [voice_data_timer invalidate];
            voice_data_timer = nil;
        }
        
        if(_pcm_data != nil) {
            [_pcm_data release];
            _pcm_data = nil;
        }
        
        [timer invalidate];
        
        if (_fileHandle != nil)
        {
            [_fileHandle closeFile];
        }
    }
}

- (void)startSendData
{
    NSLog(@"Start send data");
    
    if (voice_data_timer != nil)
    {
        [voice_data_timer invalidate];
        voice_data_timer = nil;
    }
    
    voice_data_timer = [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04
                                                        target:self
                                                      selector:@selector(sendAudioPacket:)
                                                      userInfo:nil
                                                       repeats:YES];
}

@end
