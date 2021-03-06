//
//  SensitivityInfo.h
//  BlinkHD_ios
//
//  Created by Developer on 2/20/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SensitivityInfo : NSObject

@property (nonatomic) BOOL motionOn;
@property (nonatomic) NSInteger motionValue;

@property (nonatomic) BOOL soundOn;
@property (nonatomic) NSInteger soundValue;

@property (nonatomic) BOOL tempIsFahrenheit;
@property (nonatomic) NSInteger tempLowValue;
@property (nonatomic) BOOL tempLowOn;
@property (nonatomic) NSInteger tempHighValue;
@property (nonatomic) BOOL tempHighOn;

@property (nonatomic) BOOL motionVideoRecordingOn;
@property (nonatomic) BOOL motionCaptureSnapshotOn;

@end
