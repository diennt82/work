//
//  Step09ViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 1/9/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"

@interface Step09ViewController : UIViewController

@property (nonatomic, weak)  id<ConnectionMethodDelegate> delegate;

@end
