//
//  HubbleProgressView.m
//  BlinkHD_ios
//
//  Created by Developer on 3/5/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "HubbleProgressView.h"

@implementation HubbleProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    self.transform = transform;
}

@end
