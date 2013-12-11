//
//  SlideSettingsCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlideSettingsCellDelegate <NSObject>

- (void)reportChangedSliderValue: (CGFloat)value andRowIndex: (NSInteger) rowIndex;

@end

@interface SlideSettingsCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UISlider *slideSettings;

@property (nonatomic) NSInteger rowIndex;
@property (assign, nonatomic) id<SlideSettingsCellDelegate> slideSettingsDelegate;

@end
