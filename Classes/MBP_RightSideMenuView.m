//
//  MBP_SideMenuView.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_RightSideMenuView.h"


@implementation MBP_RightSideMenuView

@synthesize multiModeButton, pushTTButton, mainMenuButton;

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
	}

- (void) disableAllButtons:(BOOL) shouldDisable;
{
	multiModeButton.enabled = !shouldDisable;
	pushTTButton.enabled = !shouldDisable;
	mainMenuButton.enabled = !shouldDisable;

}

- (void)dealloc {
	[multiModeButton release];
	[pushTTButton release];
	[mainMenuButton release];

    [super dealloc];
}

@end
