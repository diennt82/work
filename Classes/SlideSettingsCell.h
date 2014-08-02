//
//  SlideSettingsCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlideSettingsCellDelegate <NSObject>

- (void)reportChangedSliderValue:(CGFloat)value andRowIndex:(NSInteger)rowIndex;

@end

@interface SlideSettingsCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UISlider *slideSettings;
@property (nonatomic, assign) id<SlideSettingsCellDelegate> slideSettingsDelegate;
@property (nonatomic) NSInteger rowIndex;

@end
