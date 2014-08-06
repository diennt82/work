//
//  BLEConnectionCell.m
//  BlinkHD_ios
//
//  Created by Developer on 3/5/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "BLEConnectionCell.h"

@implementation BLEConnectionCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setup_check"]] autorelease];
    }
    else {
        self.accessoryView = nil;
    }
}

- (void)drawRect:(CGRect)rect
{
    UIImageView *imageViewBottomLine = (UIImageView *)[self viewWithTag:508];
    imageViewBottomLine.frame = CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5);
}

- (void)dealloc
{
    [_lblName release];
    [super dealloc];
}

@end
