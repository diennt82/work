//
//  CameraSettingsCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "CameraSettingsCell.h"

@implementation CameraSettingsCell

- (void)dealloc
{
    [_nameLabel release];
    [_valueLabel release];
    [super dealloc];
}

@end
