//
//  MenuViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define DIALOG_CANT_ADD_CAM 955 //

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
#import "CamerasViewController.h"
#import "SettingsViewController.h"

@protocol MenuViewControllerDelegate <NSObject>

- (void)pushBackToPlayerView;
- (void)finisGetCameraList;


@end

@interface MenuViewController : UITabBarController
{
    SettingsViewController *_settingsVC;
}

@property (nonatomic, assign) id<ConnectionMethodDelegate> menuDelegate;
@property (nonatomic, retain) NSMutableArray *cameras;
@property (retain, nonatomic) CamerasViewController* camerasVC;
@property (nonatomic) BOOL notUpdateCameras;
@property (nonatomic) BOOL isFirttime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
     withConnDelegate:(id<ConnectionMethodDelegate> ) caller;
- (void)refreshCameraList;
- (void)removeSubviews;

@end
