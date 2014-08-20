//
//  TimelineCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "TimelineCell.h"
#import "define.h"
#import "UIView+Custom.h"

@implementation TimelineCell

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
    [self.eventLabel setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_timeline_cell_all_is_calm", nil, [NSBundle mainBundle], @"All is calm at home ", nil)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
   /* UIImageView *imageViewWhiteDot = (UIImageView *)[self viewWithTag:950];
    imageViewWhiteDot.frame = CGRectMake(imageViewWhiteDot.frame.origin.x, _eventDetailLabel.center.y + _eventDetailLabel.frame.size.height / 2, imageViewWhiteDot.frame.size.width, imageViewWhiteDot.frame.size.height);
    //imageViewWhiteDot.center = CGPointMake(imageViewWhiteDot.center.x, imageViewWhiteDot.center.y + _eventDetailLabel.frame.size.height / 2);
    
    UIImageView *imageViewLine = (UIImageView *)[self viewWithTag:951];
    CGFloat y = imageViewWhiteDot.center.y + imageViewWhiteDot.frame.size.width / 2;
    
    imageViewLine.frame = CGRectMake(imageViewLine.frame.origin.x, y, imageViewLine.frame.size.width, self.bounds.size.height - y);
   // imageViewLine.center = CGPointMake(imageViewLine.center.x, imageViewLine.center.y + _eventDetailLabel.frame.size.height / 2);
    */
    CGRect frm = self.eventLabel.frame;
    frm.size.width = SCREEN_WIDTH-20;
    [self.eventLabel setFrame:frm];
}

- (void)dealloc {
    [_eventLabel release];
    [_eventDetailLabel release];
    [super dealloc];
}
@end
