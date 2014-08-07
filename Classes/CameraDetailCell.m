//
//  CameraDetailCell.m
//  BlinkHD_ios
//
//  Created by openxcell on 5/19/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "CameraDetailCell.h"

@implementation CameraDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = COLOR_RGB(43.0, 50.0, 56.0);
    }
    return self;
}

@end
