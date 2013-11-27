//
//  UnderlinedUILabel.m
//  MBP_ios
//
//  Created by NxComm on 10/23/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "UnderlinedUILabel.h"

@implementation UnderlinedUILabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f); // RGBA
    CGContextSetLineWidth(ctx, 1.5f);
    
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height - 1);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height - 1);
    
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];
}

@end
