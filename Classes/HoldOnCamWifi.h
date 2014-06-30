//
//  HoldOnCamWifi.h
//  BlinkHD_ios
//
//  Created by Developer on 30/6/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HoldOnCamWifi : NSObject
+ (HoldOnCamWifi *)shareInstance;
- (void)startHolder;
- (void)stopHolder;
@end
