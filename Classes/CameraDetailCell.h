//
//  CameraDetailCell.h
//  BlinkHD_ios
//
//  Created by openxcell on 5/19/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraDetailCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIButton *btnChangeName;
@property(nonatomic, weak) IBOutlet UIButton *btnChangeImage;
@property(nonatomic, weak) IBOutlet UILabel *lblCameraName;
@property(nonatomic, weak) IBOutlet UILabel *lblCamVer;

@end
