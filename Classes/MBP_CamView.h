//
//  MBP_FirstView.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_StatusBarView.h"
#import "MBP_iosViewController.h"
#import "MBP_LeftSideMenuView.h"
#import "MBP_RightSideMenuView.h"
#import "MBP_MainCameraView.h"

#import "MBP_CamListView.h"

@class MBP_StatusBarView;
@class MBP_iosViewController;
@class MBP_SideMenuView;
@class MBP_MainCameraView;



@interface MBP_CamView : UIView {
	IBOutlet MBP_StatusBarView * statusBar;
	IBOutlet MBP_LeftSideMenuView * leftSideMenu;
	IBOutlet MBP_RightSideMenuView * rightSideMenu;
	IBOutlet MBP_MainCameraView * oneCamView;


	
}

@property (nonatomic,retain) IBOutlet MBP_StatusBarView * statusBar;
@property (nonatomic,retain) IBOutlet MBP_LeftSideMenuView * leftSideMenu;
@property (nonatomic,retain) IBOutlet MBP_RightSideMenuView * rightSideMenu;
@property (nonatomic,retain) IBOutlet MBP_MainCameraView * oneCamView;




@end
