//
//  MBP_FirstView.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "MBP_iosViewController.h"
#import "MBP_CamView.h"


@implementation MBP_CamView

@synthesize statusBar,leftSideMenu, rightSideMenu, oneCamView;


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


@end
