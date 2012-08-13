//
//  MBP_SideMenuView.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_LeftSideMenuView.h"


@implementation MBP_LeftSideMenuView

@synthesize melodyButton, snapShotButton,recordButton;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self setupButtons];
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


- (void) setupButtons
{
	
	//[lang autorelease];
//	[lang addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) disableAllButtons:(BOOL) shouldDisable;
{
	melodyButton.enabled = !shouldDisable;
	snapShotButton.enabled = !shouldDisable;
	recordButton.enabled = !shouldDisable;
}

- (void)dealloc {
	[melodyButton release];
	[snapShotButton release];
	[recordButton release];
    [super dealloc];
}


@end
