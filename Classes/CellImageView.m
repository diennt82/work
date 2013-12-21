//
//  CellImageView.m
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "CellImageView.h"

@implementation CellImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)singleTapGestureCaptured:(id)sender
{
    self.selected = !_selected;
    
    [_cellImgViewDelegate tapOnImageAtRow:_rowIndex lolumn:_colomnIndex state:_selected];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
