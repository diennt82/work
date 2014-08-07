//
//  CamerasCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "CamerasCell.h"

@implementation CamerasCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [_settingsButton setImage:[UIImage imageNamed:@"camera_settings"] forState:UIControlStateNormal];
        [_settingsButton setImage:[UIImage imageNamed:@"camera_settings_pressed"] forState:UIControlEventTouchUpInside];
    }
    return self;
}

- (IBAction)settingsButtonTouchAction:(id)sender
{
    [_camerasCellDelegate sendTouchSettingsActionWithRowIndex:_rowIndex];
}

@end
