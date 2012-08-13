//
//  MBP_MulitCamView.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_MulitCamView.h"
#import "CamChannel.h"
#import "Util.h"


@implementation MBP_MulitCamView
@synthesize channel1_video, channel2_video, channel3_video, channel4_video;
@synthesize viewController,connecting;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void) initializedWithViewController:(MBP_iosViewController *) viewctlr
{

	self.viewController = viewctlr;
	
	
	self.channel1_video.userInteractionEnabled = FALSE;
	self.channel2_video.userInteractionEnabled = FALSE;
	self.channel3_video.userInteractionEnabled = FALSE;
	self.channel4_video.userInteractionEnabled = FALSE;
}



- (void)dealloc {
	[channel1_streamer release];
	[channel2_streamer release];
	[channel3_streamer release];
	[channel4_streamer release];
	
	
	
	[channel1_video release]; 
	[channel2_video release];
	[channel3_video release]; 
	[channel4_video release];
	[viewController release];
    [super dealloc];
}




#pragma mark -
#pragma mark Handle Touches 


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}



- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
#if 0 //-- NOT USED
	UITouch *touch;
	CGPoint location ;	
	NSString * saved_url = nil;
	NSSet *allTouches = [event allTouches];
	[super touchesEnded:touches withEvent:event];
	///NSLog(@"Ended Touches count: %d", [allTouches count]);
	int i =0;
	
	for (i =0 ; i < [allTouches count]; i++)
	{
		touch = [ [allTouches allObjects] objectAtIndex:i] ;
		//NSLog(@"touched view:Tag:%d", touch.view.tag);
		location = [touch locationInView:touch.view];
		
		if (touch.view.tag == MULTICAM_CHANNEL_1_TAG)
		{
			saved_url= [NSString stringWithFormat:@"http://%@:%d",channel1_streamer.device_ip,channel1_streamer.device_port];
			[Util setDefaultURL:saved_url];
			
			
			[viewController switchToSingleCameraMode:1];
			[self disconnectAllChannels];
			
		}
		
		if (touch.view.tag == MULTICAM_CHANNEL_2_TAG)
		{
			saved_url= [NSString stringWithFormat:@"http://%@:%d",channel2_streamer.device_ip,channel2_streamer.device_port];
			[Util setDefaultURL:saved_url];

			[viewController switchToSingleCameraMode:2];
			[self disconnectAllChannels];
			
			
		}
		if (touch.view.tag == MULTICAM_CHANNEL_3_TAG)
		{
			saved_url= [NSString stringWithFormat:@"http://%@:%d",channel3_streamer.device_ip,channel3_streamer.device_port];
			[Util setDefaultURL:saved_url];
			[viewController switchToSingleCameraMode:3];

			[self disconnectAllChannels];
		}
		
		if (touch.view.tag == MULTICAM_CHANNEL_4_TAG)
		{
			saved_url= [NSString stringWithFormat:@"http://%@:%d",channel4_streamer.device_ip,channel4_streamer.device_port];
			[Util setDefaultURL:saved_url];
			[viewController switchToSingleCameraMode:4];
			[self disconnectAllChannels];
		}
		
	}
#endif 
	
}






#pragma mark -
#pragma mark Setup Channels 

- (void) disconnectAllChannels
{
	
	self.channel1_video.userInteractionEnabled = FALSE;
	self.channel2_video.userInteractionEnabled = FALSE;
	self.channel3_video.userInteractionEnabled = FALSE;
	self.channel4_video.userInteractionEnabled = FALSE;
	
	if (channel1_streamer != nil)
	{
		[channel1_streamer stopStreaming];
		[channel1_streamer release];
		channel1_streamer = nil;
	}
	self.channel1_video.image = nil;
	self.channel1_video.backgroundColor = [UIColor blackColor];

	
	if (channel2_streamer != nil)
	{
		[channel2_streamer stopStreaming];
		[channel2_streamer release];
		channel2_streamer = nil;
	}
	self.channel2_video.image = nil;
	self.channel2_video.backgroundColor = [UIColor blackColor];
	
	
	if (channel3_streamer != nil)
	{
		[channel3_streamer stopStreaming];
		[channel3_streamer release];
		channel3_streamer = nil;
	}
	self.channel3_video.image = nil;
	self.channel3_video.backgroundColor = [UIColor blackColor];
	
	
	if (channel4_streamer != nil)
	{
		[channel4_streamer stopStreaming];
		[channel4_streamer release];
		channel4_streamer = nil;
	}
	self.channel4_video.image = nil;
	self.channel4_video.backgroundColor = [UIColor blackColor];
	
}


- (void) setupStreamingWithChannelArray:(NSArray*) channel_array
{
	CamChannel * ch1 = nil, * ch2 = nil, *ch3 = nil, *ch4 = nil;
	
	
	
	self.channel1_video.userInteractionEnabled = FALSE;
	self.channel2_video.userInteractionEnabled = FALSE;
	self.channel3_video.userInteractionEnabled = FALSE;
	self.channel4_video.userInteractionEnabled = FALSE;
	
	ch1 = (CamChannel *) [channel_array objectAtIndex:0];
	if (ch1.channel_configure_status == CONFIGURE_STATUS_ASSIGNED)
	{
		channel1_streamer = [[MBP_Streamer alloc] initWithIp:ch1.profile.ip_address
													 andPort:ch1.profile.port];
		[channel1_streamer setVideoView:self.channel1_video];
		[channel1_streamer startStreaming];
		
		self.channel1_video.userInteractionEnabled = TRUE;
	}
	else
	{
		if (channel1_streamer != nil)
		{
			[channel1_streamer stopStreaming];
			[channel1_streamer release];
			channel1_streamer = nil;
		}
		self.channel1_video.image = nil;
		self.channel1_video.backgroundColor = [UIColor blackColor];
		
	}

	
	ch2 = (CamChannel *) [channel_array objectAtIndex:1];
	if (ch2.channel_configure_status == CONFIGURE_STATUS_ASSIGNED)
	{
		channel2_streamer = [[MBP_Streamer alloc] initWithIp:ch2.profile.ip_address
													 andPort:ch2.profile.port];
		[channel2_streamer setVideoView:self.channel2_video];
		[channel2_streamer startStreaming];
		
		self.channel2_video.userInteractionEnabled = TRUE;
	}
	else
	{
		if (channel2_streamer != nil)
		{
			[channel2_streamer stopStreaming];
			[channel2_streamer release];
			channel2_streamer = nil;
		}
		self.channel2_video.image = nil;
		self.channel2_video.backgroundColor = [UIColor blackColor];
		
	}
	
	
	ch3 = (CamChannel *) [channel_array objectAtIndex:2];
	if (ch3.channel_configure_status == CONFIGURE_STATUS_ASSIGNED)
	{
		channel3_streamer = [[MBP_Streamer alloc] initWithIp:ch3.profile.ip_address
													 andPort:ch3.profile.port];
		[channel3_streamer setVideoView:self.channel3_video];
		[channel3_streamer startStreaming];
		self.channel3_video.userInteractionEnabled = TRUE;
	}
	else
	{
		if (channel3_streamer != nil)
		{
			[channel3_streamer stopStreaming];
			[channel3_streamer release];
			channel3_streamer = nil;
		}
		self.channel3_video.image = nil;
		self.channel3_video.backgroundColor = [UIColor blackColor];
		
	}

	
	ch4 = (CamChannel *) [channel_array objectAtIndex:3];
	if (ch4.channel_configure_status == CONFIGURE_STATUS_ASSIGNED)
	{
		channel4_streamer = [[MBP_Streamer alloc] initWithIp:ch4.profile.ip_address
													 andPort:ch4.profile.port];
		[channel4_streamer setVideoView:self.channel4_video];
		[channel4_streamer startStreaming];
		
		self.channel4_video.userInteractionEnabled = TRUE;
	}
	else
	{
		if (channel4_streamer != nil)
		{
			[channel4_streamer stopStreaming];
			[channel4_streamer release];
			channel4_streamer = nil;
		}
		self.channel4_video.image = nil;
		self.channel4_video.backgroundColor = [UIColor blackColor];
		
	}
	
}




@end
