//
//  AudioOutStreamer.m
//  MBP_ios
//
//  Created by NxComm on 5/10/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#define SENDING_SOCKET_TAG 1009

#import "AudioOutStreamer.h"

@interface AudioOutStreamer()

@end

@implementation AudioOutStreamer
@synthesize pcmPlayer;
@synthesize pcm_data;


-(id) initWithDeviceIp:(NSString *) ip andPTTport: (int) port
{
	self = [super init];
    if (self)
    {
        device_ip = [NSString stringWithString:ip];
        device_port = port;
        
        hasStartRecordingSound = FALSE;
    }
    
	return self; 
}

-(void) dealloc
{
    [pcmPlayer release];
    [pcm_data release];
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
            pcmPlayer = [[PCMPlayer alloc] init];
            pcm_data = [[NSMutableData alloc] init];
            
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
	sendingSocket = [[AsyncSocket alloc] initWithDelegate:self];
	[sendingSocket setUserData:SOCKET_ID_SEND];
	
	NSString* ip = device_ip;
	
	int port = device_port;
	
    
    NSLog(@"pTT to: %@:%d",device_ip, port);
    
	//Non-blocking connect
    [sendingSocket connectToHost:ip onPort:port withTimeout:5 error:nil];
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
    //[self disconnectSocket:nil];
}

- (void)disconnectSocket: (NSTimer *)timer
{
    NSLog(@"disconnectSocket, bufLen: %d", self.bufferLength);
    
    if (self.bufferLength == 0)
    {
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
        
        if(pcm_data != nil) {
            self.pcm_data = nil;
        }
        
        [timer invalidate];
        [self.audioOutStreamerDelegate cleanup];
    }
    
    //[self.audioOutStreamerDelegate cleanup];
}

- (void) sendAudioPacket:(NSTimer *) timer_exp
{
	
	/* read 2kb everytime */
	self.bufferLength = [self.pcmPlayer.recorder.inMemoryAudioFile readBytesPCM:pcm_data
											withLength:3*1024]; //2*1024
	[sendingSocket writeData:pcm_data withTimeout:2 tag:SENDING_SOCKET_TAG];
}



#pragma mark TCP socket delegate funcs

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{

	NSLog(@"didConnectToHost Finished");
    
    //Start sending the first 2Kb of data per 0.128 sec
    voice_data_timer = [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04
                                                        target:self
                                                      selector:@selector(sendAudioPacket:)
                                                      userInfo:nil
                                                       repeats:YES];
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

@end
