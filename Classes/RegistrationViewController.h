//
//  RegistrationViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"

@interface RegistrationViewController : UIViewController

@property (nonatomic, assign)  id<ConnectionMethodDelegate> delegate;

@end
