//
//  CameraStngsCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "CameraStngsCell.h"

@implementation CameraStngsCell

- (void)dealloc
{
    [_nameLabel release];
    [_valueSwitch release];
    [super dealloc];
}

@end
