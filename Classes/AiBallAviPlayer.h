//
//  AiBallAviPlayer.h
//  AiBallRecorder
//
//  Created by NxComm on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiBallVideoSink.h"

@interface AiBallAviPlayer : NSObject <AiBallVideoSink> {

	id <AiBallVideoSink> videoSink;
	NSTimer* timer;
	FILE* iFile;
	NSString* iFileName;
	int iState;
	long long iLastFrameTime;
	long long iLastPCMTime;
	int iFrameRate;
	int iTotalFrames;
	int iWidth;
	int iHeight;
	NSMutableData* frame;
}

@property (retain) id videoSink;
-(void)Start:(NSString*)filename;
-(void)Stop;
-(void)Run;
-(int) ReadInt ;
-(int) ReadFrame:(NSMutableData*)frame;
@end
