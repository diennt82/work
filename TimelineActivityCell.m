//
//  TimelineActivityCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "TimelineActivityCell.h"

@implementation TimelineActivityCell

- (void)dealloc
{
    [_snapshotImage release];
    [_eventLabel release];
    [_eventTimeLabel release];
    [_activityIndicatorLoading release];
    [_lineImage release];
    [_feedImageVideo release];
    [super dealloc];
}

@end
