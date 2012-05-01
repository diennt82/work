//
//  RemoteIOPlayer.h
//  AiBallRecorder
//
//  Created by NxComm on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicDefine.h"
#import "InMemoryAudioFile.h"

@interface RemoteIOPlayer : NSObject {
	InMemoryAudioFile *inMemoryAudioFile;
	
	InMemoryAudioFile *recordedAudioFile;
	
	BOOL recording_now; 
	BOOL play_now;
	
	}

@property (nonatomic, retain) InMemoryAudioFile *inMemoryAudioFile;

@property (nonatomic, retain) InMemoryAudioFile *recordedAudioFile;
@property (nonatomic) BOOL recording_now, play_now;

-(OSStatus)start;
-(OSStatus)stop;
-(void)cleanUp;
-(void)intialiseAudio;

#if DBG_AUDIO
//DBG:
FILE* fp;
#endif 
@end
