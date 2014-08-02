//
//  CellImageView.m
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "CellImageView.h"

@implementation CellImageView

- (void)singleTapGestureCaptured:(id)sender
{
    self.selected = !_selected;
    [_cellImgViewDelegate tapOnImageAtRow:_rowIndex column:_colomnIndex state:_selected];
}

@end
