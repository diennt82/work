//
//  MenuViewController.h
//  BlinkHD_ios
//
//  Created on 12/16/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
#import "CamerasViewController.h"
#import "SettingsViewController.h"

@protocol MenuViewControllerDelegate <NSObject>

- (void)pushBackToPlayerView;
- (void)finisGetCameraList;

@end

@interface MenuViewController : UITabBarController

@property (nonatomic, strong) CamerasViewController *camerasVC;
@property (nonatomic, strong) SettingsViewController *settingsVC;
@property (nonatomic, strong) NSMutableArray *cameras;
@property (nonatomic, weak) id<ConnectionMethodDelegate>menuDelegate;
@property (nonatomic) BOOL notUpdateCameras;

- (id)initWithNibName:(NSString *)nibNameOrNil withConnDelegate:(id<ConnectionMethodDelegate>)delegate;
- (void)refreshCameraList;

@end
