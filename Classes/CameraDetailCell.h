//
//  CameraDetailCell.h
//  BlinkHD_ios
//
//  Created by openxcell on 5/19/14.
//  Copyright (c) 2014 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraDetailCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UIButton *btnChangeName;
@property(nonatomic, retain) IBOutlet UIButton *btnChangeImage;
@property(nonatomic, retain) IBOutlet UILabel *lblCameraName;
@property(nonatomic, retain) IBOutlet UILabel *lblCamVer;

@end
