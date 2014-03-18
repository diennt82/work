//
//  CamerasCollectionViewCell.m
//  BlinkHD_ios
//
//  Created by Adam Beech on 3/18/2014.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CamerasCollectionViewCell.h"

@implementation CamerasCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.settingsButton setImage:[UIImage imageNamed:@"menu_settings"] forState:UIControlStateNormal];
        [self.settingsButton setImage:[UIImage imageNamed:@"menu_settings_pressed"] forState:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (IBAction)settingsButtonTouchAction:(id)sender
{
    [_camerasCellDelegate sendTouchSettingsActionWithRowIndex:_rowIndex];
}

- (void)dealloc {
    [_snapshotImage release];
    [_photoItemImage release];
    [_cameraNameLabel release];
    [_settingsButton release];
    [super dealloc];
}

@end
