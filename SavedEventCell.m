//
//  SavedEventCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "SavedEventCell.h"

@implementation SavedEventCell

- (void)dealloc
{
    [_snapshotImage release];
    [_timeLabel release];
    [_placeEventLabel release];
    [super dealloc];
}

@end
