//
//  MBP_SideMenuView.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



#define SIDEBUTTON_SNAPSHOT_TAG 200
#define SIDEBUTTON_RECORD_TAG   201
#define SIDEBUTTON_MELODY_TAG   202




@interface MBP_LeftSideMenuView : UIView {

	/* side menu buttons */
	IBOutlet UIButton * snapShotButton;
	IBOutlet UIButton * recordButton;
	IBOutlet UIButton * melodyButton;
}


@property (nonatomic,retain) IBOutlet UIButton	* melodyButton, *snapShotButton, *recordButton;



- (void) setupButtons;
- (void) disableAllButtons:(BOOL) shouldDisable;


@end
