//
//  CamerasCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CamerasCellDelegate <NSObject>

- (void)sendTouchSettingsActionWithRowIndex:(NSInteger)rowIdx;

@end

@interface CamerasCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *ibBGColorCameraSelected;
@property (nonatomic, weak) IBOutlet UIImageView *snapshotImage;
@property (nonatomic, weak) IBOutlet UIImageView *ibIconStatusCamera;
@property (nonatomic, weak) IBOutlet UILabel *ibTextStatusCamera;

@property (nonatomic, weak) IBOutlet UIImageView *photoItemImage;
@property (nonatomic, weak) IBOutlet UILabel *ibCameraNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *settingsButton;

@property (nonatomic, weak) id<CamerasCellDelegate> camerasCellDelegate;
@property (nonatomic) NSInteger rowIndex;

@end
