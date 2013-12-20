//
//  TimelineButtonCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "TimelineButtonCell.h"

@implementation TimelineButtonCell

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
- (IBAction)timelineCellButtnTouchAction:(id)sender
{
    [_timelineBtnDelegate sendTouchBtnStateWithIndex:_rowIndex];
}

- (void)dealloc {
    [_timelineCellButtn release];
    [super dealloc];
}
@end
