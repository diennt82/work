//
//  MBP_MulitCamView.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosViewController.h"
#import "MBP_Streamer.h"

@class MBP_Streamer;
@class MBP_iosViewController;


#define MULTICAM_CHANNEL_1_TAG 102
#define MULTICAM_CHANNEL_2_TAG 103
#define MULTICAM_CHANNEL_3_TAG 104
#define MULTICAM_CHANNEL_4_TAG 105

@interface MBP_MulitCamView : UIView {

	MBP_iosViewController * viewController;
	
	IBOutlet UIImageView * channel1_video; 
	IBOutlet UIImageView * channel2_video;
	IBOutlet UIImageView * channel3_video; 
	IBOutlet UIImageView * channel4_video;
	
	MBP_Streamer * channel1_streamer;
	MBP_Streamer * channel2_streamer;
	MBP_Streamer * channel3_streamer;
	MBP_Streamer * channel4_streamer;
	
	IBOutlet UIActivityIndicatorView * connecting;
	
	
}

@property (nonatomic,retain) MBP_iosViewController * viewController;

@property (nonatomic,retain) IBOutlet UIImageView * channel1_video; 
@property (nonatomic,retain) IBOutlet UIImageView * channel2_video;
@property (nonatomic,retain) IBOutlet UIImageView * channel3_video; 
@property (nonatomic,retain) IBOutlet UIImageView * channel4_video;


@property (nonatomic,retain) IBOutlet UIActivityIndicatorView * connecting;


- (void) initializedWithViewController:(MBP_iosViewController *) viewctlr;
- (void) setupStreamingWithChannelArray:(NSArray*) channel_array;
- (void) disconnectAllChannels;
@end
