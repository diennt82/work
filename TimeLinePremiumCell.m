//
//  TimeLinePremiumCell.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 12/2/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "TimeLinePremiumCell.h"
#import "UIView+Custom.h"

@implementation TimeLinePremiumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self xibDefaultLocalization];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self xibDefaultLocalization];
}

- (void)xibDefaultLocalization
{
    [self.ib_labelPremium setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_timeline_cell_upgrade_to_premium", nil, [NSBundle mainBundle], @"Upgrade to Premium", nil)];
    [self.ib_labelDayPremium setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_timeline_cell_number_of_days", nil, [NSBundle mainBundle], @"1, 7, or 30 days", nil)];
}

- (void)dealloc {
    [_timelineImagePremium release];
    [_ib_labelPremium release];
    [_ib_labelDayPremium release];
    [super dealloc];
}
@end
