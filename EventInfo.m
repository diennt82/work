//
//  EventInfo.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import "EventInfo.h"

@implementation EventInfo

- (void)dealloc
{
    [_value release];
    [_alert_name release];
    [_time_stamp release];
    [_clipInfo release];
    [super dealloc];
}

@end
