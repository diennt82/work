//
//  ClipInfo.m
//  BlinkHD_ios
//
//  Created by Developer on 12/31/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "ClipInfo.h"

@implementation ClipInfo

- (void)dealloc
{
    [_imgSnapshot release];
    [_urlImage release];
    [_titleString release];
    [_urlFile release];
    [super dealloc];
}

@end
