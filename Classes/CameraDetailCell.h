//
//  CameraDetailCell.h
//  BlinkHD_ios
//
//  Created by openxcell on 5/19/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraDetailCell : UITableViewCell
{
    
}
@property(nonatomic,retain) IBOutlet UIButton *btnChangeName,*btnChangeImage;
@property(nonatomic,retain) IBOutlet UILabel *lblCameraName,*lblCamVer;

@end
