//
//  TimelineButtonCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "TimelineButtonCell.h"
#import "UIView+Custom.h"

@implementation TimelineButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self xibDefaultLocalization];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self xibDefaultLocalization];
}

- (void)xibDefaultLocalization
{
    [self.timelineCellButtn setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_timeline_cell_save_the_day", nil, [NSBundle mainBundle], @"Save the Day", nil)];
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
