//
//  GeneralCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GeneralCellDelegate <NSObject>

- (void)clockValueChanged: (BOOL)is12hr;
- (void)temperatureValueChanged: (BOOL)isFahrenheit;

@end

@interface GeneralCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *labelClock;
@property (retain, nonatomic) IBOutlet UIButton *btnClock;
@property (retain, nonatomic) IBOutlet UILabel *labelTemperature;
@property (retain, nonatomic) IBOutlet UIButton *btnTemperature;

@property (assign, nonatomic) id<GeneralCellDelegate> generalCellDelegate;
@property (nonatomic) BOOL is12hr;
@property (nonatomic) BOOL isFahrenheit;

@end
