//
//  CellMelody.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 20/2/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "CellMelody.h"

@implementation CellMelody

- (void)dealloc
{
    [_imageCellMelody release];
    [_labelCellMelody release];
    [super dealloc];
}

@end
