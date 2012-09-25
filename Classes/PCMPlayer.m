//
//  PCMPlayer.m
//  AiBallRecorder
//
//  Created by NxComm on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PCMPlayer.h"

@implementation PCMPlayer

@synthesize player;
@synthesize recorder;
@synthesize inMemoryAudioFile;


- (id) init
{
	iInitialFlag = 1;
    self = [super init]; 
    recorder = nil;
    player = nil; 
    inMemoryAudioFile= nil; 
    

    
	return self;
}


- (void) Play: (BOOL) recordEnabled
{
	if(iInitialFlag == 1)
	{
		//allocate the audio player
		player = [[RemoteIOPlayer alloc]init];
        
        player.recordEnabled = recordEnabled; 
        
		//initialise the audio player
		[player intialiseAudio];
		inMemoryAudioFile = [[InMemoryAudioFile alloc]init];
		
		[inMemoryAudioFile flush];
		
		//open the a wav file from the application resources
		//[inMemoryAudioFile open:[[NSBundle mainBundle] pathForResource:@"iball" ofType:@"pcm"]];
		[player setInMemoryAudioFile: inMemoryAudioFile];
		[player setPlay_now:FALSE];
		
#ifdef IRABOT_AUDIO_RECORDING_SUPPORT		
		// init recorder here and set Audiofile here as well
		
		recorder = [[AudioRecorder alloc] init];
		[recorder setPlayer:player];
		
#endif
		iInitialFlag = 0;
	}
	
	[[player inMemoryAudioFile]reset];
	[player start];
}

- (void) Stop
{
	[player stop];
}

- (void) WritePCM:(unsigned char*)pcm length:(int)length
{
	[[player inMemoryAudioFile] writePCM:pcm length:length];
}



- (void)dealloc {
    


    
	if (recorder != nil)
	{

        //Dont call stop record here let whoever start it .. to stop it 
		//[recorder stopRecord];
		[recorder release];
        recorder = nil; 
	}
	if(player != nil) {


		[player cleanUp];
		[player release];
		player = nil;
	}
	if(inMemoryAudioFile != nil) {

		[inMemoryAudioFile release];
	}
    


	[super dealloc];
   
}
@end
