//
//  CameraDetailCell.h
//  BlinkHD_ios
//
//  Created by openxcell on 5/19/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraDetailCell : UITableViewCell

- (void)addCameraNameButtonTarget:(id)target action:(SEL)selector;
- (void)addCameraImageButtonTarget:(id)target action:(SEL)selector;
- (void)setCameraName:(NSString *)cameraName;
- (void)setCameraVersion:(NSString *)cameraVersion;

@end
