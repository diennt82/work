//
//  MBP_SideMenuView.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define SIDEBUTTON_MULTICAM_TAG 201
#define SIDEBUTTON_SNAPSHOT_TAG 202
#define SIDEBUTTON_MAINMENU_TAG 203
#define SIDEBUTTON_RECORD_TAG   204


@interface MBP_SideMenuView : UIView {

	/* side menu buttons */
	IBOutlet UIButton * multiModeButton;
	IBOutlet UIButton * snapShotButton;
	IBOutlet UIButton * mainMenuButton;
	IBOutlet UIButton * recordButton;
}


@property (nonatomic,retain) IBOutlet UIButton	* multiModeButton, *snapShotButton, *mainMenuButton,*recordButton;



- (void) setupButtons;
- (void) disableAllButtons:(BOOL) shouldDisable;


@end
