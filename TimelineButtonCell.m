//
//  TimelineButtonCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "TimelineButtonCell.h"

@implementation TimelineButtonCell

- (IBAction)timelineCellButtnTouchAction:(id)sender
{
    [_timelineBtnDelegate sendTouchBtnStateWithIndex:_rowIndex];
}

- (void)dealloc
{
    [_timelineCellButtn release];
    [super dealloc];
}

@end
