//
//  ADPCMDecoder.h
//  AiBallRecorder
//
//  Created by NxComm on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



@interface ADPCMDecoder : NSObject {

}

+ (void)DecodeBlock:(NSData*)adpcm offset:(int)offset data:(NSMutableData*)data;
+ (void)Decode:(NSData*)adpcm outData:(NSMutableData*)outData;


+ (void)Encode:(NSData*)pcmData outData:(NSMutableData*)adpcmData;

@end
