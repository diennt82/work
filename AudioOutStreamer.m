//
//  AudioOutStreamer.m
//  MBP_ios
//
//  Created by NxComm on 5/10/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#define SENDING_SOCKET_TAG 1009
#define REMOTE_TIMEOUT 30

#define TALKBACK_REMOTE_IP @"23.22.154.88"
#define TALKBACK_REMOTE_PORT 25000

#import "AudioOutStreamer.h"

@interface AudioOutStreamer()

@property (retain, nonatomic) NSFileManager *fileManager;
@property (retain, nonatomic) NSFileHandle *fileHandle;
@property (retain, nonatomic) NSString *sentPath;

@end

@implementation AudioOutStreamer
@synthesize pcmPlayer;
@synthesize pcm_data = _pcm_data;


-(id) initWithDeviceIp:(NSString *) ip andPTTport: (int) port
{
	self = [super init];
    if (self)
    {
        device_ip = [NSString stringWithString:ip];
        device_port = port;
        
        hasStartRecordingSound = FALSE;
        self.isInLocal = TRUE;
    }
    
	return self; 
}

- (id)initWithRemoteMode
{
    self = [super init];
    
    if (self)
    {
        device_ip   = TALKBACK_REMOTE_IP;
        device_port = TALKBACK_REMOTE_PORT;
        
        hasStartRecordingSound = FALSE;
        self.isInLocal = FALSE;
        
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
        //[self startRecordingSound];
    }
	sendingSocket = [[AsyncSocket alloc] initWithDelegate:self];
	[sendingSocket setUserData:SOCKET_ID_SEND];
	
	NSString* ip = device_ip;
	
	int port = device_port;
	
    
    NSLog(@"pTT to: %@:%d",device_ip, port);
    
	//Non-blocking connect
    if (_isInLocal)
    {
        [sendingSocket connectToHost:ip onPort:port withTimeout:5 error:nil];
    }
	else
    {
        [sendingSocket connectToHost:ip onPort:port withTimeout:REMOTE_TIMEOUT error:nil];
    }
}

- (void) disconnectFromAudioSocket
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
                                    selector:@selector(disconnectSocket:)
                                    userInfo:nil
                                     repeats:YES];
}

- (void)disconnectSocket: (NSTimer *)timer
{
    NSLog(@"disconnectSocket, bufLen: %d", self.bufferLength);
    
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
        
        if (sendingSocket != nil)
        {
            if ([sendingSocket isConnected] == YES)
            {
                [sendingSocket setDelegate:nil];
                [sendingSocket disconnect];
            }
            [sendingSocket release];
            sendingSocket = nil;
        }
        
        if(_pcm_data != nil) {
            [_pcm_data release];
            _pcm_data = nil;
        }
        
        [timer invalidate];
        [self.audioOutStreamerDelegate cleanup];
        
        if (_fileHandle != nil)
        {
            [_fileHandle closeFile];
        }
    }
}

- (void) sendAudioPacket:(NSTimer *) timer_exp
{
	
	/* read 2kb everytime */
	self.bufferLength = [self.pcmPlayer.recorder.inMemoryAudioFile readBytesPCM:_pcm_data
											withLength:2*1024]; //2*1024
	[sendingSocket writeData:_pcm_data withTimeout:2 tag:SENDING_SOCKET_TAG];
	
    //NSLog(@"AudioOutStreamer - sendAudioPacket: %@", _pcm_data);
    
    if (!_isInLocal)
    {
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
}



#pragma mark TCP socket delegate funcs

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{

	NSLog(@"didConnectToHost Finished");
	if(_isInLocal)
	{

		//Start sending the first 2Kb of data per 0.128 sec
		voice_data_timer = [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04 
															target:self
														  selector:@selector(sendAudioPacket:)
														  userInfo:nil
														   repeats:YES];
	}
    else
    {
        // Start handshake
        [sendingSocket writeData:_dataRequest withTimeout:REMOTE_TIMEOUT tag:SENDING_SOCKET_TAG];
    }
	
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
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
		[self disconnectFromAudioSocket];
	}
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // Waitint for get handshake response
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
        
        voice_data_timer = [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04
                                                            target:self
                                                          selector:@selector(sendAudioPacket:)
                                                          userInfo:nil
                                                           repeats:YES];
    }
    
    if ([data isEqualToData:unexpectedData])
    {
        NSLog(@"Equal Unexpected data");
    }
    
}

@end
