//
//  AudioOutStreamer.m
//  MBP_ios
//
//  Created by NxComm on 5/10/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "AudioOutStreamer.h"


@implementation AudioOutStreamer

-(id) initWithDeviceIp:(NSString *) ip andPTTport: (int) port
{
	[super init];
	device_ip = [NSString stringWithString:ip];
	device_port = port; 
	
	return self; 
}


/* Connect to the audio streaming socket to stream recorded data TO device */
- (void) connectToAudioSocket 
{
	/* Start the player to playback & record */
	pcmPlayer = [[PCMPlayer alloc] init];
	pcm_data = [[NSMutableData alloc] init];
	
	[pcmPlayer Play];//initialize
	[[pcmPlayer player] setPlay_now:FALSE];//disable playback 
	[pcmPlayer.recorder startRecord];
	
	sendingSocket = [[AsyncSocket alloc] initWithDelegate:self];
	[sendingSocket setUserData:SOCKET_ID_SEND];
	
	NSString* ip = device_ip;
	
	int port = device_port;
	
	//Non-blocking connect
	[sendingSocket connectToHost:ip onPort:port withTimeout:2 error:nil];
}

- (void) disconnectFromAudioSocket
{
	//disconnect 
	if (pcmPlayer != nil)
	{
		[pcmPlayer.recorder stopRecord];
		[pcmPlayer Stop];
		[pcmPlayer release];
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
	[pcmPlayer.recorder.inMemoryAudioFile readBytesPCM:pcm_data 
											withLength:2*1024]; //2*1024
	
	[sendingSocket writeData:pcm_data withTimeout:2 tag:SENDING_SOCKET_TAG];
	
}



#pragma mark TCP socket delegate funcs 

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{

	
	if(port == IRABOT_AUDIO_RECORDING_PORT)
	{

		//Start sending the first 2Kb of data per 0.128 sec
		voice_data_timer = [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04 
															target:self
														  selector:@selector(sendAudioPacket:)
														  userInfo:nil
														   repeats:YES];
	}

	
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	
	if ( sendingSocket != nil && [sendingSocket isConnected] == NO)
	{
		[self disconnectFromAudioSocket];
	}

}



@end
