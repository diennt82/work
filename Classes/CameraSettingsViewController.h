//
//  CameraSettingsViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 12/10/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraSettingsViewController : UITableViewController

@property (nonatomic) BOOL volumeState;
@property (nonatomic) CGFloat volumeValue;

@property (nonatomic) BOOL brightnessState;
@property (nonatomic) CGFloat brightnessValue;

@property (nonatomic) BOOL soundSensitivityState;
@property (nonatomic) CGFloat soundSensivitityValue;

@property (nonatomic) NSInteger temperatureType; // 0: ˚F, 1: ˚C
@property (nonatomic) NSInteger qualityType;     // 0: Normal, 1: HQ

@end
