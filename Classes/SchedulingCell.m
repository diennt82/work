//
//  SchedulingCell.m
//  BlinkHD_ios
//
//  Created by Developer on 1/15/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "SchedulingCell.h"

@implementation SchedulingCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_labelTitle release];
    [super dealloc];
}
@end
