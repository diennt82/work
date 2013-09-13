//
//  AiBallPlayViewController.h
//  AiBallRecorder
//
//  Created by NxComm on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiBallAviPlayer.h"
#import <H264MediaPlayer/H264MediaPlayer.h>

@interface AiBallPlayViewController : UIViewController {
	AiBallAviPlayer* aviPlayer;
	NSString* filename;
	IBOutlet UIImageView * imageView;
	PCMPlayer* pcmPlayer;
}

@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (retain) NSString* filename;
- (IBAction) stopPlayback: (id) sender;
- (void) onVideoEnd;
- (void) onPCM:(NSData*)pcm;
- (void) onFrame:(NSData*)frame;

@end
