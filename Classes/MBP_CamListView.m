//
//  MBP_CamListView.m
//  MBP_ios
//
//  Created by NxComm on 4/25/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_CamListView.h"


@implementation MBP_CamListView


@synthesize channel1; 
@synthesize channel2; 
@synthesize channel3; 
@synthesize channel4; 
@synthesize channelViews; 
@synthesize usrEmail; 

- (id)initWithFrame:(CGRect)frame {

    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder 
{
    if ((self = [super initWithCoder:coder])) 
    {
		// Initialization code
	
		
	}
    return self;
}

/* tobe called only after the view is loaded.. otherwise channelViews count == 0 
 because channelx is nil
 */
- (void) initViews
{
	/* populate the array here*/
	self.channelViews = [NSArray arrayWithObjects:channel1, channel2, channel3, channel4, nil];
	
	//show the User id on status bar
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * userName = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
	if (userName != nil)
	{
		[self.usrEmail setText:userName];
	}
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
	[channel1 release];
	[channel2 release];
	[channel3 release];
	[channel4 release];
	[channelViews release];
	[usrEmail release]; 
}


@end
