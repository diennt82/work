//
//  ADPCMDecoder.m
//  AiBallRecorder
//
//  Created by NxComm on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ADPCMDecoder.h"


@implementation ADPCMDecoder

static const int STEPINCREMENT[16] = {
	8,6,4,2,-1,-1,-1,-1,-1,-1,-1,-1,2,4,6,8};

static const int STEPINCREMENT_MAGNITUDE[8] = {
	-1,-1,-1,-1,2,4,6,8
};

static const int STEPSIZE[89] = {
	7, 8, 9, 10, 11, 12, 13, 14, 16, 17,
	19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
	50, 55, 60, 66, 73, 80, 88, 97, 107, 118,
	130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
	337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
	876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
	2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
	5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
	15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767
};

static const int BLOCKSAMPLES = 505;

static const int SAMPLERATE = 8000;

static const int BLOCKBYTES = (505-1)/2+4;

+ (void)DecodeBlock:(NSData*)adpcm offset:(int)offset data:(NSMutableData*)data {
	[data setLength:(BLOCKSAMPLES*2)];
	int outPos=0,inPos=offset;
	
	char* dataPtr = (char*)[data bytes];
	char* adpcmPtr = (char*)[adpcm bytes];
	
	dataPtr[outPos++]=adpcmPtr[inPos++];
	dataPtr[outPos++]=adpcmPtr[inPos++];
	
	int lastOutput=dataPtr[0]&0xff | dataPtr[1]<<8;
	
	int stepIndex=adpcmPtr[inPos++];
	inPos++;
	
	int highNibble=0;
	for(int i=1;i< BLOCKSAMPLES;i++)
	{
		int delta;
		if(highNibble)
		{
			delta=(char)(((adpcmPtr[inPos]&0xf0)<<24)>>28);
			highNibble=0;
			inPos++;
		}
		else
		{
			delta=(char)(((adpcmPtr[inPos]&0xf)<<28)>>28);
			highNibble=1;
		}
		
		int step= STEPSIZE[stepIndex];
		
		int deltaMagnitude = delta & 0x07;
		
		int valueAdjust =0;
		if ((deltaMagnitude & 4)!=0) valueAdjust += step;
		step = step >> 1;
		if ((deltaMagnitude & 2)!=0) valueAdjust += step;
		step = step >> 1;
		if ((deltaMagnitude & 1)!=0) valueAdjust += step;
		step = step >> 1;
		valueAdjust += step;
		
		if (deltaMagnitude != delta) {
			lastOutput -= valueAdjust;
			if (lastOutput<-0x8000) lastOutput = -0x8000;
		} else {
			lastOutput += valueAdjust;
			if (lastOutput>0x7fff) lastOutput = 0x7fff;
		}
		
		stepIndex+=STEPINCREMENT_MAGNITUDE[deltaMagnitude];
		if(stepIndex<0) stepIndex=0;
		else if(stepIndex>=89) stepIndex=89-1;
		
		dataPtr[outPos++]=(char)(lastOutput&0xff);
		dataPtr[outPos++]=(char)((lastOutput>>8)&0xff);
	}
}

+ (void)Decode:(NSData*)adpcm outData:(NSMutableData*)outData {
	//NSLog(@"ADPCM Decode: input length = %d", [adpcm length]);
	int iBlockNumber = [adpcm length]/BLOCKBYTES;
	[outData setLength:iBlockNumber * BLOCKSAMPLES * 2];
	
	for(int i = 0;i < iBlockNumber;i++)
	{
		NSMutableData* buf = [[NSMutableData alloc] init];
		[ADPCMDecoder DecodeBlock:adpcm offset:i * BLOCKBYTES data:buf];
		char* ptr = (char *)[outData bytes];
		char* src = (char *)[buf bytes];
		memcpy(ptr + i * BLOCKSAMPLES * 2, src, [buf length]);
		[buf release];
	}
}





#define MAX_2(a,b)  ((a>b)?a:b)
#define MIN_2(a,b)  ((a<b)?a:b)



+ (void)EncodeBlock:(NSData*)data_in offset:(int)offset length:(int) length 
			   dataout:(NSMutableData*)data_out {

//public static Block encodeBlock(byte[] data,int offset,int length)

	// If length isn't blockSamples, need to pad with zeros
	if(length<BLOCKSAMPLES*2)
	{
		
		
		NSMutableData* newData = [[NSMutableData alloc] initWithLength:BLOCKSAMPLES*2];
		NSRange old_data_range = {0, length};
		[newData resetBytesInRange:(NSRange) {0, BLOCKSAMPLES*2}];
		[newData replaceBytesInRange:old_data_range withBytes:[data_in bytes]];
		
		
		
		data_in= (NSData *)newData;
		offset=0;
		length=BLOCKSAMPLES*2;
	}
	else if(length>BLOCKSAMPLES*2)
	{
		/*
		throw new IllegalArgumentException("Cannot encode block larger than "+
										   BLOCKSAMPLES+" samples");
		 */
		NSLog(@"Cannot encode block larger than %d samples", BLOCKSAMPLES);
		return;
		
	}
	

	int maxLevel, minLevel;
	char * data, * adpcm;
	
	[data_out setLength:BLOCKBYTES];
	data = (char *) [data_in bytes];
	adpcm = (char *) [data_out bytes];
	
	int outPos=0;
	
	// Initial sample uncompressed
	int lastOutput=(int)data[0+offset]&0xff | (int)data[1+offset]<<8;
	adpcm[outPos++]=data[0+offset];
	adpcm[outPos++]=data[1+offset];
	maxLevel=lastOutput;
	minLevel=lastOutput;
	
	// Initial step index - let's find the next sample and pick the closest
	int nextSample=(int)data[2+offset]&0xff | (int)data[3+offset]<<8;
	int initialDifference=abs(nextSample-lastOutput);
	int stepIndex=0;
	for(;stepIndex< 89 ;stepIndex++)
	{
		if( STEPSIZE[stepIndex]>initialDifference) break;
	}
	if(stepIndex>0) stepIndex--;
	adpcm[outPos++]=(char )stepIndex;
	
	// Blank
	adpcm[outPos++]=0;
	
	BOOL highNibble=false;
	for(int i=2;i<length;i+=2)
	{
		int target=(int)data[i+offset]&0xff | (int)data[i+offset+1]<<8;
		maxLevel=MAX_2(maxLevel,target);
		minLevel=MIN_2(minLevel,target);
		
		int difference = target - lastOutput;
		int step= STEPSIZE[stepIndex];
		
		int delta = (abs(difference)<<2)/step;
		if(delta>7) delta=7;
		if(difference<0) delta|=0x08;
		
		if(highNibble)
		{
			adpcm[outPos++]|=(char)((delta&0xf)<<4);
			highNibble=false;
		}
		else
		{
			adpcm[outPos]=(char)(delta&0xf);
			highNibble=true;
		}
		
		int deltaMagnitude = delta & 0x07;
		
		// Possible delta values
		// 0000 = 0 [+1/8 step]
		// 0001 = 1 [+3/8 step]
		// 0010 = 2 [+5/8 step]
		// 0011 = 3 [+7/8 step]
		// 0100 = 4 [+9/8 step]
		// 0101 = 5 [+11/8 step]
		// 0110 = 6 [+13/8 step]
		// 0111 = 7 [+15/8 step]
		// 1000 = -8 [-1/8 step]
		// 1001 = -7 [-3/8 step]
		// 1010 = -6 [-5/8 step]
		// 1011 = -5 [-7/8 step]
		// 1100 = -4 [-9/8 step]
		// 1101 = -3 [-11/8 step]
		// 1110 = -2 [-13/8 step]
		// 1111 = -1 [-15/8 step]
		
		int valueAdjust =0;
		if ((deltaMagnitude & 4)!=0) valueAdjust += step;
		step = step >> 1;
		if ((deltaMagnitude & 2)!=0) valueAdjust += step;
		step = step >> 1;
		if ((deltaMagnitude & 1)!=0) valueAdjust += step;
		step = step >> 1;
		valueAdjust += step;
		
		if (deltaMagnitude != delta) {
			lastOutput -= valueAdjust;
			if (lastOutput<-0x8000) lastOutput = -0x8000;
		} else {
			lastOutput += valueAdjust;
			if (lastOutput>0x7fff) lastOutput = 0x7fff;
		}
		
		stepIndex+= STEPINCREMENT_MAGNITUDE[deltaMagnitude];
		if(stepIndex<0) stepIndex=0;
		else if(stepIndex>= 89 ) stepIndex= 89 -1;
	}
	
	if(outPos!=[data_out length])
	{
		//throw new Error("Unexpected buffer length mismatch");
		NSLog(@"Unexpected buffer length mismatch");
		
	}
	
}


+ (void)Encode:(NSData*)pcmData outData:(NSMutableData*)adpcmData
{
	
	// Work out how many blocks it will be
	int samples=[pcmData length]/2;
	int blocks=(samples+(BLOCKSAMPLES-1))/BLOCKSAMPLES;
	// Encode and write all the blocks
	int pos=0, i;
	
	
	[adpcmData setLength:(blocks * BLOCKBYTES) ];
	
	
	for(i=0;i<blocks;i++)
	{
		int size=MIN_2(BLOCKSAMPLES*2, [pcmData length]-pos);
		NSMutableData * buf = [[NSMutableData alloc] init];

		[ADPCMDecoder EncodeBlock:pcmData
						   offset:pos
						   length:size 
						  dataout:buf];
		
		char * ptr = (char *)[adpcmData bytes];
		char * src = (char *)[buf bytes];
		memcpy(ptr+i*BLOCKBYTES, src, [buf length]);

		[buf release];
		
		pos+=size;
	}
	
}


@end