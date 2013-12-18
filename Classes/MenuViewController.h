//
//  MenuViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"

@interface MenuViewController : UITabBarController

@property (nonatomic, assign) id<ConnectionMethodDelegate> menuDelegate;
@property (nonatomic, retain) NSMutableArray *cameras;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
     withConnDelegate:(id<ConnectionMethodDelegate> ) caller;

@end