//
//  MBP_SideMenuView.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define SIDEBUTTON_MAINMENU_TAG 203
#define SIDEBUTTON_MULTICAM_TAG 204
#define SIDEBUTTON_PTT_TAG 205

#define MELODY_SELECTION_TAG 206 

@interface MBP_RightSideMenuView : UIView {

	/* right side menu buttons */
	IBOutlet UIButton * mainMenuButton;
	IBOutlet UIButton * multiModeButton;
	IBOutlet UIButton * pushTTButton;


}


@property (nonatomic,retain) IBOutlet UIButton	* multiModeButton,  *mainMenuButton,*pushTTButton;



- (void) setupButtons;
- (void) disableAllButtons:(BOOL) shouldDisable;


@end
