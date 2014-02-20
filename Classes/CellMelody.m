//
//  CellMelody.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 20/2/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CellMelody.h"

@implementation CellMelody

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

- (void)dealloc {
    [_imageCellMelody release];
    [_labelCellMelody release];
    [super dealloc];
}
@end
