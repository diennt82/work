//
//  RegistrationViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 Hubble Connected Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"
#import "GAI.h"

@interface RegistrationViewController : GAITrackedViewController

@property (nonatomic, assign) id<ConnectionMethodDelegate> delegate;

@end
