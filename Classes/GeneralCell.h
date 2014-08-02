//
//  GeneralCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GeneralCellDelegate <NSObject>

- (void)clockValueChanged: (BOOL)is12hr;
- (void)temperatureValueChanged: (BOOL)isFahrenheit;

@end

@interface GeneralCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *labelClock;
@property (nonatomic, retain) IBOutlet UIButton *btnClock;
@property (nonatomic, retain) IBOutlet UILabel *labelTemperature;
@property (nonatomic, retain) IBOutlet UIButton *btnTemperature;

@property (nonatomic, assign) id<GeneralCellDelegate> generalCellDelegate;
@property (nonatomic) BOOL is12hr;
@property (nonatomic) BOOL isFahrenheit;

@end
