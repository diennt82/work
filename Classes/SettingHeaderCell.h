//
//  SettingTitleCell.h
//  BlinkHD_ios
//
//  Created by Developer on 7/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _SETTING_HELP
{
    GENERAL_SETTING,
    DO_NOT_DISTURB
}
SETTING_HELP;

@protocol SettingHeaderCellDelegate <NSObject>

- (void)helpButtonOnTouchUpInside:(SETTING_HELP)helpType;

@end

@interface SettingHeaderCell : UITableViewCell

@property (nonatomic, retain) UIButton *helpButton;
@property (nonatomic) SETTING_HELP      helpType;
@property (nonatomic, assign) id <SettingHeaderCellDelegate> delegate;
@end
