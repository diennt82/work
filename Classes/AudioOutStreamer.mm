//
//  AudioOutStreamer.m
//  MBP_ios
//
//  Created by NxComm on 5/10/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "AudioOutStreamer.h"


@implementation AudioOutStreamer
@synthesize pcmPlayer; 


-(id) initWithDeviceIp:(NSString *) ip andPTTport: (int) port
{
	[super init];
	device_ip = [NSString stringWithString:ip];
	device_port = port; 
	
	return self; 
}

-(void) dealloc
{
    [pcmPlayer release]; 
    
    [super dealloc]; 
}

/* Connect to the audio streaming socket to stream recorded data TO device */
- (void) connectToAudioSocket 
{

    
    
	/* Start the player to playback & record */
	self.pcmPlayer = [[PCMPlayer alloc] init];
	pcm_data = [[NSMutableData alloc] init];
	
	[self.pcmPlayer Play:TRUE];//initialize
	[[self.pcmPlayer player] setPlay_now:FALSE];//disable playback 
	[self.pcmPlayer.recorder startRecord];
	
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
		[self.pcmPlayer release];
        self.pcmPlayer = nil; 
	}
	
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
		[pcm_data release];
		pcm_data = nil;
	}
	
	
	
}

- (void) sendAudioPacket:(NSTimer *) timer_exp
{
	
	/* read 2kb everytime */
	[self.pcmPlayer.recorder.inMemoryAudioFile readBytesPCM:pcm_data 
											withLength:2*1024]; //2*1024
	
	[sendingSocket writeData:pcm_data withTimeout:2 tag:SENDING_SOCKET_TAG];
	
}



#pragma mark TCP socket delegate funcs 

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{

	
	//if(port == IRABOT_AUDIO_RECORDING_PORT)
	{

		//Start sending the first 2Kb of data per 0.128 sec
		voice_data_timer = [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04 
															target:self
														  selector:@selector(sendAudioPacket:)
														  userInfo:nil
														   repeats:YES];
	}

	
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"AudioOutStreamer- connection failed with error:%d:%@" , 
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
