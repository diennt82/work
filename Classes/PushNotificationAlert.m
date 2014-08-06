//
//  PushNotificationAlert.m
//  BlinkHD_ios
//
//  Created by Developer on 4/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "PushNotificationAlert.h"

@implementation PushNotificationAlert

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [_camAlert release];
    [super dealloc];
}

@end
