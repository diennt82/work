//
//  LoginViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 2/10/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
#import "GAI.h"

@interface LoginViewController : GAITrackedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate: (id<ConnectionMethodDelegate>) d;

@end
