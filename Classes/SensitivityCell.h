//
//  SensitivityCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SensitivityCellDelegate <NSObject>

- (void)reportSwitchValue:(BOOL)value andRowIndex:(NSInteger)rowIndex;
- (void)reportChangedSettingsValue:(NSInteger)value atRow:(NSInteger)rowIndx;

@end

@interface SensitivityCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UISwitch *valueSwitch;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@property (nonatomic, assign) id<SensitivityCellDelegate> sensitivityCellDelegate;
@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) NSInteger settingsValue;
@property (nonatomic) BOOL switchValue;

@end
