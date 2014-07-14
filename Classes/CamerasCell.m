//
//  CamerasCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "CamerasCell.h"

@implementation CamerasCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.settingsButton setImage:[UIImage imageNamed:@"camera_settings"] forState:UIControlStateNormal];
        [self.settingsButton setImage:[UIImage imageNamed:@"camera_settings_pressed"] forState:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    if (_settingsButton.hidden)
    {
        [_activityIndicationUpdating startAnimating];
    }
    else
    {
        [_activityIndicationUpdating stopAnimating];
    }
}

- (IBAction)settingsButtonTouchAction:(id)sender
{
    [_camerasCellDelegate sendTouchSettingsActionWithRowIndex:_rowIndex];
}

- (void)dealloc {
    [_snapshotImage release];
    [_photoItemImage release];
    [_ibCameraNameLabel release];
    [_settingsButton release];
    [_ibIconStatusCamera release];
    [_ibTextStatusCamera release];
    [_ibBGColorCameraSelected release];
    [_activityIndicationUpdating release];
    [super dealloc];
}
@end
