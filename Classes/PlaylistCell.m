//
//  PlaylistCell.m
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "PlaylistCell.h"

@implementation PlaylistCell

- (void)dealloc
{
    [_imgViewSnapshot release];
    [_labelTitle release];
    [_labelDate release];
    [_activityIndicator release];
    [super dealloc];
}

@end
