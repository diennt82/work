//
//  AiBallAviPlayer.m
//  AiBallRecorder
//
//  Created by NxComm on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AiBallAviPlayer.h"
#import "PublicDefine.h"

@implementation AiBallAviPlayer

@synthesize videoSink;

static const int EStopped = 0;
static const int EUninitialized = 1;
static const int EInitialized = 2;
static const int EFrameDelay = 3;
static const int EError = 4;

- (id) init
{
	iState = EStopped;
	frame = nil;
}

- (void) dealloc
{
	[frame release];
	[super dealloc];
}

- (void)Stop
{
	iState = EStopped;
	[[self videoSink] onVideoEnd];
	[timer invalidate];
	timer = nil;
	if(iFile != nil) {
		fclose(iFile);
		iFile = nil;
	}
}

- (void)Start:(NSString*)filename
{
	if(iState != EStopped) 
	{
		return;
	}
	if(frame == nil) {
		frame = [[NSMutableData alloc] init];
	}
	iState = EUninitialized;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(Run) userInfo:nil repeats:YES]; 
	iFileName = filename;
	[iFileName retain];
	iLastFrameTime = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
}

-(void) Run
{
	//NSLog(@"Run");
	if (iState == EStopped) {
		return;
	}
	else if (iState == EUninitialized)
	{
		iFile = fopen([iFileName cString], "rb");
		[self ParseAviHeader];
		iState = EInitialized;
	}
	else if (iState == EFrameDelay) {
		long long a = (long long)([[NSDate date] timeIntervalSince1970] * 1000) - iLastFrameTime;
		long long b = 1000000 / iFrameRate;
		
		//NSLog(@"framerate=%d a=%d b=%d", iFrameRate, a, b);
		if(a < b) return;

		[[self videoSink] onFrame:frame];
		iLastFrameTime = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
		iState = EInitialized;
	}
	else if (iState == EInitialized)
	{
		
#ifdef IBALL_AUDIO_SUPPORT
		int frameType = [self ReadFrameType];
		if(frameType == -1) {
			// end of stream
			fclose(iFile);
			iFile = nil;
			[[self videoSink] onVideoEnd];
			iState = EStopped;
			return;
		}
#endif
		int res = [self ReadFrame:frame];
		if(res < 0) {
			// end of stream
			fclose(iFile);
			iFile = nil;
			[[self videoSink] onVideoEnd];
			iState = EStopped;
			return;
		}
		
#ifdef IBALL_AUDIO_SUPPORT
		// for audio data, play immediately
		// only for video data we need to account
		// for frame rate
		if(frameType == 2) {
			[[self videoSink] onPCM:frame];
			iLastPCMTime = (long long)([[NSDate date] timeIntervalSince1970] * 1000);

			return;
		}
#endif
		// when we reach here it's a video frame
		// set the flag so that we can handle 
		// frame rate properly
		iState = EFrameDelay;
		return;
	}
}

-(int) ReadFrameType 
{
	int peek = 0;
	int type = 0;
	unsigned char b;
	unsigned char junk[2];
	
	int res = fread(&b, 1, 1, iFile);

	if(res != 1) return -1;
	fread(&b, 1, 1, iFile);
	fread(junk, 2, 1, iFile);

	if(b == 49) {
		// beginning of 01wb - audio
		type = 2;
	} else if(b == 48) {
		// beginning of 00db - video
		type = 1;
	}
	
	return type;
}

-(int) ReadFrame:(NSMutableData*)frame 
{
	int size = [self ReadInt];
	if(size < 0) return -1;
	[frame setLength:size];
	unsigned char* ptr = [frame bytes];
	fread(ptr, size, 1, iFile);
	return 0;
}

- ParseAviHeader 
{
#ifdef IBALL_AUDIO_SUPPORT
	int pos;
	pos = 0x84;
	fseek(iFile, pos, SEEK_CUR);
	iFrameRate = [self ReadInt];
	pos = 4;
	fseek(iFile, pos, SEEK_CUR);
	iTotalFrames = [self ReadInt];
	pos = 32;
	fseek(iFile, pos, SEEK_CUR);
	iWidth = [self ReadInt];
	iHeight = [self ReadInt];
	pos = 28;
	fseek(iFile, pos, SEEK_CUR);
	
	// junk
	pos = 4;
	fseek(iFile, pos, SEEK_CUR);
	pos = [self ReadInt];
	fseek(iFile, pos, SEEK_CUR);
	
	// list
	pos = 76;
	fseek(iFile, pos, SEEK_CUR);
	// strf
	pos = 4;
	fseek(iFile, pos, SEEK_CUR);
	pos = [self ReadInt];
	fseek(iFile, pos, SEEK_CUR);
	
	// junk 2
	pos = 4;
	fseek(iFile, pos, SEEK_CUR);
	pos = [self ReadInt];
	fseek(iFile, pos, SEEK_CUR);
	// junk 3
	pos = 4;
	fseek(iFile, pos, SEEK_CUR);
	pos = [self ReadInt];
	fseek(iFile, pos, SEEK_CUR);
	
	// list
	pos = 12;
	fseek(iFile, pos, SEEK_CUR);
#else
	iFrameRate = 17000;
#endif
}

-(int) ReadInt {
	unsigned char data[4];
	int res = fread(data, 4, 1, iFile);
	if(res != 1) return -1;
	return data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24);
}

@end