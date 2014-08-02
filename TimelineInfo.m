//
//  TimelineInfo.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "TimelineInfo.h"

@implementation TimelineInfo

- (void)dealloc
{
    [_snapshotImage release];
    [_eventMessage release];
    [_eventTime release];
    [super dealloc];
}

@end
