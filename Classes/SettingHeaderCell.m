//
//  SettingTitleCell.m
//  BlinkHD_ios
//
//  Created by Developer on 7/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "SettingHeaderCell.h"
#import "define.h"

@implementation SettingHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect rect = CGRectMake(0, 0, 35, 35);
        rect.origin.x = SCREEN_WIDTH - 40;
        rect.origin.y = 10;
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

- (void)dealloc
{
    [super dealloc];
}
@end
