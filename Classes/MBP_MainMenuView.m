//
//  MBP_MainMenuView.m
//  MBP_ios
//
//  Created by NxComm on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_MainMenuView.h"


@implementation MBP_MainMenuView

@synthesize melodyButton;

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


- (void) hideSingleCameraButtons:(BOOL) shouldHide
{
	
	melodyButton.hidden = shouldHide;
	temperatureButton.hidden = shouldHide;
	picQualityButton.hidden = shouldHide;
	voxButton.hidden = shouldHide;
	ledButton.hidden = shouldHide; 
	statusButton.hidden = shouldHide;
	
}



- (void)dealloc {
	[melodyButton release];
    [super dealloc];
}


@end
