//
//  SensitivityInfo.h
//  BlinkHD_ios
//
//  Created by Developer on 2/20/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
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

@end
