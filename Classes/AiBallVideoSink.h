//
//  AiBallVideoSink.h
//  AiBallRecorder
//
//  Created by NxComm on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AiBallVideoSink
- onVideoEnd;
- onPCM:(NSData*)pcm;
- onFrame:(NSData*)frame;
@end
