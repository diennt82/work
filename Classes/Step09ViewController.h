//
//  Step09ViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 1/9/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"

@interface Step09ViewController : UIViewController

@property (nonatomic, assign)  id<ConnectionMethodDelegate> delegate;

@end
