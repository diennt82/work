//
//  CameraDetailCell.m
//  BlinkHD_ios
//
//  Created by openxcell on 5/19/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CameraDetailCell.h"

@implementation CameraDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"CameraDetailCell" owner:self options:nil];
        self = [nibArray objectAtIndex:0];
        self.backgroundColor = COLOR_RGB(43.0, 50.0, 56.0);
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
