//
//  UIColor+Hubble.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 23/1/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hubble)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIColor *)holdToTalkTextColor;
+ (UIColor *)listeningTextColor;
+ (UIColor *)recordingTextColor;
+ (UIColor *)temperatureTextColor;
+ (UIColor *)barItemSelectedColor;
+ (UIColor *)timeLineColor;
+ (UIColor *)timeLineLineColor;
+ (UIColor *)cellMelodyColor;
+ (UIColor *)textTimerPlayBackColor;
+ (UIColor *)textForFinishPlayBackColor;
+ (UIColor *)doNotDisturbCellBGColor;
+ (UIColor *)selectButtonBackgroundColor;
+ (UIColor *)deSelectButtonBackgroundColor;
+ (UIColor *)deSelectButtonBackgroundTextColor;

+ (UIColor *)deSelectedAddCameraTextColor;
+ (UIColor *)deSelectedBuyCameraTextColor;
+ (UIColor *)selectCameraItemColor;

@end
