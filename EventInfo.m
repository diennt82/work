//
//  EventInfo.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "EventInfo.h"

@implementation EventInfo

- (void)dealloc
{
    [_value release];
    [_alertName release];
    [_timeStamp release];
    [_clipInfo release];
    [super dealloc];
}

@end
