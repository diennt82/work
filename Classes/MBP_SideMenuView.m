//
//  MBP_SideMenuView.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_SideMenuView.h"


@implementation MBP_SideMenuView

@synthesize multiModeButton, snapShotButton, mainMenuButton,recordButton;

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
	multiModeButton.enabled = !shouldDisable;
	snapShotButton.enabled = !shouldDisable;
	mainMenuButton.enabled = !shouldDisable;
	recordButton.enabled = !shouldDisable;
}

- (void)dealloc {
	[multiModeButton release];
	[snapShotButton release];
	[mainMenuButton release];
	[recordButton release];
    [super dealloc];
}


@end
