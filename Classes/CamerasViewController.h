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

@interface CamerasViewController : UITableViewController
{
    //member to dismiss when disDisAppearView
    UIAlertView *_alertChooseConfig;
}

@property (assign, nonatomic) id<ConnectionMethodDelegate> camerasDelegate;
@property (assign, nonatomic) id parentVC;
//@property (assign, nonatomic) UIViewController *parentVC;
@property (retain, nonatomic) NSMutableArray *camChannels;

- (id)initWithStyle:(UITableViewStyle)style
           delegate:(id<ConnectionMethodDelegate> )delegate
           parentVC: (id)parentVC;

- (void)camerasReloadData;

@end
