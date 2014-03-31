//
//  CamerasViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
//#import "MenuViewController.h"

@protocol CamerasVCDelegate <NSObject>

- (void)sendActionCommand;

@end

@interface CamerasViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) id<CamerasVCDelegate> camerasVCDelegate;
@property (assign, nonatomic) id parentVC;
@property (nonatomic) BOOL waitingForUpdateData;
@property (retain, nonatomic) NSMutableArray *camChannels;
@property (retain, nonatomic) IBOutlet UITableView *ibTableListCamera;

- (id)initWithStyle:(UITableViewStyle)style
           delegate:(id<ConnectionMethodDelegate> )delegate
           parentVC: (id)parentVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
             delegate:(id<ConnectionMethodDelegate> )delegate
             parentVC: (id)parentVC;

- (void)camerasReloadData;

@end
