//
//  SensitivityCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ADDITION_OPTION_VIDEO_RECORDING     1 << 0
#define ADDITION_OPTION_CAPTURE_SNAPSHOT    1 << 1

@protocol SensitivityCellDelegate <NSObject>

- (void)reportSwitchValue: (BOOL)value andRowIndex: (NSInteger) rowIndex;
- (void)reportChangedSettingsValue: (NSInteger )value atRow: (NSInteger )rowIndx;
- (void)reportChangedAdditionalOptionsValue:(NSArray *)values atRow:(NSInteger )rowIdx;

@end

@interface SensitivityCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UISwitch *valueSwitch;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic) NSInteger rowIndex;
@property (assign, nonatomic) id<SensitivityCellDelegate> sensitivityCellDelegate;
@property (nonatomic) NSInteger settingsValue;
@property (nonatomic) BOOL switchValue;
@property (nonatomic) BOOL recordingValue;
@property (nonatomic) BOOL captureSnapshotValue;

@end
