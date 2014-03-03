//
//  Step05Cell.m
//  BlinkHD_ios
//
//  Created by Developer on 2/28/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "Step05Cell.h"

@implementation Step05Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    UIImageView *imageViewBottomLine = (UIImageView *)[self viewWithTag:508];
    imageViewBottomLine.frame = CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5);
}

- (void)dealloc {
    [_lblName release];
    [super dealloc];
}
@end
