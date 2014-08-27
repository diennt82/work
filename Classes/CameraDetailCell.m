//
//  CameraDetailCell.m
//  BlinkHD_ios
//
//  Created by openxcell on 5/19/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "CameraDetailCell.h"

@interface CameraDetailCell ()

@property (nonatomic, weak) IBOutlet UIButton *cameraNameButton;
@property (nonatomic, weak) IBOutlet UIButton *changeImageButton;
@property (nonatomic, weak) IBOutlet UIButton *firmwareVersionButton;
@property (nonatomic, weak) IBOutlet UILabel *cameraNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *cameraVersionLabel;

@end

@implementation CameraDetailCell

#pragma mark - UITableViewCell methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = COLOR_RGB(43.0, 50.0, 56.0);
    }
    return self;
}

- (void)layoutSubviews
{
    [_cameraNameButton setTitle:LocStr(@"Change camera name") forState:UIControlStateNormal];
    [_changeImageButton setTitle:LocStr(@"Change image") forState:UIControlStateNormal];
    [_firmwareVersionButton setTitle:LocStr(@"Firmware version") forState:UIControlStateNormal];
    
    [super layoutSubviews];
}

#pragma mark - Public methods

- (void)addCameraNameButtonTarget:(id)target action:(SEL)selector
{
    [_cameraNameButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)addCameraImageButtonTarget:(id)target action:(SEL)selector
{
    [_changeImageButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setCameraName:(NSString *)cameraName
{
    _cameraNameLabel.text = cameraName;
}

- (void)setCameraVersion:(NSString *)cameraVersion
{
    _cameraVersionLabel.text = cameraVersion;
}

@end
