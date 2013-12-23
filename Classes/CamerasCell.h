//
//  CamerasCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CamerasCellDelegate <NSObject>

- (void)sendTouchSettingsActionWithRowIndex: (NSInteger) rowIdx;

@end

@interface CamerasCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *snapshotImage;
@property (retain, nonatomic) IBOutlet UIImageView *photoItemImage;
@property (retain, nonatomic) IBOutlet UILabel *cameraNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *settingsButton;

@property (nonatomic, assign) id<CamerasCellDelegate> camerasCellDelegate;

@property (nonatomic) NSInteger rowIndex;

@end
