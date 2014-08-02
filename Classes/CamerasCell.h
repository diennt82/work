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

@property (nonatomic, retain) IBOutlet UIView *ibBGColorCameraSelected;
@property (nonatomic, retain) IBOutlet UIImageView *snapshotImage;
@property (nonatomic, retain) IBOutlet UIImageView *ibIconStatusCamera;
@property (nonatomic, retain) IBOutlet UILabel *ibTextStatusCamera;

@property (nonatomic, retain) IBOutlet UIImageView *photoItemImage;
@property (nonatomic, retain) IBOutlet UILabel *ibCameraNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *settingsButton;

@property (nonatomic, assign) id<CamerasCellDelegate> camerasCellDelegate;
@property (nonatomic) NSInteger rowIndex;

@end
