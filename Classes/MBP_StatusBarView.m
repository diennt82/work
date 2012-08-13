//
//  MBP_StatusBarView.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_StatusBarView.h"


@implementation MBP_StatusBarView

@synthesize   video_rec_status_icon, channel_status_icon;
@synthesize wifi_status_icon;
@synthesize temperature_label, camName_label,batt_status_icon;

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

- (void)dealloc {
    [super dealloc];
}

- (void) switchChannel:(int) ch
{
	NSString * imageName = nil;
	switch (ch) {
		case 1:
			imageName = @"status_icon4_1.png";
			break;
		case 2:
			imageName = @"status_icon4_2.png";
			break;
		case 3:
			imageName = @"status_icon4_3.png";
			break;
		case 4:
			imageName = @"status_icon4_4.png";
			break;
		default:
			break;
	}
	
	if ( imageName == nil)
	{
		
		self.channel_status_icon.hidden = YES;
	}
	else
	{
		NSLog(@"set channel image: %@", imageName);
		self.channel_status_icon.hidden = NO;
		[self.channel_status_icon setImage:[UIImage imageNamed:imageName]];
	}

	
	
	
}

@end
