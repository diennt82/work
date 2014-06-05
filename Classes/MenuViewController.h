//
//  MenuViewController.h
//  BlinkHD_ios
//
//  Created on 12/16/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
#import "CamerasViewController.h"
#import "SettingsViewController.h"

#define DIALOG_CANT_ADD_CAM 955

@protocol MenuViewControllerDelegate <NSObject>

- (void)pushBackToPlayerView;
- (void)finisGetCameraList;

@end

@interface MenuViewController : UITabBarController

@property (nonatomic, retain) CamerasViewController *camerasVC;
@property (nonatomic, retain) SettingsViewController *settingsVC;
@property (nonatomic, retain) NSMutableArray *cameras;
@property (nonatomic, assign) id<ConnectionMethodDelegate> menuDelegate;
@property (nonatomic) BOOL notUpdateCameras;
@property (nonatomic) BOOL isFirttime;

- (id)initWithNibName:(NSString *)nibNameOrNil withConnDelegate:(id<ConnectionMethodDelegate>)caller;
- (void)refreshCameraList;

@end
