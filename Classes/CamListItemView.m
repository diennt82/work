//
//  CamListItemView.m
//  MBP_ios
//
//  Created by NxComm on 4/25/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "CamListItemView.h"


@implementation CamListItemView



@synthesize cameraSnapshot;
@synthesize cameraLocationIndicator;
@synthesize cameraMelodyIndicator;
@synthesize cameraSettings;

@synthesize cameraName;
@synthesize cameraLastComm; 


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
	
	[cameraSnapshot release];
	[cameraLocationIndicator release];
	[cameraMelodyIndicator release];
	[cameraSettings release];

	[cameraName release];
	[cameraLastComm release]; 
}




@end
