//
//  CamerasCollectionViewCell.h
//  BlinkHD_ios
//
//  Created by Adam Beech on 3/18/2014.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CamerasCellDelegate <NSObject>

- (void)sendTouchSettingsActionWithRowIndex: (NSInteger) rowIdx;

@end

@interface CamerasCollectionViewCell : UICollectionViewCell

@property (retain, nonatomic) IBOutlet UIImageView *snapshotImage;
@property (retain, nonatomic) IBOutlet UIImageView *photoItemImage;
@property (retain, nonatomic) IBOutlet UILabel *cameraNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *settingsButton;

@property (nonatomic, assign) id<CamerasCellDelegate> camerasCellDelegate;

@property (nonatomic) NSInteger rowIndex;

@end